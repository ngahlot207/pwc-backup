import { LightningElement,track,wire,api } from 'lwc';

export default class CaptureFilingGstDetails extends LightningElement {
    @api appId;
    @track gstRecsForAllLoca;
}