# CLAUDE.md — infraestructura-it.github.io
**Proyecto:** Sitio corporativo IIT  
**Repo:** `infraestructura-it/infraestructura-it.github.io`  
**Deploy:** GitHub Pages → `infraestructura-it.github.io` → `infraestructura-it.com` (Cloudflare)  
**Stack:** Vanilla HTML · CSS · JS · Sin frameworks · Sin build step  
**Última actualización:** 2026-06-26  

---

## Arquitectura del sitio

```
infraestructura-it.github.io/
├── index.html            ← Homepage
├── datacenter.html       ← Servicio: Data Center Modular
├── solar.html            ← Servicio: Energía Solar
├── redes.html            ← Servicio: Redes Empresariales
├── iot.html              ← Servicio: IoT & Automatización
├── ia.html               ← Servicio: IA & Automatización
├── casos.html            ← Portafolio de proyectos ejecutados
├── assets/
│   ├── logo-iit-core.svg ← Logo chip 1080×1080 (redes sociales / OG image)
│   ├── logo-iit-nav.svg  ← Logo horizontal compacto 260×44 (referencia)
│   └── favicon.ico
└── CLAUDE.md             ← Este archivo
```

> **Nota:** El logo del nav está incrustado **inline SVG** directamente en el `<a class="nav-logo">` de cada página HTML. No se carga como `<img src>` — esto evita una petición HTTP extra y garantiza que los colores y pines se rendericen correctamente en todos los navegadores.

---

## Identidad visual IIT

| Token | Valor | Uso |
|---|---|---|
| `--bg` | `#080b10` | Fondo global |
| `--surface` | `#0e1420` | Superficies elevadas |
| `--card` | `#131b28` | Cards de servicio |
| `--border` | `#1e2d42` | Bordes, separadores |
| `--cyan` | `#00d4ff` | Acento principal (Datacenter, IA, nav) |
| `--green` | `#10b981` | Acento Redes · pines verdes del logo |
| `--amber` | `#f59e0b` | Acento Solar |
| `--purple` | `#7c3aed` | Acento IoT |
| `--text` | `#e2e8f0` | Texto principal |
| `--muted` | `#64748b` | Texto secundario |
| `--dim` | `#334155` | Texto terciario / labels |

**Tipografía:**
- Display/Headings: `Syne` (Google Fonts) — `font-weight: 800`
- Monoespaciado / logo / valores técnicos: `Space Mono`
- Fallback: `DM Mono, system-ui, sans-serif`

**Color acento por página de servicio:**

| Página | Color acento | Hero chip |
|---|---|---|
| `datacenter.html` | `#00d4ff` cyan | RACK-01 ONLINE |
| `solar.html` | `#f59e0b` amber | INVERSOR 5kWp SOC 87% |
| `redes.html` | `#10b981` green | CORE SWITCH UPLINK 10G |
| `iot.html` | `#7c3aed` purple | ESP32-S3 12 NODOS ACTIVOS |
| `ia.html` | `#00d4ff` cyan | CLAUDE API TEMPERATURA 0 |

---

## Logo IIT — especificaciones

### Logo chip cuadrado `logo-iit-core.svg`
- **Uso:** Perfil de redes sociales, Instagram, LinkedIn, OG image
- **Tamaño:** 1080×1080 px (exportado con `width="1080" height="1080"`)
- **ViewBox:** `0 0 680 680`
- **Elementos:** Chip IC con pines cyan y verdes, grid interior, core circular, `IIT-CORE`, `REV.2026`, `infraestructura-it.com`
- **Leyenda:** `infraestructura-it.com` centrada bajo el chip con separador de puntos cyan

### Logo nav inline SVG
- **Uso:** `<a class="nav-logo">` en todas las páginas HTML — **incrustado inline**
- **ViewBox:** `0 0 260 44` · renderizado a `width="200" height="32"`
- **Elementos:** Chip mini con pines (cyan + verde), separador, `IIT` (segunda I en cyan), separador, `INFRAESTRUCTURA / IT · BOGOTÁ`
- **CSS nav-logo:**
  ```css
  .nav-logo { display:flex; align-items:center; text-decoration:none; line-height:0; }
  .nav-logo:hover { opacity: 0.85; }
  ```
- **Accesibilidad:** `aria-label="Infraestructura-IT — Inicio"` en el `<a>`

### Actualizar el logo en todas las páginas
Si se modifica el SVG del logo nav, hay que reemplazarlo en los **5 archivos de servicio** + `index.html` + `casos.html`. Script de reemplazo:
```powershell
# En PowerShell desde el repo
$OLD = '<a href="/index.html" class="nav-logo" aria-label="Infraestructura-IT — Inicio"><svg ...'
$NEW = '<a href="/index.html" class="nav-logo" aria-label="Infraestructura-IT — Inicio"><svg ...'  # nuevo SVG
Get-ChildItem *.html | ForEach-Object { (Get-Content $_) -replace [regex]::Escape($OLD), $NEW | Set-Content $_ }
```

---

## Estructura de cada página de servicio

```
1. <nav>              — sticky, blur, logo SVG inline + links + CTA
2. <section.hero>     — hero-chip animado + h1 + subtítulo + 2 CTAs + status bar
3. <div.stats-bar>    — 4 métricas (grid 4 col)
4. <section>          — 6 tarjetas (.services-grid) + marcas (.brands-row)
5. <section>          — Proceso 5 pasos (.proceso-grid)
6. <section>          — Tabla specs (.specs-table)
7. <section>          — CTA final (.cta-block)
8. <footer>           — copyright + email
```

---

## Componentes CSS reutilizables

| Clase | Descripción |
|---|---|
| `.nav-logo` | Contenedor del SVG inline del logo — flex, sin text-decoration |
| `.hero-chip` | Badge animado con punto pulsante, color por página |
| `.stats-bar` | Grid 4 columnas con separadores entre items |
| `.services-grid` | Grid auto-fit 280px, gap 1px (efecto cuadrícula) |
| `.svc-card` | Card servicio con hover bg |
| `.tag` / `.tag.accent` | Pill técnico, `.accent` usa color de la página |
| `.brand-pill` | Pill de marca, fondo surface |
| `.proceso-grid` | Grid 5 col para proceso numerado |
| `.specs-table` | Tabla técnica con hover row y `.val` monospace cyan |
| `.cta-block` | Banner CTA flex con texto + botones |
| `.btn-primary` | Filled con color acento de la página |
| `.btn-outline` | Outline que adopta color acento en hover |

---

## SEO

Cada página tiene `<title>`, `<meta description>` y `<meta keywords>` con términos Colombia/Bogotá. Schema.org pendiente → issue #1.

---

## Issues abiertos

| # | Descripción | Prioridad |
|---|---|---|
| #1 | Schema.org `LocalBusiness` + `Service` en todas las páginas | Alta |
| #2 | Fichas reales en `casos.html` (Proarques, JVTEL, etc.) | Alta |
| #3 | ~~Logo nav inline en `index.html` y `casos.html`~~ — **CERRADO** | ✅ |
| #4 | `og-image.png` 1200×630 usando `logo-iit-core.svg` | Media |
| #5 | Sección testimonios en homepage | Media |
| #6 | Formulario contacto funcional (Formspree) | Media |
| #7 | Sección certificaciones (RETIE, TIA-942, Uptime) | Baja |
| #8 | `prefers-reduced-motion` para animaciones | Baja |

---

## Historial de cambios

### v2.2 — 2026-06-26
- **fix:** Nav de páginas de servicio unificado con index — agrega Chatbot y Blog, logo texto "Infraestructura-IT"
- **fix:** `casos.html` creado con card Proarques linkeando a `infraestructura-it.com/caso-exito-solar-offgrid-proarques/`
- **fix:** Logo del nav = texto simple "Infraestructura-**IT**" (no SVG) — coherente con index, punto 4 respetado
- **chore:** CLAUDE.md v2.2

### v2.1 — 2026-06-26
- **feat:** Logo IIT-CORE chip SVG 1080×1080 con leyenda `infraestructura-it.com` (`logo-iit-core.svg`)
- **feat:** Logo nav horizontal inline SVG en los 5 archivos de servicio (datacenter, solar, redes, iot, ia)
- **fix:** CSS `.nav-logo` actualizado para contener SVG (flex, sin text-decoration)
- **chore:** CLAUDE.md actualizado con spec completa del logo y tabla de colores por página

### v2.0 — 2026-06-26
- **feat:** Contenido real en 5 páginas de servicio (6 cards + specs + proceso + CTA)
- **feat:** Stats bar con 4 métricas por página
- **feat:** Marcas reales por servicio (Schneider, Felicity, Cisco, ESP32, Claude API...)
- **feat:** SEO meta tags en todas las páginas
- **feat:** Color acento diferenciado por página
- **chore:** CLAUDE.md inicial del proyecto

### v1.0 — 2024 (baseline)
- Hero chip animado por página, nav sticky, footer

---

## Flujo de trabajo Git (trazabilidad IIT)

```powershell
cd C:\Users\User01\OneDrive\2026-proyectos\infraestructura-it.github.io

git status
git add .
git commit -m "feat: logo IIT-CORE SVG inline en nav + leyenda infraestructura-it.com closes #3

- logo-iit-core.svg: chip 1080x1080 con infraestructura-it.com
- logo-iit-nav.svg: version horizontal compacta (referencia)
- datacenter/solar/redes/iot/ia.html: logo inline SVG en nav
- CLAUDE.md v2.1: spec logo actualizada"

git push origin main
```

---

## Notas de arquitectura

- **Sin build step:** HTML/CSS/JS plano. Sin `package.json`, bundler ni preprocesador.
- **Logo inline:** SVG del nav incrustado directamente en el HTML — cero peticiones extra, funciona offline.
- **Fuentes:** Google Fonts (`Syne` + `Space Mono`). Fallback sistema mantiene legibilidad.
- **Deploy automático:** `push` a `main` → GitHub Pages actualiza en ~30 segundos.
- **DNS:** Cloudflare CNAME `infraestructura-it.com` → `infraestructura-it.github.io`.
- **Chatbot:** `/iit-chatbot/` es subdirectorio independiente, no afectado.

---

*Mantenido por Jairo Sepúlveda — IIT Director General — jairo@infraestructura-it.com*
