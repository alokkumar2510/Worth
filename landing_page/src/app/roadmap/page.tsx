"use client";

import React from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  CheckCircle2, 
  Clock, 
  Calendar,
  Sparkles,
  GitPullRequest,
  TrendingUp
} from "lucide-react";

export default function RoadmapPage() {
  const categories = [
    {
      title: "SHIPPED",
      icon: CheckCircle2,
      color: "text-emerald-400 border-emerald-500/10",
      bgGlow: "rgba(16,185,129,0.02)",
      items: [
        {
          version: "v1.11.0",
          date: "June 2026",
          title: "Premium Update Ecosystem",
          desc: "Released the self-contained Update Center, automated version checker, and net worth ledger sync warnings."
        },
        {
          version: "v1.10.0",
          date: "June 2026",
          title: "App-Wide Motion System",
          desc: "Implemented smooth animations, page transitions, settings menu searches, and local deceleration scroll physics."
        },
        {
          version: "v1.9.0",
          date: "May 2026",
          title: "Moratorium Simulator & Loan Hub",
          desc: "Released the self-contained Education Loan Center with 10-year monthly forecasts and moratorium EMI simulators."
        }
      ]
    },
    {
      title: "IN PROGRESS",
      icon: Clock,
      color: "text-primary border-primary/10",
      bgGlow: "rgba(124,77,255,0.02)",
      items: [
        {
          version: "v1.12.0",
          date: "Target: Q3 2026",
          title: "Mutual Fund NAV Sync",
          desc: "Integrating online NAV crawlers to automatically re-evaluate mutual fund investment allocations."
        },
        {
          version: "v1.12.0",
          date: "Target: Q3 2026",
          title: "Secure Web App Companion",
          desc: "Building a read-only React dashboard allowing users to visualize synced Firestore databases in desktop browsers."
        },
        {
          version: "v1.13.0",
          date: "Target: Q4 2026",
          title: "Stock Portfolio Tracker",
          desc: "Real-time stock ticker valuation sheets using direct API hooks, integrated into the Investments module."
        }
      ]
    },
    {
      title: "PLANNED",
      icon: Calendar,
      color: "text-amber-400 border-amber-500/10",
      bgGlow: "rgba(245,158,11,0.02)",
      items: [
        {
          version: "v2.0.0",
          date: "Target: Q1 2027",
          title: "iOS Platform Launch",
          desc: "Compiling and optimizing the Flutter codebase to release Worth on Apple App Store with native iOS keychain security."
        },
        {
          version: "v2.1.0",
          date: "Target: Q2 2027",
          title: "Multi-Currency conversions",
          desc: "Support tracking net worth across USD, EUR, GBP, and INR assets, calculating exchange rate shifts dynamically."
        },
        {
          version: "v2.2.0",
          date: "Target: Q2 2027",
          title: "Visual Dashboard Customizations",
          desc: "Introduce custom neon theme presets, custom cards spacing, and custom grid dashboards."
        }
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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH ROADMAP</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-primary/5 rounded-full blur-[120px]" />
        </div>

        <div className="max-w-5xl mx-auto relative z-10">
          
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto mb-20">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Development Pipelines
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight leading-tight">
              Product Roadmap.
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              Track our milestones, target quarters, and features currently shipped, under active development, or planned.
            </p>
          </div>

          {/* Columns Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start text-left">
            {categories.map((cat) => {
              const Icon = cat.icon;
              return (
                <div key={cat.title} className="space-y-6">
                  {/* Column Header */}
                  <div className="flex items-center gap-3 pb-3 border-b border-white/5">
                    <div className={`p-1.5 rounded-lg bg-white/5 border border-white/5 ${cat.color}`}>
                      <Icon className="w-4 h-4" />
                    </div>
                    <h2 className="text-xs font-bold text-white tracking-widest font-mono uppercase">{cat.title}</h2>
                  </div>

                  {/* Cards */}
                  <div className="space-y-4">
                    {cat.items.map((item, idx) => (
                      <div 
                        key={idx} 
                        style={{ background: cat.bgGlow }}
                        className={`glass-panel p-6 border ${cat.color} backdrop-blur-md rounded-2xl flex flex-col justify-between`}
                      >
                        <div>
                          <div className="flex justify-between items-center text-[10px] font-mono text-white/40 mb-3">
                            <span>{item.version}</span>
                            <span className="text-white/60 font-bold">{item.date}</span>
                          </div>
                          <h3 className="font-extrabold text-sm text-white mb-2">{item.title}</h3>
                          <p className="text-xs text-foreground/50 leading-relaxed">{item.desc}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
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
