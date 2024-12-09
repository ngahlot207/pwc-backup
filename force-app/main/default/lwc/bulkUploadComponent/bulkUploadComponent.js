import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import BulkDataUploader from '@salesforce/apex/BulkAPIController.uploadData';
export default class BulkUploadComponent extends LightningElement {
    @api recordId;
    csvData;
    disableUpload = true;
    fileName;

    handleFileInputChange(event) {
        const file = event.target.files[0];
        this.fileName = file.name; 
        const reader = new FileReader();
        reader.onload = () => {
            this.csvData = reader.result;
            this.disableUpload = false;
        };
        reader.readAsText(file);
    }

    handleUpload() {
        if (!this.csvData) {
            console.error('No CSV data to upload.');
            return;
        }

        BulkDataUploader({ csvLines: this.csvData, objectName: 'HRMS__c' })
            .then(result => {
                console.log('Upload successful:', result);
                this.showToast('success', 'Upload Successful', 'File uploaded successfully: ' );
            })
            .catch(error => {
                this.showToast('error', 'Upload Error', 'An error occurred while uploading the file.');
                
            });
    }



    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}