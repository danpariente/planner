# Datos de ejemplo del Study Planner. Idempotente: se puede correr varias veces.
# Las tablas con clave natural se upsertean; las colecciones sin clave se limpian
# y se recrean para no duplicar.

today = Date.current

# ── Categorías (clave estable = slug que referencian plan_items.category y slots) ──
[
  ["cliente",  "Cliente",  "#5b82a8"],
  ["dev",      "Dev",      "#5e9c8f"],
  ["sc",       "SC:BW",    "#7e974f"],
  ["personal", "Personal", "#7c828c"],
  ["estudio",  "Estudio",  "#8c7bb3"],
  ["otro",     "Otro",     "#bd7e50"]
].each_with_index do |(key, name, hex), i|
  cat = Category.find_or_initialize_by(key: key)
  cat.update!(name: name, hex: hex, position: i)
end

# ── D-day global (fecha objetivo única para todos los días) ───────────────────
Setting.target_date = (today + 21).iso8601   # examen/entrega en 3 semanas -> D-21

# ── Día de hoy (con prioridades, plan y barras pintadas) ──────────────────────
day = Day.for(today)
day.update!(
  goal_hours:  8.0,
  stars:       4,
  notes:       "Buen foco por la mañana. Mañana: empezar antes el bloque de dev."
)

# slots: 24 casillas, idx 0 = 04:00. Pintamos una jornada realista.
slots = Array.new(24)
(5..8).each  { |i| slots[i] = "cliente"  }   # 09:00–12:00 cliente
slots[9]     = "personal"                     # 13:00 comida
(10..12).each { |i| slots[i] = "dev"     }    # 14:00–16:00 dev
(13..14).each { |i| slots[i] = "estudio" }    # 17:00–18:00 estudio
(16..17).each { |i| slots[i] = "sc"      }    # 20:00–21:00 SC:BW
day.update!(slots: slots)

day.priorities.delete_all
["Cerrar propuesta del cliente", "Repasar capítulo 4", "Gimnasio 19:00"].each_with_index do |body, i|
  day.priorities.create!(body: body, done: i.zero?, position: i)
end

day.plan_items.delete_all
[
  ["cliente", "Llamada de kickoff + notas",          true],
  ["dev",     "Refactor del módulo de pagos",         false],
  ["estudio", "Ejercicios de álgebra lineal",         false],
  ["personal","Meal prep de la semana",               false]
].each_with_index do |(cat, body, done), i|
  day.plan_items.create!(category: cat, body: body, done: done, position: i)
end

# ── Ayer (para que el navegador ‹ › tenga contenido) ─────────────────────────
yday = Day.for(today - 1)
yday.update!(goal_hours: 6.0, stars: 3, notes: "Día más flojo, muchas reuniones.")
ys = Array.new(24)
(6..9).each { |i| ys[i] = "cliente" }
(11..12).each { |i| ys[i] = "personal" }
yday.update!(slots: ys)

# ── Notas del mes + pendientes del mes ───────────────────────────────────────
period = today.strftime("%Y-%m")
{
  today.beginning_of_month + 4  => "Entrega informe Q2",
  today                         => "Hoy: kickoff cliente",
  today + 9                     => "Dentista 16:30",
  today.end_of_month - 2        => "Cierre de mes"
}.each do |on_date, body|
  note = MonthNote.for(on_date)
  note.update!(body: body)
end

MonthTodo.where(period: period).delete_all
["Renovar certificación", "Plan de viaje de julio", "Revisar presupuesto"].each_with_index do |body, i|
  MonthTodo.create!(period: period, body: body, done: false, position: i)
end

# ── Horario fijo semanal (fila = franja, col 0..4 = Lun..Vie) ─────────────────
TimetableCell.delete_all
{
  [0, 0] => "Standup", [0, 1] => "Standup", [0, 2] => "Standup", [0, 3] => "Standup", [0, 4] => "Standup",
  [2, 0] => "Cliente", [2, 2] => "Cliente", [2, 4] => "Cliente",
  [4, 1] => "Dev",     [4, 3] => "Dev",
  [6, 0] => "Estudio", [6, 1] => "Estudio", [6, 2] => "Estudio", [6, 3] => "Estudio", [6, 4] => "Estudio",
  [8, 0] => "Gym",     [8, 2] => "Gym",     [8, 4] => "Gym"
}.each { |(r, c), body| TimetableCell.write(r, c, body) }

# ── Objetivos medibles ───────────────────────────────────────────────────────
Goal.delete_all
[
  ["MMR ladder", "1600", "1500", "1540", false],
  ["Cert AWS",   "aprobar", "—", "75% sim", false],
  ["Lectura",    "12 libros", "8", "9", false]
].each_with_index do |(area, target, prev, ach, done), i|
  Goal.create!(area: area, target: target, previous: prev, achieved: ach, done: done, position: i)
end

# ── Tareas con deadline ──────────────────────────────────────────────────────
Task.delete_all
[
  ["cliente", "Enviar propuesta final",     today + 2,  false],
  ["dev",     "Deploy v2 a producción",     today + 5,  false],
  ["estudio", "Entregar problem set 3",     today + 1,  false],
  ["personal","Renovar pasaporte",          today + 30, false],
  ["otro",    "Reservar vuelos",            nil,        false]
].each_with_index do |(cat, body, due, done), i|
  Task.create!(category: cat, body: body, due_on: due, done: done, position: i)
end

# ── Avance por material ──────────────────────────────────────────────────────
Material.delete_all
[
  ["The Rust Programming Language", 9,  20],
  ["Curso de Kubernetes (VODs)",    14, 32],
  ["Álgebra lineal — problemas",    40, 50]
].each_with_index do |(title, done_c, total_c), i|
  Material.create!(title: title, done_count: done_c, total_count: total_c, position: i)
end

puts "Seed completo:"
puts "  Days=#{Day.count}  Priorities=#{Priority.count}  PlanItems=#{PlanItem.count}"
puts "  MonthNotes=#{MonthNote.count}  MonthTodos=#{MonthTodo.count}  TimetableCells=#{TimetableCell.count}"
puts "  Goals=#{Goal.count}  Tasks=#{Task.count}  Materials=#{Material.count}"
