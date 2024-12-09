import { LightningElement,api,track } from 'lwc';
import fetchFiles from '@salesforce/apex/Fileuploadcttrl.fetchFiles';
import {deleteRecord} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {NavigationMixin} from 'lightning/navigation';   
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// Custom labels
import UploadFile_SuccessMessage from '@salesforce/label/c.UploadFile_SuccessMessage';

export default class Uploadfilecomdemo extends NavigationMixin(LightningElement) {
    label = {
        UploadFile_SuccessMessage
    }
    @api recordId;
    @track lstAllFiles=[];
 
    @track error;
    @api toView;
    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.doc','.csv'];
    }
 
    handleUploadFinished(event) {
        this.connectedCallback();
    }
 
    connectedCallback() {
        this.handleFilesUploaded();
    }
    handleFilesUploaded(){
        fetchFiles({recordId:this.recordId})
        .then(result=>{
            this.lstAllFiles = result; 
            this.error = undefined;
            console.log('lstAllFiles ' + JSON.stringify(this.lstAllFiles));
        }).catch(error=>{
            this.error = error;
            this.lstAllFiles = undefined; 
            
        })
    }
    handleDocumentDelete(event){
        this.recordIdToDelete = event.currentTarget.dataset.id;
        //window.console.log('recordId# ' + this.recordId);
        console.log('recordIdToDelete ' + JSON.stringify(this.recordIdToDelete))
        deleteRecord(this.recordIdToDelete) 
        .then(() =>{
   
           const toastEvent = new ShowToastEvent({
               title:'Record Deleted',
               message: this.label.UploadFile_SuccessMessage,
               variant:'success',
               mode: 'sticky'
           })
           this.dispatchEvent(toastEvent);
            this.lstAllFiles =[];
            this.handleFilesUploaded();
           return refreshApex(this.lstAllFiles);
           
        })

}
}