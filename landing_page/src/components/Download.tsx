"use client";

import React from "react";
import { motion } from "framer-motion";
import { Download, Github, ShieldCheck } from "lucide-react";

export default function DownloadSection() {
  return (
    <section className="py-24 bg-[#050507] relative overflow-hidden grid-bg">
      {/* Background glowing sphere */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary/10 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-4xl mx-auto px-6 relative z-10 text-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="glass-panel p-10 md:p-16 border border-white/5 bg-[#0B0B0F]/65 backdrop-blur-md rounded-3xl"
        >
          <div className="w-12 h-12 rounded-full bg-primary/20 border border-primary/30 flex items-center justify-center text-accent mx-auto mb-6">
            <ShieldCheck className="w-6 h-6" />
          </div>

          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-6">
            Start Tracking Your Wealth Today.
          </h2>
          
          <p className="text-base md:text-lg text-foreground/60 leading-relaxed mb-10 max-w-xl mx-auto">
            Take complete control of your asset portfolio, debts, and milestones. Free of ads, trackers, and mandatory bank API log-ins.
          </p>

          <div className="flex flex-col sm:flex-row justify-center items-center gap-4">
            <a
              href="https://github.com/alokkumar2510/Worth/releases/download/v1.0.0/app-release.apk"
              className="w-full sm:w-auto flex items-center justify-center gap-2 bg-primary hover:bg-primary-hover text-white px-8 py-4 rounded-xl font-medium transition-all duration-300 shadow-lg shadow-primary/25 hover:shadow-primary/45"
            >
              <Download className="w-5 h-5" />
              Download APK
            </a>
            <a
              href="https://github.com/alokkumar2510/Worth/releases/tag/v1.0.0"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto flex items-center justify-center gap-2 bg-white/5 hover:bg-white/10 border border-white/10 text-white px-8 py-4 rounded-xl font-medium transition-all duration-300"
            >
              <Github className="w-5 h-5 text-accent" />
              GitHub Release
            </a>
          </div>

          <div className="mt-8 text-xs text-foreground/40 font-mono">
            Requires Android 8.0+ | SHA-256 Verified
          </div>
        </motion.div>
      </div>
    </section>
  );
}
