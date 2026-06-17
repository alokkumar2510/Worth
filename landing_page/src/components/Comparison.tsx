"use client";

import React from "react";
import { motion } from "framer-motion";
import { X, Check } from "lucide-react";

export default function Comparison() {
  const points = [
    {
      label: "Core Philosophy",
      traditional: "Micro-level daily budgeting and expense categorization.",
      worth: "Macro-level Net Worth growth and wealth intelligence command.",
    },
    {
      label: "User Action",
      traditional: "Tedious manual logging of every coffee, snack, and bill purchase.",
      worth: "Track total balance weights, principal growth, and liabilities.",
    },
    {
      label: "Data Freedom",
      traditional: "Forced connection to banks or automated parsers that constantly break.",
      worth: "Complete adjustment freedom with audit logs and reason-history sheets.",
    },
    {
      label: "Monetization",
      traditional: "Laced with third-party ads, credit card promotions, and loans.",
      worth: "100% private. Offline first database with zero cross-selling.",
    },
    {
      label: "Milestones Celebration",
      traditional: "Childish game badges, cartoon medals, and trophy gamification.",
      worth: "Luxury, custom-painted geometric crystal unlock dialogs.",
    },
    {
      label: "Expected Income & Receivables",
      traditional: "Ignored or combined into simple monthly budget pools.",
      worth: "Explicit modules to track debt recovery and forthcoming revenue streams.",
    },
  ];

  return (
    <section id="comparison" className="py-24 bg-[#050507] relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <span className="text-xs font-bold text-primary uppercase tracking-widest">
            Comparative Architecture
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mt-6 mb-6">
            Designed for Wealth Builders, <br />Not Expense Loggers
          </h2>
          <p className="text-lg text-foreground/60">
            Stop worrying about every cup of coffee. Start optimizing your aggregate asset values, reducing outstanding debts, and celebrating growth milestones.
          </p>
        </div>

        {/* Comparison Table / Desktop grid */}
        <div className="max-w-5xl mx-auto">
          {/* Header Row */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-4 border-b border-white/5 pb-6 mb-6 text-center md:text-left">
            <div className="md:col-span-4 text-xs font-bold text-foreground/40 uppercase tracking-widest">Category</div>
            <div className="md:col-span-4 text-xs font-bold text-red-500/80 uppercase tracking-widest">Traditional Apps</div>
            <div className="md:col-span-4 text-xs font-bold text-primary uppercase tracking-widest">Worth Center</div>
          </div>

          {/* Rows */}
          <div className="space-y-4">
            {points.map((point, idx) => (
              <motion.div
                key={point.label}
                initial={{ opacity: 0, y: 15 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: idx * 0.05 }}
                className="grid grid-cols-1 md:grid-cols-12 gap-4 p-4 rounded-xl hover:bg-white/5 transition-colors items-center border border-transparent hover:border-white/5"
              >
                {/* Category name */}
                <div className="md:col-span-4 font-bold text-white tracking-wide text-sm md:text-base">
                  {point.label}
                </div>

                {/* Traditional */}
                <div className="md:col-span-4 flex items-start gap-2 text-sm text-foreground/50">
                  <X className="w-5 h-5 text-red-500/60 shrink-0 mt-0.5" />
                  <span>{point.traditional}</span>
                </div>

                {/* Worth */}
                <div className="md:col-span-4 flex items-start gap-2 text-sm text-white font-medium">
                  <Check className="w-5 h-5 text-primary shrink-0 mt-0.5" />
                  <span>{point.worth}</span>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

      </div>
    </section>
  );
}
