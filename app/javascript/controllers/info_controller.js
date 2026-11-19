import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [ "details" ]
  openInfo(event) {
    // Un clic sur « details » (summary) : le navigateur ouvre ou ferme déjà le <details> tout seul.
    // Sans ce retour, on l'inversait une deuxième fois et la fiche ne se refermait plus.
    if (event.target.closest("summary")) return

    this.detailsTarget.open = !this.detailsTarget.open
  }

  // Appelé à chaque ouverture ou fermeture du <details> (événement « toggle »), quelle qu'en soit la cause :
  // l'encadré suit toujours l'état réel de la fiche.
  sync() {
    this.element.classList.toggle("changementEtat", this.detailsTarget.open)
  }

  stop(event){
    event.stopPropagation()
  }
}
