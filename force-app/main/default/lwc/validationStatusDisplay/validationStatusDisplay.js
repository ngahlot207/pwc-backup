import { LightningElement, api, track } from 'lwc';

export default class ValidationStatusDisplay extends LightningElement {
    @api validationStatus;
    @api ocrStatus;
    @api fileIterator
    // = {
    //        docDetName: 'Photopraph'
    //      };
    @api showRerunIcon = false;
    // @api docName;
    // @api get validStatusVlaue() {
    //     return this.validationStatus;
    // }

    conditionForIntMsg = ['PASSPORT', 'AADHAAR', 'VOTER ID', 'DRIVING LICENSE', 'PAN', 'UDYAM REGISTRATION CERTIFICATE', 'ELECTRICITY BILL', 'SHOP AND ESTABLISHMENT', 'GST CERTIFICATE'];

    // connectedCallback() {
    //     console.log('fileIterator', this.fileIterator);
    // }

    //&& this.conditionForIntMsg.includes(this.fileIterator.docDetName)
    //= {
    //   docDetName: 'Photopraph'
    // };
    get success() {
        if (this.validationStatus == 'Success' && this.fileIterator.docDetName && this.conditionForIntMsg.includes(this.fileIterator.docDetName.toUpperCase())) {
            return true;
        } else {
            return false;
        }
    }
    get failure() {
        if (this.validationStatus == 'Failure' && this.fileIterator.docDetName && this.conditionForIntMsg.includes(this.fileIterator.docDetName.toUpperCase())) {
            return true;
        } else {
            return false;
        }
    }
    get inProgress() {
        if (((this.validationStatus !== 'Success' && this.validationStatus !== 'Failure') || !this.validationStatus) && this.fileIterator.docDetName && this.conditionForIntMsg.includes(this.fileIterator.docDetName.toUpperCase())) {
            return true;
        } else {
            return false;
        }
    }

    get skipforwardIcon() {
        console.log('doc detail name', this.fileIterator.docDetName);
        if (this.validationStatus !== 'Success' && this.fileIterator.docDetName && this.conditionForIntMsg.includes(this.fileIterator.docDetName.toUpperCase())) {
            return true;
        } else {
            return false;
        }
    }

    // get showValiAndOcrStatus() {
    //     if (this.conditionForIntMsg.includes(this.docName)) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }


    handleForwardClicked() {
        console.log('fileIterator', this.fileIterator)
        let param = {
            fileIterator: this.fileIterator
        }
        console.log('param', param)
        const selectEvent = new CustomEvent('click', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }
    // set validStatusVlaue(value) {
    //     if (value == 'Failure') {
    //         this.failure = true;
    //     } else if (value == 'Success') {
    //         this.success = true;
    //     } else {
    //         this.inProgress = true;
    //     }
    // }
    // connectedCallback() {
    //     console.log('validationStatus ', this.validationStatus);
    //     if (this.validationStatus == 'Failure') {
    //         this.failure = true;
    //     } else if (this.validationStatus == 'Success') {
    //         this.success = true;
    //     } else {
    //         this.inProgress = true;
    //     }
    // }
}