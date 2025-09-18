import { defineConfig, Plugin } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  server: {
    host: "::",
    port: 8080,
    fs: {
      allow: ["./client", "./shared", "./"],
      deny: [".env", ".env.*", "*.{crt,pem}", "**/.git/**", "server/**"],
    },
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
        secure: false,
      }
    }
  },
  build: {
    outDir: "dist/spa",
    rollupOptions: {
      external: ["next/navigation", "next/router", "next/image"],
    },
  },
  plugins: [
    react({
      // Fix JSX runtime for production builds
      jsxImportSource: "react",
      plugins: [],
    }),
    // No longer need expressPlugin since we use proxy
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./client"),
      "@shared": path.resolve(__dirname, "./shared"),
    },
  },
  define: {
    "process.env": {},
    global: "globalThis",
  },
  // Ensure proper JSX runtime handling
  esbuild: {
    jsx: "automatic",
    jsxImportSource: "react",
  },
}));
