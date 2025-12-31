import express from "express";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import dotenv from "dotenv";

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;
const ADMIN_PATH = process.env.ADMIN_PATH || "/panel_super_secret";
const __dirname = path.resolve();
const KEYS_FILE = path.join(__dirname, "keys.json");
const USER_RESET_FILE = path.join(__dirname, "user_resets.json");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 🔐 Load & Save Keys
const loadKeys = () => {
  if (!fs.existsSync(KEYS_FILE)) fs.writeFileSync(KEYS_FILE, "{}");
  return JSON.parse(fs.readFileSync(KEYS_FILE, "utf8"));
};

const saveKeys = (data) =>
  fs.writeFileSync(KEYS_FILE, JSON.stringify(data, null, 2));

// 🔄 Load & Save User Reset Records
const loadUserResets = () => {
  if (!fs.existsSync(USER_RESET_FILE)) fs.writeFileSync(USER_RESET_FILE, "{}");
  return JSON.parse(fs.readFileSync(USER_RESET_FILE, "utf8"));
};

const saveUserResets = (data) =>
  fs.writeFileSync(USER_RESET_FILE, JSON.stringify(data, null, 2));

// ==== ROOT ====
app.get("/", (req, res) => {
  const html = `
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LS Hub Panel - Premium Script Services</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Inter:wght@400;500;600;700&display=swap');

        :root {
            --primary: #3b82f6;
            --primary-dark: #2563eb;
            --primary-light: #60a5fa;
            --secondary: #8b5cf6;
            --accent: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --dark-1: #0f172a;
            --dark-2: #1e293b;
            --dark-3: #334155;
            --light-1: #f8fafc;
            --light-2: #e2e8f0;
            --light-3: #cbd5e1;
            --radius: 12px;
            --radius-sm: 8px;
            --shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
            --shadow-lg: 0 20px 40px -10px rgba(0, 0, 0, 0.4);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --gradient-primary: linear-gradient(135deg, var(--primary), var(--secondary));
            --gradient-dark: linear-gradient(135deg, var(--dark-1), var(--dark-2));
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--gradient-dark);
            color: var(--light-1);
            line-height: 1.6;
            min-height: 100vh;
            overflow-x: hidden;
            animation: fadeIn 1s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Header & Navigation */
        .header {
            padding: 20px 0;
            backdrop-filter: blur(10px);
            background: rgba(15, 23, 42, 0.8);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            animation: slideDown 0.6s ease-out;
        }

        @keyframes slideDown {
            from { transform: translateY(-100%); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
            text-decoration: none;
        }

        .logo-icon {
            width: 50px;
            height: 50px;
            background: var(--gradient-primary);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
            font-weight: bold;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
            70% { box-shadow: 0 0 0 15px rgba(59, 130, 246, 0); }
            100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
        }

        .logo-text h1 {
            font-family: 'Poppins', sans-serif;
            font-size: 1.8rem;
            font-weight: 700;
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            line-height: 1.2;
        }

        .logo-text span {
            font-size: 0.9rem;
            color: var(--light-3);
            font-weight: 400;
        }

        .nav-links {
            display: flex;
            gap: 30px;
            align-items: center;
        }

        .nav-link {
            color: var(--light-2);
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border-radius: var(--radius-sm);
            position: relative;
            overflow: hidden;
        }

        .nav-link::before {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 2px;
            background: var(--gradient-primary);
            transition: var(--transition);
            transform: translateX(-50%);
        }

        .nav-link:hover {
            color: white;
            background: rgba(255, 255, 255, 0.05);
        }

        .nav-link:hover::before {
            width: 80%;
        }

        .nav-link.active {
            color: var(--primary-light);
            background: rgba(59, 130, 246, 0.1);
        }

        .nav-link i {
            font-size: 1.1rem;
        }

        .btn {
            padding: 12px 28px;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-family: 'Inter', sans-serif;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--gradient-primary);
            color: white;
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(59, 130, 246, 0.4);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: var(--light-1);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(255, 255, 255, 0.2);
            transform: translateY(-3px);
        }

        /* Hero Section */
        .hero {
            padding: 180px 0 100px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: 
                radial-gradient(circle at 20% 30%, rgba(59, 130, 246, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(139, 92, 246, 0.1) 0%, transparent 50%);
            z-index: -1;
        }

        .hero-content {
            max-width: 800px;
            margin: 0 auto;
        }

        .hero h2 {
            font-family: 'Poppins', sans-serif;
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #ffffff, var(--primary-light));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            line-height: 1.2;
            animation: fadeInUp 0.8s ease-out 0.2s both;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .hero p {
            font-size: 1.2rem;
            color: var(--light-2);
            margin-bottom: 40px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            animation: fadeInUp 0.8s ease-out 0.4s both;
        }

        .hero-btns {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 40px;
            animation: fadeInUp 0.8s ease-out 0.6s both;
        }

        /* Features Section */
        .features {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.5);
        }

        .section-title {
            text-align: center;
            margin-bottom: 60px;
            animation: fadeInUp 0.8s ease-out 0.8s both;
        }

        .section-title h2 {
            font-family: 'Poppins', sans-serif;
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .section-title p {
            color: var(--light-3);
            font-size: 1.1rem;
            max-width: 600px;
            margin: 0 auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 50px;
        }

        .feature-card {
            background: rgba(30, 41, 59, 0.6);
            border-radius: var(--radius);
            padding: 35px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.8s ease-out calc(var(--delay, 0.2s) + 1s) both;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: var(--shadow-lg);
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--gradient-primary);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .feature-card:hover::before {
            transform: scaleX(1);
        }

        .feature-icon {
            width: 70px;
            height: 70px;
            background: var(--gradient-primary);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            color: white;
            margin-bottom: 25px;
            transition: var(--transition);
        }

        .feature-card:hover .feature-icon {
            transform: rotate(15deg) scale(1.1);
        }

        .feature-card h3 {
            font-size: 1.4rem;
            margin-bottom: 15px;
            color: var(--light-1);
        }

        .feature-card p {
            color: var(--light-3);
            font-size: 1rem;
            line-height: 1.7;
        }

        /* Scripts Section */
        .scripts {
            padding: 100px 0;
        }

        .scripts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 30px;
            margin-top: 50px;
        }

        .script-card {
            background: rgba(30, 41, 59, 0.6);
            border-radius: var(--radius);
            padding: 30px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            transition: var(--transition);
            text-align: center;
            animation: fadeInUp 0.8s ease-out calc(var(--delay, 0.2s) + 1.2s) both;
        }

        .script-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
            box-shadow: var(--shadow);
        }

        .script-icon {
            width: 80px;
            height: 80px;
            background: rgba(59, 130, 246, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 32px;
            color: var(--primary);
            border: 2px solid var(--primary);
        }

        .script-card h3 {
            font-size: 1.3rem;
            margin-bottom: 15px;
            color: var(--light-1);
        }

        .script-card p {
            color: var(--light-3);
            font-size: 0.95rem;
            margin-bottom: 20px;
        }

        .script-tag {
            display: inline-block;
            padding: 5px 15px;
            background: rgba(16, 185, 129, 0.1);
            color: var(--accent);
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-top: 10px;
        }

        /* How It Works */
        .how-it-works {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.5);
        }

        .steps {
            display: flex;
            justify-content: space-between;
            margin-top: 60px;
            position: relative;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .steps::before {
            content: '';
            position: absolute;
            top: 40px;
            left: 50px;
            right: 50px;
            height: 2px;
            background: var(--gradient-primary);
            z-index: 1;
        }

        .step {
            text-align: center;
            position: relative;
            z-index: 2;
            flex: 1;
            animation: fadeInUp 0.8s ease-out calc(var(--delay, 0.2s) + 1.4s) both;
        }

        .step-number {
            width: 80px;
            height: 80px;
            background: var(--gradient-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: bold;
            color: white;
            margin: 0 auto 20px;
            border: 5px solid var(--dark-1);
        }

        .step h4 {
            font-size: 1.2rem;
            margin-bottom: 10px;
            color: var(--light-1);
        }

        .step p {
            color: var(--light-3);
            font-size: 0.95rem;
            max-width: 200px;
            margin: 0 auto;
        }

        /* Stats */
        .stats {
            padding: 80px 0;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
            text-align: center;
        }

        .stat-item {
            animation: fadeInUp 0.8s ease-out calc(var(--delay, 0.2s) + 1.6s) both;
        }

        .stat-number {
            font-size: 3.5rem;
            font-weight: 800;
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
            line-height: 1;
        }

        .stat-label {
            color: var(--light-3);
            font-size: 1.1rem;
            font-weight: 500;
        }

        /* CTA Section */
        .cta {
            padding: 100px 0;
            text-align: center;
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
            position: relative;
            overflow: hidden;
        }

        .cta::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            right: -50%;
            bottom: -50%;
            background: radial-gradient(circle at center, rgba(59, 130, 246, 0.05) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .cta-content {
            position: relative;
            z-index: 2;
            animation: fadeInUp 0.8s ease-out 1.8s both;
        }

        .cta h2 {
            font-family: 'Poppins', sans-serif;
            font-size: 2.8rem;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #ffffff, var(--primary-light));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .cta p {
            font-size: 1.2rem;
            color: var(--light-2);
            max-width: 600px;
            margin: 0 auto 40px;
        }

        /* Footer */
        .footer {
            background: rgba(15, 23, 42, 0.9);
            padding: 60px 0 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 40px;
            margin-bottom: 40px;
        }

        .footer-column h3 {
            font-size: 1.3rem;
            margin-bottom: 25px;
            color: var(--light-1);
        }

        .footer-links {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 12px;
        }

        .footer-links a {
            color: var(--light-3);
            text-decoration: none;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .footer-links a:hover {
            color: var(--primary-light);
            transform: translateX(5px);
        }

        .footer-bottom {
            text-align: center;
            padding-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            color: var(--light-3);
            font-size: 0.9rem;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .hero h2 {
                font-size: 2.5rem;
            }

            .nav-links {
                display: none;
            }

            .hero-btns {
                flex-direction: column;
                gap: 15px;
            }

            .steps {
                flex-direction: column;
                gap: 50px;
            }

            .steps::before {
                display: none;
            }

            .features-grid,
            .scripts-grid,
            .footer-content {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .hero h2 {
                font-size: 2rem;
            }

            .section-title h2 {
                font-size: 2rem;
            }

            .feature-card,
            .script-card {
                padding: 25px;
            }

            .stat-number {
                font-size: 2.5rem;
            }
        }

        /* Animations */
        .animate-on-scroll {
            opacity: 0;
            transform: translateY(30px);
            transition: opacity 0.8s ease, transform 0.8s ease;
        }

        .animate-on-scroll.visible {
            opacity: 1;
            transform: translateY(0);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <nav class="nav">
                <a href="/" class="logo">
                    <div class="logo-icon">LS</div>
                    <div class="logo-text">
                        <h1>LS Hub BETA TEST</h1>
                        <span>Premium Script Services</span>
                    </div>
                </a>
                <div class="nav-links">
                    <a href="/" class="nav-link active"><i class="fas fa-home"></i> Home</a>
                    <a href="/reset-hwid-page" class="nav-link"><i class="fas fa-key"></i> Reset HWID</a>
                    <a href="#scripts" class="nav-link"><i class="fas fa-code"></i> Scripts</a>
                    <a href="#features" class="nav-link"><i class="fas fa-star"></i> Features</a>
                    <a href="#how-it-works" class="nav-link"><i class="fas fa-play-circle"></i> How It Works</a>
                </div>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="hero-content">
                <h2>Premium Script Services</h2>
                <p>Akses berbagai script premium. Dapatkan pengalaman gaming terbaik dengan tools eksklusif kami.</p>
                <div class="hero-btns">
                    <a href="/reset-hwid-page" class="btn btn-primary">
                        <i class="fas fa-key"></i> Reset HWID Saya
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Features -->
    <section id="features" class="features">
        <div class="container">
            <div class="section-title">
                <h2>Why Choose LS Hub?</h2>
                <p>Kami menyediakan solusi terbaik untuk kebutuhan scripting Anda</p>
            </div>
            <div class="features-grid">
                <div class="feature-card" style="--delay: 0.1s">
                    <div class="feature-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3>HWID Protection</h3>
                    <p>Sistem keamanan berbasis Hardware ID dengan kemampuan reset mandiri setiap 3 hari untuk fleksibilitas penggunaan.</p>
                </div>
                <div class="feature-card" style="--delay: 0.2s">
                    <div class="feature-icon">
                        <i class="fas fa-bolt"></i>
                    </div>
                    <h3>High Performance</h3>
                    <p>Script dioptimalkan untuk performa maksimal dengan resource usage minimal. Tidak ada lag, hanya hasil terbaik.</p>
                </div>
                <div class="feature-card" style="--delay: 0.3s">
                    <div class="feature-icon">
                        <i class="fas fa-sync-alt"></i>
                    </div>
                    <h3>Auto Updates</h3>
                    <p>Script selalu diperbarui secara otomatis. Tidak perlu download manual, sistem kami yang akan meng-handle update.</p>
                </div>
                <div class="feature-card" style="--delay: 0.4s">
                    <div class="feature-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <h3>24/7 Support</h3>
                    <p>Tim support siap membantu 24 jam. Masalah apapun akan kami bantu selesaikan dengan cepat dan profesional.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Scripts -->
    <section id="scripts" class="scripts">
        <div class="container">
            <div class="section-title">
                <h2>Premium Scripts Collection</h2>
                <p>Koleksi script premium terbaik yang terus diperbarui</p>
            </div>
            <div class="scripts-grid">
                <div class="script-card" style="--delay: 0.1s">
                    <div class="script-icon">
                        <i class="fas fa-fish"></i>
                    </div>
                    <h3>Fish It</h3>
                    <p>Auto fishing dengan AI detection. Tingkatkan hasil tangkapan Anda secara otomatis.</p>
                    <span class="script-tag">Game Enhancement</span>
                </div>
                <div class="script-card" style="--delay: 0.2s">
                    <div class="script-icon">
                        <i class="fas fa-crown"></i>
                    </div>
                    <h3>Premium VIP</h3>
                    <p>Akses fitur VIP eksklusif dengan kemampuan tak terbatas dalam game.</p>
                    <span class="script-tag">VIP Features</span>
                </div>
                <div class="script-card" style="--delay: 0.3s">
                    <div class="script-icon">
                        <i class="fas fa-sync-alt"></i>
                    </div>
                    <h3>Auto Fling</h3>
                    <p>Auto combat system dengan precision tinggi. Optimalkan pertarungan Anda.</p>
                    <span class="script-tag">Combat System</span>
                </div>
                <div class="script-card" style="--delay: 0.4s">
                    <div class="script-icon">
                        <i class="fas fa-walking"></i>
                    </div>
                    <h3>Auto Walk</h3>
                    <p>Auto navigation system dengan pathfinding cerdas. Hemat waktu perjalanan.</p>
                    <span class="script-tag">Navigation</span>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works -->
    <section id="how-it-works" class="how-it-works">
        <div class="container">
            <div class="section-title">
                <h2>How It Works</h2>
                <p>Mudah digunakan dalam 4 langkah sederhana</p>
            </div>
            <div class="steps">
                <div class="step" style="--delay: 0.1s">
                    <div class="step-number">1</div>
                    <h4>Dapatkan Key</h4>
                    <p>Hubungi admin untuk mendapatkan key akses premium</p>
                </div>
                <div class="step" style="--delay: 0.2s">
                    <div class="step-number">2</div>
                    <h4>Verifikasi HWID</h4>
                    <p>Gunakan key Anda untuk verifikasi Hardware ID</p>
                </div>
                <div class="step" style="--delay: 0.3s">
                    <div class="step-number">3</div>
                    <h4>Execute Script</h4>
                    <p>Execute script lalu verfy key yang telah diberikan admin</p>
                </div>
                <div class="step" style="--delay: 0.4s">
                    <div class="step-number">4</div>
                    <h4>Mulai Gunakan</h4>
                    <p>Jalankan script dan nikmati pengalaman gaming terbaik</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats -->
    <section class="stats">
        <div class="container">
            <div class="stat-item" style="--delay: 0.1s">
                <div class="stat-number">865+</div>
                <div class="stat-label">Active Users</div>
            </div>
            <div class="stat-item" style="--delay: 0.2s">
                <div class="stat-number">99%</div>
                <div class="stat-label">Uptime</div>
            </div>
            <div class="stat-item" style="--delay: 0.3s">
                <div class="stat-number">24/7</div>
                <div class="stat-label">Support</div>
            </div>
            <div class="stat-item" style="--delay: 0.4s">
                <div class="stat-number">Universal</div>
                <div class="stat-label">Scripts</div>
            </div>
        </div>
    </section>

    <!-- CTA -->
    <section class="cta">
        <div class="container">
            <div class="cta-content">
                <h2>Ready to Get Started?</h2>
                <p>Bergabunglah dengan komunitas premium kami dan tingkatkan pengalaman gaming Anda hari ini!</p>
                <div class="hero-btns">
                    <a href="/reset-hwid-page" class="btn btn-primary">
                        <i class="fas fa-key"></i> Reset HWID Saya
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-column">
                    <h3>LS Hub</h3>
                    <p>Premium Script Services dengan sistem keamanan terbaik. Menyediakan berbagai tools eksklusif untuk kebutuhan gaming Anda.</p>
                </div>
                <div class="footer-column">
                    <h3>Quick Links</h3>
                    <ul class="footer-links">
                        <li><a href="/"><i class="fas fa-chevron-right"></i> Home</a></li>
                        <li><a href="/reset-hwid-page"><i class="fas fa-chevron-right"></i> Reset HWID</a></li>
                    </ul>
                </div>
                <div class="footer-column">
                    <h3>Resources</h3>
                    <ul class="footer-links">
                        <li><a href="#features"><i class="fas fa-chevron-right"></i> Features</a></li>
                        <li><a href="#scripts"><i class="fas fa-chevron-right"></i> Scripts</a></li>
                        <li><a href="#how-it-works"><i class="fas fa-chevron-right"></i> How It Works</a></li>
                    </ul>
                </div>
                <div class="footer-column">
                    <h3>Contact</h3>
                    <ul class="footer-links">
                        <li><a href="#"><i class="fas fa-question-circle"></i> Support</a></li>
                        <li><a href="#"><i class="fas fa-bug"></i> Report Bug</a></li>
                        <li><a href="#"><i class="fas fa-lightbulb"></i> Suggestions</a></li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2024 LS Hub. All rights reserved. | Premium Script Services</p>
            </div>
        </div>
    </footer>

    <script>
        // Animation on scroll
        document.addEventListener('DOMContentLoaded', function() {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('visible');
                    }
                });
            }, {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            });

            // Observe all animate-on-scroll elements
            document.querySelectorAll('.animate-on-scroll').forEach(el => {
                observer.observe(el);
            });

            // Add scroll animation to feature cards
            document.querySelectorAll('.feature-card, .script-card, .step, .stat-item').forEach((el, index) => {
                el.classList.add('animate-on-scroll');
            });

            // Smooth scroll for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    const targetId = this.getAttribute('href');
                    if (targetId === '#') return;

                    const targetElement = document.querySelector(targetId);
                    if (targetElement) {
                        window.scrollTo({
                            top: targetElement.offsetTop - 80,
                            behavior: 'smooth'
                        });
                    }
                });
            });

            // Auto-update stats
            function animateCounter(element, target, duration = 2000) {
                let start = 0;
                const increment = target / (duration / 16);
                const timer = setInterval(() => {
                    start += increment;
                    if (start >= target) {
                        element.textContent = target;
                        clearInterval(timer);
                    } else {
                        element.textContent = Math.floor(start);
                    }
                }, 16);
            }

            // Start counters when stats section is visible
            const statsObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        animateCounter(document.getElementById('counter-users'), 865);
                        animateCounter(document.getElementById('counter-scripts'), Universal);
                        statsObserver.disconnect();
                    }
                });
            });

            // Add IDs to stat numbers
            document.querySelectorAll('.stat-number').forEach((el, index) => {
                if (index === 0) el.id = 'counter-users';
                if (index === 3) el.id = 'counter-scripts';
            });

            // Observe stats section
            const statsSection = document.querySelector('.stats');
            if (statsSection) {
                statsObserver.observe(statsSection);
            }
        });

        // Add hover effect to cards
        document.querySelectorAll('.feature-card, .script-card').forEach(card => {
            card.addEventListener('mouseenter', () => {
                card.style.transform = 'translateY(-10px)';
            });

            card.addEventListener('mouseleave', () => {
                card.style.transform = 'translateY(0)';
            });
        });
    </script>
</body>
</html>`;
  res.send(html);
});

// ... (sisanya kode Anda yang sudah ada tetap sama)
// ==== VERIFY ====
app.get("/verify", (req, res) => {
  const { key, hwid } = req.query;
  if (!key) return res.json({ ok: false, reason: "no key" });

  const keys = loadKeys();
  const hashed = crypto.createHash("sha256").update(key).digest("hex");
  const record = keys[hashed];

  if (!record || !record.active)
    return res.json({ ok: false, reason: "invalid key" });

  // Jika HWID belum diatur, atur HWID pertama yang menggunakan key ini
  if (!record.hwid) {
    record.hwid = hwid;
    saveKeys(keys);
    console.log(`Key ${key.substring(0, 8)}... diikat ke HWID: ${hwid}`);
  }

  // Periksa apakah HWID cocok dengan yang sudah terdaftar
  if (record.hwid !== hwid)
    return res.json({ ok: false, reason: "hwid mismatch" });

  // Periksa apakah key sudah kedaluwarsa
  if (record.expires && Date.now() > record.expires)
    return res.json({ ok: false, reason: "expired" });

  // Buat token untuk autentikasi
  const token = Buffer.from(JSON.stringify({ k: key, t: Date.now() })).toString(
    "base64",
  );
  res.json({ ok: true, token });
});

// ==== USER RESET HWID ====
app.post("/user-reset-hwid", (req, res) => {
  const { key } = req.body;

  if (!key) {
    return res.json({ ok: false, reason: "Key diperlukan" });
  }

  const keys = loadKeys();
  const hashed = crypto.createHash("sha256").update(key).digest("hex");
  const record = keys[hashed];

  if (!record || !record.active) {
    return res.json({ ok: false, reason: "Key tidak valid atau tidak aktif" });
  }

  // Cek apakah key memiliki HWID
  if (!record.hwid) {
    return res.json({ ok: false, reason: "Key ini belum terikat ke HWID manapun" });
  }

  // Load user reset records
  const userResets = loadUserResets();
  const now = Date.now();
  const cooldownPeriod = 3 * 24 * 60 * 60 * 1000; // 3 hari dalam milidetik

  // Cek cooldown
  if (userResets[hashed] && userResets[hashed].lastReset) {
    const timeSinceLastReset = now - userResets[hashed].lastReset;
    const remainingCooldown = cooldownPeriod - timeSinceLastReset;

    if (remainingCooldown > 0) {
      const hours = Math.floor(remainingCooldown / (60 * 60 * 1000));
      const minutes = Math.floor((remainingCooldown % (60 * 60 * 1000)) / (60 * 1000));
      return res.json({ 
        ok: false, 
        reason: `Anda harus menunggu ${hours} jam ${minutes} menit sebelum bisa reset HWID lagi`,
        remainingCooldown: remainingCooldown
      });
    }
  }

  // Reset HWID
  const oldHwid = record.hwid;
  record.hwid = null;
  saveKeys(keys);

  // Update reset record
  userResets[hashed] = {
    lastReset: now,
    username: record.username,
    key: key.substring(0, 8) + "..." + key.substring(key.length - 4),
    resetCount: (userResets[hashed]?.resetCount || 0) + 1,
    history: [
      ...(userResets[hashed]?.history || []),
      {
        timestamp: now,
        oldHwid: oldHwid
      }
    ]
  };
  saveUserResets(userResets);

  console.log(`User ${record.username} mereset HWID untuk key ${key.substring(0, 8)}...`);

  res.json({ 
    ok: true, 
    message: "HWID berhasil direset! Sekarang key dapat digunakan di perangkat baru.",
    nextResetAvailable: now + cooldownPeriod,
    resetCount: userResets[hashed].resetCount
  });
});

// ==== CHECK RESET COOLDOWN ====
app.get("/check-reset-cooldown", (req, res) => {
  const { key } = req.query;

  if (!key) {
    return res.json({ ok: false, reason: "Key diperlukan" });
  }

  const hashed = crypto.createHash("sha256").update(key).digest("hex");
  const userResets = loadUserResets();
  const userRecord = userResets[hashed];

  if (!userRecord || !userRecord.lastReset) {
    return res.json({ 
      ok: true, 
      canReset: true,
      message: "Anda dapat mereset HWID sekarang"
    });
  }

  const now = Date.now();
  const cooldownPeriod = 3 * 24 * 60 * 60 * 1000;
  const timeSinceLastReset = now - userRecord.lastReset;
  const remainingCooldown = cooldownPeriod - timeSinceLastReset;

  if (remainingCooldown > 0) {
    const days = Math.floor(remainingCooldown / (24 * 60 * 60 * 1000));
    const hours = Math.floor((remainingCooldown % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000));
    const minutes = Math.floor((remainingCooldown % (60 * 60 * 1000)) / (60 * 1000));

    return res.json({
      ok: true,
      canReset: false,
      message: `Reset HWID tersedia dalam ${days} hari ${hours} jam ${minutes} menit`,
      remainingCooldown: remainingCooldown,
      nextResetTime: userRecord.lastReset + cooldownPeriod,
      resetCount: userRecord.resetCount || 0
    });
  } else {
    return res.json({
      ok: true,
      canReset: true,
      message: "Anda dapat mereset HWID sekarang",
      resetCount: userRecord.resetCount || 0
    });
  }
});

// ==== LOAD SCRIPT ====
app.get("/load", (req, res) => {
  const { token } = req.query;
  if (!token) return res.json({ ok: false, reason: "no token" });

  let decoded;
  try {
    decoded = JSON.parse(Buffer.from(token, "base64").toString("utf8"));
  } catch {
    return res.json({ ok: false, reason: "invalid token" });
  }

  const key = decoded.k;
  const timestamp = decoded.t;
  if (Date.now() - timestamp > 60 * 1000)
    return res.json({ ok: false, reason: "token expired" });

  const keys = loadKeys();
  const hashed = crypto.createHash("sha256").update(key).digest("hex");
  const record = keys[hashed];
  if (!record || !record.active)
    return res.json({ ok: false, reason: "invalid key" });

  const scriptPath = path.join(__dirname, "scripts", record.script);
  if (!fs.existsSync(scriptPath))
    return res.json({ ok: false, reason: "script not found" });

  const script = fs.readFileSync(scriptPath, "utf8");
  res.setHeader("Content-Type", "text/plain");
  res.send(script);
});

// ... (sisanya kode Anda yang sudah ada tetap sama)
// ==== ADMIN API - GENERATE KEY ====
app.post(`${ADMIN_PATH}/generate`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const { type, script, username } = req.body;
  if (!username) {
    return res.json({ ok: false, reason: "username is required" });
  }

  const plainKey = crypto.randomBytes(12).toString("hex");
  const hashed = crypto.createHash("sha256").update(plainKey).digest("hex");

  const keys = loadKeys();
  keys[hashed] = {
    active: true,
    hwid: null,
    username: username,
    plainKey: plainKey,
    created: Date.now(),
    expires: type === "perm" ? null : Date.now() + 7 * 24 * 60 * 60 * 1000,
    script,
  };
  saveKeys(keys);
  res.json({ ok: true, type, key: plainKey, hashed, script, username });
});

// ==== ADMIN API - GET ALL KEYS ====
app.get(`${ADMIN_PATH}/keys`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const keys = loadKeys();
  const userResets = loadUserResets();

  const keysList = Object.entries(keys).map(([hashed, info]) => {
    let plainKey = info.plainKey;
    if (!plainKey) {
      plainKey = hashed.substring(0, 8) + "...";
    }

    // Tambahkan info reset dari user
    const resetInfo = userResets[hashed];

    return {
      hashed,
      key: plainKey,
      plainKey: info.plainKey || plainKey,
      username: info.username,
      script: info.script,
      hwid: info.hwid,
      active: info.active,
      expires: info.expires,
      userResets: resetInfo ? {
        resetCount: resetInfo.resetCount || 0,
        lastReset: resetInfo.lastReset,
        canResetAgain: resetInfo.lastReset ? 
          (Date.now() - resetInfo.lastReset) > (3 * 24 * 60 * 60 * 1000) : true
      } : null
    };
  });

  res.json({ ok: true, keys: keysList });
});

// ==== ADMIN API - SEARCH KEYS ====
app.get(`${ADMIN_PATH}/search`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const { username } = req.query;
  if (!username) {
    return res.json({ ok: false, reason: "username is required" });
  }

  const keys = loadKeys();
  const userResets = loadUserResets();

  const keysList = Object.entries(keys)
    .filter(
      ([hashed, info]) =>
        info.username &&
        info.username.toLowerCase().includes(username.toLowerCase()),
    )
    .map(([hashed, info]) => {
      let plainKey = info.plainKey;
      if (!plainKey) {
        plainKey = hashed.substring(0, 8) + "...";
      }

      const resetInfo = userResets[hashed];

      return {
        hashed,
        key: plainKey,
        plainKey: info.plainKey || plainKey,
        username: info.username,
        script: info.script,
        hwid: info.hwid,
        active: info.active,
        expires: info.expires,
        userResets: resetInfo ? {
          resetCount: resetInfo.resetCount || 0,
          lastReset: resetInfo.lastReset,
          canResetAgain: resetInfo.lastReset ? 
            (Date.now() - resetInfo.lastReset) > (3 * 24 * 60 * 60 * 1000) : true
        } : null
      };
    });

  res.json({ ok: true, keys: keysList });
});

// ==== ADMIN API - GET USER RESET HISTORY ====
app.get(`${ADMIN_PATH}/reset-history`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const { hashed } = req.query;
  const userResets = loadUserResets();

  if (!hashed) {
    // Return all reset history
    const allResets = Object.entries(userResets).map(([keyHash, info]) => ({
      keyHash: keyHash,
      key: info.key,
      username: info.username,
      resetCount: info.resetCount || 0,
      lastReset: info.lastReset,
      history: info.history || []
    }));

    return res.json({ ok: true, resets: allResets });
  }

  const resetInfo = userResets[hashed];
  if (!resetInfo) {
    return res.json({ ok: false, reason: "Tidak ada riwayat reset untuk key ini" });
  }

  res.json({ 
    ok: true, 
    resetInfo: {
      key: resetInfo.key,
      username: resetInfo.username,
      resetCount: resetInfo.resetCount || 0,
      lastReset: resetInfo.lastReset,
      history: resetInfo.history || []
    }
  });
});

// ==== ADMIN API - RESET HWID ====
app.post(`${ADMIN_PATH}/reset-hwid`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const { hashed } = req.body;
  const keys = loadKeys();

  if (!keys[hashed]) return res.json({ ok: false, reason: "key not found" });

  keys[hashed].hwid = null;
  saveKeys(keys);

  res.json({ ok: true, message: "HWID berhasil direset" });
});

// ==== ADMIN API - TOGGLE KEY STATUS ====
app.post(`${ADMIN_PATH}/toggle-key`, (req, res) => {
  const adm = req.headers["x-admin-token"];
  if (adm !== process.env.ADMIN_SECRET)
    return res.json({ ok: false, reason: "unauthorized" });

  const { hashed, active } = req.body;
  const keys = loadKeys();

  if (!keys[hashed]) return res.json({ ok: false, reason: "key not found" });

  keys[hashed].active = active;
  saveKeys(keys);

  res.json({
    ok: true,
    message: `Key berhasil ${active ? "diaktifkan" : "dinonaktifkan"}`,
  });
});

// ==== USER RESET PAGE ====
app.get("/reset-hwid-page", (req, res) => {
  const html = `
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Reset HWID - LS Hub</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

  :root {
    --primary: #3b82f6;
    --primary-dark: #2563eb;
    --danger: #ef4444;
    --success: #10b981;
    --dark-1: #111827;
    --dark-2: #1f2937;
    --light-1: #f9fafb;
    --light-2: #e5e7eb;
    --light-3: #d1d5db;
    --radius: 12px;
    --shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
  }

  * { 
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  body { 
    font-family: 'Inter', sans-serif;
    background: linear-gradient(135deg, var(--dark-1) 0%, var(--dark-2) 100%);
    color: var(--light-1);
    line-height: 1.6;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
  }

  .container {
    max-width: 500px;
    width: 100%;
  }

  .reset-card {
    background: rgba(15, 23, 42, 0.9);
    border-radius: var(--radius);
    padding: 40px;
    box-shadow: var(--shadow);
    border: 1px solid rgba(255, 255, 255, 0.08);
    text-align: center;
  }

  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 15px;
    margin-bottom: 25px;
  }

  .logo-icon {
    width: 50px;
    height: 50px;
    background: linear-gradient(135deg, var(--primary), #8b5cf6);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    color: white;
  }

  h1 {
    font-size: 2rem;
    font-weight: 700;
    background: linear-gradient(135deg, var(--primary), #8b5cf6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 10px;
  }

  .description {
    color: var(--light-3);
    margin-bottom: 30px;
    font-size: 1rem;
  }

  .info-box {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
    border-left: 4px solid var(--primary);
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 25px;
    text-align: left;
  }

  .info-box h3 {
    color: var(--primary);
    margin-bottom: 10px;
    font-size: 1.1rem;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .info-box ul {
    padding-left: 20px;
    color: var(--light-2);
  }

  .info-box li {
    margin-bottom: 8px;
  }

  .form-group {
    margin-bottom: 25px;
    text-align: left;
  }

  label {
    display: block;
    margin-bottom: 8px;
    color: var(--light-2);
    font-weight: 500;
  }

  input {
    width: 100%;
    padding: 14px 16px;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    color: var(--light-1);
    font-size: 1rem;
    transition: all 0.2s;
  }

  input:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .btn {
    width: 100%;
    padding: 16px;
    border: none;
    border-radius: 8px;
    font-size: 1.1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-bottom: 15px;
  }

  .btn-primary {
    background: linear-gradient(135deg, var(--primary), #8b5cf6);
    color: white;
  }

  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(59, 130, 246, 0.3);
  }

  .btn-secondary {
    background: rgba(255, 255, 255, 0.1);
    color: var(--light-1);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .btn-secondary:hover {
    background: rgba(255, 255, 255, 0.15);
  }

  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
  }

  .result {
    margin-top: 25px;
    padding: 20px;
    border-radius: 8px;
    font-family: 'SF Mono', monospace;
    font-size: 0.9rem;
    text-align: left;
    max-height: 300px;
    overflow-y: auto;
  }

  .result.success {
    background: rgba(16, 185, 129, 0.1);
    border: 1px solid rgba(16, 185, 129, 0.2);
    color: var(--success);
  }

  .result.error {
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.2);
    color: var(--danger);
  }

  .cooldown-info {
    background: rgba(245, 158, 11, 0.1);
    border: 1px solid rgba(245, 158, 11, 0.2);
    padding: 15px;
    border-radius: 8px;
    margin-top: 20px;
    text-align: center;
  }

  .cooldown-info h3 {
    color: #f59e0b;
    margin-bottom: 10px;
  }

  .cooldown-timer {
    font-size: 1.5rem;
    font-weight: 700;
    color: white;
    margin: 10px 0;
  }

  .notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: 8px;
    color: white;
    font-weight: 600;
    z-index: 1000;
    display: flex;
    align-items: center;
    gap: 10px;
    transform: translateX(150%);
    transition: transform 0.3s;
    max-width: 400px;
  }

  .notification.show {
    transform: translateX(0);
  }

  .notification.success {
    background: linear-gradient(135deg, var(--success), #0da271);
  }

  .notification.error {
    background: linear-gradient(135deg, var(--danger), #c53030);
  }

  @media (max-width: 600px) {
    .reset-card {
      padding: 30px 20px;
    }

    h1 {
      font-size: 1.8rem;
    }
  }
</style>
</head>
<body>

<div class="container">
  <div class="reset-card">
    <div class="logo">
      <div class="logo-icon">
        <i class="fas fa-key"></i>
      </div>
      <h1>Reset HWID</h1>
    </div>

    <p class="description">Reset HWID untuk menggunakan key di perangkat baru</p>

    <div class="info-box">
      <h3><i class="fas fa-info-circle"></i> Cara Penggunaan</h3>
      <ul>
        <li>Cooldown Reset HWID 3 hari sekali</li>
        <li>Pastikan key Anda aktif dan valid</li>
        <li>Setelah reset, key dapat digunakan di perangkat baru</li>
      </ul>
    </div>

    <div class="form-group">
      <label for="key-input"><i class="fas fa-key"></i> Masukkan Key Anda</label>
      <input type="text" id="key-input" placeholder="Contoh: a1b2c3d4e5f6...">
    </div>

    <button class="btn btn-primary" id="check-btn" onclick="checkCooldown()">
      <i class="fas fa-search"></i> Cek Status Reset
    </button>

    <div id="cooldown-info" style="display: none;"></div>

    <button class="btn btn-primary" id="reset-btn" onclick="resetHWID()" style="display: none; margin-top: 15px;">
      <i class="fas fa-sync-alt"></i> Reset HWID Sekarang
    </button>

    <div id="result" class="result" style="display: none;"></div>

    <button class="btn btn-secondary" onclick="window.location.href = '/'">
      <i class="fas fa-home"></i> Kembali ke Home
    </button>
  </div>
</div>

<div id="notification" class="notification">
  <span class="notification-icon"></span>
  <span class="notification-message"></span>
</div>

<script>
function showNotification(message, type) {
  const notification = document.getElementById('notification');
  const messageEl = notification.querySelector('.notification-message');
  const iconEl = notification.querySelector('.notification-icon');

  iconEl.className = 'notification-icon fas fa-' + 
    (type === 'success' ? 'check-circle' : 'exclamation-circle');

  messageEl.textContent = message;
  notification.className = 'notification ' + type + ' show';

  setTimeout(() => {
    notification.classList.remove('show');
  }, 3000);
}

async function checkCooldown() {
  const keyInput = document.getElementById('key-input').value.trim();
  const checkBtn = document.getElementById('check-btn');
  const resetBtn = document.getElementById('reset-btn');
  const cooldownInfo = document.getElementById('cooldown-info');
  const resultDiv = document.getElementById('result');

  if (!keyInput) {
    showNotification('Masukkan key terlebih dahulu!', 'error');
    return;
  }

  const originalText = checkBtn.innerHTML;
  checkBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Mengecek...';
  checkBtn.disabled = true;

  try {
    const response = await fetch('/check-reset-cooldown?key=' + encodeURIComponent(keyInput));
    const data = await response.json();

    resultDiv.style.display = 'block';
    resultDiv.className = 'result ' + (data.ok ? 'success' : 'error');
    resultDiv.innerHTML = JSON.stringify(data, null, 2);

    cooldownInfo.style.display = 'none';
    resetBtn.style.display = 'none';

    if (data.ok) {
      if (data.canReset) {
        resetBtn.style.display = 'flex';
        showNotification('Anda dapat mereset HWID sekarang!', 'success');
      } else {
        cooldownInfo.style.display = 'block';
        cooldownInfo.innerHTML = \`
          <div class="cooldown-info">
            <h3><i class="fas fa-clock"></i> Cooldown Aktif</h3>
            <p>\${data.message}</p>
            <div class="cooldown-timer" id="cooldown-timer"></div>
            <p>Reset tersedia pada: <br><strong>\${new Date(data.nextResetTime).toLocaleString()}</strong></p>
          </div>
        \`;

        // Start countdown timer
        if (data.remainingCooldown) {
          startCountdown(data.remainingCooldown);
        }
      }
    } else {
      showNotification(data.reason || 'Gagal memeriksa status', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    resultDiv.style.display = 'block';
    resultDiv.className = 'result error';
    resultDiv.textContent = 'Error: ' + error.message;
  } finally {
    checkBtn.innerHTML = originalText;
    checkBtn.disabled = false;
  }
}

async function resetHWID() {
  const keyInput = document.getElementById('key-input').value.trim();
  const resetBtn = document.getElementById('reset-btn');
  const resultDiv = document.getElementById('result');

  if (!keyInput) {
    showNotification('Masukkan key terlebih dahulu!', 'error');
    return;
  }

  if (!confirm('Yakin ingin mereset HWID? Setelah reset, untuk reset selanjutnya memiliki cooldown 3 hari.')) {
    return;
  }

  const originalText = resetBtn.innerHTML;
  resetBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memproses...';
  resetBtn.disabled = true;

  try {
    const response = await fetch('/user-reset-hwid', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ key: keyInput })
    });

    const data = await response.json();

    resultDiv.style.display = 'block';
    resultDiv.className = 'result ' + (data.ok ? 'success' : 'error');
    resultDiv.innerHTML = JSON.stringify(data, null, 2);

    if (data.ok) {
      showNotification(data.message || 'HWID berhasil direset!', 'success');
      // Update UI setelah reset berhasil
      document.getElementById('cooldown-info').style.display = 'block';
      document.getElementById('cooldown-info').innerHTML = \`
        <div class="cooldown-info">
          <h3><i class="fas fa-check-circle"></i> Reset Berhasil!</h3>
          <p>\${data.message}</p>
          <p>Reset berikutnya tersedia pada: <br><strong>\${new Date(data.nextResetAvailable).toLocaleString()}</strong></p>
          <p>Total reset: <strong>\${data.resetCount}</strong> kali</p>
        </div>
      \`;
      resetBtn.style.display = 'none';
    } else {
      showNotification(data.reason || 'Gagal mereset HWID', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    resultDiv.style.display = 'block';
    resultDiv.className = 'result error';
    resultDiv.textContent = 'Error: ' + error.message;
  } finally {
    resetBtn.innerHTML = originalText;
    resetBtn.disabled = false;
  }
}

function startCountdown(milliseconds) {
  const timerElement = document.getElementById('cooldown-timer');
  if (!timerElement) return;

  let remaining = milliseconds;

  function updateTimer() {
    const days = Math.floor(remaining / (1000 * 60 * 60 * 24));
    const hours = Math.floor((remaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((remaining % (1000 * 60)) / 1000);

    timerElement.textContent = \`\${days.toString().padStart(2, '0')}:\${hours.toString().padStart(2, '0')}:\${minutes.toString().padStart(2, '0')}:\${seconds.toString().padStart(2, '0')}\`;

    if (remaining <= 0) {
      clearInterval(interval);
      timerElement.textContent = "00:00:00:00";
      // Refresh status
      setTimeout(() => checkCooldown(), 1000);
    }

    remaining -= 1000;
  }

  updateTimer();
  const interval = setInterval(updateTimer, 1000);
}

// Auto-check ketika user selesai mengetik
let checkTimeout;
document.getElementById('key-input').addEventListener('input', function() {
  clearTimeout(checkTimeout);
  const key = this.value.trim();
  if (key.length > 10) {
    checkTimeout = setTimeout(checkCooldown, 1000);
  }
});
</script>

</body>
</html>`;

  res.send(html);
});

// --- RUTE UNTUK MENAMPILKAN HALAMAN HTML ADMIN (HARUS PALING BAWAH) ---
app.get(`${ADMIN_PATH}`, (req, res) => {
  // Gunakan concatenation string untuk menghindari template literal dalam template literal
  const html = `
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>LS Hub Admin Panel</title>
<!-- Font Awesome Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<!-- Animate CSS -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

  :root {
    --primary: #3b82f6;
    --primary-dark: #2563eb;
    --primary-light: #60a5fa;
    --secondary: #8b5cf6;
    --danger: #ef4444;
    --danger-dark: #dc2626;
    --success: #10b981;
    --warning: #f59e0b;
    --dark-1: #111827;
    --dark-2: #1f2937;
    --dark-3: #374151;
    --dark-4: #4b5563;
    --light-1: #f9fafb;
    --light-2: #e5e7eb;
    --light-3: #d1d5db;
    --radius: 12px;
    --radius-sm: 8px;
    --shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
    --shadow-lg: 0 20px 40px -10px rgba(0, 0, 0, 0.4);
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    --transition-fast: all 0.2s ease;
  }

  * { 
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  body { 
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    background: linear-gradient(135deg, var(--dark-1) 0%, var(--dark-2) 100%);
    color: var(--light-1);
    line-height: 1.6;
    min-height: 100vh;
    padding: 20px;
    animation: fadeIn 0.8s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
  }

  .header {
    text-align: center;
    margin-bottom: 40px;
    padding: 40px 30px;
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9));
    border-radius: var(--radius);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--shadow);
    animation: slideDown 0.6s ease-out;
    position: relative;
    overflow: hidden;
  }

  .header::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--primary), var(--secondary));
  }

  @keyframes slideDown {
    from { transform: translateY(-20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
  }

  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
    margin-bottom: 20px;
  }

  .logo-icon {
    width: 60px;
    height: 60px;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border-radius: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: 700;
    color: white;
    box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
    70% { box-shadow: 0 0 0 15px rgba(59, 130, 246, 0); }
    100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
  }

  h1 {
    font-size: 2.8rem;
    font-weight: 800;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin: 0;
    letter-spacing: -0.5px;
  }

  .tagline {
    color: var(--light-3);
    font-size: 1.1rem;
    margin-top: 15px;
    max-width: 700px;
    margin: 15px auto 0;
    line-height: 1.7;
  }

  .admin-panel {
    background: rgba(15, 23, 42, 0.8);
    border-radius: var(--radius);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.05);
    overflow: hidden;
    box-shadow: var(--shadow-lg);
    animation: fadeInUp 0.8s ease-out 0.2s both;
  }

  @keyframes fadeInUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .tabs-header {
    display: flex;
    background: linear-gradient(90deg, var(--dark-2), rgba(30, 41, 59, 0.9));
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  }

  .tab-btn {
    flex: 1;
    padding: 22px;
    background: none;
    border: none;
    color: var(--light-3);
    font-size: 1.05rem;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
  }

  .tab-btn i {
    font-size: 1.2rem;
    transition: var(--transition);
  }

  .tab-btn:hover {
    background: rgba(255, 255, 255, 0.03);
    color: var(--light-2);
  }

  .tab-btn:hover i {
    transform: translateY(-2px);
  }

  .tab-btn.active {
    color: white;
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.15), rgba(139, 92, 246, 0.15));
  }

  .tab-btn.active i {
    color: var(--primary-light);
  }

  .tab-btn.active::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--primary), var(--secondary));
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from { width: 0; left: 50%; }
    to { width: 100%; left: 0; }
  }

  .tab-content {
    display: none;
    padding: 35px;
    animation: fadeIn 0.4s ease-out;
  }

  .tab-content.active {
    display: block;
  }

  .card {
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(30, 41, 59, 0.9));
    border-radius: var(--radius);
    padding: 30px;
    margin-bottom: 30px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--shadow);
    transition: var(--transition);
    position: relative;
    overflow: hidden;
  }

  .card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-lg);
    border-color: rgba(255, 255, 255, 0.12);
  }

  .card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--primary), var(--secondary));
    transform: scaleX(0);
    transition: transform 0.3s ease;
  }

  .card:hover::before {
    transform: scaleX(1);
  }

  .card-title {
    font-size: 1.3rem;
    font-weight: 700;
    margin-bottom: 25px;
    color: var(--light-1);
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .card-title i {
    color: var(--primary-light);
    font-size: 1.4rem;
    background: rgba(59, 130, 246, 0.1);
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: var(--transition);
  }

  .card:hover .card-title i {
    transform: rotate(10deg) scale(1.1);
    background: rgba(59, 130, 246, 0.2);
  }

  .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 25px;
    margin-bottom: 30px;
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .input-label {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--light-2);
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .input-label i {
    color: var(--primary-light);
    font-size: 1rem;
  }

  .input-label.required::after {
    content: '*';
    color: var(--danger);
    margin-left: 4px;
  }

  input, select {
    padding: 16px 18px;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: var(--radius-sm);
    color: var(--light-1);
    font-size: 1rem;
    font-family: 'Inter', sans-serif;
    transition: var(--transition-fast);
  }

  input:hover, select:hover {
    background: rgba(255, 255, 255, 0.08);
    border-color: rgba(255, 255, 255, 0.15);
  }

  input:focus, select:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
    background: rgba(255, 255, 255, 0.1);
    transform: translateY(-2px);
  }

  input::placeholder {
    color: var(--dark-4);
    font-weight: 400;
  }

  .btn {
    padding: 16px 32px;
    border: none;
    border-radius: var(--radius-sm);
    font-size: 1.05rem;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    font-family: 'Inter', sans-serif;
    position: relative;
    overflow: hidden;
  }

  .btn::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 5px;
    height: 5px;
    background: rgba(255, 255, 255, 0.5);
    opacity: 0;
    border-radius: 100%;
    transform: scale(1, 1) translate(-50%);
    transform-origin: 50% 50%;
  }

  .btn:focus:not(:active)::after {
    animation: ripple 1s ease-out;
  }

  @keyframes ripple {
    0% { transform: scale(0, 0); opacity: 0.5; }
    100% { transform: scale(20, 20); opacity: 0; }
  }

  .btn i {
    font-size: 1.1rem;
    transition: var(--transition-fast);
  }

  .btn:hover i {
    transform: translateY(-2px);
  }

  .btn-primary {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
  }

  .btn-primary:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 30px rgba(59, 130, 246, 0.4);
  }

  .btn-primary:active {
    transform: translateY(-1px);
  }

  .btn-secondary {
    background: linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05));
    color: var(--light-1);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .btn-secondary:hover {
    background: linear-gradient(135deg, rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.08));
    border-color: rgba(255, 255, 255, 0.2);
    transform: translateY(-3px);
  }

  .btn-danger {
    background: linear-gradient(135deg, var(--danger), #c53030);
    color: white;
    box-shadow: 0 8px 20px rgba(239, 68, 68, 0.3);
  }

  .btn-danger:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 30px rgba(239, 68, 68, 0.4);
  }

  .btn-success {
    background: linear-gradient(135deg, var(--success), #0da271);
    color: white;
    box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
  }

  .btn-success:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 30px rgba(16, 185, 129, 0.4);
  }

  .btn-sm {
    padding: 10px 20px;
    font-size: 0.9rem;
    gap: 8px;
  }

  .btn-sm i {
    font-size: 0.95rem;
  }

  .btn-group {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    margin-top: 25px;
  }

  .info-box {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
    border-left: 4px solid var(--primary);
    padding: 25px;
    border-radius: var(--radius-sm);
    margin-bottom: 30px;
    position: relative;
    overflow: hidden;
  }

  .info-box::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.03) 50%, transparent 70%);
    animation: shimmer 3s infinite;
  }

  @keyframes shimmer {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(100%); }
  }

  .info-box h3 {
    color: var(--primary-light);
    margin-bottom: 15px;
    font-size: 1.2rem;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .info-box h3 i {
    font-size: 1.3rem;
  }

  .info-box ol {
    padding-left: 25px;
    margin: 0;
  }

  .info-box li {
    margin-bottom: 10px;
    color: var(--light-2);
    line-height: 1.7;
    transition: var(--transition-fast);
  }

  .info-box li:hover {
    color: var(--light-1);
    transform: translateX(5px);
  }

  .info-box li:last-child {
    margin-bottom: 0;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 25px;
    margin-bottom: 35px;
  }

  .stat-card {
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(30, 41, 59, 0.9));
    border-radius: var(--radius);
    padding: 25px;
    text-align: center;
    border: 1px solid rgba(255, 255, 255, 0.08);
    transition: var(--transition);
    position: relative;
    overflow: hidden;
  }

  .stat-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow);
    border-color: rgba(255, 255, 255, 0.15);
  }

  .stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--primary), var(--secondary));
    transform: scaleX(0);
    transition: transform 0.3s ease;
  }

  .stat-card:hover::before {
    transform: scaleX(1);
  }

  .stat-icon {
    width: 60px;
    height: 60px;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
    font-size: 1.8rem;
    color: white;
    box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
    transition: var(--transition);
  }

  .stat-card:hover .stat-icon {
    transform: rotate(20deg) scale(1.1);
  }

  .stat-value {
    font-size: 2.8rem;
    font-weight: 800;
    color: var(--primary-light);
    margin-bottom: 10px;
    transition: var(--transition);
  }

  .stat-card:hover .stat-value {
    color: white;
  }

  .stat-label {
    color: var(--light-3);
    font-size: 0.95rem;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 600;
  }

  .table-container {
    overflow-x: auto;
    border-radius: var(--radius);
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--shadow);
    margin-top: 20px;
    animation: fadeIn 0.5s ease-out;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    min-width: 1000px;
  }

  thead {
    background: linear-gradient(90deg, var(--dark-2), rgba(30, 41, 59, 0.9));
    border-bottom: 2px solid rgba(255, 255, 255, 0.1);
  }

  th {
    padding: 20px 18px;
    text-align: left;
    font-weight: 700;
    color: var(--light-2);
    font-size: 0.95rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    white-space: nowrap;
  }

  th i {
    margin-right: 8px;
    color: var(--primary-light);
  }

  tbody tr {
    background: rgba(15, 23, 42, 0.6);
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    transition: var(--transition);
  }

  tbody tr:hover {
    background: rgba(30, 41, 59, 0.9);
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  }

  td {
    padding: 18px;
    color: var(--light-2);
    vertical-align: middle;
    transition: var(--transition-fast);
  }

  tbody tr:hover td {
    color: var(--light-1);
  }

  .key-display {
    font-family: 'SF Mono', Monaco, Consolas, monospace;
    background: rgba(0, 0, 0, 0.3);
    padding: 10px 15px;
    border-radius: var(--radius-sm);
    font-size: 0.9rem;
    word-break: break-all;
    margin-right: 10px;
    flex: 1;
    border: 1px solid rgba(255, 255, 255, 0.05);
  }

  .key-cell {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .status-badge {
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: var(--transition);
  }

  .status-badge i {
    font-size: 0.75rem;
  }

  .status-active {
    background: linear-gradient(135deg, rgba(16, 185, 129, 0.2), rgba(16, 185, 129, 0.1));
    color: var(--success);
    border: 1px solid rgba(16, 185, 129, 0.3);
  }

  .status-inactive {
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(239, 68, 68, 0.1));
    color: var(--danger);
    border: 1px solid rgba(239, 68, 68, 0.3);
  }

  .actions-cell {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }

  .result-panel {
    margin-top: 35px;
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(30, 41, 59, 0.9));
    border-radius: var(--radius);
    border: 1px solid rgba(255, 255, 255, 0.08);
    overflow: hidden;
    box-shadow: var(--shadow);
    animation: fadeInUp 0.5s ease-out 0.3s both;
  }

  .result-header {
    background: linear-gradient(90deg, var(--dark-2), rgba(30, 41, 59, 0.9));
    padding: 18px 25px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  }

  .result-title {
    font-weight: 700;
    color: var(--light-2);
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 1.1rem;
  }

  .result-title i {
    color: var(--primary-light);
    font-size: 1.3rem;
  }

  .result-content {
    padding: 25px;
    font-family: 'SF Mono', Monaco, Consolas, monospace;
    font-size: 0.92rem;
    color: var(--primary-light);
    max-height: 350px;
    overflow-y: auto;
    background: rgba(0, 0, 0, 0.3);
    line-height: 1.8;
  }

  .notification {
    position: fixed;
    top: 30px;
    right: 30px;
    padding: 20px 25px;
    border-radius: var(--radius);
    color: white;
    font-weight: 600;
    z-index: 1000;
    display: flex;
    align-items: center;
    gap: 15px;
    transform: translateX(150%);
    transition: transform 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    max-width: 450px;
    box-shadow: var(--shadow-lg);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .notification.show {
    transform: translateX(0);
  }

  .notification.success {
    background: linear-gradient(135deg, var(--success), #0da271);
    border-left: 5px solid #0da271;
  }

  .notification.error {
    background: linear-gradient(135deg, var(--danger), #c53030);
    border-left: 5px solid #c53030;
  }

  .notification.info {
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    border-left: 5px solid var(--primary-dark);
  }

  .notification-icon {
    font-size: 1.4rem;
  }

  .empty-state {
    text-align: center;
    padding: 80px 30px;
    color: var(--dark-4);
    animation: fadeIn 0.6s ease-out;
  }

  .empty-state i {
    font-size: 4rem;
    margin-bottom: 25px;
    opacity: 0.5;
    color: var(--primary-light);
    animation: float 3s ease-in-out infinite;
  }

  @keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-15px); }
  }

  .empty-state h3 {
    color: var(--light-3);
    margin-bottom: 15px;
    font-size: 1.5rem;
  }

  .empty-state p {
    color: var(--dark-4);
    font-size: 1.1rem;
    max-width: 400px;
    margin: 0 auto;
  }

  .loading {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    border-top-color: var(--primary);
    animation: spin 1s ease-in-out infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  @media (max-width: 768px) {
    .container {
      padding: 15px;
    }

    .header {
      padding: 30px 20px;
      margin-bottom: 30px;
    }

    h1 {
      font-size: 2.2rem;
    }

    .tab-content {
      padding: 25px 20px;
    }

    .tab-btn {
      padding: 18px;
      font-size: 1rem;
    }

    .form-grid {
      grid-template-columns: 1fr;
      gap: 20px;
    }

    .stats-grid {
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
    }

    .btn-group {
      flex-direction: column;
      gap: 12px;
    }

    .btn {
      width: 100%;
    }

    .notification {
      left: 20px;
      right: 20px;
      max-width: none;
      top: 20px;
    }
  }

  @media (max-width: 480px) {
    .stats-grid {
      grid-template-columns: 1fr;
    }

    .tabs-header {
      flex-direction: column;
    }

    .tab-btn {
      padding: 16px;
      justify-content: flex-start;
      padding-left: 25px;
    }

    .logo {
      flex-direction: column;
      text-align: center;
      gap: 15px;
    }

    .logo-icon {
      width: 70px;
      height: 70px;
      font-size: 32px;
    }

    h1 {
      font-size: 2rem;
    }

    .card {
      padding: 25px 20px;
    }
  }
</style>
</head>
<body>

<div class="container">
  <div class="header">
    <div class="logo">
      <div class="logo-icon"><i class="fas fa-cube"></i></div>
      <h1>Panel Admin</h1>
    </div>
    <p class="tagline">Welcome To LS Hub Admin Panel</p>
    <div style="margin-top: 20px;">
      <a href="/reset-hwid-page" style="color: var(--primary-light); text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
        <i class="fas fa-external-link-alt"></i>
        <span>Halaman Reset HWID untuk Pengguna</span>
      </a>
    </div>
  </div>

  <div class="admin-panel">
    <div class="tabs-header">
      <button class="tab-btn active" data-tab="generate">
        <i class="fas fa-key"></i> Generate Key
      </button>
      <button class="tab-btn" data-tab="manage">
        <i class="fas fa-tasks"></i> Kelola Key
      </button>
      <button class="tab-btn" data-tab="stats">
        <i class="fas fa-chart-bar"></i> Statistik
      </button>
      <button class="tab-btn" data-tab="user-resets">
        <i class="fas fa-history"></i> Riwayat Reset
      </button>
    </div>

    <!-- Generate Tab -->
    <div id="generate-tab" class="tab-content active">
      <div class="info-box">
        <h3><i class="fas fa-info-circle"></i> Panduan</h3>
        <ol>
          <li>Masukkan <strong>Admin Token</strong></li>
        </ol>
      </div>

      <div class="card">
        <h2 class="card-title"><i class="fas fa-cogs"></i> Form Generate Key</h2>
        <div class="form-grid">
          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-lock"></i> Admin Token
            </label>
            <input type="password" id="adm" placeholder="Masukkan token admin...">
          </div>

          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-user"></i> Username Pemilik
            </label>
            <input type="text" id="username" placeholder="Masukkan username...">
          </div>

          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-file-code"></i> Script
            </label>
            <select id="script">
              <option value="fishit.lua"><i class="fas fa-fish"></i> Fish It</option>
              <option value="prem_vip.lua"><i class="fas fa-crown"></i> Prem VIP</option>
              <option value="fling.lua"><i class="fas fa-sync-alt"></i> Fling</option>
              <option value="autowalk.lua"><i class="fas fa-walking"></i> Autowalk</option>
              <option value="ringpart.lua"><i class="fas fa-ring"></i> Ringpart</option>
            </select>
          </div>
        </div>

        <div class="btn-group">
          <button class="btn btn-primary" onclick="gen('7d')">
            <i class="fas fa-hourglass-half"></i> Generate 7 Hari
          </button>
          <button class="btn btn-primary" onclick="gen('perm')">
            <i class="fas fa-infinity"></i> Generate Permanen
          </button>
          <button class="btn btn-secondary" onclick="resetGenerateForm()">
            <i class="fas fa-redo"></i> Reset Form
          </button>
        </div>
      </div>
    </div>

    <!-- Manage Tab -->
    <div id="manage-tab" class="tab-content">
      <div class="info-box">
        <h3><i class="fas fa-info-circle"></i> Panduan</h3>
        <ol>
          <li>Masukkan <strong>Admin Token</strong></li>
          <li>Filter key berdasarkan username</li>
        </ol>
      </div>

      <div class="card">
        <h2 class="card-title"><i class="fas fa-filter"></i> Filter & Pencarian</h2>
        <div class="form-grid">
          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-lock"></i> Admin Token
            </label>
            <input type="password" id="adm-manage" placeholder="Masukkan token admin...">
          </div>

          <div class="input-group">
            <label class="input-label">
              <i class="fas fa-search"></i> Cari Username
            </label>
            <input type="text" id="search-username" placeholder="Cari berdasarkan username...">
          </div>
        </div>

        <div class="btn-group">
          <button class="btn btn-primary" onclick="loadKeys()">
            <i class="fas fa-list"></i> Tampilkan Semua Key
          </button>
          <button class="btn btn-secondary" onclick="searchByUsername()">
            <i class="fas fa-search"></i> Cari Key
          </button>
          <button class="btn btn-secondary" onclick="refreshKeyList()">
            <i class="fas fa-sync-alt"></i> Refresh
          </button>
        </div>
      </div>

      <div id="keys-table-container" style="display: none;">
        <div class="card">
          <h2 class="card-title"><i class="fas fa-table"></i> Daftar Key</h2>
          <div class="table-container">
            <table id="keys-list">
              <thead>
                <tr>
                  <th><i class="fas fa-key"></i> Key</th>
                  <th><i class="fas fa-user"></i> Username</th>
                  <th><i class="fas fa-file-code"></i> Script</th>
                  <th><i class="fas fa-microchip"></i> HWID</th>
                  <th><i class="fas fa-circle"></i> Status</th>
                  <th><i class="fas fa-history"></i> Reset User</th>
                  <th><i class="fas fa-cogs"></i> Aksi</th>
                </tr>
              </thead>
              <tbody id="keys-tbody">
                <!-- Data akan diisi oleh JavaScript -->
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div id="empty-state" class="empty-state" style="display: none;">
        <i class="fas fa-inbox"></i>
        <h3>Tidak ada key ditemukan</h3>
        <p>Generate key baru atau gunakan filter berbeda</p>
      </div>
    </div>

    <!-- Stats Tab -->
    <div id="stats-tab" class="tab-content">
      <div class="info-box">
        <h3><i class="fas fa-info-circle"></i> Statistik Sistem</h3>
        <p>Informasi terkini mengenai penggunaan key dan sistem</p>
      </div>

      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-key"></i>
          </div>
          <div class="stat-value" id="total-keys">0</div>
          <div class="stat-label">Total Key</div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-check-circle"></i>
          </div>
          <div class="stat-value" id="active-keys">0</div>
          <div class="stat-label">Key Aktif</div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-times-circle"></i>
          </div>
          <div class="stat-value" id="inactive-keys">0</div>
          <div class="stat-label">Key Non-Aktif</div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-link"></i>
          </div>
          <div class="stat-value" id="bound-keys">0</div>
          <div class="stat-label">Terikat HWID</div>
        </div>
      </div>

      <div class="card">
        <h2 class="card-title"><i class="fas fa-chart-line"></i> Ringkasan Aktivitas</h2>
        <div class="form-grid">
          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-lock"></i> Admin Token
            </label>
            <input type="password" id="adm-stats" placeholder="Masukkan token admin...">
          </div>
        </div>
        <button class="btn btn-primary" onclick="loadStats()">
          <i class="fas fa-sync-alt"></i> Muat Statistik
        </button>
      </div>
    </div>

    <!-- User Resets Tab -->
    <div id="user-resets-tab" class="tab-content">
      <div class="info-box">
        <h3><i class="fas fa-info-circle"></i> Riwayat Reset HWID oleh Pengguna</h3>
        <ol>
          <li>Hanya Admin yang dapat melihat semua riwayat</li>
        </ol>
      </div>

      <div class="card">
        <h2 class="card-title"><i class="fas fa-history"></i> Data Reset Pengguna</h2>
        <div class="form-grid">
          <div class="input-group">
            <label class="input-label required">
              <i class="fas fa-lock"></i> Admin Token
            </label>
            <input type="password" id="adm-resets" placeholder="Masukkan token admin...">
          </div>

          <div class="input-group">
            <label class="input-label">
              <i class="fas fa-search"></i> Cari Key Hash
            </label>
            <input type="text" id="search-reset-hash" placeholder="Cari berdasarkan key hash...">
          </div>
        </div>

        <div class="btn-group">
          <button class="btn btn-primary" onclick="loadResetHistory()">
            <i class="fas fa-history"></i> Tampilkan Semua Riwayat
          </button>
          <button class="btn btn-secondary" onclick="searchResetHistory()">
            <i class="fas fa-search"></i> Cari Riwayat
          </button>
        </div>
      </div>

      <div id="resets-table-container" style="display: none;">
        <div class="card">
          <h2 class="card-title"><i class="fas fa-table"></i> Riwayat Reset HWID</h2>
          <div class="table-container">
            <table id="resets-list">
              <thead>
                <tr>
                  <th><i class="fas fa-key"></i> Key Hash</th>
                  <th><i class="fas fa-user"></i> Username</th>
                  <th><i class="fas fa-redo"></i> Total Reset</th>
                  <th><i class="fas fa-clock"></i> Reset Terakhir</th>
                  <th><i class="fas fa-history"></i> Cooldown</th>
                  <th><i class="fas fa-list"></i> Riwayat Detail</th>
                </tr>
              </thead>
              <tbody id="resets-tbody">
                <!-- Data akan diisi oleh JavaScript -->
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div id="resets-empty-state" class="empty-state" style="display: none;">
        <i class="fas fa-history"></i>
        <h3>Tidak ada riwayat reset</h3>
        <p>Belum ada pengguna yang melakukan reset HWID</p>
      </div>
    </div>

    <!-- Result Panel -->
    <div class="result-panel">
      <div class="result-header">
        <div class="result-title">
          <i class="fas fa-terminal"></i> Hasil & Output
        </div>
        <button class="btn btn-sm btn-secondary" onclick="clearResult()">
          <i class="fas fa-trash-alt"></i> Bersihkan
        </button>
      </div>
      <pre class="result-content" id="out">Menunggu perintah...</pre>
    </div>
  </div>
</div>

<!-- Notification -->
<div id="notification" class="notification">
  <span class="notification-icon"></span>
  <span class="notification-message">Pesan notifikasi</span>
</div>

<script>
// Gunakan string concatenation untuk menghindari template literal dalam template literal
const ADMIN_PATH = '${ADMIN_PATH}';

// Tab Management
document.addEventListener('DOMContentLoaded', function() {
  const tabs = document.querySelectorAll('.tab-btn');
  tabs.forEach(tab => {
    tab.addEventListener('click', function() {
      const tabName = this.getAttribute('data-tab');
      showTab(tabName);
    });
  });

  // Tambahkan animasi saat pertama kali load
  document.querySelectorAll('.card, .stat-card').forEach((card, index) => {
    card.style.animationDelay = (index * 0.1) + 's';
  });
});

function showTab(tabName) {
  // Update active tab button
  document.querySelectorAll('.tab-btn').forEach(tab => tab.classList.remove('active'));
  document.querySelector('[data-tab="' + tabName + '"]').classList.add('active');

  // Update active tab content
  document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
  document.getElementById(tabName + '-tab').classList.add('active');
}

// Notification System
function showNotification(message, type) {
  type = type || 'info';
  const notification = document.getElementById('notification');
  const messageEl = notification.querySelector('.notification-message');
  const iconEl = notification.querySelector('.notification-icon');

  // Set icon based on type
  switch(type) {
    case 'success':
      iconEl.className = 'notification-icon fas fa-check-circle';
      break;
    case 'error':
      iconEl.className = 'notification-icon fas fa-exclamation-circle';
      break;
    case 'info':
      iconEl.className = 'notification-icon fas fa-info-circle';
      break;
  }

  messageEl.textContent = message;
  notification.className = 'notification ' + type + ' show';

  // Auto-hide after 3 seconds
  setTimeout(function() {
    notification.classList.remove('show');
  }, 3000);
}

// Form Functions
function resetGenerateForm() {
  document.getElementById('username').value = '';
  document.getElementById('script').value = 'fishit.lua';
  showNotification('Form telah direset', 'success');
}

function clearResult() {
  document.getElementById('out').textContent = 'Menunggu perintah...';
  showNotification('Output dibersihkan', 'success');
}

// Generate Key
async function gen(type) {
  const adm = document.getElementById('adm').value;
  const username = document.getElementById('username').value;
  const script = document.getElementById('script').value;

  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    document.getElementById('adm').focus();
    return;
  }

  if (!username) {
    showNotification('Masukkan Username!', 'error');
    document.getElementById('username').focus();
    return;
  }

  const btn = event.target;
  const originalText = btn.innerHTML;
  btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memproses...';
  btn.disabled = true;

  try {
    const res = await fetch(ADMIN_PATH + '/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      },
      body: JSON.stringify({ type: type, script: script, username: username })
    });

    const data = await res.json();
    document.getElementById('out').textContent = JSON.stringify(data, null, 2);

    if (data.ok) {
      showNotification('Key berhasil dibuat untuk ' + username + '!', 'success');
      // Auto copy key if available
      if (data.key) {
        navigator.clipboard.writeText(data.key).then(function() {
          showNotification('Key telah disalin ke clipboard!', 'success');
        });
      }
    } else {
      showNotification(data.reason || 'Gagal membuat key', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    btn.innerHTML = originalText;
    btn.disabled = false;
  }
}

// Load Keys
async function loadKeys() {
  const adm = document.getElementById('adm-manage').value;
  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memuat...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/keys', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      }
    });

    const data = await res.json();
    if (!data.ok) {
      showNotification(data.reason || 'Gagal memuat key', 'error');
      document.getElementById('out').textContent = JSON.stringify(data, null, 2);
      return;
    }

    displayKeys(data.keys);
    showNotification('Berhasil memuat ' + data.keys.length + ' key', 'success');
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

async function searchByUsername() {
  const adm = document.getElementById('adm-manage').value;
  const username = document.getElementById('search-username').value;

  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  if (!username) {
    showNotification('Masukkan username yang ingin dicari!', 'error');
    return;
  }

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Mencari...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/search?username=' + encodeURIComponent(username), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      }
    });

    const data = await res.json();
    if (!data.ok) {
      showNotification(data.reason || 'Gagal mencari key', 'error');
      document.getElementById('out').textContent = JSON.stringify(data, null, 2);
      return;
    }

    displayKeys(data.keys);
    showNotification('Ditemukan ' + data.keys.length + ' key untuk "' + username + '"', 'success');
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

function displayKeys(keys) {
  const tbody = document.getElementById('keys-tbody');
  const tableContainer = document.getElementById('keys-table-container');
  const emptyState = document.getElementById('empty-state');

  tbody.innerHTML = '';

  if (!keys || keys.length === 0) {
    tableContainer.style.display = 'none';
    emptyState.style.display = 'block';
    return;
  }

  tableContainer.style.display = 'block';
  emptyState.style.display = 'none';

  // Calculate statistics
  let activeCount = 0;
  let boundCount = 0;

  keys.forEach(function(keyInfo) {
    const isActive = keyInfo.active;
    const hasHwid = keyInfo.hwid && keyInfo.hwid !== 'Belum diikat';

    if (isActive) activeCount++;
    if (hasHwid) boundCount++;

    // Determine key display
    let keyDisplay = 'N/A';
    let copyButton = '<button class="btn btn-sm btn-secondary" disabled><i class="fas fa-lock"></i> Old Key</button>';

    if (keyInfo.plainKey) {
      keyDisplay = keyInfo.plainKey;
      copyButton = '<button class="btn btn-sm btn-success" onclick="copyToClipboard(\\'' + keyInfo.plainKey + '\\', this)">' +
                   '<i class="fas fa-copy"></i> Copy</button>';
    } else if (keyInfo.hashed) {
      keyDisplay = keyInfo.hashed.substring(0, 8) + '...' + keyInfo.hashed.substring(keyInfo.hashed.length - 4);
    }

    // User reset info
    let resetInfo = '';
    if (keyInfo.userResets) {
      const lastReset = keyInfo.userResets.lastReset ? 
        new Date(keyInfo.userResets.lastReset).toLocaleDateString('id-ID') : 'Belum pernah';
      const resetCount = keyInfo.userResets.resetCount || 0;
      resetInfo = \`<div style="font-size: 0.85rem;">
        <div><strong>Reset:</strong> \${resetCount} kali</div>
        <div><strong>Terakhir:</strong> \${lastReset}</div>
        <div><strong>Status:</strong> \${keyInfo.userResets.canResetAgain ? '<span style="color: #10b981;">Bisa reset</span>' : '<span style="color: #f59e0b;">Cooldown</span>'}</div>
      </div>\`;
    } else {
      resetInfo = '<div style="font-size: 0.85rem; color: var(--dark-4);">Belum pernah reset</div>';
    }

    const row = document.createElement('tr');

    // Gunakan string concatenation untuk innerHTML
    let actionsHtml = '';
    if (hasHwid) {
      actionsHtml += '<button class="btn btn-sm btn-danger" onclick="resetHwid(\\'' + keyInfo.hashed + '\\')">' +
                     '<i class="fas fa-unlink"></i> Reset HWID (Admin)</button>';
    }

    actionsHtml += '<button class="btn btn-sm ' + (isActive ? 'btn-secondary' : 'btn-success') + '" ' +
                   'onclick="toggleKey(\\'' + keyInfo.hashed + '\\', ' + isActive + ')">' +
                   '<i class="' + (isActive ? 'fas fa-pause' : 'fas fa-play') + '"></i> ' + (isActive ? 'Non-aktifkan' : 'Aktifkan') + '</button>';

    row.innerHTML = '<td>' +
                    '<div class="key-cell">' +
                    '<span class="key-display">' + keyDisplay + '</span>' +
                    copyButton +
                    '</div>' +
                    '</td>' +
                    '<td>' + (keyInfo.username || '<em>Tidak ada</em>') + '</td>' +
                    '<td>' + (keyInfo.script || 'N/A') + '</td>' +
                    '<td>' + (keyInfo.hwid || '<em>Belum diikat</em>') + '</td>' +
                    '<td>' +
                    '<span class="status-badge ' + (isActive ? 'status-active' : 'status-inactive') + '">' +
                    '<i class="' + (isActive ? 'fas fa-check' : 'fas fa-times') + '"></i>' +
                    (isActive ? 'Aktif' : 'Non-Aktif') +
                    '</span>' +
                    '</td>' +
                    '<td>' + resetInfo + '</td>' +
                    '<td>' +
                    '<div class="actions-cell">' +
                    actionsHtml +
                    '</div>' +
                    '</td>';

    tbody.appendChild(row);
  });

  // Update statistics display
  document.getElementById('total-keys').textContent = keys.length;
  document.getElementById('active-keys').textContent = activeCount;
  document.getElementById('inactive-keys').textContent = keys.length - activeCount;
  document.getElementById('bound-keys').textContent = boundCount;

  // Tambahkan animasi untuk setiap row
  tbody.querySelectorAll('tr').forEach((row, index) => {
    row.style.animationDelay = (index * 0.05) + 's';
    row.classList.add('animate__animated', 'animate__fadeInUp');
  });
}

// Load Reset History
async function loadResetHistory() {
  const adm = document.getElementById('adm-resets').value;
  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memuat...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/reset-history', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      }
    });

    const data = await res.json();
    if (!data.ok) {
      showNotification(data.reason || 'Gagal memuat riwayat reset', 'error');
      document.getElementById('out').textContent = JSON.stringify(data, null, 2);
      return;
    }

    displayResetHistory(data.resets);
    showNotification('Berhasil memuat ' + (data.resets ? data.resets.length : 0) + ' riwayat reset', 'success');
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

async function searchResetHistory() {
  const adm = document.getElementById('adm-resets').value;
  const hash = document.getElementById('search-reset-hash').value.trim();

  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  if (!hash) {
    loadResetHistory();
    return;
  }

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Mencari...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/reset-history?hashed=' + encodeURIComponent(hash), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      }
    });

    const data = await res.json();
    document.getElementById('out').textContent = JSON.stringify(data, null, 2);

    if (data.ok) {
      if (data.resetInfo) {
        // Single result
        displayResetHistory([{
          keyHash: hash,
          key: data.resetInfo.key,
          username: data.resetInfo.username,
          resetCount: data.resetInfo.resetCount || 0,
          lastReset: data.resetInfo.lastReset,
          history: data.resetInfo.history || []
        }]);
        showNotification('Riwayat reset ditemukan', 'success');
      } else {
        showNotification('Tidak ada riwayat reset untuk key ini', 'info');
        document.getElementById('resets-empty-state').style.display = 'block';
        document.getElementById('resets-table-container').style.display = 'none';
      }
    } else {
      showNotification(data.reason || 'Gagal mencari riwayat', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

function displayResetHistory(resets) {
  const tbody = document.getElementById('resets-tbody');
  const tableContainer = document.getElementById('resets-table-container');
  const emptyState = document.getElementById('resets-empty-state');

  tbody.innerHTML = '';

  if (!resets || resets.length === 0) {
    tableContainer.style.display = 'none';
    emptyState.style.display = 'block';
    return;
  }

  tableContainer.style.display = 'block';
  emptyState.style.display = 'none';

  resets.forEach(function(resetInfo) {
    const now = Date.now();
    const cooldownPeriod = 3 * 24 * 60 * 60 * 1000;
    const lastReset = resetInfo.lastReset;
    let cooldownStatus = 'Tidak aktif';
    let cooldownTime = '';

    if (lastReset) {
      const timeSinceReset = now - lastReset;
      const remainingCooldown = cooldownPeriod - timeSinceReset;

      if (remainingCooldown > 0) {
        const days = Math.floor(remainingCooldown / (24 * 60 * 60 * 1000));
        const hours = Math.floor((remainingCooldown % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000));
        cooldownStatus = '<span style="color: #f59e0b;">Cooldown aktif</span>';
        cooldownTime = \`\${days}h \${hours}j tersisa\`;
      } else {
        cooldownStatus = '<span style="color: #10b981;">Bisa reset</span>';
        cooldownTime = 'Siap';
      }
    }

    // Format history
    let historyHtml = '<div style="max-height: 150px; overflow-y: auto; font-size: 0.8rem;">';
    if (resetInfo.history && resetInfo.history.length > 0) {
      resetInfo.history.forEach((hist, index) => {
        const date = new Date(hist.timestamp).toLocaleString('id-ID');
        historyHtml += \`<div style="margin-bottom: 5px; padding: 5px; background: rgba(255,255,255,0.05); border-radius: 4px;">
          <strong>#\${resetInfo.history.length - index}</strong> - \${date}
          <div style="font-size: 0.75rem; color: var(--dark-4);">HWID: \${hist.oldHwid ? hist.oldHwid.substring(0, 8) + '...' : 'Tidak ada'}</div>
        </div>\`;
      });
    } else {
      historyHtml += '<div style="color: var(--dark-4);">Belum ada detail</div>';
    }
    historyHtml += '</div>';

    const row = document.createElement('tr');

    row.innerHTML = '<td>' +
                    '<div style="font-family: monospace; font-size: 0.85rem;">' + 
                    resetInfo.keyHash.substring(0, 12) + '...' + 
                    '</div></td>' +
                    '<td>' + (resetInfo.username || '<em>Tidak ada</em>') + '</td>' +
                    '<td><span style="font-weight: 700; font-size: 1.1rem;">' + (resetInfo.resetCount || 0) + '</span></td>' +
                    '<td>' + (lastReset ? new Date(lastReset).toLocaleString('id-ID') : 'Belum pernah') + '</td>' +
                    '<td>' + cooldownStatus + '<br><small>' + cooldownTime + '</small></td>' +
                    '<td>' + historyHtml + '</td>';

    tbody.appendChild(row);
  });

  // Tambahkan animasi untuk setiap row
  tbody.querySelectorAll('tr').forEach((row, index) => {
    row.style.animationDelay = (index * 0.05) + 's';
    row.classList.add('animate__animated', 'animate__fadeInUp');
  });
}

// Key Management Functions
async function copyToClipboard(text, buttonElement) {
  try {
    await navigator.clipboard.writeText(text);
    const originalContent = buttonElement.innerHTML;
    buttonElement.innerHTML = '<i class="fas fa-check"></i> Tersalin!';
    buttonElement.className = 'btn btn-sm btn-success';
    showNotification('Key berhasil disalin ke clipboard!', 'success');

    setTimeout(function() {
      buttonElement.innerHTML = originalContent;
    }, 2000);
  } catch (err) {
    showNotification('Gagal menyalin key: ' + err.message, 'error');
  }
}

async function resetHwid(hashed) {
  const adm = document.getElementById('adm-manage').value;
  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  if (!confirm('Yakin ingin mereset HWID untuk key ini? (Admin Reset)')) return;

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memproses...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/reset-hwid', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      },
      body: JSON.stringify({ hashed: hashed })
    });

    const data = await res.json();
    document.getElementById('out').textContent = JSON.stringify(data, null, 2);

    if (data.ok) {
      showNotification('HWID berhasil direset (Admin)', 'success');
      loadKeys(); // Refresh the list
    } else {
      showNotification(data.reason || 'Gagal mereset HWID', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

async function toggleKey(hashed, currentState) {
  const adm = document.getElementById('adm-manage').value;
  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  const action = currentState ? 'menonaktifkan' : 'mengaktifkan';
  if (!confirm('Yakin ingin ' + action + ' key ini?')) return;

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memproses...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/toggle-key', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      },
      body: JSON.stringify({ hashed: hashed, active: !currentState })
    });

    const data = await res.json();
    document.getElementById('out').textContent = JSON.stringify(data, null, 2);

    if (data.ok) {
      showNotification('Key berhasil ' + (!currentState ? 'diaktifkan' : 'dinonaktifkan'), 'success');
      loadKeys(); // Refresh the list
    } else {
      showNotification(data.reason || 'Gagal mengubah status key', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
    document.getElementById('out').textContent = 'Error: ' + error.message;
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

// Statistics
async function loadStats() {
  const adm = document.getElementById('adm-stats').value;
  if (!adm) {
    showNotification('Masukkan Admin Token!', 'error');
    return;
  }

  const btn = event ? event.target : null;
  if (btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memuat...';
    btn.disabled = true;
  }

  try {
    const res = await fetch(ADMIN_PATH + '/keys', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-admin-token': adm
      }
    });

    const data = await res.json();
    if (data.ok && data.keys) {
      displayKeys(data.keys); // Reuse displayKeys to update stats
      showNotification('Statistik berhasil dimuat', 'success');
    } else {
      showNotification(data.reason || 'Gagal memuat statistik', 'error');
    }
  } catch (error) {
    showNotification('Terjadi kesalahan: ' + error.message, 'error');
  } finally {
    if (btn) {
      btn.innerHTML = originalText;
      btn.disabled = false;
    }
  }
}

// Refresh key list without loading animation
function refreshKeyList() {
  if (document.getElementById('adm-manage').value) {
    loadKeys();
  } else {
    showNotification('Masukkan Admin Token terlebih dahulu', 'error');
  }
}

// Initialize with some data if available
window.addEventListener('load', function() {
  console.log('Admin Panel Loaded');
});
</script>

</body>
</html>`;

  res.send(html);
});

// ==== START SERVER ====
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));