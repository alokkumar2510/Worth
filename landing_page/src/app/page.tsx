"use client";

import React from "react";
import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Features from "@/components/Features";
import Timeline from "@/components/Timeline";
import Comparison from "@/components/Comparison";
import Screenshots from "@/components/Screenshots";
import Security from "@/components/Security";
import Founder from "@/components/Founder";
import DownloadSection from "@/components/Download";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <div className="bg-[#050507] text-[#f4f4f6] min-h-screen font-sans overflow-x-hidden flex flex-col justify-between">
      {/* Navigation Header */}
      <Navbar />

      {/* Main Sections */}
      <main className="flex-1">
        {/* Hero Banner & Self Drawing Line Chart */}
        <Hero />

        {/* Core Features Grid */}
        <Features />

        {/* Scrolling milestone vertical timeline */}
        <Timeline />

        {/* Budgets vs Worth comparative layout */}
        <Comparison />

        {/* Interactive Screenshot mockups */}
        <Screenshots />

        {/* Safety & technical overview */}
        <Security />

        {/* Founder Spotlight */}
        <Founder />

        {/* Bottom Download CTA Block */}
        <DownloadSection />
      </main>

      {/* Global Footer */}
      <Footer />
    </div>
  );
}
