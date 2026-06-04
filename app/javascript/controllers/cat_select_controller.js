import { Controller } from "@hotwired/stimulus"

// Permite elegir una categoría existente o crear una nueva "en el momento"
// desde el mismo <select> del plan. Al elegir "+ nueva categoría…" aparece un
// input; al confirmar (Enter), crea la categoría (color auto de la paleta),
// la añade a todos los selects de la página y la deja seleccionada.
export default class extends Controller {
  static targets = ["form", "select", "newInput"]
  static values  = { createUrl: String }

  connect() { this.prev = this.selectTarget.value }

  changed() {
    if (this.selectTarget.value === "__new__") {
      this.newInputTarget.hidden = false
      this.newInputTarget.value = ""
      this.newInputTarget.focus()
    } else {
      this.prev = this.selectTarget.value
      this.recolor()                          // actualiza el color del texto en vivo
      this.formTarget.requestSubmit()         // guarda la categoría elegida
    }
  }

  // Tiñe el <select> con el color de la categoría seleccionada (data-hex).
  recolor() {
    const hex = this.selectTarget.selectedOptions[0]?.dataset.hex
    if (hex) this.selectTarget.style.color = hex
  }

  cancel() {
    this.newInputTarget.hidden = true
    this.selectTarget.value = this.prev      // restaura la selección previa
  }

  async create(e) {
    e.preventDefault()
    const name = this.newInputTarget.value.trim()
    if (!name) { this.cancel(); return }

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    let data
    try {
      const res = await fetch(this.createUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": token },
        body: JSON.stringify({ category: { name } })
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      data = await res.json()
    } catch (err) {
      console.error("cat-select: no se pudo crear la categoría", err)
      this.cancel()
      return
    }

    this.addOptionEverywhere(data)
    // avisa al painter para que cree el swatch al instante (si está en la página)
    this.dispatch("created", { detail: data, prefix: "category" })
    this.newInputTarget.hidden = true
    this.selectTarget.value = data.key
    this.selectTarget.style.color = data.hex
    this.prev = data.key
    this.formTarget.requestSubmit()          // persiste plan_item.category = nueva
  }

  // Inserta la nueva opción (antes de "+ nueva…") en todos los selects de
  // categoría del plan, para que las demás filas también la vean sin recargar.
  addOptionEverywhere({ key, name, hex }) {
    document.querySelectorAll('select[name="plan_item[category]"]').forEach(sel => {
      if (sel.querySelector(`option[value="${CSS.escape(key)}"]`)) return
      const opt = new Option(name, key)
      opt.dataset.hex = hex                   // para que recolor() la pueda teñir luego
      sel.insertBefore(opt, sel.querySelector('option[value="__new__"]'))
    })
  }
}
