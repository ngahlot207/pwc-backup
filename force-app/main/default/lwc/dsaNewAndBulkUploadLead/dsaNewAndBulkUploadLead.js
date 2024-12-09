import { LightningElement, track } from 'lwc';  
  
export default class DsaNewAndBulkUploadLeads extends LightningElement {  
    @track isBulkUpload = false;  
    @track isModalOpen = false;  
  
    handleNewClick() {  
        // Open the modal dialog  
        this.isModalOpen = true;  
        this.isBulkUpload = false; // Reset bulk upload state  
    }  
  
    handleBulkUploadClick() {  
        // Trigger the existing 'leadbulkupload' component  
        this.isBulkUpload = true;  
        this.isModalOpen = false; // Reset modal state  
    }  
  
    handleCloseModal() {  
        // Close the modal dialog  
        this.isModalOpen = false;  
    }  
  
    handleStatusChange(event) {  
        // Handle flow status change events if needed  
        if (event.detail.status === 'FINISHED') {  
            this.isModalOpen = false;  
        }  
    }  
}