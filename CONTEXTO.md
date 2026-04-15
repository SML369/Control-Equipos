# Dermato Control — Contexto del Proyecto

## ¿Qué es este proyecto?
Sistema de gestión para el consultorio dermatológico de la **Dra. Carolina Mejía (Dra. Red)**,
ubicado en Medellín, Colombia. Incluye dos áreas principales:

1. **Sistema de control de equipos** — registro de sesiones, inventario de transductores,
   lógica financiera y reportes mensuales por doctor.
2. **Contenido y marketing** — guiones, mensajes de WhatsApp, tablas de precios y materiales
   para redes sociales y campañas.

---

## Personas del proyecto

| Persona | Rol | PIN sistema |
|---|---|---|
| Santiago | Administrador — ingresa todos los datos | 1234 |
| Carolina | Doctora — dueña del Ultraformer | 5678 |
| Sneider | Doctor — dueño del Volnewmer | 9012 |
| Diana | Cosmetóloga | — |
| Vero | Cosmetóloga | — |
| Cristina | Cosmetóloga | — |

**Código para eliminar/editar registros:** `5027`

---

## Equipos del consultorio

| Equipo | Dueño | Tipo |
|---|---|---|
| Ultraformer MPT | Carolina | HIFU facial y corporal |
| Volnewmer | Sneider | HIFU con punteras especializadas |
| Volformer | Ambos | Combinación Ultraformer + Volnewmer |
| Aquapure | Ambos (50/50) | Limpieza facial con soluciones |

---

## Lógica financiera

### Ultraformer (dueño: Carolina) / Volnewmer (dueño: Sneider)
- **Dueño atiende:** `utilidad bruta - mantenimiento% - admin%` = ganancia del dueño
- **Uso cruzado (el otro doctor atiende):** `utilidad → 30% al dueño / 70% al visitante`
  (porcentaje configurable desde Configuración)

### Volformer
- Se calcula por separado para cada equipo según proporción de costos de disparos
- Porcentajes cruzados aplicados a cada lado independientemente

### Aquapure
- `precio - comisión referido - consumibles - pago cosmetóloga - mant% - admin%`
- Utilidad resultante: **50% Carolina / 50% Sneider**

### Costos de transductores
- **Ultraformer:** $700/disparo, 20.000 disparos por transductor
- **Volnewmer punteras:**
  - 0.25mm → $912,33/disparo (6.000 disparos)
  - 3mm → $1.368,5/disparo (4.000 disparos)
  - 4mm → $1.824,67/disparo (3.000 disparos)
  - 16mm → $1.824,67/disparo (3.000 disparos)

### Comisiones referidos
- Cosmetólogas: 5% en Aquapure / 3% en otros equipos
- Médicos (Carolina/Sneider): sin comisión cuando refieren

### Porcentajes configurables (desde pantalla Configuración)
- Cobro uso cruzado al dueño: **30%** (default)
- Mantenimiento — todos los equipos: **5%** (default)
- Admin / Santiago: **5%** (default)

---

## Infraestructura técnica

### Base de datos — Supabase
- **URL:** `https://sfcdoeuyjtmeovvderim.supabase.co`
- **Anon key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmY2RvZXV5anRtZW92dmRlcmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MTMzNTQsImV4cCI6MjA5MDk4OTM1NH0.8E35cofE8kLb5RhmpIc5Q0ygdKTRiy_9z0NHzNGPl3Q`

### Tablas en Supabase
| Tabla | Contenido |
|---|---|
| `sesiones` | Todas las sesiones registradas (campo `data` jsonb) |
| `inventario_ultra` | Transductores Ultraformer (campo `data` jsonb) |
| `inventario_vol` | Transductores Volnewmer (campo `data` jsonb) |
| `soluciones` | Compras de soluciones Aquapure (campo `data` jsonb) |
| `configuracion` | Porcentajes y lista de referidos (clave/valor jsonb) |
| `protocolos` | Todos los protocolos por equipo con precios y disparos |

### Hosting — GitHub Pages
- **Repositorio:** `https://github.com/SML369/Control-Equipos`
- **URL pública:** `https://SML369.github.io/Control-Equipos`
- **Archivo principal:** `index.html` (minúsculas, en la raíz)

### Formulario de sesiones — Jotform
- **URL:** `https://form.jotform.com/260947117694063`
- Carolina y Sneider llenan este formulario después de cada sesión
- Santiago registra la información en el sistema

### Sincronización — Google Sheets + Apps Script
- **Sheet ID:** `1jy6p8byZzZcr3pz6z1gWOPq7ZENwWQNCYItOu6ZR8tE`
- Script en Apps Script sincroniza Supabase → Sheets automáticamente cada día a las 7am
- Función manual: `sincronizarDatos()`
- Hojas generadas: `Sesiones`, `Transductores Ultraformer`, `Transductores Volnewmer`, `Soluciones Aquapure`

### Dashboard — Looker Studio (pendiente)
- Fuente: Google Sheets → Looker Studio
- Pendiente construir cuando haya primeras sesiones reales

---

## Identidad de marca

### Colores
| Color | Hex | Uso |
|---|---|---|
| Rojo/Terracotta | `#a53036` | Color principal, encabezados, botones |
| Arena | `#E7DCC9` | Fondos suaves, bordes |
| Dorado/Bronceado | `#B28B69` | Acentos secundarios |

### Tipografía
- Principal: **Montserrat**
- Secundaria: **TT Travels Next**

### Redes sociales
- Instagram/TikTok: `@caromejiadermatologia`

### Logos disponibles
- `Logo_png.png` — logo sobre fondo negro (recolorear a `#a53036` con fondo transparente para PDFs)
- `Logo_Color.jpeg` — versión color terracotta
- `Logo_png.png` con fondo negro — variante oscura

---

## Estructura del sistema HTML (index.html)

### Pantallas (páginas)
| ID página | Contenido |
|---|---|
| `page-nueva` | Formulario de nueva sesión |
| `page-sesiones` | Historial de sesiones con edición y eliminación |
| `page-pacientes` | Vista por paciente |
| `page-financiero` | Resumen financiero y desglose por doctor |
| `page-inv-ultra` | Inventario transductores Ultraformer |
| `page-inv-vol` | Inventario transductores Volnewmer |
| `page-inv-aqua` | Inventario soluciones Aquapure |
| `page-protocolos` | Gestión de protocolos (editar precios/disparos) |
| `page-config` | Configuración de porcentajes y referidos |

### Variables globales importantes
```javascript
const USUARIOS = {'1234':'Santiago','5678':'Carolina','9012':'Sneider'};
const DELETE_CODE = '5027';
const SUPA_URL = 'https://sfcdoeuyjtmeovvderim.supabase.co';
const SUPA_KEY = '...'; // ver arriba
```

### Funciones clave
| Función | Descripción |
|---|---|
| `cargarDatos()` | Carga todo desde Supabase al iniciar o login |
| `guardarSesion()` | Registra una sesión nueva |
| `confirmarDelete()` | Elimina sesión con código 5027 |
| `guardarEdicion()` | Edita sesión existente con código 5027 |
| `renderSesiones()` | Renderiza historial |
| `renderFinanciero()` | Calcula y muestra resumen financiero |
| `_desgloseEquipo()` | Calcula distribución financiera por equipo |
| `_cargarProtocolos()` | Pobla arrays de protocolos desde Supabase |

---

## Protocolos cargados en Supabase

**57 protocolos en total:**
- 33 Ultraformer MPT
- 14 Volnewmer
- 6 Volformer
- 5 Aquapure

Campos de la tabla `protocolos`:
```sql
id text, equipo text, nombre text, precio bigint,
precio_doc bigint, disparos_ref int, disparos_vol jsonb,
costo_consumibles bigint, pago_cosmeto bigint, activo boolean
```

---

## Materiales de marketing generados

### PDFs creados
- `tabla_precios_dermato.pdf` — tabla de precios Ultraformer, Volnewmer y Volformer
- `mensajes_whatsapp_dermato.pdf` — secuencia de 3 mensajes para responder pacientes

### Mensajes WhatsApp — secuencia Ultraformer MPT
- **Mensaje 1:** Saludo + qué es el tratamiento → termina con pregunta
- **Mensaje 2:** Resultados, sensación, duración → termina con pregunta
- **Mensaje 3:** Precios + CTA para agendar
- **Mensaje 3 directo:** Para quien pregunta precio inmediatamente — 2 líneas de contexto + precios + CTA

### Tono de comunicación
- Profesional pero cercano — como hablaría la doctora directamente
- Respaldo médico siempre presente pero explicado en lenguaje simple
- CTA natural — la cita como solución, no como venta
- Referencia de estilo: Vane la Neuróloga en TikTok

---

## Pendientes / Próximas tareas

- [ ] Actualizar 3 precios en Supabase y PDF:
  - Piel brillante: $800.000
  - Surco nasolabial: $2.000.000
  - Arrugas periorales: $1.500.000
- [ ] Agregar mensaje 3 directo al PDF de mensajes WhatsApp
- [ ] Construir dashboard en Looker Studio (cuando haya sesiones reales)
- [ ] Crear mensajes rápidos para Volnewmer y Volformer
- [ ] Contenido para redes sociales (reels, carruseles educativos)

---

## Workflow para actualizaciones

### Cambiar algo en el sistema
1. Editar `index.html` en local
2. `git add . && git commit -m "descripción" && git push`
3. GitHub Pages actualiza en ~2 minutos

### Cambiar protocolos/precios
- Desde la pantalla **Protocolos** dentro del sistema (sin tocar código)
- O directamente en Supabase Table Editor

### Sincronizar Google Sheets manualmente
- Abrir la hoja → Extensiones → Apps Script → ejecutar `sincronizarDatos()`
