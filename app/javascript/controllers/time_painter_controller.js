import { Controller } from "@hotwired/stimulus"

// Pinta las 24 casillas de tiempo real y persiste vía PATCH al Day.
export default class extends Controller {
  static targets = ["slot", "swatch"]
  static values  = { url: String, slots: Array, colors: Object, defaultCat: String }

  connect() {
    this.cat = this.defaultCatValue || Object.keys(this.colorsValue)[0]
    this.painting = false
    this._up = () => this.endPaint()
    document.addEventListener("mouseup", this._up)
    document.addEventListener("touchend", this._up)
    this.render()
  }

  disconnect() {
    document.removeEventListener("mouseup", this._up)
    document.removeEventListener("touchend", this._up)
  }

  pick(e) {
    this.cat = e.currentTarget.dataset.cat
    this.swatchTargets.forEach(s => s.classList.toggle("sel", s === e.currentTarget))
  }

  // Reacciona a una categoría creada desde el dropdown del plan: añade su color
  // y crea el swatch nuevo (antes de "borrar") para poder pintar al instante.
  addSwatch({ detail: { key, name, hex } }) {
    if (this.colorsValue[key]) return
    this.colorsValue = { ...this.colorsValue, [key]: hex }
    const sw = document.createElement("div")
    sw.className = "swatch"
    sw.style.background = hex
    sw.textContent = name
    sw.dataset.cat = key
    sw.dataset.timePainterTarget = "swatch"
    sw.dataset.action = "click->time-painter#pick"
    this.element.querySelector(".swatch.erase").before(sw)
  }

  down(e) { e.preventDefault(); this.painting = true; this.paint(e.currentTarget) }
  over(e) { if (this.painting) this.paint(e.currentTarget) }

  touchmove(e) {
    const t = e.touches[0]
    const el = document.elementFromPoint(t.clientX, t.clientY)
    if (el && el.classList.contains("slot") && this.painting) this.paint(el)
  }

  paint(el) {
    const i = Number(el.dataset.index)
    const slots = [...this.slotsValue]
    slots[i] = this.cat === "erase" ? null : this.cat
    this.slotsValue = slots
    this.render()
  }

  endPaint() {
    if (!this.painting) return
    this.painting = false
    this.save()
  }

  render() {
    const slots = this.slotsValue
    this.slotTargets.forEach((s, i) => {
      const c = slots[i]
      s.style.background = c ? (this.colorsValue[c] || "transparent") : "transparent"
    })
    const real = document.getElementById("real-hours")
    if (real) real.textContent = slots.filter(Boolean).length + "h"
  }

  save() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ day: { slots: this.slotsValue } })
    })
      .then(r => { if (!r.ok) throw new Error(`HTTP ${r.status}`) })
      .catch(e => console.error("time-painter: no se pudo guardar", e))
  }
}
