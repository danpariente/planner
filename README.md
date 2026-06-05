# Planner — 플래너 · Rails 8 + SQLite (tema Light)

Planner personal server-rendered con Hotwire (Turbo + Stimulus), sin build de JS (importmap).
**Multi-cuenta**: cada cuenta es un planner privado, con login por magic link + código OTP.
Seis secciones: Diario, Mensual, Semana, Objetivos, Tareas, Progreso.

Originalmente un port de un *study planner* coreano; ahora generalizado a un planner de uso
amplio (trabajo, estudio, personal…).

📖 **Manual de uso (con capturas):** [docs/manual/MANUAL.md](docs/manual/MANUAL.md)

## Requisitos

- Ruby 3.2+ (idealmente 3.3/3.4)
- Rails 8.x

## Setup

```bash
bin/rails db:migrate
bin/rails db:seed     # opcional: datos de ejemplo + categorías
bin/rails server      # o bin/dev
```

Abre `http://localhost:3000` → arranca en el día de hoy.

Los controladores Stimulus (`autosubmit`, `time-painter`, `cat-select`, `stars`, `dday`) se
autoregistran con el `app/javascript/controllers/index.js` por defecto de Rails 8
(`eagerLoadControllersFrom`), así que no hay que pinear nada.

## Diseño

**Modelos**

- `Day` — una fila por fecha (única). Guarda `goal_hours`, `stars`, `notes` y `slots`
  (columna **JSON**: array de 24, índice 0 = 04:00, cada posición es la `key` de categoría
  pintada o `null`). `real_hours` se deriva (`slots.compact.size`), no se almacena. Tiene
  `priorities` y `plan_items`.
- `Priority`, `PlanItem` — hijos del día (con `done`, `position`). `PlanItem` referencia una
  categoría por su `key` (string).
- `Category` — **tabla** `categories` (`key` slug estable, `name`, `hex`, `position`).
  `plan_items.category` y `day.slots` referencian la `key`, así que renombrar no rompe datos.
  Se crean **en el momento** desde el dropdown del plan ("+ nueva…"), con color auto-asignado
  de una paleta armoniosa (colores tradicionales japoneses 和色).
- `Setting` — ajustes globales clave/valor. Hoy guarda el **D-day global** (`target_date`):
  una sola fecha objetivo para todos los días; la cuenta `D-` se calcula desde el día visible.
- `MonthNote` — nota por celda del calendario (una por fecha). `MonthTodo` — pendientes del mes
  (`period` = "YYYY-MM").
- `TimetableCell` — celda del horario fijo (`row` 0–10 × `col` 0–4). Upsert por celda; se borra
  la fila si queda en blanco.
- `Goal` (área/meta/anterior/logrado/✓), `Task` (tareas con deadline), `Material` (avance %).

**Interacción (Hotwire)**

- Edición inline: cada campo vive en un form con el controlador `autosubmit` (debounce al
  teclear, inmediato al cambiar checkbox/select/fecha). El server responde `204 No Content`.
- Alta/baja de filas (prioridades, plan, objetivos, tareas, materiales, pendientes del mes):
  `button_to` → Turbo Stream `append`/`remove`.
- Pintado de barras: controlador `time-painter` que pinta las 24 casillas y persiste con un
  `PATCH` (JSON) al `Day`. El total "real" se recalcula en vivo.
- Categorías (`cat-select`): elegir o **crear en el momento** desde el dropdown; el color del
  texto y el swatch nuevo aparecen al instante.
- Estrellas (`stars`): relleno en vivo con vista previa al pasar el ratón.
- D-day (`dday`): la cuenta regresiva se actualiza al vuelo al elegir la fecha objetivo.
- El check instantáneo usa CSS `:has(input:checked)`.

## Notas / detalles conocidos

- Visitar una fecha **crea** la fila `Day` (auto-crea el día en blanco). Para no crear filas
  vacías al navegar, cambia `Day.for` por `find_or_initialize_by`.
- Borrar una categoría deja datos viejos que la referencian con color de respaldo (no migra).
- SQLite con columna `json`: funciona en Rails 8 (JSON1). En producción revisa
  `config/database.yml` y el modo WAL.

## Extensiones naturales

- **Multi-usuario**: añade auth (generador de Rails 8) y `belongs_to :user` + scoping.
- **Editar color/orden de categorías**: hoy el alta es inline con color auto; un pequeño gestor
  permitiría recolorear/reordenar/borrar desde la UI.
