import { Controller } from "@hotwired/stimulus"

// Rellena en vivo las estrellas de satisfacción (hasta la seleccionada), con
// vista previa al pasar el ratón. El guardado lo hace el form (autosubmit).
export default class extends Controller {
  static targets = ["star"]

  connect() { this.paint(this.current()) }

  current() {
    const checked = this.element.querySelector("input:checked")
    return checked ? Number(checked.value) : 0
  }

  paint(n) {
    this.starTargets.forEach(l => l.classList.toggle("on", Number(l.dataset.value) <= n))
  }

  update()    { this.paint(this.current()) }                       // al elegir (change)
  preview(e)  { this.paint(Number(e.currentTarget.dataset.value)) } // al pasar el ratón
  reset()     { this.paint(this.current()) }                       // al salir
}
