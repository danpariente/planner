import { Controller } from "@hotwired/stimulus"

// Rellena en vivo las estrellas de satisfacción (hasta la seleccionada), con
// vista previa al pasar el ratón. El guardado lo hace el form (autosubmit).
export default class extends Controller {
  static targets = ["star", "pet"]

  connect() { this.paint(this.current()) }

  current() {
    const checked = this.element.querySelector("input:checked")
    return checked ? Number(checked.value) : 0
  }

  paint(n) {
    this.starTargets.forEach(l => l.classList.toggle("on", Number(l.dataset.value) <= n))
  }

  // La mascota salta sobre la estrella elegida (solo al confirmar, no en hover).
  celebrate() {
    const n = this.current()
    if (!n || !this.hasPetTarget) return
    const star = this.starTargets.find(l => Number(l.dataset.value) === n)
    const pet = this.petTarget
    pet.style.left = `${star.offsetLeft + star.offsetWidth / 2}px`
    pet.classList.remove("go")
    void pet.offsetWidth // reinicia la animación si ya corrió
    pet.classList.add("go")
  }

  update()    { this.paint(this.current()); this.celebrate() }     // al elegir (change)
  preview(e)  { this.paint(Number(e.currentTarget.dataset.value)) } // al pasar el ratón
  reset()     { this.paint(this.current()) }                       // al salir
}
