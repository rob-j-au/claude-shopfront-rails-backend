import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="test"
export default class extends Controller {
  connect() {
    console.log("Test controller connected!")
    this.element.style.backgroundColor = "lightgreen"
    this.element.textContent = "Stimulus is working!"
  }
}
