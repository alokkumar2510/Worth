"use client";

import React from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  Download, 
  ShieldCheck, 
  Smartphone, 
  Cpu, 
  HardDrive,
  Copy,
  Info,
  CheckCircle,
  HelpCircle
} from "lucide-react";

export default function DownloadPage() {
  const latestVersion = "1.12.0";
  const buildNumber = 13;
  const releaseDate = "June 22, 2026";
  const apkSize = "94.1 MB";
  const sha256Checksum = "4debb71d7152aa31eafee3903fb84524283fea69b35999de920c53191692f7a3";
  const downloadUrl = "https://github.com/alokkumar2510/Worth/releases/download/v1.12.0/app-release.apk";

  const handleCopyChecksum = () => {
    navigator.clipboard.writeText(sha256Checksum);
    alert("SHA-256 Checksum copied to clipboard!");
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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH DOWNLOAD</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-primary/5 rounded-full blur-[120px]" />
        </div>

        <div className="max-w-4xl mx-auto relative z-10">
          
          {/* Page Hero */}
          <div className="text-center max-w-2xl mx-auto mb-16">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Get the App
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight leading-tight">
              Download Worth OS.
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              Install the personal wealth operating system on your Android device. Secure, offline-first, local SQLite storage.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
            
            {/* Left Column: Release Details Card */}
            <div className="lg:col-span-6 glass-panel p-8 border border-white/5 bg-[#0B0B0F]/40 backdrop-blur-md rounded-3xl text-left">
              <span className="text-[10px] font-mono tracking-widest text-primary font-bold uppercase">LATEST RELEASE</span>
              <h2 className="text-3xl font-black text-white mt-2 mb-6">Worth v{latestVersion}</h2>
              
              {/* Release parameters */}
              <div className="space-y-4 mb-8 text-xs font-mono">
                <div className="flex justify-between py-2.5 border-b border-white/5">
                  <span className="text-white/40">Release Date</span>
                  <span className="text-white font-bold">{releaseDate}</span>
                </div>
                <div className="flex justify-between py-2.5 border-b border-white/5">
                  <span className="text-white/40">Build Version</span>
                  <span className="text-white font-bold">{buildNumber}</span>
                </div>
                <div className="flex justify-between py-2.5 border-b border-white/5">
                  <span className="text-white/40">File Size</span>
                  <span className="text-white font-bold">{apkSize}</span>
                </div>
                <div className="flex justify-between py-2.5 border-b border-white/5">
                  <span className="text-white/40">Operating System</span>
                  <span className="text-white font-bold">Android 8.0+</span>
                </div>
              </div>

              {/* Download CTA */}
              <a
                href={downloadUrl}
                className="w-full flex items-center justify-center gap-2.5 bg-white text-black hover:bg-[#A78BFA] hover:text-black font-bold text-sm py-4.5 rounded-full transition-all duration-300 shadow-[0_10px_35px_rgba(255,255,255,0.1)] mb-6"
              >
                <Download className="w-5 h-5" />
                DOWNLOAD APK
              </a>

              {/* Checksum display */}
              <div className="p-4 bg-white/5 border border-white/5 rounded-2xl">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[9px] font-mono text-white/40 font-bold uppercase tracking-wider flex items-center gap-1">
                    <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
                    SHA-256 CHECKSUM
                  </span>
                  <button 
                    onClick={handleCopyChecksum}
                    className="p-1 hover:bg-white/5 rounded-lg text-white/40 hover:text-white transition-colors"
                    title="Copy Checksum"
                  >
                    <Copy className="w-3.5 h-3.5" />
                  </button>
                </div>
                <p className="text-[10px] font-mono text-white/60 break-all select-all leading-normal">
                  {sha256Checksum}
                </p>
              </div>
            </div>

            {/* Right Column: System Specs & Install Guide */}
            <div className="lg:col-span-6 space-y-6">
              
              {/* System Specs */}
              <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30 text-left">
                <h3 className="text-sm font-extrabold text-white mb-4 flex items-center gap-2">
                  <Cpu className="w-4 h-4 text-accent" />
                  System Requirements
                </h3>
                <div className="grid grid-cols-2 gap-4 text-xs font-sans">
                  <div className="space-y-1">
                    <div className="text-white/30">MINIMUM OS</div>
                    <div className="text-white font-bold">Android 8.0 (Oreo)</div>
                  </div>
                  <div className="space-y-1">
                    <div className="text-white/30">RECOMMENDED OS</div>
                    <div className="text-white font-bold">Android 11.0+</div>
                  </div>
                  <div className="space-y-1">
                    <div className="text-white/30">FREE SPACE</div>
                    <div className="text-white font-bold">50 MB minimum</div>
                  </div>
                  <div className="space-y-1">
                    <div className="text-white/30">BIOMETRICS</div>
                    <div className="text-white font-bold">Fingerprint / Face ID</div>
                  </div>
                </div>
              </div>

              {/* Install Instructions */}
              <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30 text-left">
                <h3 className="text-sm font-extrabold text-white mb-4 flex items-center gap-2">
                  <Info className="w-4 h-4 text-amber-400" />
                  Installation Instructions
                </h3>
                <ol className="space-y-3.5 text-xs text-foreground/70 pl-1 list-decimal list-inside">
                  <li>
                    <strong className="text-white">Download APK:</strong> Tap the download button to transfer the installer file onto your device.
                  </li>
                  <li>
                    <strong className="text-white">Enable Unknown Sources:</strong> Go to settings, search &ldquo;Install Unknown Apps&rdquo;, and select the browser you used to download Worth, then toggle &ldquo;Allow from this source&rdquo;.
                  </li>
                  <li>
                    <strong className="text-white">Run Installer:</strong> Locate the `.apk` in your Downloads folder and run the system installation wizard.
                  </li>
                  <li>
                    <strong className="text-white">Launch & Secure:</strong> Open Worth, set up your local biometric security PIN, and begin tracking your net worth privately.
                  </li>
                </ol>
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
