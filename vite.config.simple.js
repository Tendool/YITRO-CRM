import react from "@vitejs/plugin-react-swc";
import path from "path";

export default {
  server: {
    host: "::",
    port: 8080,
    fs: {
      allow: ["./client", "./shared"],
      deny: [".env", ".env.*", "*.{crt,pem}", "**/.git/**", "server/**"],
    },
  },
  build: {
    outDir: "dist/spa",
    rollupOptions: {
      external: ["next/navigation", "next/router", "next/image"],
    },
  },
  plugins: [
    react({
      jsxImportSource: "react",
      plugins: [],
    })
  ],
  resolve: {
    alias: {
      "@": path.resolve(process.cwd(), "./client"),
      "@shared": path.resolve(process.cwd(), "./shared"),
    },
  },
  define: {
    "process.env": {},
    global: "globalThis",
  },
  esbuild: {
    jsx: "automatic",
    jsxImportSource: "react",
  },
};
