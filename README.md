# Dinamicas365

Plataforma web de dinámicas/rifas: listado de rifas activas, detalle de cada dinámica con su cuadrícula de boletos, panel de administración y panel de vendedores.

- **Producción:** https://dinamicas365.netlify.app
- **Panel de Netlify:** https://app.netlify.com/projects/dinamicas365
- **Repositorio:** https://github.com/Valbuena99/dinamicas365 (rama `main`)

---

## 1. Stack tecnológico

| Pieza | Tecnología |
| --- | --- |
| Framework | [TanStack Start](https://tanstack.com/start) (React + SSR) |
| Bundler | Vite (Rolldown) |
| Hosting / SSR | Netlify (funciones en `us-east-1`) |
| Base de datos | Netlify Database (Postgres administrado) con migraciones |
| Autenticación | Netlify Identity (roles en `app_metadata.roles`) |
| Archivos subidos | Endpoint `/api/upload` (Netlify Blobs) |
| Imágenes | Netlify Image CDN (`/.netlify/images`) |

---

## 2. ⚠️ Estado actual del repositorio (leer antes de desplegar)

El repositorio **solo contiene la salida compilada del cliente**:

```
assets/        ← JS/CSS ya compilados (con hash en el nombre)
img/           ← imágenes de premios
favicon.ico
netlify.toml
```

Las migraciones de la base de datos ya están en `netlify/database/migrations/`, pero **falta el código fuente**: no hay `package.json`, `src/`, `vite.config.*` ni funciones del servidor. Con el contenido actual, un despliegue desde Git **falla** por estas razones:

1. `netlify.toml` ejecuta `vite build`, pero sin `package.json` Netlify no instala dependencias y Vite no existe.
2. El directorio de publicación `dist/client` no existe en el repositorio.
3. La base de datos ya tiene estas migraciones aplicadas, y Netlify exige que **cada una exista en disco con su contenido original** (ya están en el repositorio; no las borres ni las edites):
   - `20261026222416_create_raffle_tables`
   - `20261026222417_seed_demo_raffles`
   - `20261026234259_add_ticket_shares_settings_results`
   - `20261026234303_copy_tickets_seed_settings`
   - `20261026234502_drop_legacy_tickets`
4. Sin el código del servidor (SSR, `/api/upload`, acceso a base de datos) la app no funciona aunque se suban los archivos estáticos.

La versión en producción funciona porque se publicó desde un despliegue que sí incluía el código fuente, no desde el contenido actual de `main`.

### Configuración temporal

Para que el build no falle mientras se recupera el código fuente, el repositorio incluye un `index.html` de mantenimiento y un `vite.config.mjs` mínimo que lo compila en `dist/client`.

> **Importante:** si se despliegan estos archivos a producción (`main`), el sitio mostrará la página de mantenimiento en lugar de la app de rifas. Restaura primero el código fuente y después borra `index.html` y `vite.config.mjs` (o reemplázalos por los originales).

### Cómo recuperarlo

1. Abre el último despliegue en producción en el panel de Netlify (**Deploys → despliegue publicado**). Ese despliegue tiene el código fuente adjunto: descárgalo desde ahí.
2. Copia en la raíz de este repositorio el proyecto completo (`package.json`, `package-lock.json`, `src/`, `vite.config.ts`, `netlify/`, migraciones, etc.).
3. Borra del repositorio los artefactos compilados (`assets/`, archivos con hash). Se regeneran en cada build.
4. Verifica la estructura de la sección 3 y haz *commit* + *push* a `main`.

---

## 3. Estructura esperada del proyecto

```
.
├── netlify.toml
├── package.json
├── package-lock.json          # versiona el lockfile para builds reproducibles
├── vite.config.ts             # incluye el plugin de TanStack Start y @netlify/vite-plugin-tanstack-start
├── tsconfig.json
├── public/                    # favicon.ico, img/premio-*.png
├── src/
│   ├── routes/                # /, /dinamica/$raffleId, /admin, /vendedor, /api/upload
│   └── ...
└── netlify/
    └── database/
        └── migrations/        # las 5 migraciones listadas arriba, SIN modificar
```

`.gitignore` recomendado:

```
node_modules/
dist/
.netlify/
.env
```

---

## 4. Configuración de Netlify (`netlify.toml`)

```toml
[build]
  command = "vite build"
  publish = "dist/client"

[build.environment]
  NODE_VERSION = "24"

[dev]
  framework = "#custom"
  command = "npm run dev"
  targetPort = 3000
  port = 8888
```

- `publish = "dist/client"` es la salida de TanStack Start. El plugin de Netlify genera la función SSR automáticamente.
- `NODE_VERSION = "24"`: usa la misma versión mayor en local.
- `package.json` debe tener al menos estos scripts:

```json
{
  "scripts": {
    "dev": "vite dev --port 3000",
    "build": "vite build"
  }
}
```

---

## 5. Desarrollo local

Requisitos: Node 24, npm y Netlify CLI (`npm i -g netlify-cli`).

```bash
npm install
netlify login
netlify link            # elige el proyecto "dinamicas365"
netlify dev             # http://localhost:8888
```

`netlify dev` emula Identity, Blobs, Image CDN, funciones y la base de datos, así que no hacen falta credenciales manuales.

---

## 6. Despliegue

### Despliegue continuo (recomendado)

Cada *push* a `main` dispara un build de producción. Los *pull requests* generan **Deploy Previews**, cada uno con su propia rama de base de datos, así que puedes probar migraciones sin tocar producción.

### Despliegue manual con la CLI

```bash
netlify deploy           # borrador / preview
netlify deploy --prod    # producción
```

### Lista de verificación antes de desplegar

- [ ] Existen `package.json` y el lockfile en la raíz.
- [ ] Las 5 migraciones aplicadas existen con su contenido original.
- [ ] Los cambios de esquema van en una **migración nueva** con un timestamp posterior.
- [ ] `node_modules/`, `dist/` y `.netlify/` no están versionados.
- [ ] No hay secretos en el código ni en `netlify.toml`.
- [ ] Probaste `netlify dev` en local sin errores.

---

## 7. Base de datos y migraciones

- Producción usa la rama de base de datos `production`. Cada Deploy Preview usa una rama aislada.
- Las migraciones se aplican automáticamente durante el despliegue.
- **Nunca edites, renombres ni borres una migración ya aplicada.** Netlify rechaza el despliegue. Para corregir algo, crea una migración nueva que lo arregle.
- Si faltan migraciones en disco, recupéralas desde la base de datos con:

  ```bash
  netlify db migrations pull --force
  ```

---

## 8. Autenticación y roles

- Los usuarios se gestionan con **Netlify Identity** (panel → *Identity*).
- Los roles se leen de `app_metadata.roles` (por ejemplo `admin`, `vendedor`) y controlan el acceso a `/admin` y `/vendedor`.
- El registro de vendedores está restringido: asigna los roles desde el panel de Identity o invita a los usuarios desde ahí.

---

## 9. Variables de entorno

Netlify inyecta automáticamente las credenciales de la base de datos, Blobs e Identity, así que no hay que configurarlas a mano. Si agregas variables propias:

```bash
netlify env:set NOMBRE_VARIABLE valor
```

O usa el panel: **Project configuration → Environment variables**. No subas archivos `.env` al repositorio.

---

## 10. Solución de problemas

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `vite: command not found` | Falta `package.json` o la dependencia `vite` | Restaura el código fuente (sección 2) |
| `Deploy directory 'dist/client' does not exist` | El build no se ejecutó o falló antes | Revisa el log del build anterior |
| Error de migraciones faltantes o modificadas | Se borró o editó una migración aplicada | Restaura el archivo original y crea una migración nueva |
| 404 en rutas como `/admin` | No se generó la función SSR | Verifica el plugin de Netlify en `vite.config.ts` |
| Las imágenes de `/.netlify/images` no cargan | Dominio remoto no permitido | Añade `[images] remote_images = [...]` en `netlify.toml` |
| El login no funciona | Identity deshabilitado | Actívalo en el panel → *Identity* |
| La versión de Node no coincide | Local distinto de 24 | Usa `nvm use 24` |

Logs: panel de Netlify → **Deploys** (build) y **Logs → Functions** (servidor).
