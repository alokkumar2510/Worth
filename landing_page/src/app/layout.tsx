import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Worth — Premium Wealth Intelligence Center & Personal Wealth OS",
  description: "Know What You're Worth. Track your net worth, cash flow assets, liabilities, investments, receivables, expected payouts, and milestone metrics in a dark luxury, privacy-first command center.",
  keywords: ["Worth", "Net Worth Tracker", "Wealth Intelligence Center", "Personal Wealth OS", "Wealthfront alternative", "Copilot Money alternative", "Offline financial tracker", "Wealth tracking APK", "Asset allocation dashboard"],
  authors: [{ name: "Alok Kumar Sahu", url: "https://alokkumarsahu.in" }],
  metadataBase: new URL("https://worth.alokkumarsahu.in"),
  alternates: {
    canonical: "/",
  },
  manifest: "/manifest.json",
  openGraph: {
    title: "Worth — Premium Wealth Intelligence Center & Personal Wealth OS",
    description: "Know What You're Worth. Track your net worth, cash flow assets, liabilities, investments, receivables, expected payouts, and milestone metrics in a dark luxury, privacy-first command center.",
    url: "https://worth.alokkumarsahu.in",
    siteName: "Worth",
    type: "website",
    locale: "en_US",
    images: [
      {
        url: "/og/og-image.png",
        width: 1200,
        height: 630,
        alt: "Worth Private Wealth OS",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Worth — Premium Wealth Intelligence Center & Personal Wealth OS",
    description: "Know What You're Worth. Track your net worth, assets, liabilities, and milestone metrics offline-first.",
    images: ["/og/og-image.png"],
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/icons/icon-192.png",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  // JSON-LD Structured Data Schema for Search Engines (SoftwareApplication & Brand)
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "Worth",
    "operatingSystem": "Android",
    "applicationCategory": "FinanceApplication",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "INR"
    },
    "description": "Know What You're Worth. Track your net worth, assets, liabilities, and milestone metrics in a dark luxury, privacy-first dashboard.",
    "author": {
      "@type": "Person",
      "name": "Alok Kumar Sahu",
      "url": "https://alokkumarsahu.in"
    },
    "downloadUrl": "https://github.com/alokkumar2510/Worth/releases/download/v1.11.0/app-release.apk"
  };

  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased dark`}
    >
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
        />
        <script
          dangerouslySetInnerHTML={{
            __html: `
              if ('serviceWorker' in navigator) {
                window.addEventListener('load', function() {
                  navigator.serviceWorker.register('/sw.js').then(
                    function(reg) {
                      console.log('PWA ServiceWorker registered successfully:', reg.scope);
                    },
                    function(err) {
                      console.error('PWA ServiceWorker registration failed:', err);
                    }
                  );
                });
              }
            `,
          }}
        />
      </head>
      <body className="min-h-full flex flex-col bg-[#050507] text-[#f4f4f6]">
        {children}
      </body>
    </html>
  );
}
