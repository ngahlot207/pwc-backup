import { LightningElement, track } from 'lwc';
import uploadLeadsFromCSV from '@salesforce/apex/LeadCretorController.uploadLeadsFromCSV';

export default class UploadBulkLead extends LightningElement {
    @track isButtonDisabled = true;
    fileContents;

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContents = reader.result;
                this.isButtonDisabled = false;
            };
            reader.readAsText(file);
        }
    }

    uploadLeads() {
        uploadLeadsFromCSV({ csvString: this.fileContents })
            .then((result) => {
                // Handle the result (e.g., show a success message)
                console.log('Upload successful: ', result);
            })
            .catch((error) => {
                // Handle the error (e.g., show an error message)
                console.error('Error uploading leads: ', error);
            });
    }
}