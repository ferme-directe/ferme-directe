import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [ "card" ]
  filter_prix() {
    // On récupère toutes nos cartes grace à notre target dans le html
  let cards = this.cardTargets
  // on lance une boucle sur cards pour récupèrer les prix grace a notre data-element (data-price) dans le html
  cards.forEach((element) => {
    element.dataset.price

  })
  // on lance la comparaison de nos tarifs avec la méthode .sort, on compare nos fiches et leur prix
 let trie = cards.sort((a,b) => a.dataset.price - b.dataset.price);
      console.log(trie)
  // On doit parcourir de nouveau le tableau trie avec nos fiches dans le nouvelle ordre et les afficher
  trie.forEach((element) => {
   this.element.appendChild(element)
})
  }
  filter_distance() {
    let cards = this.cardTargets
    cards.forEach((element) => {
      element.dataset.distance
    })
    let trie_distance = cards.sort((a,b) => a.dataset.distance - b.dataset.distance);
    console.log(trie_distance)
    trie_distance.forEach((element) => {
      this.element.appendChild(element)
    })
  }
}
