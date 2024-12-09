import { LightningElement,track, api, wire } from 'lwc';
import clearStorage from '@salesforce/apex/CleanStorageDevQA.clearStorage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CleanStorage extends LightningElement {


@track reviewModalOpen=false;
@track showSpinner=false;
@track lookUpRec;
@track lookupId;

  handleLookupFieldChange(event) {
    if (event.detail) {
      this.lookUpRec= event.detail;
      this.lookupId = event.detail.id;
          
    } 
    console.log('lookUpRec::::::',this.lookUpRec, this.lookupId);
}

handleYesClick(){
    this.showSpinner = true;
    this.clearStorage(this.lookupId);
    this.reviewModalOpen=false;
    this.showSpinner = false;
   
   
  }

  clearStorage(userId){
    clearStorage({userId: userId}).then((result) => {
        console.log('result:::::::36',result);
        this.showToastMessage('Success', 'Data Storage Cleared Successfully', 'success', 'sticky');
      })
      .catch((error) => {
        console.log("ERROR #766", error);
      });
  }


  handleStorage(){
    this.reviewModalOpen=true;
  }


  closeModal() {
    this.reviewModalOpen=false;

  }
  
  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    this.dispatchEvent(evt);
}
}