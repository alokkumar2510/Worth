"use client";

import React from "react";
import { motion } from "framer-motion";
import { Sparkles, Compass, CheckCircle2, TrendingUp, Gem } from "lucide-react";

interface MilestoneStep {
  icon: React.ComponentType<any>;
  title: string;
  subtitle: string;
  description: string;
  worth: string;
  color: string;
}

export default function Timeline() {
  const steps: MilestoneStep[] = [
    {
      icon: Compass,
      title: "Started Tracking",
      subtitle: "Day One Reached",
      description: "Initialized your local Drift SQLite database, aggregate your first cash accounts, and secure with biometrics.",
      worth: "₹0",
      color: "from-blue-500 to-indigo-500",
    },
    {
      icon: TrendingUp,
      title: "First Investment Logged",
      subtitle: "Capital Deployment",
      description: "Recorded your primary mutual fund SIP or equity transaction. Watch principal capital adjust to market value changes.",
      worth: "₹50K",
      color: "from-indigo-500 to-primary",
    },
    {
      icon: CheckCircle2,
      title: "₹100K Milestone",
      subtitle: "First Milestone Unlocked",
      description: "Unlocked the ₹100,000 net worth boundary. Custom badge painting triggers a global celebration dialog overlay.",
      worth: "₹100K",
      color: "from-primary to-accent",
    },
    {
      icon: Sparkles,
      title: "₹500K Milestone",
      subtitle: "Half Million Club",
      description: "Halfway to the first million. Allocation weights balance out liabilities, and net worth reports generate historical growth graphs.",
      worth: "₹500K",
      color: "from-accent to-fuchsia-500",
    },
    {
      icon: Gem,
      title: "₹1M Milestone",
      subtitle: "Millionaire Celebration",
      description: "Unlock the ultimate standard milestone. Custom double-octahedron crystal badges rotate and pulse in full luxury glassmorphic panels.",
      worth: "₹10L",
      color: "from-fuchsia-500 to-amber-500",
    },
  ];

  return (
    <section id="timeline" className="py-24 bg-[#050507] relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute top-1/2 left-0 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-24">
          <span className="text-xs font-bold text-accent uppercase tracking-widest bg-accent/10 border border-accent/20 px-3 py-1 rounded-full">
            Milestones Track
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mt-6 mb-6">
            The Wealth Evolution Timeline
          </h2>
          <p className="text-lg text-foreground/60">
            Celebrate meaningful wealth growth automatically. Watch the tracker outline your financial achievements as you build capital.
          </p>
        </div>

        {/* Timeline Path */}
        <div className="relative max-w-4xl mx-auto">
          {/* Vertical Center Line */}
          <div className="absolute left-1/2 -translate-x-1/2 top-4 bottom-4 w-[2px] bg-white/5" />

          {/* Vertical Glowing Line on scroll-fill */}
          <motion.div
            initial={{ height: 0 }}
            whileInView={{ height: "92%" }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 2, ease: "easeInOut" }}
            className="absolute left-1/2 -translate-x-1/2 top-4 w-[2px] bg-gradient-to-b from-primary via-accent to-amber-500 shadow-[0_0_10px_rgba(124,77,255,0.5)] z-0"
          />

          {/* Steps */}
          <div className="space-y-20">
            {steps.map((step, idx) => {
              const Icon = step.icon;
              const isEven = idx % 2 === 0;

              return (
                <div key={step.title} className="relative flex flex-col md:flex-row items-center justify-between">
                  {/* Left Side Content (Desktop) */}
                  <div className={`w-full md:w-[45%] order-2 md:order-1 ${isEven ? "md:text-right" : "md:opacity-0 pointer-events-none md:order-3"}`}>
                    {!isEven && <div className="hidden md:block" />}
                    {isEven && (
                      <motion.div
                        initial={{ opacity: 0, x: -30 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.5, delay: 0.1 }}
                        className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-md relative"
                      >
                        <span className={`inline-block text-[10px] font-mono font-bold tracking-widest text-transparent bg-clip-text bg-gradient-to-r ${step.color} uppercase mb-2`}>
                          {step.subtitle}
                        </span>
                        <h3 className="text-xl font-bold text-white mb-2">{step.title}</h3>
                        <p className="text-sm text-foreground/60 leading-relaxed">{step.description}</p>
                      </motion.div>
                    )}
                  </div>

                  {/* Central Node Checkpoint */}
                  <div className="absolute left-1/2 -translate-x-1/2 top-0 md:top-1/2 md:-translate-y-1/2 z-10 flex flex-col items-center">
                    <motion.div
                      initial={{ scale: 0 }}
                      whileInView={{ scale: 1 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.5, type: "spring", stiffness: 100 }}
                      className={`w-12 h-12 rounded-full bg-[#050507] border-2 border-white/10 flex items-center justify-center text-white relative group-hover:border-primary transition-colors`}
                    >
                      <div className={`absolute inset-0.5 rounded-full bg-gradient-to-tr ${step.color} opacity-20 blur-sm`} />
                      <Icon className="w-5 h-5 relative z-10 text-white" />
                    </motion.div>
                    <span className="text-[10px] font-bold text-foreground/40 font-mono mt-2 bg-[#050507] px-2 py-0.5 border border-white/5 rounded-full">
                      {step.worth}
                    </span>
                  </div>

                  {/* Right Side Content (Desktop) */}
                  <div className={`w-full md:w-[45%] order-2 md:order-3 ${!isEven ? "md:text-left" : "md:opacity-0 pointer-events-none"}`}>
                    {isEven && <div className="hidden md:block" />}
                    {!isEven && (
                      <motion.div
                        initial={{ opacity: 0, x: 30 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.5, delay: 0.1 }}
                        className="glass-panel p-6 border border-white/5 bg-[#0B0B0F]/50 backdrop-blur-md relative"
                      >
                        <span className={`inline-block text-[10px] font-mono font-bold tracking-widest text-transparent bg-clip-text bg-gradient-to-r ${step.color} uppercase mb-2`}>
                          {step.subtitle}
                        </span>
                        <h3 className="text-xl font-bold text-white mb-2">{step.title}</h3>
                        <p className="text-sm text-foreground/60 leading-relaxed">{step.description}</p>
                      </motion.div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

      </div>
    </section>
  );
}
