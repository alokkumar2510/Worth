"use client";

import React from "react";
import Link from "next/link";
import { Github, Globe, Heart } from "lucide-react";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-[#050507] border-t border-white/5 py-12 relative z-10">
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
        
        {/* Left Column: Brand & Tagline */}
        <div className="md:col-span-4 text-center md:text-left">
          <div className="flex items-center justify-center md:justify-start gap-2 mb-3">
            <span className="w-6 h-6 rounded bg-gradient-to-tr from-primary to-accent flex items-center justify-center text-xs">
              💎
            </span>
            <span className="font-semibold tracking-wider text-white text-sm">WORTH</span>
          </div>
          <p className="text-xs text-foreground/40 font-medium">Know What You&apos;re Worth.</p>
        </div>

        {/* Center Column: Legal & Navigation Links */}
        <div className="md:col-span-5 flex flex-wrap justify-center gap-6 text-xs text-foreground/60">
          <a href="#features" className="hover:text-white transition-colors">Features</a>
          <a href="#timeline" className="hover:text-white transition-colors">Timeline</a>
          <Link href="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
          <Link href="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
          <a 
            href="https://github.com/alokkumar2510/Worth" 
            target="_blank" 
            rel="noopener noreferrer" 
            className="hover:text-white transition-colors flex items-center gap-1"
          >
            <Github className="w-3 h-3" />
            GitHub
          </a>
        </div>

        {/* Right Column: Credits & Creator details */}
        <div className="md:col-span-3 text-center md:text-right text-xs text-foreground/40">
          <div className="flex items-center justify-center md:justify-end gap-1 mb-1">
            <span>Created with</span>
            <Heart className="w-3.5 h-3.5 text-primary fill-primary animate-pulse" />
            <span>by</span>
            <a 
              href="https://alokkumarsahu.in" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="text-foreground/70 hover:text-white underline underline-offset-2 transition-colors font-medium"
            >
              Alok Kumar Sahu
            </a>
          </div>
          <p>© {currentYear} Worth. All rights reserved.</p>
        </div>

      </div>
    </footer>
  );
}
