import { Controller } from "@hotwired/stimulus"

// Envía el <form> al que está conectado. `submit` con debounce (al teclear),
// `now` inmediato (al cambiar un checkbox/select/fecha).
export default class extends Controller {
  static values = { delay: { type: Number, default: 450 } }

  submit() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  now() {
    clearTimeout(this.timer)
    this.element.requestSubmit()
  }
}
