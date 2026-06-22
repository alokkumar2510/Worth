"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  Download, 
  ShieldCheck, 
  Info,
  CheckCircle,
  HelpCircle,
  AlertTriangle,
  FileCode
} from "lucide-react";

interface UpdateJson {
  version: string;
  build: number;
  release_date: string;
  force_update: boolean;
  download_url: string;
  release_notes: string[];
}

export default function UpdatePage() {
  const [updateInfo, setUpdateInfo] = useState<UpdateJson | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch live version info served from our public/version.json
    fetch("/version.json")
      .then((res) => res.json())
      .then((data: UpdateJson) => {
        setUpdateInfo(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Failed to fetch version JSON:", err);
        // Fallback static state if fetch fails
        setUpdateInfo({
          version: "1.11.0",
          build: 12,
          release_date: "2026-06-22",
          force_update: false,
          download_url: "https://github.com/alokkumar2510/Worth/releases/download/v1.11.0/app-release.apk",
          release_notes: [
            "Premium Update Ecosystem and In-App Update Center.",
            "Production Image Rendering Engine for Receivables.",
            "Embedded Scan-to-Pay QR Codes (UPI integrated).",
            "Smart Contact Picker Import for receivables.",
            "Sleek App-Wide Motion and decel scroll physics."
          ]
        });
        setLoading(false);
      });
  }, []);

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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH UPDATE</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[550px] h-[550px] bg-primary/5 rounded-full blur-[130px]" />
        </div>

        <div className="max-w-3xl mx-auto relative z-10">
          
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto mb-16">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Update Hub
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight leading-tight">
              Software Update.
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              You are running the update utility. Check specifications below and download the latest secure binary.
            </p>
          </div>

          {loading ? (
            <div className="text-center py-20 text-xs font-mono text-white/50">
              Fetching update descriptors...
            </div>
          ) : (
            <div className="space-y-8 text-left">
              
              {/* Critical warning if force update is active */}
              {updateInfo?.force_update && (
                <div className="p-6 bg-red-950/20 border border-red-500/30 rounded-3xl flex items-start gap-4">
                  <AlertTriangle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
                  <div className="text-xs">
                    <strong className="text-white text-sm">Critical Security Update Required</strong><br />
                    <p className="text-foreground/50 mt-1 leading-relaxed">
                      This release contains vital security and database schema updates. Previous mobile installations must upgrade to prevent local sync issues.
                    </p>
                  </div>
                </div>
              )}

              {/* Update Info Card */}
              <div className="glass-panel p-8 border border-white/5 bg-[#0B0B0F]/40 backdrop-blur-md rounded-3xl grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
                <div className="md:col-span-7 space-y-3">
                  <span className="text-[10px] font-mono tracking-widest text-[#7C4DFF] font-bold uppercase">VERSION DESCRIPTOR</span>
                  <h2 className="text-3xl font-black text-white">Worth v{updateInfo?.version}</h2>
                  <p className="text-xs text-foreground/50 font-sans">
                    Released on <strong className="text-white font-mono">{updateInfo?.release_date}</strong>. This release is optimized for Android 8.0+ configurations.
                  </p>
                  
                  {/* Download Action */}
                  <div className="pt-3">
                    <a
                      href={updateInfo?.download_url}
                      className="inline-flex items-center justify-center gap-2 bg-white hover:bg-[#A78BFA] text-black font-bold text-xs px-6 py-4 rounded-full transition-all duration-300 shadow-[0_5px_15px_rgba(255,255,255,0.05)]"
                    >
                      <Download className="w-4 h-4" />
                      DOWNLOAD INSTALLER (APK)
                    </a>
                  </div>
                </div>

                <div className="md:col-span-5 border-t md:border-t-0 md:border-l border-white/5 pt-6 md:pt-0 md:pl-8 space-y-4 text-xs font-mono text-foreground/60">
                  <div className="flex justify-between border-b border-white/5 pb-2">
                    <span>BUILD</span>
                    <span className="text-white font-bold">{updateInfo?.build}</span>
                  </div>
                  <div className="flex justify-between border-b border-white/5 pb-2">
                    <span>FORCE</span>
                    <span className={`font-bold ${updateInfo?.force_update ? "text-red-400" : "text-emerald-400"}`}>
                      {updateInfo?.force_update ? "YES" : "NO"}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>TARGET</span>
                    <span className="text-white font-bold">Android OS</span>
                  </div>
                </div>
              </div>

              {/* Release Notes */}
              <div className="glass-panel p-8 border border-white/5 bg-[#0B0B0F]/30 rounded-3xl">
                <h3 className="text-xs font-bold text-white tracking-widest font-mono uppercase mb-6 flex items-center gap-2">
                  <FileCode className="w-4.5 h-4.5 text-accent" />
                  RELEASE NOTE LOG
                </h3>
                <ul className="space-y-4 pl-1 text-xs text-foreground/70">
                  {updateInfo?.release_notes.map((note, idx) => (
                    <li key={idx} className="flex gap-3 items-start">
                      <CheckCircle className="w-4.5 h-4.5 text-emerald-400 shrink-0 mt-0.5" />
                      <span className="leading-relaxed">{note}</span>
                    </li>
                  ))}
                </ul>
              </div>

            </div>
          )}

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
