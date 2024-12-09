import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRecordData from '@salesforce/apex/DummyFormController.getRecordData';

export default class BillDeskForm extends LightningElement {

    currentPageRef;
    @track bdorderid;
    @track merchantid = 'BDUATV2K06'; //BDMERCID
    @track rdata;
    @track href;
    

    @wire(CurrentPageReference)
   setCurrentPageReference(currentPageRef) {
   this.currentPageReference = currentPageRef;

   console.log('this.currentPageReference',this.currentPageReference);
   console.log('this.recordId',this.currentPageReference.state.id)

   if(this.currentPageReference.state.id){
    this.fetchRecordData(this.currentPageReference.state.id);
   }
  }


  fetchRecordData(recordId) {
    let recId =recordId;
    console.log('recId',recId);

    getRecordData({ imdId:recId })
        .then(result => {
            if (result) {
                console.log('Record Data:', JSON.stringify(result));
                this.bdorderid = result.bdorderid;
                this.rdata = result.rdata;
                this.href = result.href;
            }
        })
        .catch(error => {
            console.error('Error fetching record data:', error);
        });
}


handleOnClick(){
    const form = this.template.querySelector('form');
    console.log('form',form)
        form.submit();
}
}