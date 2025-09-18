export default {
  build: {
    lib: {
      entry: "server/index.ts",
      formats: ["es"],
      fileName: "node-build",
    },
    outDir: "dist/server",
    rollupOptions: {
      external: ["express", "cors", "dotenv", "@prisma/client", "bcryptjs", "jsonwebtoken", "nodemailer", "@neondatabase/serverless"],
    },
    target: "node18",
    ssr: true,
  },
};
