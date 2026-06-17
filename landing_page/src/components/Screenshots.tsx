"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { LayoutDashboard, FolderKanban, History, LineChart, Settings } from "lucide-react";

interface ScreenShotItem {
  id: string;
  name: string;
  icon: React.ComponentType<any>;
  path: string;
  description: string;
}

export default function Screenshots() {
  const [activeTab, setActiveTab] = useState("dashboard");

  const screens: ScreenShotItem[] = [
    {
      id: "dashboard",
      name: "Dashboard",
      icon: LayoutDashboard,
      path: "/images/dashboard.png",
      description: "Get a unified look at your net worth, assets value, current debt, goal trackers, and next milestones.",
    },
    {
      id: "portfolio",
      name: "Portfolio",
      icon: FolderKanban,
      path: "/images/assets dashboard of portfolio.png",
      description: "Manage accounts, investments, liabilities, receivables, and expected incomes with custom adjustment reason logs.",
    },
    {
      id: "transactions",
      name: "Transactions",
      icon: History,
      path: "/images/transactions overview.png",
      description: "A gorgeous, collapsible Activity search timeline with chip categories, amount flows, and detailed filters.",
    },
    {
      id: "reports",
      name: "Reports",
      icon: LineChart,
      path: "/images/Finance report dashboard.png",
      description: "Track performance curves, historical net worth lines, and allocation ratios in the premium Wealth Intelligence Center.",
    },
    {
      id: "settings",
      name: "Settings",
      icon: Settings,
      path: "/images/settings.png",
      description: "Configure biometric security settings, manage local secure storage, database backups, and data purging.",
    },
  ];

  const activeScreen = screens.find((s) => s.id === activeTab) || screens[0];

  return (
    <section id="screenshots" className="py-24 bg-[#050507] relative overflow-hidden grid-bg">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <span className="text-xs font-bold text-accent uppercase tracking-widest bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
            Interface Showcase
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mt-6 mb-6">
            The Wealth OS Experience
          </h2>
          <p className="text-lg text-foreground/60">
            Interactive, highly fluid, and dark-themed mobile pages optimized for clarity, premium typography, and responsive touch controls.
          </p>
        </div>

        {/* Content Box */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">
          
          {/* Left Column: Screen Tabs & Description */}
          <div className="lg:col-span-5 flex flex-col gap-6">
            <div className="flex flex-col gap-3">
              {screens.map((screen) => {
                const Icon = screen.icon;
                const isActive = screen.id === activeTab;

                return (
                  <button
                    key={screen.id}
                    onClick={() => setActiveTab(screen.id)}
                    className={`flex items-center gap-4 p-4 rounded-xl text-left border transition-all duration-300 w-full ${
                      isActive 
                        ? "bg-white/5 border-primary text-white shadow-lg shadow-primary/5" 
                        : "bg-transparent border-transparent text-foreground/50 hover:text-white hover:bg-white/5"
                    }`}
                  >
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center border transition-colors ${
                      isActive ? "bg-primary/20 border-primary text-accent" : "bg-white/5 border-white/5 text-foreground/40"
                    }`}>
                      <Icon className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="font-bold text-sm md:text-base tracking-wide">{screen.name}</h3>
                      <p className={`text-xs mt-1 transition-opacity ${isActive ? "text-foreground/70" : "text-foreground/40"}`}>
                        {isActive ? "Viewing layout" : "Click to view"}
                      </p>
                    </div>
                  </button>
                );
              })}
            </div>

            {/* Dynamic Description Box */}
            <motion.div
              key={activeScreen.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="glass-panel p-6 border border-white/5"
            >
              <h3 className="text-lg font-bold text-white mb-2">{activeScreen.name} Overview</h3>
              <p className="text-sm text-foreground/60 leading-relaxed">{activeScreen.description}</p>
            </motion.div>
          </div>

          {/* Right Column: High-Fidelity Glassmorphic Phone Mockup */}
          <div className="lg:col-span-7 flex justify-center items-center w-full">
            <div className="relative w-[300px] h-[610px] rounded-[45px] bg-[#050507] border-[10px] border-white/10 shadow-[0_25px_60px_-15px_rgba(124,77,255,0.25)] p-2 relative overflow-hidden flex flex-col items-center">
              
              {/* Camera Notch */}
              <div className="absolute top-4 w-28 h-6 bg-[#050507] rounded-full border border-white/5 z-20 flex items-center justify-center">
                <span className="w-2.5 h-2.5 rounded-full bg-blue-900/60 mr-2" />
                <span className="w-1.5 h-1.5 rounded-full bg-slate-900" />
              </div>

              {/* Screen container */}
              <div className="w-full h-full rounded-[35px] bg-surface relative overflow-hidden z-10">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={activeScreen.id}
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95 }}
                    transition={{ duration: 0.3 }}
                    className="w-full h-full relative"
                  >
                    {/* Background fallback gradient to look like the app background */}
                    <div className="absolute inset-0 bg-[#050507] z-0" />
                    {/* App screenshot */}
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img 
                      src={activeScreen.path}
                      alt={activeScreen.name}
                      className="w-full h-full object-cover relative z-10"
                    />
                  </motion.div>
                </AnimatePresence>
              </div>

              {/* Home Indicator Bar */}
              <div className="absolute bottom-2.5 w-24 h-1 bg-white/20 rounded-full z-20" />
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
