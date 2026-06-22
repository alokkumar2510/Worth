"use client";

import React from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { 
  ArrowLeft, 
  Wallet, 
  TrendingUp, 
  TrendingDown, 
  Target, 
  Coins, 
  Lock, 
  Database, 
  Calendar, 
  Fingerprint, 
  School,
  QrCode,
  Sparkles,
  RefreshCw,
  BellRing,
  ShieldCheck
} from "lucide-react";

export default function FeaturesPage() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        duration: 0.5,
        ease: [0.16, 1, 0.3, 1] as any
      }
    }
  };

  const features = [
    {
      title: "Assets Tracking",
      desc: "Monitor cash, savings accounts, properties, and physical items. Track values dynamically over time with balance histories.",
      icon: Wallet,
      color: "text-purple-400 border-purple-500/10"
    },
    {
      title: "Liabilities Tracker",
      desc: "Log loans, credit card balances, and due bills. Monitor amortization rates and debt reduction strides.",
      icon: TrendingDown,
      color: "text-red-400 border-red-500/10"
    },
    {
      title: "Investments Dashboard",
      desc: "Organize stocks, mutual funds, gold, and fixed deposits. Integrates with systematic investment plan (SIP) reminders.",
      icon: TrendingUp,
      color: "text-indigo-400 border-indigo-500/10"
    },
    {
      title: "Receivables Hub",
      desc: "Track loans given to family, friends, or entities. Generates direct Scan-to-Pay UPI QR codes for easy settlements.",
      icon: Coins,
      color: "text-emerald-400 border-emerald-500/10"
    },
    {
      title: "Milestone Calibrator",
      desc: "Unlock custom geometric crystal milestone badges as your aggregate net worth reaches critical checkpoints.",
      icon: Target,
      color: "text-amber-400 border-amber-500/10"
    },
    {
      title: "Education Loan Center",
      desc: "Simulate EMI prepayments, disbursement dates, interest accrual moratoriums, and view a 10-year repayment forecast.",
      icon: School,
      color: "text-cyan-400 border-cyan-500/10"
    },
    {
      title: "Financial Calendar",
      desc: "Check due dates, check-in streaks, expected payouts, and SIP alarms on a premium interactive calendar interface.",
      icon: Calendar,
      color: "text-pink-400 border-pink-500/10"
    },
    {
      title: "QR Code Generator",
      desc: "Generate UPI-standard QR codes dynamically to request exact repayment sums directly from the receivables ledger.",
      icon: QrCode,
      color: "text-teal-400 border-teal-500/10"
    },
    {
      title: "Biometric Locks",
      desc: "Protect your database with Android biometric prompt controls. Safe against device intrusions and snooping.",
      icon: Fingerprint,
      color: "text-rose-400 border-rose-500/10"
    },
    {
      title: "Cloud Sync Option",
      desc: "Keep data local or back up snapshots to your private Firebase storage container. No intermediating servers.",
      icon: RefreshCw,
      color: "text-blue-400 border-blue-500/10"
    },
    {
      title: "Smart Notification Alerts",
      desc: "Custom notifications for SIP dates, expected receivables, check-in streaks, and local alarms.",
      icon: BellRing,
      color: "text-violet-400 border-violet-500/10"
    },
    {
      title: "On-Device SQLite Storage",
      desc: "All values, logs, and notes are committed locally into a highly efficient SQLite sandbox via Drift.",
      icon: Database,
      color: "text-emerald-500 border-emerald-500/10"
    }
  ];

  return (
    <div className="bg-[#050507] text-[#f4f4f6] min-h-screen font-sans flex flex-col justify-between selection:bg-primary/30 selection:text-white">
      
      {/* Header bar */}
      <header className="fixed top-0 left-0 right-0 bg-[#050507]/80 backdrop-blur-md border-b border-white/5 py-4 z-50">
        <div className="max-w-5xl mx-auto px-6 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-xs text-foreground/60 hover:text-white transition-colors uppercase tracking-wider font-mono">
            <ArrowLeft className="w-4 h-4" />
            Back to Home
          </Link>
          <div className="flex items-center gap-2">
            <span className="w-5 h-5 rounded bg-gradient-to-tr from-primary to-accent flex items-center justify-center text-[10px]">💎</span>
            <span className="font-semibold tracking-wider text-white text-xs">WORTH FEATURES</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/4 w-[600px] h-[600px] bg-primary/5 rounded-full blur-[140px]" />
          <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-accent/5 rounded-full blur-[120px]" />
        </div>

        <div className="max-w-5xl mx-auto relative z-10">
          
          {/* Hero Header */}
          <div className="text-center max-w-2xl mx-auto mb-20">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Full Overview
            </span>
            <h1 className="text-4xl md:text-6xl font-black text-white mt-6 mb-6 tracking-tight leading-none">
              Capabilities of <br />
              <span className="text-gradient-purple">Worth OS.</span>
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              Explore the modules, tools, and local security systems built directly into your private wealth operating system.
            </p>
          </div>

          {/* Features Grid */}
          <motion.div 
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {features.map((feat) => {
              const Icon = feat.icon;
              return (
                <motion.div
                  key={feat.title}
                  variants={itemVariants}
                  className={`glass-panel p-8 border ${feat.color} bg-[#0B0B0F]/30 flex flex-col justify-between items-start h-64 hover:scale-[1.02] transition-transform duration-300`}
                >
                  <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-white">
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-lg font-black text-white tracking-wider mb-2">{feat.title}</h3>
                    <p className="text-xs text-foreground/50 leading-relaxed">{feat.desc}</p>
                  </div>
                </motion.div>
              );
            })}
          </motion.div>

          {/* High Fidelity Screenshots Feature Callout */}
          <div className="mt-32 border-t border-white/5 pt-24">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
              <div>
                <span className="text-xs font-bold text-accent tracking-widest font-mono uppercase bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
                  Visual Fidelity
                </span>
                <h2 className="text-3xl md:text-4xl font-extrabold text-white mt-6 mb-6 tracking-tight">
                  Hand-crafted interface.
                </h2>
                <p className="text-sm text-foreground/50 leading-relaxed mb-6">
                  Worth is built using custom glassmorphic panels, uniform iOS-style bouncing scroll physics, and low-latency particle background engines. Every layout transition is smoothed out using custom cubic-bezier deceleration curves.
                </p>
                <div className="space-y-4">
                  <div className="flex items-center gap-3 text-xs text-foreground/70">
                    <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0" />
                    <span>60 FPS performance boundaries</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-foreground/70">
                    <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0" />
                    <span>Consistent dark theme, premium assets</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-foreground/70">
                    <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0" />
                    <span>Fluid animated counters and statistics charts</span>
                  </div>
                </div>
              </div>
              <div className="relative rounded-3xl overflow-hidden border border-white/10 shadow-[0_20px_50px_rgba(124,77,255,0.15)] bg-[#0B0B0F]/40 backdrop-blur-sm">
                <img 
                  src="/images/Monthly_financial_snapshot_dashboard.png" 
                  alt="Worth Features Dashboard Screenshot"
                  className="w-full object-cover"
                />
              </div>
            </div>
          </div>

        </div>
      </main>

      {/* Footer */}
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
