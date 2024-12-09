import { LightningElement, api, track } from 'lwc';

export default class NdcDetails extends LightningElement {
    @api loanAppId = 'a08C40000063xjHIAQ';
    @api hasEditAccess = false;
    @api layoutSize;


    @track ndcOptions = [{ label: "NDC1", value: "NDC1", checked: false },
    { label: "NDC2", value: "NDC2", checked: false }];
    @track ndcVisible = false;
    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
    }
    handleNdcChange(event) {
        if (event.target.value) {
            this.ndcVisible = true;
        }
    }
}