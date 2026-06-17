"use client";

import React from "react";
import { motion } from "framer-motion";
import { GlowCard } from "./GlowCard";
import { 
  Wallet, 
  TrendingDown, 
  TrendingUp, 
  Coins, 
  ArrowUpRight, 
  Target, 
  BarChart3, 
  WifiOff, 
  RefreshCw, 
  Fingerprint 
} from "lucide-react";

interface FeatureItem {
  icon: React.ComponentType<any>;
  title: string;
  description: string;
  badge?: string;
}

export default function Features() {
  const featuresList: FeatureItem[] = [
    {
      icon: Wallet,
      title: "Assets Tracking",
      description: "Aggregate cash, bank balances, physical possessions, and custom assets with derived balance tracking.",
    },
    {
      icon: TrendingDown,
      title: "Liability Management",
      description: "Manage loans, credit cards, and debt repayment plans while monitoring outstanding principal balances.",
    },
    {
      icon: TrendingUp,
      title: "Investment Tracking",
      description: "Track investment capital and market fluctuations across equities, mutual funds, gold, and real estate.",
    },
    {
      icon: Coins,
      title: "Receivables Tracking",
      description: "Track lent balances, loans to associates, recovery records, and downstream transaction reconciliations.",
    },
    {
      icon: ArrowUpRight,
      title: "Expected Income Tracking",
      description: "Log forthcoming payouts, salary streams, or sales. Convert expected income to transactions upon receipt.",
    },
    {
      icon: Target,
      title: "Goals Tracking",
      description: "Set milestone boundaries for capital preservation, real estate, or retirement. Monitor delta logs.",
    },
    {
      icon: BarChart3,
      title: "Monthly Wealth Reports",
      description: "Access a detailed monthly snapshot detailing net inflows, capital expansion, asset ratios, and growth vectors.",
      badge: "Premium",
    },
    {
      icon: WifiOff,
      title: "Offline First",
      description: "All database queries, balance logs, and history sheets run 100% locally. Zero server latency.",
    },
    {
      icon: RefreshCw,
      title: "Secure Cloud Sync",
      description: "Synchronize encrypted database snapshots to private Firestore document trees with automatic conflict resolution.",
    },
    {
      icon: Fingerprint,
      title: "Biometric Security",
      description: "Protect financial records with biometric locks, passcode guards, and strict route redirection logic.",
    },
  ];

  return (
    <section id="features" className="py-24 bg-[#050507] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header Section */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="text-xs font-bold text-primary uppercase tracking-widest mb-3"
          >
            Capabilities
          </motion.div>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-6"
          >
            Granular Wealth Command Center.
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="text-lg text-foreground/60 leading-relaxed"
          >
            Worth strips away the complexity of traditional budgeting and concentrates purely on your net worth evolution.
          </motion.p>
        </div>

        {/* Feature Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {featuresList.map((feature, idx) => {
            const Icon = feature.icon;
            return (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: idx * 0.05 }}
              >
                <GlowCard className="p-8 h-full flex flex-col justify-between items-start cursor-default">
                  <div className="w-full">
                    {/* Header: Icon & Badge */}
                    <div className="flex justify-between items-center mb-6">
                      <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-accent">
                        <Icon className="w-5 h-5" />
                      </div>
                      {feature.badge && (
                        <span className="text-[10px] uppercase font-bold tracking-widest text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-full">
                          {feature.badge}
                        </span>
                      )}
                    </div>

                    {/* Title */}
                    <h3 className="text-xl font-bold text-white mb-3 tracking-wide">{feature.title}</h3>
                    
                    {/* Description */}
                    <p className="text-sm text-foreground/60 leading-relaxed">{feature.description}</p>
                  </div>
                </GlowCard>
              </motion.div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
