"use client";

import React from "react";
import { motion } from "framer-motion";
import { Quote, Github, Linkedin, Globe, Twitter, Instagram } from "lucide-react";

export default function Founder() {
  return (
    <section className="py-24 bg-[#050507] relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[300px] bg-primary/5 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-4xl mx-auto px-6 relative z-10">
        <div className="glass-panel p-8 md:p-12 border border-white/5 bg-[#0B0B0F]/45 backdrop-blur-md rounded-2xl flex flex-col md:flex-row gap-8 items-center">
          
          {/* Left: Founder Avatar Image */}
          <div className="relative shrink-0">
            <div className="w-28 h-28 md:w-36 md:h-36 rounded-full bg-gradient-to-tr from-primary to-accent p-1 shadow-xl overflow-hidden">
              <img 
                src="/images/founder.png" 
                alt="Alok Kumar Sahu" 
                className="w-full h-full rounded-full object-cover"
              />
            </div>
            {/* Pulsing online indicator */}
            <span className="absolute bottom-2 right-2 w-4 h-4 bg-emerald-500 border-2 border-[#0B0B0F] rounded-full animate-pulse" />
          </div>

          {/* Right: Message & Links */}
          <div className="flex-1 text-center md:text-left">
            <Quote className="w-8 h-8 text-accent/40 mb-4 mx-auto md:mx-0" />
            <h3 className="text-xl font-bold text-white mb-1 tracking-wide">Alok Kumar Sahu</h3>
            <span className="text-xs text-primary font-bold uppercase tracking-widest font-mono">Founder & Lead Architect</span>
            
            <p className="text-sm md:text-base text-foreground/70 leading-relaxed mt-4 mb-6">
              &ldquo;Worth was born out of a simple frustration: legacy budgeting apps are far too micro-focused on small daily purchases, and automated bank sync APIs constantly disconnect. I wanted a luxury, privacy-first command center that focuses entirely on long-term net worth, milestone tracking, and clean manual balance adjustments with logs. Worth represents that vision.&rdquo;
            </p>

            {/* Social Links */}
            <div className="flex flex-wrap justify-center md:justify-start gap-4">
              <a
                href="https://alokkumarsahu.in"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 text-foreground/50 hover:text-white transition-all duration-300 bg-white/5 rounded-lg border border-white/5 hover:border-primary/30 hover:scale-105"
                title="Portfolio Website"
                aria-label="Portfolio Website"
              >
                <Globe className="w-4 h-4" />
              </a>
              <a
                href="https://github.com/alokkumar2510"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 text-foreground/50 hover:text-white transition-all duration-300 bg-white/5 rounded-lg border border-white/5 hover:border-primary/30 hover:scale-105"
                title="GitHub"
                aria-label="GitHub Profile"
              >
                <Github className="w-4 h-4" />
              </a>
              <a
                href="https://www.linkedin.com/in/alok-kumar-sahu-7a7059370/"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 text-foreground/50 hover:text-white transition-all duration-300 bg-white/5 rounded-lg border border-white/5 hover:border-primary/30 hover:scale-105"
                title="LinkedIn"
                aria-label="LinkedIn Profile"
              >
                <Linkedin className="w-4 h-4" />
              </a>
              <a
                href="https://x.com/alok_chintu"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 text-foreground/50 hover:text-white transition-all duration-300 bg-white/5 rounded-lg border border-white/5 hover:border-primary/30 hover:scale-105"
                title="X (Twitter)"
                aria-label="X Profile"
              >
                <Twitter className="w-4 h-4" />
              </a>
              <a
                href="https://instagram.com/alokkumar.in"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 text-foreground/50 hover:text-white transition-all duration-300 bg-white/5 rounded-lg border border-white/5 hover:border-primary/30 hover:scale-105"
                title="Instagram"
                aria-label="Instagram Profile"
              >
                <Instagram className="w-4 h-4" />
              </a>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
