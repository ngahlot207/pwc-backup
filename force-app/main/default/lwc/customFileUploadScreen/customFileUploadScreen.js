import { LightningElement, api, track } from 'lwc';
//import saveFiles from '@salesforce/apex/FileUploadController.saveFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFiles from '@salesforce/apex/CustomFileUploadController.createAccountWithFile';
// import Longitude from '@salesforce/schema/Lead.Longitude';

export default class CustomFileUploadScreen extends LightningElement {

    @track imageUrl;
    @track imageFile;
    @track imageUrlview=false;
    handleImageChange(event) {
        this.imageFile = event.target.files[0];
        
    }
    handleDocumentView(){
        if (this.imageFile) {
            this.imageUrlview=true;
            this.imageUrl = URL.createObjectURL(this.imageFile);
        } else {
            this.imageUrl = null;
            this.imageUrlview=true;
        }
    }
    uploadFile(){
        saveFiles({ file: this.imageFile })
        .then(result => {
          console.log('Result', result);
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }
   
    

    // @track selectedFile;
    // @track fileUrl;

    // handleFileChange(event) {
    //     console.log('event>>>>>>>>>',event);
    //     console.log('event file>>>>>>>>>',event.target.files[0]);
    //     this.selectedFile = event.target.files[0];

    // }

    // async saveFiles() {
    //     if (!this.selectedFile) {
    //         return;
    //     }
        
    //     try {
    //         // Call Apex method to create account and attach file
    //         const accountId = await saveFiles({ file: this.selectedFile });
    //         if (accountId) {
    //             console.log('accountId>>>>>>',accountId);
    //             // Success, handle UI feedback or navigation
    //         } else {
    //             // Handle error
    //         }
    //     } catch (error) {
    //         // Handle error
    //     }
    // }

    // viewFile() {
    //     if (this.selectedFile) {

    //         // Assuming your file is stored as a ContentVersion and you have its Id
    //         this.fileUrl = `/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=${this.selectedFile.Id}`;
    //     }
    // }
       
}