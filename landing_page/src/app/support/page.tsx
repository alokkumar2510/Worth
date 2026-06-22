"use client";

import React, { useState } from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  HelpCircle, 
  BookOpen, 
  ChevronDown, 
  ChevronUp, 
  Database, 
  RefreshCw, 
  Key,
  ShieldCheck
} from "lucide-react";

export default function SupportPage() {
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(null);

  const faqs = [
    {
      q: "Is my financial data secure?",
      a: "Yes. Worth is designed as a local-first application. All assets, liabilities, transactions, and settings are stored locally on your device in an encrypted SQLite (Drift) database. No financial data is sent to external servers unless you explicitly choose to configure and enable your personal Cloud Sync."
    },
    {
      q: "How do I configure the optional Cloud Sync?",
      a: "Worth lets you backup database snapshots to your private Firebase account. To configure it: 1) Open Worth on your phone. 2) Go to Settings → Cloud Sync Configuration. 3) Provide your personal Google Firestore container endpoint keys. 4) Toggle 'Enable Cloud Backup'. Once active, database snapshots will replicate securely using Firestore HTTPS pipelines."
    },
    {
      q: "How does the database restore process work?",
      a: "If you change devices or need to restore a backup: 1) Go to Settings → Data Management → Import JSON. 2) Select your previously exported AES-encrypted JSON file. 3) Input your backup encryption key. 4) The app will decrypt the snapshot, verify integrity, and overwrite the local SQLite database."
    },
    {
      q: "What are the Wealth Milestone badges?",
      a: "Worth calibrates your net worth and unlocks crystal badges to celebrate milestones: 1) 🌱 Base Sandbox (Default start status), 2) 🥉 ₹50K Milestone (Bronze Octahedron), 3) 🥈 ₹2.5L Milestone (Silver Pyramid), 4) 🥇 ₹10L Milestone (Gold Decahedron), and 5) 💎 ₹25L Milestone (Diamond Crystal)."
    },
    {
      q: "How does the Education Loan forecasting model work?",
      a: "The Education Loan Center uses a pure math engine. When you log disbursements, moratorium terms, and prepayments, it computes interest accruals and maps a 10-year monthly amortization projection. It remains isolated from your main Net Worth calculations to keep planning data clean."
    }
  ];

  const handleToggleFaq = (idx: number) => {
    setOpenFaqIndex(openFaqIndex === idx ? null : idx);
  };

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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH SUPPORT</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[500px] h-[500px] bg-primary/5 rounded-full blur-[120px]" />
        </div>

        <div className="max-w-4xl mx-auto relative z-10">
          
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto mb-16">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Help Center
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight leading-tight">
              Private Wealth Support.
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              Find technical documentation, setup tutorials, and frequently asked questions about the Worth ecosystem.
            </p>
          </div>

          {/* Quick Guides Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-16 text-left">
            <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30">
              <Database className="w-5 h-5 text-primary mb-3" />
              <h3 className="text-sm font-bold text-white mb-2">Local Data Safety</h3>
              <p className="text-xs text-foreground/50 leading-relaxed">
                Learn how Worth wraps your SQLite storage keys inside secure device Keystores and processes biometrics.
              </p>
            </div>
            <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30">
              <RefreshCw className="w-5 h-5 text-accent mb-3" />
              <h3 className="text-sm font-bold text-white mb-2">Sync Configurations</h3>
              <p className="text-xs text-foreground/50 leading-relaxed">
                Step-by-step documentation on deploying a Firestore bucket and linking it securely for cloud synchronization.
              </p>
            </div>
            <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30">
              <Key className="w-5 h-5 text-emerald-400 mb-3" />
              <h3 className="text-sm font-bold text-white mb-2">Backup & Decryption</h3>
              <p className="text-xs text-foreground/50 leading-relaxed">
                Guides on restoring asset logs, custom transaction categories, and expected payouts from JSON exports.
              </p>
            </div>
          </div>

          {/* FAQ Accordion */}
          <div className="glass-panel border border-white/5 bg-[#0B0B0F]/20 p-8 text-left">
            <h2 className="text-lg font-black text-white mb-6 flex items-center gap-2">
              <HelpCircle className="w-4.5 h-4.5 text-accent" />
              Frequently Asked Questions
            </h2>
            <div className="space-y-4">
              {faqs.map((faq, idx) => {
                const isOpen = openFaqIndex === idx;
                return (
                  <div key={idx} className="border-b border-white/5 pb-4 last:border-0 last:pb-0">
                    <button
                      onClick={() => handleToggleFaq(idx)}
                      className="w-full flex justify-between items-center text-xs font-extrabold text-white tracking-wider text-left py-2 hover:text-primary transition-colors focus:outline-none uppercase"
                    >
                      <span>{faq.q}</span>
                      {isOpen ? <ChevronUp className="w-4 h-4 text-foreground/50" /> : <ChevronDown className="w-4 h-4 text-foreground/50" />}
                    </button>
                    {isOpen && (
                      <p className="text-xs text-foreground/50 mt-2 leading-relaxed font-sans normal-case">
                        {faq.a}
                      </p>
                    )}
                  </div>
                );
              })}
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
