import { Controller } from "@hotwired/stimulus"

// Actualiza en vivo la etiqueta D- al elegir la fecha objetivo global, sin
// recargar. Calcula desde el día visible (fromValue) hasta la fecha elegida.
// El guardado lo hace el form (autosubmit).
export default class extends Controller {
  static targets = ["input", "label"]
  static values  = { from: String }   // fecha del día visible (iso, YYYY-MM-DD)

  update() {
    this.labelTarget.textContent = this.label(this.inputTarget.value)
  }

  label(target) {
    if (!target) return ""
    const from = new Date(this.fromValue + "T00:00:00")
    const to   = new Date(target + "T00:00:00")
    const d = Math.round((to - from) / 86400000)
    if (d > 0) return `D-${d}`
    if (d === 0) return "D-DAY"
    return `D+${-d}`
  }
}
