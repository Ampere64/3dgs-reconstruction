import { defineConfig } from "vite";

export default defineConfig({
  base: "./",
  server: {
    host: true,
    port: 5173,
    headers: {
      // 启用 crossOriginIsolated，供 gaussian-splats-3d 的 SharedArrayBuffer Worker 使用
      "Cross-Origin-Opener-Policy": "same-origin",
      "Cross-Origin-Embedder-Policy": "require-corp",
    },
  },
});
