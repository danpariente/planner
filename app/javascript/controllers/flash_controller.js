import { Controller } from "@hotwired/stimulus"

// Desvanece y quita el mensaje flash tras unos segundos.
export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() { clearTimeout(this.timer) }

  dismiss() {
    this.element.classList.add("hide")
    setTimeout(() => this.element.remove(), 400)
  }
}
