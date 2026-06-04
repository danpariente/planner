import { Controller } from "@hotwired/stimulus"

// Auto-envía el formulario del código OTP cuando hay 6 dígitos (también al pegar).
// Limpia cualquier carácter no numérico.
export default class extends Controller {
  static targets = ["input"]

  check() {
    const digits = this.inputTarget.value.replace(/\D/g, "").slice(0, 6)
    if (this.inputTarget.value !== digits) this.inputTarget.value = digits
    if (digits.length === 6) this.element.requestSubmit()
  }
}
