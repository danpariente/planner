# Datos de ejemplo del Planner, bajo la cuenta de ejemplo. Idempotente.
today = Date.current

# ── Cuentas permitidas (cada una = su propio planner) ─────────────────────────
account = Account.find_or_create_by!(email: "dansification@gmail.com")
account.seed_default_categories                 # no-op si ya tiene categorías
Account.find_or_create_by!(email: "barboza.soledad@gmail.com")  # planner vacío

# ── D-day de la cuenta ────────────────────────────────────────────────────────
account.update!(target_date: today + 21)        # examen/entrega en 3 semanas -> D-21

# ── Día de hoy (prioridades, plan y barras pintadas) ──────────────────────────
day = account.day_for(today)
day.update!(goal_hours: 8.0, stars: 4,
            notes: "Buen foco por la mañana. Mañana: empezar antes el bloque de dev.")
slots = Array.new(24)
(5..8).each   { |i| slots[i] = "cliente"  }
slots[9]      = "personal"
(10..12).each { |i| slots[i] = "dev"      }
(13..14).each { |i| slots[i] = "estudio"  }
(16..17).each { |i| slots[i] = "sc"       }
day.update!(slots: slots)

day.priorities.delete_all
["Cerrar propuesta del cliente", "Repasar capítulo 4", "Gimnasio 19:00"].each_with_index do |body, i|
  day.priorities.create!(body: body, done: i.zero?, position: i)
end

day.plan_items.delete_all
[
  ["cliente", "Llamada de kickoff + notas",  true],
  ["dev",     "Refactor del módulo de pagos", false],
  ["estudio", "Ejercicios de álgebra lineal", false],
  ["personal","Meal prep de la semana",       false]
].each_with_index do |(cat, body, done), i|
  day.plan_items.create!(category: cat, body: body, done: done, position: i)
end

# ── Ayer ──────────────────────────────────────────────────────────────────────
yday = account.day_for(today - 1)
yday.update!(goal_hours: 6.0, stars: 3, notes: "Día más flojo, muchas reuniones.")
ys = Array.new(24)
(6..9).each   { |i| ys[i] = "cliente" }
(11..12).each { |i| ys[i] = "personal" }
yday.update!(slots: ys)

# ── Notas + pendientes del mes ────────────────────────────────────────────────
period = today.strftime("%Y-%m")
{
  today.beginning_of_month + 4 => "Entrega informe Q2",
  today                        => "Hoy: kickoff cliente",
  today + 9                    => "Dentista 16:30",
  today.end_of_month - 2       => "Cierre de mes"
}.each do |on_date, body|
  account.month_notes.find_or_initialize_by(on_date: on_date).update!(body: body)
end

account.month_todos.where(period: period).delete_all
["Renovar certificación", "Plan de viaje de julio", "Revisar presupuesto"].each_with_index do |body, i|
  account.month_todos.create!(period: period, body: body, done: false, position: i)
end

# ── Horario fijo semanal ──────────────────────────────────────────────────────
account.timetable_cells.delete_all
{
  [0,0]=>"Standup",[0,1]=>"Standup",[0,2]=>"Standup",[0,3]=>"Standup",[0,4]=>"Standup",
  [2,0]=>"Cliente",[2,2]=>"Cliente",[2,4]=>"Cliente",
  [4,1]=>"Dev",[4,3]=>"Dev",
  [6,0]=>"Estudio",[6,1]=>"Estudio",[6,2]=>"Estudio",[6,3]=>"Estudio",[6,4]=>"Estudio",
  [8,0]=>"Gym",[8,2]=>"Gym",[8,4]=>"Gym"
}.each { |(r,c), body| TimetableCell.write(account, r, c, body) }

# ── Objetivos ─────────────────────────────────────────────────────────────────
account.goals.delete_all
[
  ["MMR ladder","1600","1500","1540"],
  ["Cert AWS","aprobar","—","75% sim"],
  ["Lectura","12 libros","8","9"]
].each_with_index do |(area, target, prev, ach), i|
  account.goals.create!(area: area, target: target, previous: prev, achieved: ach, position: i)
end

# ── Tareas ────────────────────────────────────────────────────────────────────
account.tasks.delete_all
[
  ["cliente","Enviar propuesta final",today+2],
  ["dev","Deploy v2 a producción",today+5],
  ["estudio","Entregar problem set 3",today+1],
  ["personal","Renovar pasaporte",today+30],
  ["otro","Reservar vuelos",nil]
].each_with_index do |(cat, body, due), i|
  account.tasks.create!(category: cat, body: body, due_on: due, position: i)
end

# ── Materiales ────────────────────────────────────────────────────────────────
account.materials.delete_all
[
  ["The Rust Programming Language",9,20],
  ["Curso de Kubernetes (VODs)",14,32],
  ["Álgebra lineal — problemas",40,50]
].each_with_index do |(title, dc, tc), i|
  account.materials.create!(title: title, done_count: dc, total_count: tc, position: i)
end

puts "Seed OK. Cuentas: #{Account.pluck(:email).inspect}"
puts "  #{account.email}: Days=#{account.days.count} Goals=#{account.goals.count} Tasks=#{account.tasks.count} Materials=#{account.materials.count} Categories=#{account.categories.count}"
