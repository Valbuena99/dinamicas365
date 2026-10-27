import { defineConfig } from 'vite'

// Configuración mínima mientras se restaura el código fuente de TanStack Start.
// Reemplázala por la configuración original del proyecto al recuperarlo.
export default defineConfig({
  publicDir: false,
  build: {
    outDir: 'dist/client',
    emptyOutDir: true,
  },
})
