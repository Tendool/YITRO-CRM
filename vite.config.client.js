import path from "path";

export default {
  build: {
    outDir: "dist/spa",
    rollupOptions: {
      external: ["next/navigation", "next/router", "next/image"],
    },
  },
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
