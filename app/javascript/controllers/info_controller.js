import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [ "details" ]
  openInfo() {
if (this.detailsTarget.open){
  this.detailsTarget.open = false


}else{
  this.detailsTarget.open = true
}
 this.element.classList.toggle("changementEtat")
  }


stop(event){
 event.stopPropagation()
}


}
