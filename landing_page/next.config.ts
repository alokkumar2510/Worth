import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  images: {
    unoptimized: true, // Required for static exports since Next.js image optimizer runs on node server
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
};

export default nextConfig;
