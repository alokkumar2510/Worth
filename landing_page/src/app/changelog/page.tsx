"use client";

import React from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  Sparkles, 
  Wrench, 
  Zap, 
  GitCommit,
  ArrowUpRight
} from "lucide-react";

export default function ChangelogPage() {
  const releases = [
    {
      version: "1.12.0",
      date: "June 22, 2026",
      tagline: "MTF Ledger Stabilizations & Safe DB Conflict Resolution",
      features: [
        "Auto-Conflict Resolution: Upgraded direct SQLite database writes to automatically update existing records on key conflicts.",
        "Type Propagation: Enforced strict asset and liability classification fields across forms, preventing generic type mismatch errors."
      ],
      fixes: [
        "Resolved database crash triggered when saving mutual funds, stock positions, or ETF portfolios combined with margin trading finance (MTF) borrowing."
      ],
      improvements: [
        "Strengthened database insertion pipelines with transactional safe-guards."
      ]
    },
    {
      version: "1.11.0",
      date: "June 22, 2026",
      tagline: "The Net Worth Ecosystem and Update Center",
      features: [
        "Update Ecosystem: Introduced the secure in-app Update Center, automated version checks, and safety thresholds.",
        "Contact Picker: Fast contact searches to select and pre-populate receivable debtor details.",
        "QR Scan-to-Pay Generator: Request direct UPI payments with automatically embedded visual QR codes in generated reminders."
      ],
      fixes: [
        "Corrected minor routing duplicate warnings during page pushing.",
        "Corrected double constructor definitions in liability models."
      ],
      improvements: [
        "App-Wide Motion: Sleek screen transitions, luxury dark-mode aesthetics, and uniform haptic feedback.",
        "Smooth decel scroll physics added to all settings lists and dashboard charts."
      ]
    },
    {
      version: "1.10.0",
      date: "June 15, 2026",
      tagline: "The Motion and Performance Beta",
      features: [
        "Financial Calendar: Unified scheduler for tracking due transactions, SIP reminders, and check-in streaks.",
        "Moratorium Simulators: Expanded loan tracking modules supporting complex disbursements and forecast calculations.",
        "Advanced Settings Search: Fast, indexed query capability across all local configurations."
      ],
      fixes: [
        "Moratorium repayment simulation cast corrections.",
        "Smoothed out Particle paint boundaries on older graphics units."
      ],
      improvements: [
        "Uniform iOS-style bouncing scroll physics added across all lists and carousels.",
        "Low-overhead tactile haptic triggers integrated into navigation and buttons."
      ]
    },
    {
      version: "1.9.0",
      date: "May 15, 2026",
      tagline: "moratoriums & JSON backup vaults",
      features: [
        "Moratorium SIM trackers inside the brand new Education Loan module.",
        "Data backup export vault (triggers AES-encrypted JSON string files)."
      ],
      fixes: [
        "Fixed sync race conditions when restoring database tables from backup snapshots."
      ],
      improvements: [
        "Improved Firestore cloud replication speeds.",
        "Enhanced local database caching indices."
      ]
    },
    {
      version: "1.8.0",
      date: "April 10, 2026",
      tagline: "Time Machine ledgers",
      features: [
        "Time Machine: Travel back to check historical transaction logs and asset snapshots.",
        "Expected Income: Log expected streams and due dates in a clean dashboard widget."
      ],
      fixes: [
        "Fixed alignment issues on smaller viewports."
      ],
      improvements: [
        "Optimized balance recalculation loops."
      ]
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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH CHANGELOG</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/3 w-[600px] h-[300px] bg-primary/5 rounded-full blur-[100px]" />
        </div>

        <div className="max-w-3xl mx-auto relative z-10">
          
          {/* Header */}
          <div className="text-left mb-20">
            <span className="text-xs font-bold text-accent tracking-widest font-mono uppercase bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
              Release History
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight">
              What&apos;s New in Worth.
            </h1>
            <p className="text-sm text-foreground/50 leading-relaxed max-w-xl">
              Chronological log of features, performance tunings, and local database safeguards implemented.
            </p>
          </div>

          {/* Timeline */}
          <div className="relative border-l border-white/10 pl-8 ml-4 space-y-20 text-left">
            {releases.map((rel) => (
              <div key={rel.version} className="relative">
                
                {/* Node indicator */}
                <span className="absolute -left-[45px] top-1.5 w-6 h-6 rounded-full bg-[#050507] border-2 border-primary flex items-center justify-center z-10">
                  <GitCommit className="w-3.5 h-3.5 text-primary" />
                </span>

                {/* Release Header */}
                <div className="mb-6">
                  <div className="flex items-center gap-3">
                    <h2 className="text-2xl font-black text-white">v{rel.version}</h2>
                    <span className="text-xs text-foreground/40 font-mono">({rel.date})</span>
                  </div>
                  <p className="text-xs text-accent font-mono uppercase tracking-wider mt-1 font-semibold">{rel.tagline}</p>
                </div>

                {/* Details Section */}
                <div className="space-y-6">
                  
                  {/* Features */}
                  {rel.features.length > 0 && (
                    <div>
                      <h3 className="text-xs font-bold text-white tracking-widest font-mono uppercase mb-3 flex items-center gap-2">
                        <Sparkles className="w-3.5 h-3.5 text-primary" />
                        NEW FEATURES
                      </h3>
                      <ul className="list-disc list-inside text-xs text-foreground/60 space-y-1.5 pl-2 leading-relaxed">
                        {rel.features.map((f, idx) => (
                          <li key={idx}>{f}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Improvements */}
                  {rel.improvements.length > 0 && (
                    <div>
                      <h3 className="text-xs font-bold text-white tracking-widest font-mono uppercase mb-3 flex items-center gap-2">
                        <Zap className="w-3.5 h-3.5 text-[#7C4DFF]" />
                        IMPROVEMENTS
                      </h3>
                      <ul className="list-disc list-inside text-xs text-foreground/60 space-y-1.5 pl-2 leading-relaxed">
                        {rel.improvements.map((imp, idx) => (
                          <li key={idx}>{imp}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Fixes */}
                  {rel.fixes.length > 0 && (
                    <div>
                      <h3 className="text-xs font-bold text-white tracking-widest font-mono uppercase mb-3 flex items-center gap-2">
                        <Wrench className="w-3.5 h-3.5 text-red-400" />
                        BUG FIXES
                      </h3>
                      <ul className="list-disc list-inside text-xs text-foreground/60 space-y-1.5 pl-2 leading-relaxed">
                        {rel.fixes.map((fix, idx) => (
                          <li key={idx}>{fix}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                </div>

              </div>
            ))}
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
