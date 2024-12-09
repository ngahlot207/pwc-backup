import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class ScreenConfigView extends LightningElement {

    @api stageName;
    @api currentTabId;//   have  id clicked on multiple tabset component
    @api recordId;
    @api metadata;
    @api isReadOnly;
    @api hasEditAccess;
    @api hasReadAccess
    @api currentApplTabId;
    @api stage;
    @api applicantId

    // _recordId
    // get recordId() {
    //     return this._recordId;
    // }
    // @api set recordId(value) {
    //     this. = value;
    //     this.setAttribute("recordId", value);
    // }
    connectedCallback() {

        // console.log(this.applicantIdTab + 'Screen config applicant Id and in tab  latest ', this.applicantIdInTab);
        console.log('ScreenConfigView  metadata>>>>>', JSON.stringify(this.metadata));
        console.log('ScreenConfigView  hasEditAccess>>>>>', this.hasEditAccess);
        console.log('ScreenConfigView  hasReadAccess>>>>>', this.hasReadAccess);
        console.log('ScreenConfigView  currentTabId>>>>>', this.currentTabId);
        console.log('ScreenConfigView  currentActiveTabId>>>>>', this.currentApplTabId);
        console.log('ScreenConfigView  stage>>>>>', this.stage);
        console.log('ScreenConfigView  stageName>>>>>', this.stageName);
        localStorage.setItem('currentApplTabId', this.currentApplTabId);

    }

    showToastMessage(title, message, variant) {
        const showToastMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: "dismissable"
        });
        this.dispatchEvent(showToastMessage);
    }
}