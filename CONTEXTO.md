# Dermato Control — Contexto del Proyecto

## ¿Qué es este proyecto?
Sistema de gestión para el consultorio dermatológico de la **Dra. Carolina Mejía (Dra. Red)**,
ubicado en Medellín, Colombia. Incluye dos áreas principales:

1. **Sistema de control de equipos** — registro de sesiones, inventario de transductores,
   agenda Aquapure, cotizaciones, liquidaciones y reportes financieros por doctor.
2. **Contenido y marketing** — guiones, mensajes de WhatsApp, tablas de precios y materiales
   para redes sociales y campañas.

---

## Personas y acceso

El ingreso es con **correo y contraseña** (Supabase Auth). Solo estas 4 cuentas pueden entrar
(están en `EMAIL_TO_USER` del `index.html` y en la tabla `app_usuarios` de la base):

| Correo | Rol en la app | Qué ve |
|---|---|---|
| santiagomejia930314@gmail.com | Santiago (administrador) | Todo; registra los datos |
| carolinamejiadermatologia@gmail.com | Carolina (doctora, dueña del Ultraformer) | Todo |
| sneidertorres07@gmail.com | Sneider (doctor, dueño del Volnewmer) | Todo |
| dermatologia1228@hotmail.com | Cosmetóloga (cuenta compartida) | Solo Agenda Aquapure, Liquidaciones e Historial Aquapure |

- La cuenta de cosmetóloga pide elegir el nombre (Diana, Vero, Cristina…) al entrar. La restricción
  de pantallas es **solo visual**: la base da el mismo acceso a las 4 cuentas autorizadas.
- **Código para eliminar/editar registros dentro de la app:** `5027` (constante `DELETE_CODE`).
- Ya no existen los PIN antiguos (1234/5678/9012).

---

## Equipos del consultorio

| Equipo | Dueño | Tipo |
|---|---|---|
| Ultraformer MPT | Carolina | HIFU facial y corporal |
| Volnewmer | Sneider | HIFU con punteras especializadas |
| Volformer | Ambos | Combinación Ultraformer + Volnewmer |
| Aquapure | Consultorio | Limpieza facial con soluciones; la atiende una cosmetóloga |

---

## Modelo financiero vigente (por disparo)

Todo el reparto lo calcula una sola función, `calcularDesglose()`, que usan el formulario
(vista previa), `guardarSesion()` y `guardarEdicion()`. Lo que recibe cada doctor en una
sesión guardada lo lee `repartoSesion()` (resumen financiero y los Excel).

### Ultraformer (dueña: Carolina)
- **Carolina atiende:** utilidad = precio − disparos × $700; se descuenta el % de mantenimiento
  (`cfg.mant`, 5% por defecto); exento si la sesión tiene descuento.
- **Sneider atiende:** paga **$2.000 por disparo**. Carolina recibe el **neto de $1.300/disparo**
  (`ganancia_dueno`); los $700 restantes van solo al **Fondo Ultraformer** (recompra de
  transductores). Sneider recibe el resto del precio (`ganancia_otro`).

### Volnewmer (dueño: Sneider)
- **Sneider atiende:** utilidad − mantenimiento %.
- **Carolina atiende:** paga el costo de puntera **× 2,4**. Sneider recibe costo × 1,4 (neto);
  Carolina recibe el resto.

### Volformer
- La utilidad se reparte entre el lado Ultra y el lado Vol en proporción al costo de los
  disparos de cada equipo; cada lado aplica su regla de arriba.

### Aquapure
- Utilidad = precio final − consumibles − pago a la cosmetóloga (ambos vienen del protocolo).
- **El 100% de la utilidad va al doctor de la cita o sesión** (Carolina o Sneider).
- Si la refiere una cosmetóloga, ella recibe el 5% de la utilidad y el resto va al doctor.
- El pago a la cosmetóloga por sueroterapia es **$70.000** (el protocolo es la fuente; ya no
  hay valores fijos en el código).

### Comisiones por referido
- Cosmetólogas: 5% en Aquapure / 3% en los demás equipos.
- Médicos (Carolina/Sneider): sin comisión cuando refieren y no cambian quién recibe.

### Costos de transductores
- **Ultraformer:** $700/disparo, 20.000 disparos por transductor.
- **Volnewmer punteras:** 0.25mm → $912,33 (6.000 disparos); 3mm → $1.368,5 (4.000);
  4mm y 16mm → $1.824,67 (3.000).

### Fondo Ultraformer
- $700 × disparos Ultra (cualquier doctor) + mantenimiento. Se muestra en el resumen financiero.

### Porcentajes configurables (pantalla Configuración)
- Cobro uso cruzado al dueño: 30% (solo aplica al caso residual de médico "Cosmetóloga").
- Mantenimiento: 5%.

### Precio ROI y descuentos
- `precioROI(s)` = máximo entre `precio` y la suma de precios de `zonas_json`. Una cita realizada
  guarda el ROI en `precio`; una sesión manual lo guarda en `zonas_json`.
- Descuento = precio ROI − precio final. En la edición de una sesión el precio ingresado **es** el
  final y el % de descuento es solo informativo.

---

## Infraestructura técnica

### Base de datos — Supabase
- **URL:** `https://sfcdoeuyjtmeovvderim.supabase.co`
- **Anon key (pública, va en el HTML):** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmY2RvZXV5anRtZW92dmRlcmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MTMzNTQsImV4cCI6MjA5MDk4OTM1NH0.8E35cofE8kLb5RhmpIc5Q0ygdKTRiy_9z0NHzNGPl3Q`

### Tablas en Supabase
| Tabla | Contenido |
|---|---|
| `sesiones` | Todas las sesiones registradas (campo `data` jsonb) |
| `inventario_ultra` | Transductores Ultraformer (campo `data` jsonb) |
| `inventario_vol` | Transductores Volnewmer (campo `data` jsonb) |
| `soluciones` | Compras de soluciones Aquapure (campo `data` jsonb) |
| `configuracion` | Porcentajes, lista de referidos y cosmetólogas (clave/valor jsonb) |
| `protocolos` | Protocolos por equipo con precios, disparos, consumibles y pago cosmetóloga |
| `agenda_aquapure` | Citas Aquapure (campo `data` jsonb) |
| `cotizaciones` | Cotizaciones por doctor |
| `app_usuarios` | Lista de correos autorizados (la lee solo `es_autorizado()`) |

### Seguridad
- **`setup_seguridad.sql`** (raíz del proyecto): se corre en el SQL Editor de Supabase, las veces
  que haga falta. Crea `app_usuarios` y la función `es_autorizado()`, activa RLS en las 8 tablas,
  borra las políticas viejas, crea la política "cuentas autorizadas" y quita permisos a `anon`.
- Sin ese script la base queda abierta: con la llave pública cualquiera podría leer y modificar.
- La app no consulta la base antes del login, usa siempre el token de la sesión y lo renueva
  automáticamente (`asegurarToken()`) antes de que venza.
- Para agregar o quitar una cuenta: editar `EMAIL_TO_USER` en `index.html`, insertar/borrar el
  correo en `app_usuarios` y crear el usuario en Authentication.
- Recomendado: desactivar "Allow new users to sign up" en Authentication → Providers → Email.
- **Pendiente:** la Edge Function `agenda-ical` (calendario público iCal) usa la llave de servicio y
  hoy es pública; falta protegerla con una clave secreta en la URL.

### Hosting — GitHub Pages
- **Repositorio:** `https://github.com/SML369/Control-Equipos`
- **URL pública:** `https://SML369.github.io/Control-Equipos`
- **Archivo principal:** `index.html` (minúsculas, en la raíz). Los logos de las cotizaciones se
  cargan desde `Logos/` (deben estar en el repositorio).
- Librerías externas con `integrity` (SRI): xlsx 0.20.3 (cdn.sheetjs.com) y docx 8.5.0
  (`build/index.umd.js` en jsDelivr).

### Formulario de sesiones — Jotform
- **URL:** `https://form.jotform.com/260947117694063`
- Carolina y Sneider llenan este formulario después de cada sesión; Santiago registra en el sistema.

### Sincronización con Google Sheets — DESCONTINUADA
- Ya no se usa el Apps Script que copiaba Supabase a la hoja `1jy6p8byZzZcr3pz6z1gWOPq7ZENwWQNCYItOu6ZR8tE`.
  Con RLS activo dejaría de funcionar; no hay que mantenerlo.

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
- `Logos/Logo carolina.png` y `Logos/Logo sneider.png` — se usan en el Word de las cotizaciones.

---

## Estructura del sistema HTML (index.html)

### Pantallas (páginas)
| ID página | Contenido |
|---|---|
| `page-nueva` | Formulario de nueva sesión |
| `page-sesiones` | Historial de sesiones con edición y eliminación |
| `page-pacientes` | Vista por paciente |
| `page-financiero` | Resumen financiero, fondo Ultraformer y desglose por doctor |
| `page-cotizaciones` | Cotizaciones por doctor (exporta Word) |
| `page-tarifario` | Precios, disparos y costos por protocolo |
| `page-liquidaciones` | Pagos pendientes a cosmetólogas y mantenimiento |
| `page-inv-ultra` | Inventario transductores Ultraformer |
| `page-inv-vol` | Inventario transductores Volnewmer |
| `page-inv-aqua` | Inventario soluciones Aquapure |
| `page-agenda-aquapure` | Agenda de citas Aquapure |
| `page-protocolos` | Gestión de protocolos (editar precios/disparos) |
| `page-config` | Porcentajes, referidos y cosmetólogas (el botón "Borrar todos los datos" se eliminó) |

### Variables globales importantes
```javascript
const EMAIL_TO_USER = { 'correo': 'Santiago' | 'Carolina' | 'Sneider' | 'Cosmetologa' };
const DELETE_CODE = '5027';
const SUPA_URL = 'https://sfcdoeuyjtmeovvderim.supabase.co';
const SUPA_KEY = '...'; // anon key, ver arriba
```

### Funciones clave
| Función | Descripción |
|---|---|
| `asegurarToken()` | Renueva el token de Supabase si está por vencer (se llama antes de cada petición) |
| `sbGet / sbUpsert / sbUpsertMany / sbDelete` | Acceso REST a Supabase; lanzan error si la petición falla |
| `cargarDatos()` | Carga todo desde Supabase después del login (una vez) |
| `calcularDesglose()` | Cálculo único del reparto de una sesión (vista previa, guardar y editar) |
| `repartoSesion(s)` | Cuánto recibe cada doctor en una sesión guardada (resumen y Excel) |
| `precioROI(s)` | Precio de referencia de una sesión para calcular descuentos |
| `hoyLocal()` | Fecha local YYYY-MM-DD (evita el desfase UTC desde las 7 p. m.) |
| `esc()` | Escapa texto antes de insertarlo en HTML |
| `guardarSesion()` / `guardarEdicion()` / `confirmarDelete()` | Registro, edición y eliminación de sesiones |
| `renderFinanciero()` / `exportarExcel*()` | Resumen y exportaciones |
| `_cargarProtocolos()` | Pobla los arreglos de protocolos desde Supabase |

### Protocolos
- Los protocolos de la base **siempre mandan** (pueden editarse desde la pantalla Protocolos).
  Del respaldo del código (`_PROTO_FALLBACK`) solo se insertan los que falten por `id`; nunca se
  sobrescriben ni se desactivan.

---

## Pendientes / Próximas tareas

- [ ] Correr `setup_seguridad.sql` en Supabase y desactivar el registro de usuarios nuevos.
- [ ] Proteger la Edge Function `agenda-ical` con una clave secreta en la URL.
- [ ] Rediseño visual de la app (fase aparte).
- [ ] Crear mensajes rápidos para Volnewmer y Volformer.
- [ ] Contenido para redes sociales (reels, carruseles educativos).

---

## Workflow para actualizaciones

### Cambiar algo en el sistema
1. Editar `index.html` en local
2. `git add . && git commit -m "descripción" && git push`
3. GitHub Pages actualiza en ~2 minutos

### Cambiar protocolos/precios
- Desde la pantalla **Protocolos** dentro del sistema (sin tocar código)
- O directamente en Supabase Table Editor
