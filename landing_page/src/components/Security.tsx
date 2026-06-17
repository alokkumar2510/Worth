"use client";

import React from "react";
import { motion } from "framer-motion";
import { Shield, Fingerprint, Database, HardDrive, Lock } from "lucide-react";

export default function Security() {
  return (
    <section id="security" className="py-24 bg-[#050507] relative overflow-hidden">
      {/* Background highlight */}
      <div className="absolute bottom-1/4 right-0 w-[500px] h-[500px] bg-primary/5 rounded-full blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">
          
          {/* Left Column: Visual Icon & Header */}
          <div className="lg:col-span-5 flex flex-col items-start text-left">
            <span className="text-xs font-bold text-primary uppercase tracking-widest bg-primary/10 border border-primary/20 px-3 py-1 rounded-full mb-6">
              Privacy First
            </span>
            <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-6 leading-tight">
              Your Wealth Data <br />Is Your Business
            </h2>
            <p className="text-lg text-foreground/60 leading-relaxed mb-8">
              Worth is designed as a secure local fortress. By keeping database engines and security checks on-device, you remain in complete command of your financial data.
            </p>

            {/* Giant Glassmorphic Shield Icon */}
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              className="relative w-44 h-44 rounded-3xl bg-[#0B0B0F]/40 border border-white/5 flex items-center justify-center backdrop-blur-md shadow-2xl overflow-hidden self-center lg:self-start"
            >
              <div className="absolute inset-0 bg-gradient-to-tr from-primary to-accent opacity-10 blur-xl animate-pulse" />
              <Shield className="w-20 h-20 text-primary animate-pulse" />
            </motion.div>
          </div>

          {/* Right Column: Security Pillars */}
          <div className="lg:col-span-7 grid grid-cols-1 sm:grid-cols-2 gap-6">
            
            {/* Card 1: Biometric Lock */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
              className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-sm"
            >
              <div className="w-10 h-10 rounded-lg bg-primary/20 border border-primary/30 flex items-center justify-center text-accent mb-4">
                <Fingerprint className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">Biometric Lock Guard</h3>
              <p className="text-sm text-foreground/50 leading-relaxed">
                App routes are blocked by native security checks (`local_auth`) and GoRouter guards, preventing lock bypasses.
              </p>
            </motion.div>

            {/* Card 2: Offline First Database */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-sm"
            >
              <div className="w-10 h-10 rounded-lg bg-accent/20 border border-accent/30 flex items-center justify-center text-primary mb-4">
                <Database className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">Drift SQLite Caching</h3>
              <p className="text-sm text-foreground/50 leading-relaxed">
                Financial balances, audit changes, and transactions are stored on-device in a reactive SQLite storage engine.
              </p>
            </motion.div>

            {/* Card 3: Encrypted Storage Keys */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-sm"
            >
              <div className="w-10 h-10 rounded-lg bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-emerald-400 mb-4">
                <Lock className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">Keystore Cryptography</h3>
              <p className="text-sm text-foreground/50 leading-relaxed">
                Authentication flags and encryption parameters are locked securely inside Android Keystore cryptographic trees.
              </p>
            </motion.div>

            {/* Card 4: Cloud Backups */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-sm"
            >
              <div className="w-10 h-10 rounded-lg bg-blue-500/20 border border-blue-500/30 flex items-center justify-center text-blue-400 mb-4">
                <HardDrive className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">Private Firestore Sync</h3>
              <p className="text-sm text-foreground/50 leading-relaxed">
                Back up your database securely to your private cloud storage. All records are synced with audit timestamps.
              </p>
            </motion.div>

          </div>
        </div>
      </div>
    </section>
  );
}
