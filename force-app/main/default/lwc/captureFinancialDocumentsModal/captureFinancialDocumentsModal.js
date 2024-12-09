import { LightningElement, api, track } from 'lwc';

export default class CaptureFinancialDocumentsModal extends LightningElement {
    @api popupHeaderName = 'Upload Documents';
    @track availableInFile;
    @api disableAvialbleInFile = false;


    handleCancelPopUp(){
        
    }
}