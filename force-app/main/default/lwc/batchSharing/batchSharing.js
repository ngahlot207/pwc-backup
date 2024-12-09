import { LightningElement,track } from 'lwc';
import callBatch from '@salesforce/apex/CallBatchClassSharing.callBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BatchSharing extends LightningElement {


    
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

  clearStorage(lanId){
    callBatch({loanId: lanId}).then((result) => {
        console.log('result:::::::36',result);
        this.showToastMessage('Success', 'Loan Application Shared Successfully', 'success', 'sticky');

        this.lookupId=''
      })
      .catch((error) => {
        console.log("Bacth Class Button Sharing ERROR #766", error);
      });
  }


  handleStorage(){
    this.lookupId ='';
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