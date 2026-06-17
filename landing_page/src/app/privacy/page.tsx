"use client";

import React from "react";
import Link from "next/link";
import { ArrowLeft, Shield, Eye, ShieldCheck, Database, Key } from "lucide-react";
import Footer from "@/components/Footer";

export default function PrivacyPolicy() {
  return (
    <div className="bg-[#050507] text-[#f4f4f6] min-h-screen font-sans flex flex-col justify-between">
      
      {/* Header bar */}
      <header className="fixed top-0 left-0 right-0 bg-[#050507]/80 backdrop-blur-md border-b border-white/5 py-4 z-50">
        <div className="max-w-4xl mx-auto px-6 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-xs text-foreground/60 hover:text-white transition-colors uppercase tracking-wider font-mono">
            <ArrowLeft className="w-4 h-4" />
            Back to Home
          </Link>
          <div className="flex items-center gap-2">
            <span className="w-5 h-5 rounded bg-gradient-to-tr from-primary to-accent flex items-center justify-center text-[10px]">💎</span>
            <span className="font-semibold tracking-wider text-white text-xs">WORTH PRIVACY</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-20 px-6 max-w-3xl mx-auto w-full relative z-10">
        
        {/* Decorative background glow */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[500px] h-[300px] bg-primary/5 rounded-full blur-[100px] pointer-events-none -z-10" />

        {/* Title */}
        <div className="mb-12">
          <span className="text-xs font-mono font-bold text-accent uppercase tracking-widest">Legal & Security</span>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-white mt-4 mb-2">Privacy Policy</h1>
          <p className="text-xs text-foreground/40 font-mono">Last Updated: June 17, 2026</p>
        </div>

        {/* Highlight cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-12">
          <div className="glass-panel p-5 border border-white/5 bg-[#0B0B0F]/30">
            <Database className="w-5 h-5 text-primary mb-2" />
            <h3 className="text-sm font-bold text-white mb-1">Local Processing</h3>
            <p className="text-xs text-foreground/50 leading-relaxed">
              Your financial values, balances, transaction lists, and portfolio logs reside on-device in your SQLite database.
            </p>
          </div>
          <div className="glass-panel p-5 border border-white/5 bg-[#0B0B0F]/30">
            <Key className="w-5 h-5 text-accent mb-2" />
            <h3 className="text-sm font-bold text-white mb-1">OS-Isolated Biometrics</h3>
            <p className="text-xs text-foreground/50 leading-relaxed">
              Biometric checks are handled locally via Android OS secure APIs. Worth never accesses or stores your physical fingerprint.
            </p>
          </div>
        </div>

        {/* Policy Details */}
        <div className="space-y-8 text-sm text-foreground/70 leading-relaxed font-sans">
          
          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">1. Core Information Principles</h2>
            <p className="mb-3">
              Worth is designed as a standalone, offline-first personal financial operating system. Unlike traditional fintech applications, we do not require you to connect your bank accounts to third-party scrapers, nor do we run background analytics on your financial performance.
            </p>
            <p>
              Your data belongs solely to you. We believe in complete transparency and maximum local data containment.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">2. Collected Data & Permissions</h2>
            <ul className="list-disc list-inside space-y-2 pl-2">
              <li>
                <strong>Financial Assets & Transactions:</strong> All asset balances, outstanding liabilities, investment values, receivable timelines, expected streams, and goals you enter are stored inside an encrypted local Drift (SQLite) database cache. This data is never transmitted to us or any third-party marketing companies.
              </li>
              <li>
                <strong>Biometric Authentications:</strong> The app requests permission to use your device&apos;s Biometric sensors (Fingerprint / Face Unlock). This authentication is managed directly by the Android operating system. Worth does not have access to, nor does it log, your actual biometric identifiers.
              </li>
              <li>
                <strong>Device State permissions:</strong> We query basic local storage directories to save local SQLite backups if you choose to trigger database exports.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">3. Optional Firestore Synchronization</h2>
            <p className="mb-3">
              Worth provides an optional cloud sync module allowing you to backup database snapshots. If you choose to enable cloud backup, the app connects directly to your private Google Firestore container. 
            </p>
            <p>
              This sync pipeline uses secure, authenticated HTTPS channels. We do not host, store, or monitor these Firestore documents; they reside entirely within your own Firebase environment.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">4. Security Measures</h2>
            <p>
              Worth uses cryptographic key wrapping to verify app access PIN codes and security states. We recommend keeping your Android device updated, enabling device-level encryption, and disabling developer debugging interfaces to maximize local SQLite file security.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">5. Privacy Updates</h2>
            <p>
              We may modify this privacy protocol from time to time as features develop. Any updates will be pushed to the GitHub repository and reflected on this website. Continued use of the application constitutes acceptance of these local storage policies.
            </p>
          </section>

          <section className="pt-6 border-t border-white/5 text-xs text-foreground/40 flex items-center justify-between">
            <span>© Worth Operating System</span>
            <a href="mailto:privacy@alokkumarsahu.in" className="hover:text-white underline transition-colors">privacy@alokkumarsahu.in</a>
          </section>
        </div>

      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
}
