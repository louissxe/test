// database.js - SEMUA DATABASE LOGIC
import pg from 'pg';
const { Pool } = pg;
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// ========== FUNGSI DATABASE ==========

// 1. Setup Tables
export async function setupDatabase() {
  try {
    // Keys table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS keys (
        id SERIAL PRIMARY KEY,
        key_hash VARCHAR(64) UNIQUE NOT NULL,
        plain_key VARCHAR(24) NOT NULL,
        username VARCHAR(100),
        script VARCHAR(100),
        hwid TEXT,
        active BOOLEAN DEFAULT true,
        created_at BIGINT,
        expires_at BIGINT
      )
    `);
    
    // Resets table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_resets (
        id SERIAL PRIMARY KEY,
        key_hash VARCHAR(64),
        last_reset BIGINT,
        reset_count INT DEFAULT 0
      )
    `);
    
    console.log('✅ Database ready');
  } catch (error) {
    console.error('❌ Database error:', error);
  }
}

// 2. Get Key by Hash
export async function getKey(hash) {
  try {
    const result = await pool.query(
      'SELECT * FROM keys WHERE key_hash = $1',
      [hash]
    );
    return result.rows[0] || null;
  } catch (error) {
    console.error('Get key error:', error);
    return null;
  }
}

// 3. Create New Key
export async function createKey(keyData) {
  try {
    const { hash, plainKey, username, script, expires } = keyData;
    
    await pool.query(
      `INSERT INTO keys 
       (key_hash, plain_key, username, script, expires_at, created_at)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [hash, plainKey, username, script, expires, Date.now()]
    );
    
    return true;
  } catch (error) {
    console.error('Create key error:', error);
    return false;
  }
}

// 4. Update Key
export async function updateKey(hash, updates) {
  try {
    const fields = [];
    const values = [];
    let i = 1;
    
    for (const [key, value] of Object.entries(updates)) {
      fields.push(`${key} = $${i}`);
      values.push(value);
      i++;
    }
    
    values.push(hash);
    
    await pool.query(
      `UPDATE keys SET ${fields.join(', ')} WHERE key_hash = $${i}`,
      values
    );
    
    return true;
  } catch (error) {
    console.error('Update key error:', error);
    return false;
  }
}

// 5. Get All Keys
export async function getAllKeys() {
  try {
    const result = await pool.query(`
      SELECT k.*, ur.last_reset, ur.reset_count
      FROM keys k
      LEFT JOIN user_resets ur ON k.key_hash = ur.key_hash
      ORDER BY k.created_at DESC
    `);
    return result.rows;
  } catch (error) {
    console.error('Get all keys error:', error);
    return [];
  }
}

// 6. Search Keys
export async function searchKeys(username) {
  try {
    const result = await pool.query(
      `SELECT k.*, ur.last_reset, ur.reset_count
       FROM keys k
       LEFT JOIN user_resets ur ON k.key_hash = ur.key_hash
       WHERE LOWER(k.username) LIKE LOWER($1)
       ORDER BY k.created_at DESC`,
      [`%${username}%`]
    );
    return result.rows;
  } catch (error) {
    console.error('Search keys error:', error);
    return [];
  }
}

// 7. Update Reset Record
export async function updateResetRecord(hash) {
  try {
    const now = Date.now();
    
    // Cek apakah sudah ada
    const check = await pool.query(
      'SELECT * FROM user_resets WHERE key_hash = $1',
      [hash]
    );
    
    if (check.rows.length > 0) {
      // Update
      await pool.query(
        'UPDATE user_resets SET last_reset = $1, reset_count = reset_count + 1 WHERE key_hash = $2',
        [now, hash]
      );
    } else {
      // Insert baru
      await pool.query(
        'INSERT INTO user_resets (key_hash, last_reset, reset_count) VALUES ($1, $2, 1)',
        [hash, now]
      );
    }
    
    return true;
  } catch (error) {
    console.error('Update reset error:', error);
    return false;
  }
}

// 8. Get Reset Info
export async function getResetInfo(hash) {
  try {
    const result = await pool.query(
      'SELECT * FROM user_resets WHERE key_hash = $1',
      [hash]
    );
    return result.rows[0] || null;
  } catch (error) {
    console.error('Get reset info error:', error);
    return null;
  }
}

// 9. Get Stats
export async function getStats() {
  try {
    const total = await pool.query('SELECT COUNT(*) FROM keys');
    const active = await pool.query('SELECT COUNT(*) FROM keys WHERE active = true');
    const bound = await pool.query('SELECT COUNT(*) FROM keys WHERE hwid IS NOT NULL');
    
    return {
      total: parseInt(total.rows[0].count),
      active: parseInt(active.rows[0].count),
      bound: parseInt(bound.rows[0].count)
    };
  } catch (error) {
    console.error('Get stats error:', error);
    return { total: 0, active: 0, bound: 0 };
  }
}
