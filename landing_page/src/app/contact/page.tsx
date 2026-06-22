"use client";

import React, { useState } from "react";
import Link from "next/link";
import { 
  ArrowLeft, 
  Mail, 
  Github, 
  Linkedin, 
  Twitter, 
  Globe, 
  Send,
  MessageSquare,
  Sparkles
} from "lucide-react";

export default function ContactPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !email || !message) return;
    
    // Simulate submission
    setSubmitted(true);
    setName("");
    setEmail("");
    setSubject("");
    setMessage("");
    setTimeout(() => {
      setSubmitted(false);
    }, 5000);
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
            <span className="font-semibold tracking-wider text-white text-xs">WORTH CONTACT</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-32 pb-24 px-6 relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-primary/5 rounded-full blur-[120px]" />
          <div className="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px]" />
        </div>

        <div className="max-w-5xl mx-auto relative z-10">
          
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto mb-16">
            <span className="text-xs font-bold text-primary tracking-widest font-mono uppercase bg-primary/10 border border-primary/20 px-3 py-1 rounded-full">
              Get in Touch
            </span>
            <h1 className="text-4xl md:text-5xl font-black text-white mt-6 mb-4 tracking-tight">
              Connect With Us.
            </h1>
            <p className="text-base text-foreground/50 leading-relaxed">
              Have questions, feedback, or need help with Worth? Send a message directly to the developer team.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
            
            {/* Left Column: Form */}
            <div className="lg:col-span-7 glass-panel p-8 border border-white/5 bg-[#0B0B0F]/40 backdrop-blur-md rounded-3xl text-left">
              <h2 className="text-lg font-black text-white mb-6 flex items-center gap-2">
                <MessageSquare className="w-4 h-4 text-primary" />
                Send a Message
              </h2>

              {submitted ? (
                <div className="p-6 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex items-center gap-4 text-left text-xs text-emerald-400">
                  <Sparkles className="w-5 h-5 shrink-0" />
                  <div>
                    <strong className="text-white">Message Transmitted!</strong><br />
                    Thank you for reaching out. We will review your query and respond shortly.
                  </div>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-5 text-xs">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="font-extrabold text-white/70 tracking-wider font-mono">YOUR NAME</label>
                      <input 
                        type="text" 
                        required
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        placeholder="e.g. Alok Kumar"
                        className="w-full bg-white/5 border border-white/5 focus:border-primary px-4 py-3 rounded-xl text-white outline-none transition-colors"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="font-extrabold text-white/70 tracking-wider font-mono">EMAIL ADDRESS</label>
                      <input 
                        type="email" 
                        required
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="e.g. name@example.com"
                        className="w-full bg-white/5 border border-white/5 focus:border-primary px-4 py-3 rounded-xl text-white outline-none transition-colors"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="font-extrabold text-white/70 tracking-wider font-mono">SUBJECT (OPTIONAL)</label>
                    <input 
                      type="text" 
                      value={subject}
                      onChange={(e) => setSubject(e.target.value)}
                      placeholder="e.g. Feature Suggestion"
                      className="w-full bg-white/5 border border-white/5 focus:border-primary px-4 py-3 rounded-xl text-white outline-none transition-colors"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="font-extrabold text-white/70 tracking-wider font-mono">MESSAGE</label>
                    <textarea 
                      required
                      rows={5}
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      placeholder="Type your message here..."
                      className="w-full bg-white/5 border border-white/5 focus:border-primary px-4 py-3 rounded-xl text-white outline-none transition-colors resize-none"
                    />
                  </div>

                  <button
                    type="submit"
                    className="w-full flex items-center justify-center gap-2 bg-white hover:bg-[#A78BFA] text-black font-bold py-4 rounded-xl transition-all duration-300 shadow-[0_5px_15px_rgba(255,255,255,0.05)]"
                  >
                    <Send className="w-4 h-4" />
                    SEND MESSAGE
                  </button>
                </form>
              )}
            </div>

            {/* Right Column: Developer details */}
            <div className="lg:col-span-5 space-y-6 text-left">
              
              {/* Direct Info */}
              <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30">
                <h3 className="text-sm font-extrabold text-white mb-4 flex items-center gap-2">
                  <Mail className="w-4 h-4 text-accent" />
                  Direct Channels
                </h3>
                <div className="space-y-3.5 text-xs text-foreground/70 font-mono">
                  <div className="flex justify-between items-center py-1 border-b border-white/5">
                    <span>Developer Email</span>
                    <a href="mailto:contact@alokkumarsahu.in" className="text-white hover:text-primary transition-colors">contact@alokkumarsahu.in</a>
                  </div>
                  <div className="flex justify-between items-center py-1 border-b border-white/5">
                    <span>Support Desk</span>
                    <a href="mailto:support@alokkumarsahu.in" className="text-white hover:text-primary transition-colors">support@alokkumarsahu.in</a>
                  </div>
                  <div className="flex justify-between items-center py-1">
                    <span>GitHub Codebase</span>
                    <a href="https://github.com/alokkumar2510/Worth" target="_blank" rel="noopener noreferrer" className="text-white hover:text-primary transition-colors">github.com/alokkumar2510/Worth</a>
                  </div>
                </div>
              </div>

              {/* Developer Spotlight */}
              <div className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/30 flex gap-4 items-center">
                <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-primary to-accent p-0.5 shadow-xl shrink-0 overflow-hidden">
                  <img 
                    src="/images/founder.png" 
                    alt="Alok Kumar Sahu" 
                    className="w-full h-full rounded-full object-cover"
                  />
                </div>
                <div>
                  <h4 className="font-extrabold text-sm text-white">Alok Kumar Sahu</h4>
                  <p className="text-[10px] text-foreground/40 font-mono mt-0.5">Founder & Lead Architect</p>
                  
                  {/* Social links */}
                  <div className="flex gap-2 mt-3">
                    {[
                      { url: "https://alokkumarsahu.in", icon: Globe },
                      { url: "https://github.com/alokkumar2510", icon: Github },
                      { url: "https://www.linkedin.com/in/alok-kumar-sahu-7a7059370/", icon: Linkedin },
                      { url: "https://x.com/alok_chintu", icon: Twitter }
                    ].map((item, idx) => {
                      const Icon = item.icon;
                      return (
                        <a
                          key={idx}
                          href={item.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="p-1.5 bg-white/5 border border-white/5 hover:border-white/20 text-white/50 hover:text-white rounded-lg transition-transform duration-300 hover:scale-105"
                        >
                          <Icon className="w-3.5 h-3.5" />
                        </a>
                      );
                    })}
                  </div>
                </div>
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
