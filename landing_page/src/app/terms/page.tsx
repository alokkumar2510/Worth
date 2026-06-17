"use client";

import React from "react";
import Link from "next/link";
import { ArrowLeft, FileText, CheckCircle2, AlertTriangle, HelpCircle } from "lucide-react";

export default function TermsOfService() {
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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH TERMS</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-20 px-6 max-w-3xl mx-auto w-full relative z-10">
        
        {/* Decorative background glow */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[500px] h-[300px] bg-primary/5 rounded-full blur-[100px] pointer-events-none -z-10" />

        {/* Title */}
        <div className="mb-12">
          <span className="text-xs font-mono font-bold text-accent uppercase tracking-widest">Agreement & License</span>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-white mt-4 mb-2">Terms of Service</h1>
          <p className="text-xs text-foreground/40 font-mono">Last Updated: June 17, 2026</p>
        </div>

        {/* Highlight cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-12">
          <div className="glass-panel p-5 border border-white/5 bg-[#0B0B0F]/30">
            <CheckCircle2 className="w-5 h-5 text-emerald-400 mb-2" />
            <h3 className="text-sm font-bold text-white mb-1">Open Source License</h3>
            <p className="text-xs text-foreground/50 leading-relaxed">
              Worth is licensed under the permissive MIT license. You are free to inspect, build, modify, and distribute the code.
            </p>
          </div>
          <div className="glass-panel p-5 border border-white/5 bg-[#0B0B0F]/30">
            <AlertTriangle className="w-5 h-5 text-amber-400 mb-2" />
            <h3 className="text-sm font-bold text-white mb-1">Local Data Risk</h3>
            <p className="text-xs text-foreground/50 leading-relaxed">
              Because all data is offline-first, if you uninstall the app or wipe device storage without backing up, your data will be permanently deleted.
            </p>
          </div>
        </div>

        {/* Terms Details */}
        <div className="space-y-8 text-sm text-foreground/70 leading-relaxed font-sans">
          
          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">1. Acceptance of Agreement</h2>
            <p>
              By installing the Worth mobile application, downloading the release APK, or navigating this landing page, you agree to comply with and be bound by these Terms of Service. If you do not agree, please do not run the application or compile the repository.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">2. MIT Open Source License</h2>
            <p className="mb-3">
              The Worth codebase is distributed openly under the terms of the MIT License. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the &ldquo;Software&rdquo;), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.
            </p>
            <p className="font-mono text-xs bg-white/5 border border-white/5 p-4 rounded-lg text-foreground/50 leading-relaxed">
              THE SOFTWARE IS PROVIDED &ldquo;AS IS&rdquo;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">3. User Responsibilities & Data Backups</h2>
            <p className="mb-3">
              Worth maintains an **offline-first local-only database cache**. Financial values, transaction records, audit adjustments, expected income, and goals are stored in your device&apos;s local storage.
            </p>
            <ul className="list-disc list-inside space-y-2 pl-2">
              <li>
                <strong>Permanency of Local Storage:</strong> You acknowledge that uninstalling the Worth application, clearing app data, or wiping your device will permanently delete your database, transactions, and settings.
              </li>
              <li>
                <strong>Cloud Backups:</strong> If you choose to enable private Firestore synchronization, you are responsible for maintaining your own Firebase storage rules, credentials, and authentication states.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">4. No Financial Advice</h2>
            <p>
              Worth is a financial data organization utility and calculator. It does not provide investment consulting, debt advice, asset management, tax preparation, or bank deposit guarantees. All calculations, report values, allocation weights, and milestone entries are illustrative and rely entirely on values entered by you.
            </p>
          </section>

          <section>
            <h2 className="text-lg font-bold text-white mb-3 tracking-wide uppercase font-mono text-xs text-accent">5. Limitations of Liability</h2>
            <p>
              Under no circumstances shall the author (Alok Kumar Sahu) or contributors be liable for any direct, indirect, special, incidental, or consequential damages resulting from data loss, system errors, biometric lockout loops, incorrect calculations inside the Reports module, or failed Firestore backups.
            </p>
          </section>

          <section className="pt-6 border-t border-white/5 text-xs text-foreground/40 flex items-center justify-between">
            <span>© Worth Operating System</span>
            <a href="mailto:support@alokkumarsahu.in" className="hover:text-white underline transition-colors">support@alokkumarsahu.in</a>
          </section>
        </div>

      </main>

      {/* Footer */}
      <footer className="bg-[#050507] border-t border-white/5 py-12">
        <div className="max-w-4xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-6">
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
