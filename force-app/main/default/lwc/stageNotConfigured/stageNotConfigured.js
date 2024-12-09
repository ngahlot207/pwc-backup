import { LightningElement, track, api } from 'lwc';
import IMAGE from "@salesforce/resourceUrl/WebsiteUnderConstruction";
export default class StageNotConfigured extends LightningElement {
    @api header;
    @api message;
    imgLink = IMAGE;

}