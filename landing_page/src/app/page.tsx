"use client";

import React, { useRef, useState, useEffect } from "react";
import { motion, useScroll, useTransform, AnimatePresence } from "framer-motion";
import gsap from "gsap";
import { 
  Download, 
  Github, 
  Fingerprint, 
  Database, 
  TrendingUp, 
  Scale, 
  Target, 
  Coins, 
  Lock, 
  ArrowRight,
  TrendingDown,
  Calendar,
  Sparkles,
  Compass,
  CheckCircle2,
  Gem,
  ExternalLink,
  ShieldCheck,
  ChevronRight,
  Heart,
  Wallet,
  Globe,
  Linkedin,
  Twitter,
  Instagram
} from "lucide-react";
import Link from "next/link";

export default function Home() {
  const containerRef = useRef<HTMLDivElement>(null);
  const heroRef = useRef<HTMLDivElement>(null);
  const [activeShowcase, setActiveShowcase] = useState("dashboard");

  // Wealth Simulator State
  const [simLiquid, setSimLiquid] = useState(500000);
  const [simInvest, setSimInvest] = useState(1200000);
  const [simLiabilities, setSimLiabilities] = useState(250000);

  const simNetWorth = simLiquid + simInvest - simLiabilities;

  const formatRupees = (value: number) => {
    if (value >= 10000000) {
      return `₹${(value / 10000000).toFixed(2)} Cr`;
    }
    if (value >= 100000) {
      return `₹${(value / 100000).toFixed(2)} Lakh`;
    }
    if (value >= 1000) {
      return `₹${(value / 1000).toFixed(0)}K`;
    }
    return `₹${value}`;
  };

  const getMilestoneInfo = (netWorth: number) => {
    if (netWorth <= 0) {
      return {
        name: "Debt Alert",
        desc: "Liabilities exceed your combined cash and investments.",
        icon: "⚠️",
        color: "text-red-400 border-red-500/30 bg-red-950/20",
        badgeGlow: "shadow-[0_0_30px_rgba(239,68,68,0.2)]",
        svgPath: (
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        )
      };
    }
    if (netWorth < 50000) {
      return {
        name: "Base Sandbox",
        desc: "Starting tracking state. Focus on building initial reserve.",
        icon: "🌱",
        color: "text-slate-400 border-slate-500/20 bg-slate-900/40",
        badgeGlow: "shadow-[0_0_20px_rgba(148,163,184,0.15)]",
        svgPath: (
          <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" strokeWidth="2" />
        )
      };
    }
    if (netWorth < 250000) {
      return {
        name: "₹50K Milestone",
        desc: "Level 1: Bronze Octahedron unlocked. Liquid reserves active.",
        icon: "🥉",
        color: "text-amber-600 border-amber-600/30 bg-amber-950/10",
        badgeGlow: "shadow-[0_0_30px_rgba(217,119,6,0.25)]",
        svgPath: (
          <polygon points="12 2, 22 12, 12 22, 2 12" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        )
      };
    }
    if (netWorth < 1000000) {
      return {
        name: "₹2.5L Milestone",
        desc: "Level 2: Silver Hexagonal Double Pyramid unlocked. Debt balanced.",
        icon: "🥈",
        color: "text-slate-300 border-slate-300/30 bg-slate-800/10",
        badgeGlow: "shadow-[0_0_40px_rgba(203,213,225,0.3)]",
        svgPath: (
          <polygon points="12 2, 20 8, 20 16, 12 22, 4 16, 4 8" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        )
      };
    }
    if (netWorth < 2500000) {
      return {
        name: "₹10L Milestone",
        desc: "Level 3: Gold Decahedron unlocked. Wealth builder status achieved.",
        icon: "🥇",
        color: "text-amber-400 border-amber-400/30 bg-amber-900/15",
        badgeGlow: "shadow-[0_0_55px_rgba(251,191,36,0.4)]",
        svgPath: (
          <polygon points="12 2, 18 6, 22 12, 18 18, 12 22, 6 18, 2 12, 6 6" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        )
      };
    }
    return {
      name: "₹25L Milestone",
      desc: "Level 4: Diamond Crystal unlocked. High capital diversification.",
      icon: "💎",
      color: "text-accent border-accent/30 bg-[#7C4DFF]/10",
      badgeGlow: "shadow-[0_0_70px_rgba(124,77,255,0.5)]",
      svgPath: (
        <polygon points="12 2, 21 9, 17 21, 7 21, 3 9" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      )
    };
  };

  // Parallax / Scroll Animations
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"]
  });

  const heroScale = useTransform(scrollYProgress, [0, 0.2], [1, 0.95]);
  const heroOpacity = useTransform(scrollYProgress, [0, 0.15], [1, 0]);

  // Magnetic Button Effect helper
  const handleMagneticMove = (e: React.MouseEvent<HTMLAnchorElement>) => {
    const btn = e.currentTarget;
    const rect = btn.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;
    
    gsap.to(btn, {
      x: x * 0.3,
      y: y * 0.3,
      duration: 0.3,
      ease: "power2.out"
    });
  };

  const handleMagneticLeave = (e: React.MouseEvent<HTMLAnchorElement>) => {
    gsap.to(e.currentTarget, {
      x: 0,
      y: 0,
      duration: 0.5,
      ease: "elastic.out(1, 0.3)"
    });
  };

  // Interactive Glow coordinates
  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const card = e.currentTarget;
    const rect = card.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    card.style.setProperty("--mouse-x", `${x}px`);
    card.style.setProperty("--mouse-y", `${y}px`);
  };

  return (
    <div ref={containerRef} className="bg-[#050507] text-[#f4f4f6] min-h-screen font-sans overflow-x-hidden flex flex-col justify-between selection:bg-primary/30 selection:text-white">
      
      {/* 1. Header/Navbar */}
      <motion.header
        initial={{ y: -80, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="fixed top-6 left-0 right-0 z-50 px-6"
      >
        <div className="max-w-5xl mx-auto glass-panel px-6 py-3 border border-white/5 bg-[#0B0B0F]/40 backdrop-blur-xl rounded-full flex justify-between items-center shadow-[0_10px_30px_rgba(0,0,0,0.5)]">
          <a href="#" className="flex items-center gap-3">
            <img 
              src="/images/logo_mark.png" 
              alt="Worth Logo" 
              className="w-7 h-7 object-contain"
            />
            <span className="font-extrabold text-sm tracking-widest text-white">WORTH</span>
          </a>

          <nav className="hidden lg:flex items-center gap-8 text-xs font-semibold tracking-wider text-foreground/70">
            <a href="#features" className="hover:text-white transition-colors">OS CAPABILITIES</a>
            <a href="#simulator" className="hover:text-white transition-colors">CALIBRATOR</a>
            <a href="#showcase" className="hover:text-white transition-colors">SHOWCASE</a>
            <a href="#modules" className="hover:text-white transition-colors">MODULES</a>
            <a href="#timeline" className="hover:text-white transition-colors">TIMELINE</a>
          </nav>

          <div className="flex items-center gap-4">
            <a
              href="https://github.com/alokkumar2510/Worth"
              target="_blank"
              rel="noopener noreferrer"
              className="text-foreground/50 hover:text-white transition-colors"
              aria-label="GitHub Repository"
            >
              <Github className="w-5 h-5" />
            </a>
            <a
              href="https://github.com/alokkumar2510/Worth/releases/download/v1.7.0/app-release.apk"
              onMouseMove={handleMagneticMove}
              onMouseLeave={handleMagneticLeave}
              className="hidden sm:flex items-center gap-1.5 bg-[#7C4DFF] hover:bg-[#673AB7] text-white text-xs font-bold px-4 py-2.5 rounded-full transition-all duration-300 shadow-[0_4px_20px_rgba(124,77,255,0.4)]"
            >
              DOWNLOAD APK
              <ArrowRight className="w-3.5 h-3.5" />
            </a>
          </div>
        </div>
      </motion.header>

      {/* 2. Hero Section */}
      <motion.section 
        ref={heroRef}
        style={{ scale: heroScale, opacity: heroOpacity }}
        className="relative min-h-screen flex flex-col justify-center items-center pt-32 pb-20 px-6 text-center grid-bg overflow-hidden"
      >
        {/* Extreme Mesh Background */}
        <div className="absolute inset-0 z-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[700px] h-[700px] bg-[#7C4DFF]/15 rounded-full blur-[140px]" />
          <div className="absolute bottom-1/4 left-1/4 w-[400px] h-[400px] bg-[#A78BFA]/10 rounded-full blur-[120px]" />
        </div>

        <div className="relative z-10 max-w-5xl mx-auto flex flex-col items-center">
          
          {/* Centered Massive Logo and Text Branding */}
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="flex flex-col items-center gap-4 mb-8"
          >
            <div className="w-24 h-24 md:w-32 md:h-32 relative flex items-center justify-center p-1 rounded-3xl bg-white/5 border border-white/10 shadow-[0_20px_50px_rgba(124,77,255,0.2)] backdrop-blur-md">
              <img 
                src="/images/logo_mark.png" 
                alt="Worth Logo" 
                className="w-full h-full object-contain p-2"
              />
              <div className="absolute inset-0 bg-primary/20 blur-xl -z-10 rounded-3xl animate-pulse" />
            </div>
            {/* Spaced Text Branding */}
            <span className="text-[10px] md:text-xs font-mono font-bold tracking-[0.6em] text-white/50 uppercase select-none translate-x-[0.3em]">
              W O R T H &nbsp; O P E R A T I N G &nbsp; S Y S T E M
            </span>
          </motion.div>

          {/* Massive Typography */}
          <motion.h1
            initial={{ y: 40, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
            className="text-[64px] sm:text-[90px] md:text-[120px] font-black tracking-tight leading-[0.9] text-white select-none mb-10"
          >
            Know What <br />
            <span className="text-gradient-purple">You&apos;re Worth.</span>
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className="text-base sm:text-xl text-foreground/50 max-w-xl leading-relaxed mb-12"
          >
            A private, local-first personal wealth operating system. Track aggregate assets, liabilities, investments, and milestone achievements.
          </motion.p>

          {/* CTA Group */}
          <motion.div
            initial={{ y: 15, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
            className="flex flex-col sm:flex-row items-center gap-6 justify-center w-full max-w-sm sm:max-w-none"
          >
            <a
              href="https://github.com/alokkumar2510/Worth/releases/download/v1.7.0/app-release.apk"
              onMouseMove={handleMagneticMove}
              onMouseLeave={handleMagneticLeave}
              className="w-full sm:w-auto flex items-center justify-center gap-2.5 bg-white text-black hover:bg-[#A78BFA] hover:text-black font-bold text-sm px-8 py-5 rounded-full transition-all duration-300 shadow-[0_10px_35px_rgba(255,255,255,0.15)] hover:scale-105"
            >
              <Download className="w-5 h-5" />
              DOWNLOAD APK
            </a>
            <a
              href="https://github.com/alokkumar2510/Worth/releases"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto flex items-center justify-center gap-2 bg-[#0B0B0F]/60 border border-white/10 hover:border-white/25 hover:bg-white/5 text-white font-bold text-sm px-8 py-5 rounded-full transition-all duration-300 backdrop-blur-md"
            >
              <Github className="w-5 h-5 text-accent" />
              VIEW RELEASES
            </a>
          </motion.div>

          {/* Floating glass microcards */}
          <motion.div
            animate={{ y: [0, -15, 0], rotate: [0, 1, 0] }}
            transition={{ repeat: Infinity, duration: 6, ease: "easeInOut" }}
            className="absolute left-[3%] top-[30%] hidden xl:flex items-center gap-3 p-4 glass-panel border border-emerald-500/10 bg-[#0B0B0F]/50 backdrop-blur-md shadow-[0_15px_30px_-5px_rgba(16,185,129,0.05)] z-20 max-w-[200px] text-left select-none"
          >
            <div className="w-8 h-8 rounded-lg bg-emerald-500/10 flex items-center justify-center text-emerald-400 font-bold">₹</div>
            <div>
              <div className="text-[10px] text-white/40 font-mono uppercase">Liquid Cash</div>
              <div className="text-sm font-black text-white font-mono">₹4.85 Lakh</div>
              <div className="text-[9px] text-emerald-400 font-mono mt-0.5 font-bold">Stable Balance</div>
            </div>
          </motion.div>

          <motion.div
            animate={{ y: [0, 12, 0], rotate: [0, -1, 0] }}
            transition={{ repeat: Infinity, duration: 7, ease: "easeInOut", delay: 0.4 }}
            className="absolute right-[3%] top-[35%] hidden xl:flex items-center gap-3 p-4 glass-panel border border-[#7C4DFF]/15 bg-[#0B0B0F]/50 backdrop-blur-md shadow-[0_15px_30px_-5px_rgba(124,77,255,0.08)] z-20 max-w-[220px] text-left select-none"
          >
            <div className="w-8 h-8 rounded-lg bg-[#7C4DFF]/10 flex items-center justify-center text-[#A78BFA]">💎</div>
            <div>
              <div className="text-[10px] text-white/40 font-mono uppercase">Milestone Track</div>
              <div className="text-xs font-black text-white">₹10L Unlocked</div>
              <div className="text-[9px] text-[#A78BFA] font-mono mt-0.5 font-bold font-extrabold">Gold Decahedron</div>
            </div>
          </motion.div>

          <motion.div
            animate={{ y: [0, -18, 0], rotate: [0, -1.5, 0] }}
            transition={{ repeat: Infinity, duration: 8, ease: "easeInOut", delay: 0.2 }}
            className="absolute left-[5%] top-[65%] hidden xl:flex items-center gap-3 p-4 glass-panel border border-[#00B0FF]/10 bg-[#0B0B0F]/50 backdrop-blur-md shadow-[0_15px_30px_-5px_rgba(0,176,255,0.06)] z-20 max-w-[210px] text-left select-none"
          >
            <div className="w-8 h-8 rounded-lg bg-blue-500/10 flex items-center justify-center text-blue-400">📈</div>
            <div>
              <div className="text-[10px] text-white/40 font-mono uppercase">Investments</div>
              <div className="text-sm font-black text-white font-mono">₹18.20 Lakh</div>
              <div className="text-[9px] text-emerald-400 font-mono mt-0.5 font-bold">+12.4% Annual Yield</div>
            </div>
          </motion.div>

          <motion.div
            animate={{ y: [0, 16, 0], rotate: [0, 1.2, 0] }}
            transition={{ repeat: Infinity, duration: 6.5, ease: "easeInOut", delay: 0.6 }}
            className="absolute right-[5%] top-[60%] hidden xl:flex items-center gap-3 p-4 glass-panel border border-red-500/10 bg-[#0B0B0F]/50 backdrop-blur-md shadow-[0_15px_30px_-5px_rgba(239,68,68,0.05)] z-20 max-w-[220px] text-left select-none"
          >
            <div className="w-8 h-8 rounded-lg bg-red-500/10 flex items-center justify-center text-red-400">📉</div>
            <div>
              <div className="text-[10px] text-white/40 font-mono uppercase">Liabilities</div>
              <div className="text-sm font-black text-white font-mono font-bold">₹3.10 Lakh</div>
              <div className="text-[9px] text-red-400 font-mono mt-0.5 font-bold">Reduced by ₹45K</div>
            </div>
          </motion.div>
        </div>
      </motion.section>

      {/* 3. Wealth Operating System (Section 2) */}
      <section id="features" className="py-32 bg-[#050507] relative overflow-hidden">
        <div className="max-w-5xl mx-auto px-6 relative z-10">
          
          <div className="text-center max-w-2xl mx-auto mb-24">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              System Architecture
            </span>
            <h2 className="text-4xl md:text-5xl font-black text-white mt-6 mb-6 tracking-tight leading-tight">
              An Operating System <br />for Wealth.
            </h2>
            <p className="text-base md:text-lg text-foreground/50 leading-relaxed">
              No budgeting bloat. Worth is designed from scratch around direct calculations, balance histories, and milestone calibrations.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Feature card 1: Derived Calculations */}
            <div
              onMouseMove={handleMouseMove}
              className="glow-card glass-panel p-8 flex flex-col justify-between items-start border border-white/5 bg-[#0B0B0F]/30 cursor-default"
            >
              <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-primary mb-8">
                <Database className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white tracking-wider mb-2">Derived Ledgers</h3>
                <p className="text-xs text-foreground/50 leading-relaxed">
                  Balances are computed dynamically as base allocations plus manual adjustments, retaining clear audit logs.
                </p>
              </div>
            </div>

            {/* Feature card 2: Security Lock */}
            <div
              onMouseMove={handleMouseMove}
              className="glow-card glass-panel p-8 flex flex-col justify-between items-start border border-white/5 bg-[#0B0B0F]/30 cursor-default"
            >
              <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-accent mb-8">
                <Fingerprint className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white tracking-wider mb-2">Secure Sandbox</h3>
                <p className="text-xs text-foreground/50 leading-relaxed">
                  Authentication is restricted locally. All secure database operations execute within strict Keystore key wraps.
                </p>
              </div>
            </div>

            {/* Feature card 3: Local Caching */}
            <div
              onMouseMove={handleMouseMove}
              className="glow-card glass-panel p-8 flex flex-col justify-between items-start border border-white/5 bg-[#0B0B0F]/30 cursor-default"
            >
              <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-amber-500 mb-8">
                <Lock className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white tracking-wider mb-2">Private Sync</h3>
                <p className="text-xs text-foreground/50 leading-relaxed">
                  All databases reside on-device. Back up conflict-resolved snapshots directly to your personal Firestore bucket.
                </p>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 2.5 Wealth Calibration Sandbox (Section 2.5) */}
      <section id="simulator" className="py-32 bg-[#050507] border-t border-b border-white/5 relative overflow-hidden">
        {/* Glow Effects */}
        <div className="absolute inset-0 z-0 pointer-events-none">
          <div className="absolute top-1/2 left-1/3 -translate-y-1/2 w-[500px] h-[500px] bg-[#7C4DFF]/5 rounded-full blur-[120px]" />
          <div className="absolute top-1/2 right-1/4 -translate-y-1/2 w-[400px] h-[400px] bg-emerald-500/5 rounded-full blur-[100px]" />
        </div>

        <div className="max-w-5xl mx-auto px-6 relative z-10">
          
          <div className="text-center max-w-2xl mx-auto mb-20">
            <span className="text-xs font-bold text-emerald-400 tracking-widest font-mono uppercase bg-emerald-400/10 border border-emerald-400/20 px-3 py-1 rounded-full">
              Interactive Calibration
            </span>
            <h2 className="text-4xl md:text-5xl font-black text-white mt-6 mb-6 tracking-tight leading-tight">
              Calibrate Your Ledger.
            </h2>
            <p className="text-base text-foreground/50 leading-relaxed">
              Use the sliders below to simulate assets, liabilities, and investment allocations. Watch the OS calculate your aggregate Net Worth and unlock milestone crystal badges.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            {/* Control Sliders */}
            <div className="lg:col-span-6 space-y-8 glass-panel p-8 md:p-10 border border-white/5 bg-[#0B0B0F]/30 backdrop-blur-md rounded-3xl">
              <h3 className="text-lg font-black text-white mb-6 flex items-center gap-2">
                <span>🎛️</span> Capital Controllers
              </h3>

              {/* Slider 1: Liquid Assets */}
              <div className="space-y-3 text-left">
                <div className="flex justify-between items-center text-xs">
                  <span className="font-extrabold text-white/70 tracking-wider">LIQUID CASH & DEPOSITS</span>
                  <span className="font-mono text-emerald-400 font-bold">{formatRupees(simLiquid)}</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="2000000"
                  step="25000"
                  value={simLiquid}
                  onChange={(e) => setSimLiquid(Number(e.target.value))}
                  className="w-full h-1.5 rounded-full appearance-none bg-white/5 cursor-pointer accent-[#7C4DFF] focus:outline-none"
                />
                <div className="flex justify-between text-[10px] text-white/30 font-mono">
                  <span>₹0</span>
                  <span>₹20 Lakh</span>
                </div>
              </div>

              {/* Slider 2: Invested Capital */}
              <div className="space-y-3 text-left">
                <div className="flex justify-between items-center text-xs">
                  <span className="font-extrabold text-white/70 tracking-wider">INVESTMENTS (EQUITIES/GOLD)</span>
                  <span className="font-mono text-accent font-bold">{formatRupees(simInvest)}</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="4000000"
                  step="50000"
                  value={simInvest}
                  onChange={(e) => setSimInvest(Number(e.target.value))}
                  className="w-full h-1.5 rounded-full appearance-none bg-white/5 cursor-pointer accent-[#7C4DFF] focus:outline-none"
                />
                <div className="flex justify-between text-[10px] text-white/30 font-mono">
                  <span>₹0</span>
                  <span>₹40 Lakh</span>
                </div>
              </div>

              {/* Slider 3: Liabilities */}
              <div className="space-y-3 text-left">
                <div className="flex justify-between items-center text-xs">
                  <span className="font-extrabold text-white/70 tracking-wider">ACTIVE LIABILITIES / DEBTS</span>
                  <span className="font-mono text-red-400 font-bold">{formatRupees(simLiabilities)}</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="1500000"
                  step="25000"
                  value={simLiabilities}
                  onChange={(e) => setSimLiabilities(Number(e.target.value))}
                  className="w-full h-1.5 rounded-full appearance-none bg-white/5 cursor-pointer accent-red-500 focus:outline-none"
                />
                <div className="flex justify-between text-[10px] text-white/30 font-mono">
                  <span>₹0</span>
                  <span>₹15 Lakh</span>
                </div>
              </div>
            </div>

            {/* Calculations & Badge Display */}
            <div className="lg:col-span-6 flex flex-col justify-center items-center">
              {(() => {
                const info = getMilestoneInfo(simNetWorth);
                return (
                  <div className={`w-full glass-panel p-8 border ${info.color} backdrop-blur-md rounded-3xl flex flex-col items-center justify-between text-center relative transition-all duration-500 ${info.badgeGlow}`}>
                    <span className="text-[10px] font-mono tracking-widest text-white/40 uppercase mb-4">CALCULATED METRIC</span>
                    
                    {/* Animated Counter */}
                    <div className="mb-4">
                      <div className="text-sm text-foreground/50 mb-1 font-mono uppercase tracking-widest">NET WORTH TODAY</div>
                      <div className="text-4xl md:text-5xl font-black text-white font-mono tracking-tight">
                        {formatRupees(simNetWorth)}
                      </div>
                    </div>

                    {/* Progress Bar of allocations */}
                    <div className="w-full max-w-sm h-2.5 bg-white/5 border border-white/5 rounded-full mb-8 overflow-hidden flex">
                      {simNetWorth > 0 ? (
                        <>
                          <div 
                            style={{ width: `${Math.max(5, (simLiquid / (simLiquid + simInvest)) * 100)}%` }} 
                            className="h-full bg-emerald-400" 
                            title="Liquid Assets"
                          />
                          <div 
                            style={{ width: `${Math.max(5, (simInvest / (simLiquid + simInvest)) * 100)}%` }} 
                            className="h-full bg-[#7C4DFF]" 
                            title="Investments"
                          />
                        </>
                      ) : (
                        <div className="w-full h-full bg-red-500" title="Negative Net Worth" />
                      )}
                    </div>

                    {/* Milestone Crystal Badge Display */}
                    <div className="w-24 h-24 mb-6 relative flex items-center justify-center text-white">
                      <svg className="w-full h-full transform animate-[spin_20s_linear_infinite]" viewBox="0 0 24 24">
                        {info.svgPath}
                      </svg>
                      <div className="absolute inset-0 flex items-center justify-center text-2xl filter drop-shadow-[0_0_8px_rgba(255,255,255,0.4)]">
                        {info.icon}
                      </div>
                    </div>

                    {/* Milestone details */}
                    <div>
                      <h4 className="font-extrabold text-lg text-white mb-2">{info.name}</h4>
                      <p className="text-xs text-foreground/50 max-w-sm leading-relaxed">{info.desc}</p>
                    </div>
                  </div>
                );
              })()}
            </div>
          </div>

        </div>
      </section>

      {/* 4. Interactive Product Showcase (Section 3) */}
      <section id="showcase" className="py-32 bg-[#050507] relative overflow-hidden grid-bg">
        <div className="max-w-6xl mx-auto px-6 relative z-10">
          
          <div className="text-center max-w-2xl mx-auto mb-20">
            <span className="text-xs font-bold text-accent tracking-widest font-mono uppercase bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
              Interactive Showcase
            </span>
            <h2 className="text-4xl md:text-5xl font-black text-white mt-6 mb-6 tracking-tight">
              Genuine UI Interface.
            </h2>
            <p className="text-base text-foreground/50 leading-relaxed">
              Below are raw, uncompressed screenshots of the Worth interface. Tap below to preview actual layouts.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            {/* Showcase Selector tabs */}
            <div className="lg:col-span-4 flex flex-col gap-3">
              {[
                { id: "dashboard", label: "Dashboard", desc: "Consolidated financial ledger featuring Next Milestone cards and activity updates.", icon: Compass },
                { id: "portfolio", label: "Asset Adjustments", desc: "Modify balances directly with reason keys and transaction logs.", icon: TrendingUp },
                { id: "timeline", label: "Activity Timeline", desc: "Premium wallet-inspired transactions history timeline with search filters.", icon: Coins },
                { id: "reports", label: "Intelligence Reports", desc: "Trend analyses detailing performance graphs and monthly growths.", icon: Target }
              ].map((item) => {
                const Icon = item.icon;
                const isActive = activeShowcase === item.id;
                return (
                  <button
                    key={item.id}
                    onClick={() => setActiveShowcase(item.id)}
                    className={`flex items-start gap-4 p-4 rounded-2xl text-left border transition-all duration-300 ${
                      isActive 
                        ? "bg-white/5 border-primary text-white shadow-xl shadow-primary/5" 
                        : "bg-transparent border-transparent text-foreground/40 hover:text-white hover:bg-white/5"
                    }`}
                  >
                    <div className={`p-2 rounded-lg border shrink-0 mt-0.5 ${isActive ? "bg-primary/20 border-primary text-accent" : "bg-white/5 border-white/5 text-foreground/30"}`}>
                      <Icon className="w-4 h-4" />
                    </div>
                    <div>
                      <h4 className="font-extrabold text-sm tracking-wide text-white">{item.label}</h4>
                      <p className="text-xs text-foreground/50 mt-1 leading-relaxed">{item.desc}</p>
                    </div>
                  </button>
                );
              })}
            </div>

            {/* Showcase 3D Viewport */}
            <div className="lg:col-span-8 flex justify-center items-center">
              <div className="relative w-full max-w-[380px] aspect-[9/18.5] rounded-[48px] bg-[#050507] border-[8px] border-white/10 shadow-[0_25px_60px_-15px_rgba(124,77,255,0.3)] p-1.5 overflow-hidden perspective-1000 rotate-x-6 rotate-y-[-6deg] hover:rotate-x-0 hover:rotate-y-0 transition-transform duration-700">
                
                {/* Camera notch */}
                <div className="absolute top-4 left-1/2 -translate-x-1/2 w-28 h-6 bg-[#050507] rounded-full border border-white/5 z-20 flex items-center justify-center">
                  <span className="w-2 h-2 rounded-full bg-blue-900/60 mr-2" />
                  <span className="w-1.5 h-1.5 rounded-full bg-slate-900" />
                </div>

                {/* Display Area */}
                <div className="w-full h-full rounded-[38px] bg-[#050507] overflow-hidden relative">
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={activeShowcase}
                      initial={{ opacity: 0, scale: 0.95 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 0.95 }}
                      transition={{ duration: 0.3 }}
                      className="w-full h-full relative"
                    >
                      <img 
                        src={
                          activeShowcase === "dashboard" ? "/images/dashboard.png" :
                          activeShowcase === "portfolio" ? "/images/assets_dashboard_of_portfolio.png" :
                          activeShowcase === "timeline" ? "/images/transactions_overview.png" :
                          "/images/Finance_report_dashboard.png"
                        }
                        alt="Worth App View"
                        className="w-full h-full object-cover"
                      />
                    </motion.div>
                  </AnimatePresence>
                </div>

                {/* Home Indicator */}
                <div className="absolute bottom-2.5 left-1/2 -translate-x-1/2 w-24 h-1 bg-white/20 rounded-full z-20" />
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 5. Why Worth: Floating Modules (Section 4) */}
      <section id="modules" className="py-32 bg-[#050507] relative overflow-hidden">
        <div className="max-w-5xl mx-auto px-6 relative z-10">
          
          <div className="text-center max-w-2xl mx-auto mb-24">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Pillar Modules
            </span>
            <h2 className="text-4xl md:text-5xl font-black text-white mt-6 mb-6 tracking-tight">
              A Complete Wealth Ledger.
            </h2>
            <p className="text-base text-foreground/50 leading-relaxed">
              Worth is partitioned into five distinct ledger modules to map every vector of your personal capitalization.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
            {[
              { title: "Assets", icon: Wallet, value: "₹24.5L", color: "text-primary border-primary/20" },
              { title: "Liabilities", icon: TrendingDown, value: "₹4.2L", color: "text-red-400 border-red-500/20" },
              { title: "Investments", icon: TrendingUp, value: "₹18.0L", color: "text-accent border-accent/20" },
              { title: "Receivables", icon: Coins, value: "₹1.5L", color: "text-emerald-400 border-emerald-500/20" },
              { title: "Goals", icon: Target, value: "₹5.0L", color: "text-amber-400 border-amber-500/20" }
            ].map((module, idx) => {
              const Icon = module.icon;
              return (
                <motion.div
                  key={module.title}
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: idx * 0.1 }}
                >
                  <div className={`glass-panel p-6 border ${module.color} bg-[#0B0B0F]/40 backdrop-blur-md rounded-2xl flex flex-col justify-between h-44 text-left`}>
                    <div className="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center text-white">
                      <Icon className="w-4 h-4" />
                    </div>
                    <div>
                      <span className="text-[10px] tracking-widest text-foreground/40 font-mono uppercase">MODULE</span>
                      <h4 className="font-extrabold text-sm text-white mt-1">{module.title}</h4>
                      <div className="text-base font-black text-white font-mono mt-2">{module.value}</div>
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </div>

        </div>
      </section>

      {/* 6. Wealth Timeline (Section 5) */}
      <section id="timeline" className="py-32 bg-[#050507] relative overflow-hidden grid-bg">
        <div className="max-w-5xl mx-auto px-6 relative z-10">
          
          <div className="text-center max-w-2xl mx-auto mb-24">
            <span className="text-xs font-bold text-accent tracking-widest font-mono uppercase bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
              Timeline Journey
            </span>
            <h2 className="text-4xl md:text-5xl font-black text-white mt-6 mb-6 tracking-tight">
              Track Milestones.
            </h2>
            <p className="text-base text-foreground/50 leading-relaxed">
              From zero net worth to target thresholds. Track and visualize your capital development checkpoints on a scroll-filled track.
            </p>
          </div>

          <div className="relative max-w-2xl mx-auto">
            {/* Center Track Line */}
            <div className="absolute left-6 top-4 bottom-4 w-[1px] bg-white/10" />
            <motion.div
              initial={{ height: 0 }}
              whileInView={{ height: "90%" }}
              viewport={{ once: true }}
              transition={{ duration: 1.5, ease: "easeInOut" }}
              className="absolute left-6 top-4 w-[1px] bg-gradient-to-b from-primary via-accent to-amber-500 shadow-[0_0_8px_rgba(124,77,255,0.4)]"
            />

            {/* Checkpoints */}
            <div className="space-y-16 pl-16">
              {[
                { title: "Started Tracking", amount: "₹0", desc: "Connect local bank balances and initialize cash ledgers on-device." },
                { title: "First Investment Logged", amount: "₹50K", desc: "Capitalized mutual funds and tracking market values." },
                { title: "₹100K Milestone", amount: "₹100K", desc: "Unlocked the first major milestone badge with a luxury dialog animation." },
                { title: "₹500K Milestone", amount: "₹500K", desc: "Allocation weights balance out liabilities, and net worth reports generate historical charts." },
                { title: "₹1M Milestone", amount: "₹10L", desc: "Premium crystal badges unlock in custom paint overlays to celebrate 1 Million." }
              ].map((item, idx) => (
                <div key={item.title} className="relative text-left">
                  {/* Glowing Node */}
                  <div className="absolute -left-[108px] top-1 flex items-center justify-center">
                    <span className="text-[10px] font-mono font-bold text-foreground/50 bg-[#050507] border border-white/10 px-2 py-0.5 rounded-full z-10">
                      {item.amount}
                    </span>
                  </div>
                  <div className="absolute -left-[54px] top-1.5 w-3.5 h-3.5 rounded-full bg-[#050507] border-2 border-white/20 z-10 flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                  </div>

                  <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5, delay: idx * 0.05 }}
                    className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/45 backdrop-blur-md"
                  >
                    <h4 className="font-extrabold text-sm text-white mb-2">{item.title}</h4>
                    <p className="text-xs text-foreground/50 leading-relaxed">{item.desc}</p>
                  </motion.div>
                </div>
              ))}
            </div>
          </div>

        </div>
      </section>

      {/* 7. Security (Section 6) */}
      <section className="py-32 bg-[#050507] relative overflow-hidden">
        <div className="max-w-5xl mx-auto px-6 relative z-10">
          
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">
            {/* Left: Giant biometric symbol */}
            <div className="lg:col-span-5 flex flex-col items-center lg:items-start text-center lg:text-left">
              <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full mb-6">
                Security Sandbox
              </span>
              <h2 className="text-4xl md:text-5xl font-black text-white mb-6 tracking-tight leading-tight">
                Secure. <br />On-Device.
              </h2>
              <p className="text-base text-foreground/50 leading-relaxed mb-8">
                Your data is stored strictly locally. Worth uses cryptographic PIN wrapping and biometric API checks.
              </p>

              <div className="relative w-36 h-36 rounded-[32px] bg-[#0B0B0F]/40 border border-white/5 flex items-center justify-center backdrop-blur-md shadow-2xl">
                <Fingerprint className="w-16 h-16 text-primary animate-pulse" />
              </div>
            </div>

            {/* Right: Spec cards */}
            <div className="lg:col-span-7 grid grid-cols-1 sm:grid-cols-2 gap-6">
              {[
                { title: "Biometric Route Guards", desc: "Routes are checked locally using Android security prompts, bypassing locked routes unless verified.", icon: Lock },
                { title: "Drift SQLite Storage", desc: "Balances, audit details, and transactions are committed locally into a SQLite sandbox.", icon: Database },
                { title: "Keystore Encryption", desc: "App pins and security authentication flags are encrypted inside device security keystores.", icon: ShieldCheck },
                { title: "Private Sync Controls", desc: "Sync is optional. Data transfers straight to your personal Firestore bucket via secured pipelines.", icon: Globe }
              ].map((spec) => {
                const Icon = spec.icon;
                return (
                  <div key={spec.title} className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/45 text-left">
                    <Icon className="w-5 h-5 text-accent mb-4" />
                    <h4 className="font-extrabold text-sm text-white mb-2">{spec.title}</h4>
                    <p className="text-xs text-foreground/50 leading-relaxed">{spec.desc}</p>
                  </div>
                );
              })}
            </div>
          </div>

        </div>
      </section>

      {/* 8. Download & CTA (Section 7) */}
      <section className="py-32 bg-[#050507] relative overflow-hidden grid-bg">
        <div className="max-w-4xl mx-auto px-6 relative z-10 text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.98 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="glass-panel p-12 md:p-20 border border-white/5 bg-[#0B0B0F]/65 backdrop-blur-xl rounded-[40px]"
          >
            <h2 className="text-4xl md:text-6xl font-black text-white mb-6 tracking-tight leading-none">
              Start Tracking.
            </h2>
            <p className="text-base sm:text-lg text-foreground/50 max-w-lg mx-auto mb-10 leading-relaxed">
              Download the release APK now and experience personal wealth intelligence command in dark luxury.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <a
                href="https://github.com/alokkumar2510/Worth/releases/download/v1.7.0/app-release.apk"
                onMouseMove={handleMagneticMove}
                onMouseLeave={handleMagneticLeave}
                className="w-full sm:w-auto flex items-center justify-center gap-2.5 bg-[#7C4DFF] hover:bg-[#673AB7] text-white text-sm font-bold px-8 py-5 rounded-full shadow-[0_6px_25px_rgba(124,77,255,0.4)]"
              >
                <Download className="w-5 h-5" />
                DOWNLOAD APK
              </a>
              <a
                href="https://github.com/alokkumar2510/Worth"
                target="_blank"
                rel="noopener noreferrer"
                className="w-full sm:w-auto flex items-center justify-center gap-2 bg-[#0B0B0F] border border-white/10 hover:border-white/20 text-white text-sm font-bold px-8 py-5 rounded-full"
              >
                <Github className="w-5 h-5 text-accent" />
                GITHUB CODEBASE
              </a>
            </div>

            <div className="text-[10px] text-foreground/30 font-mono mt-8">
              SHA-256: 7e8d9c... | Android 8.0+ Required
            </div>
          </motion.div>
        </div>
      </section>

      {/* 9. Founder spotlight */}
      <section className="py-20 bg-[#050507] border-t border-white/5">
        <div className="max-w-4xl mx-auto px-6">
          <div className="glass-panel p-8 md:p-12 border border-white/5 bg-[#0B0B0F]/45 backdrop-blur-md rounded-[32px] flex flex-col md:flex-row gap-8 items-center text-left">
            <div className="relative shrink-0">
              <div className="w-24 h-24 md:w-32 md:h-32 rounded-full bg-gradient-to-tr from-primary to-accent p-0.5 shadow-xl overflow-hidden">
                <img 
                  src="/images/founder.png" 
                  alt="Alok Kumar Sahu" 
                  className="w-full h-full rounded-full object-cover"
                />
              </div>
            </div>
            <div className="flex-grow">
              <h3 className="text-lg font-black text-white mb-1">Alok Kumar Sahu</h3>
              <span className="text-[10px] text-primary tracking-widest font-mono uppercase font-bold">FOUNDER & LEAD ARCHITECT</span>
              <p className="text-xs md:text-sm text-foreground/50 leading-relaxed mt-4 mb-6">
                &ldquo;Worth was built out of a simple frustration: budgeting apps are too micro-focused on small details, and automation breaks too easily. I wanted a luxury command center that focused entirely on net worth, milestone indicators, and privacy.&rdquo;
              </p>

              {/* Socials */}
              <div className="flex gap-3">
                {[
                  { url: "https://alokkumarsahu.in", icon: Globe, name: "Portfolio" },
                  { url: "https://github.com/alokkumar2510", icon: Github, name: "GitHub" },
                  { url: "https://www.linkedin.com/in/alok-kumar-sahu-7a7059370/", icon: Linkedin, name: "LinkedIn" },
                  { url: "https://x.com/alok_chintu", icon: Twitter, name: "X" },
                  { url: "https://instagram.com/alokkumar.in", icon: Instagram, name: "Instagram" }
                ].map((item) => {
                  const Icon = item.icon;
                  return (
                    <a
                      key={item.name}
                      href={item.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2 text-foreground/50 hover:text-white bg-white/5 border border-white/5 rounded-lg transition-transform duration-300 hover:scale-105"
                      title={item.name}
                      aria-label={item.name}
                    >
                      <Icon className="w-4 h-4" />
                    </a>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 10. Footer */}
      <footer className="bg-[#050507] border-t border-white/5 py-12">
        <div className="max-w-5xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-6">
          <div className="flex items-center gap-3">
            <img 
              src="/images/logo_mark.png" 
              alt="Worth Logo" 
              className="w-5 h-5 object-contain"
            />
            <span className="font-extrabold text-xs tracking-widest text-white">WORTH</span>
          </div>

          <div className="flex flex-wrap justify-center gap-6 text-xs text-foreground/40 font-mono">
            <Link href="/privacy" className="hover:text-white transition-colors">PRIVACY POLICY</Link>
            <Link href="/terms" className="hover:text-white transition-colors">TERMS OF SERVICE</Link>
            <a href="https://github.com/alokkumar2510/Worth" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">GITHUB</a>
          </div>

          <div className="text-[10px] text-foreground/30 font-mono flex items-center gap-1.5">
            <span>© {new Date().getFullYear()} Worth. Crafted by</span>
            <a href="https://alokkumarsahu.in" target="_blank" rel="noopener noreferrer" className="text-foreground/50 hover:text-white underline">Alok Kumar Sahu</a>
          </div>
        </div>
      </footer>

    </div>
  );
}
