"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Github, ArrowRight } from "lucide-react";

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <motion.header
      initial={{ y: -100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled 
          ? "bg-[#050507]/75 backdrop-blur-md border-b border-white/5 py-4" 
          : "bg-transparent py-6"
      }`}
    >
      <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
        {/* Logo */}
        <a href="#" className="flex items-center gap-2 group">
          <span className="w-8 h-8 rounded-lg bg-gradient-to-tr from-primary to-accent flex items-center justify-center font-bold text-white shadow-lg shadow-primary/20">
            💎
          </span>
          <span className="font-semibold text-lg tracking-wider text-white group-hover:text-accent transition-colors duration-300">
            WORTH
          </span>
        </a>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-8">
          <a href="#features" className="text-sm text-foreground/80 hover:text-white transition-colors">Features</a>
          <a href="#timeline" className="text-sm text-foreground/80 hover:text-white transition-colors">Timeline</a>
          <a href="#comparison" className="text-sm text-foreground/80 hover:text-white transition-colors">Why Worth</a>
          <a href="#security" className="text-sm text-foreground/80 hover:text-white transition-colors">Security</a>
        </nav>

        {/* Action Buttons */}
        <div className="hidden md:flex items-center gap-4">
          <a
            href="https://github.com/alokkumar2510/Worth"
            target="_blank"
            rel="noopener noreferrer"
            className="p-2 text-foreground/80 hover:text-white transition-colors rounded-lg hover:bg-white/5"
            aria-label="GitHub Repository"
          >
            <Github className="w-5 h-5" />
          </a>
          <a
            href="https://github.com/alokkumar2510/Worth/releases/download/v1.0.0/app-release.apk"
            className="flex items-center gap-1 bg-primary hover:bg-primary-hover text-white text-sm font-medium px-4 py-2 rounded-lg transition-all shadow-md hover:shadow-primary/20 hover:scale-[1.02]"
          >
            Download APK
            <ArrowRight className="w-4 h-4" />
          </a>
        </div>

        {/* Mobile Menu Toggle */}
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden p-2 text-foreground/80 hover:text-white transition-colors"
          aria-label="Toggle Menu"
        >
          {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Drawer */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
            className="md:hidden bg-[#0B0B0F]/95 backdrop-blur-lg border-b border-white/5 px-6 py-4 flex flex-col gap-4"
          >
            <a 
              href="#features" 
              onClick={() => setIsOpen(false)}
              className="text-foreground/80 hover:text-white transition-colors py-2"
            >
              Features
            </a>
            <a 
              href="#timeline" 
              onClick={() => setIsOpen(false)}
              className="text-foreground/80 hover:text-white transition-colors py-2"
            >
              Timeline
            </a>
            <a 
              href="#comparison" 
              onClick={() => setIsOpen(false)}
              className="text-foreground/80 hover:text-white transition-colors py-2"
            >
              Why Worth
            </a>
            <a 
              href="#security" 
              onClick={() => setIsOpen(false)}
              className="text-foreground/80 hover:text-white transition-colors py-2"
            >
              Security
            </a>
            <hr className="border-white/5 my-2" />
            <div className="flex justify-between items-center gap-4">
              <a
                href="https://github.com/alokkumar2510/Worth"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-foreground/80 hover:text-white py-2"
              >
                <Github className="w-5 h-5" />
                GitHub
              </a>
              <a
                href="https://github.com/alokkumar2510/Worth/releases/download/v1.0.0/app-release.apk"
                className="flex items-center justify-center gap-1 bg-primary text-white text-sm font-medium px-4 py-2 rounded-lg w-full text-center"
              >
                Download APK
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  );
}
