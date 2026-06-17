"use client";

import React from "react";
import { motion } from "framer-motion";
import { ArrowRight, Download, Eye, Sparkles } from "lucide-react";

export default function Hero() {
  // SVG Chart path definition
  const chartPath = "M 20 180 C 60 160, 100 170, 140 120 C 180 70, 220 90, 260 40 L 300 20";

  return (
    <section className="relative min-h-screen flex items-center justify-center pt-32 pb-20 overflow-hidden grid-bg">
      {/* Mesh Background */}
      <div className="mesh-bg" />

      {/* Background radial highlight */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/10 rounded-full blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 w-full grid grid-cols-1 lg:grid-cols-12 gap-16 items-center relative z-10">
        
        {/* Left Column: Heading and CTA */}
        <div className="lg:col-span-6 flex flex-col items-start text-left">
          {/* Tagline Badge */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/5 border border-white/10 mb-6 backdrop-blur-sm"
          >
            <Sparkles className="w-3.5 h-3.5 text-accent animate-pulse" />
            <span className="text-xs font-semibold text-accent uppercase tracking-widest">
              Wealth Intelligence Center
            </span>
          </motion.div>

          {/* Main Headline */}
          <motion.h1
            initial={{ opacity: 0, y: 25 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="text-5xl md:text-7xl font-extrabold tracking-tight mb-6 leading-tight"
          >
            Know What <br className="hidden md:inline" />
            <span className="text-gradient-purple">You&apos;re Worth.</span>
          </motion.h1>

          {/* Subheadline */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="text-lg md:text-xl text-foreground/70 mb-10 max-w-xl leading-relaxed"
          >
            Track assets, liabilities, investments, receivables, goals, and net worth in one beautiful, privacy-first command center. Designed for the financially minded.
          </motion.p>

          {/* CTA Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto"
          >
            <a
              href="https://github.com/alokkumar2510/Worth/releases/download/v1.0.0/app-release.apk"
              className="w-full sm:w-auto flex items-center justify-center gap-2 bg-primary hover:bg-primary-hover text-white px-8 py-4 rounded-xl font-medium transition-all duration-300 shadow-lg shadow-primary/25 hover:shadow-primary/40 hover:-translate-y-0.5"
            >
              <Download className="w-5 h-5" />
              Download APK
            </a>
            <a
              href="#features"
              className="w-full sm:w-auto flex items-center justify-center gap-2 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 text-white px-8 py-4 rounded-xl font-medium transition-all duration-300 backdrop-blur-sm"
            >
              <Eye className="w-5 h-5 text-accent" />
              View Features
            </a>
          </motion.div>

          {/* Additional details */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="mt-8 text-xs text-foreground/40 flex items-center gap-4"
          >
            <span>✓ Android Release APK v1.0.0</span>
            <span className="w-1.5 h-1.5 rounded-full bg-white/10" />
            <span>✓ Offline First</span>
            <span className="w-1.5 h-1.5 rounded-full bg-white/10" />
            <span>✓ Encrypted DB</span>
          </motion.div>
        </div>

        {/* Right Side: Animated Dashboard Mockup */}
        <div className="lg:col-span-6 relative flex justify-center items-center w-full">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="relative w-full max-w-[500px] aspect-[4/3] rounded-2xl bg-surface/50 border border-white/5 backdrop-blur-md shadow-2xl p-6 overflow-hidden flex flex-col justify-between"
          >
            {/* Header bar of mockup */}
            <div className="flex justify-between items-center border-b border-white/5 pb-4">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-red-500/60" />
                <span className="w-2.5 h-2.5 rounded-full bg-yellow-500/60" />
                <span className="w-2.5 h-2.5 rounded-full bg-green-500/60" />
              </div>
              <div className="text-[10px] text-white/40 tracking-wider font-mono">WEALTH_INTELLIGENCE_CENTER</div>
            </div>

            {/* Dashboard Content */}
            <div className="flex-1 py-4 flex flex-col justify-between">
              {/* Top Row: Metric & Allocation */}
              <div className="flex justify-between items-start gap-4">
                <div>
                  <span className="text-xs text-white/50 tracking-wider">NET WORTH</span>
                  <motion.h3 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.5, duration: 1 }}
                    className="text-2xl md:text-3xl font-extrabold tracking-tight mt-1 text-white font-mono"
                  >
                    ₹12,45,000
                  </motion.h3>
                </div>
                {/* Micro Allocation Box */}
                <div className="bg-white/5 border border-white/10 rounded-lg p-2 text-right">
                  <div className="text-[9px] text-white/40 uppercase">Assets Allocation</div>
                  <div className="flex items-center gap-1.5 mt-1">
                    <span className="w-2 h-2 rounded-full bg-accent" />
                    <span className="text-xs font-semibold text-white">82% Liquid</span>
                  </div>
                </div>
              </div>

              {/* Animated Growth Graph */}
              <div className="h-28 w-full relative mt-4 flex items-end">
                <svg className="w-full h-full" viewBox="0 0 320 200">
                  {/* Fill gradient */}
                  <defs>
                    <linearGradient id="chart-glow" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#7C4DFF" stopOpacity="0.25" />
                      <stop offset="100%" stopColor="#7C4DFF" stopOpacity="0" />
                    </linearGradient>
                  </defs>
                  {/* Area fill path */}
                  <motion.path
                    d={`${chartPath} L 300 200 L 20 200 Z`}
                    fill="url(#chart-glow)"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 1, delay: 1 }}
                  />
                  {/* Main Line path */}
                  <motion.path
                    d={chartPath}
                    fill="none"
                    stroke="#7C4DFF"
                    strokeWidth="3.5"
                    strokeLinecap="round"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1.5, ease: "easeInOut", delay: 0.6 }}
                  />
                  {/* Glowing end node */}
                  <motion.circle
                    cx="300"
                    cy="20"
                    r="5"
                    fill="#A78BFA"
                    initial={{ scale: 0 }}
                    animate={{ scale: [0, 1.5, 1] }}
                    transition={{ duration: 0.5, delay: 1.8 }}
                  />
                </svg>
              </div>
            </div>
          </motion.div>

          {/* Floating Card 1: Milestones */}
          <motion.div
            animate={{
              y: [0, -10, 0],
            }}
            transition={{
              repeat: Infinity,
              duration: 5,
              ease: "easeInOut",
            }}
            className="absolute -top-6 -left-6 md:-left-10 bg-[#0B0B0F]/80 border border-white/10 backdrop-blur-md rounded-xl p-4 shadow-xl z-20 max-w-[170px]"
          >
            <div className="flex items-center gap-2">
              <span className="text-lg">💎</span>
              <div>
                <div className="text-[10px] text-white/50 tracking-wider">MILESTONE UNLOCKED</div>
                <div className="text-sm font-bold text-white mt-0.5">₹10L Achieved</div>
              </div>
            </div>
            <div className="text-[9px] text-emerald-400 font-semibold mt-2 flex items-center gap-1">
              <span>↑ 24% growth speed</span>
            </div>
          </motion.div>

          {/* Floating Card 2: Recent Transaction */}
          <motion.div
            animate={{
              y: [0, 12, 0],
            }}
            transition={{
              repeat: Infinity,
              duration: 6,
              ease: "easeInOut",
              delay: 0.5,
            }}
            className="absolute -bottom-8 -right-6 bg-[#0B0B0F]/80 border border-white/10 backdrop-blur-md rounded-xl p-4 shadow-xl z-20 max-w-[190px]"
          >
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-lg bg-accent/20 flex items-center justify-center text-accent font-bold text-xs">
                +
              </div>
              <div>
                <div className="text-[9px] text-white/40">INVESTMENT RECOUP</div>
                <div className="text-xs font-semibold text-white mt-0.5">SIP Principal Added</div>
              </div>
            </div>
            <div className="text-xs font-bold text-white font-mono text-right mt-2">
              + ₹25,000.00
            </div>
          </motion.div>
        </div>

      </div>
    </section>
  );
}
