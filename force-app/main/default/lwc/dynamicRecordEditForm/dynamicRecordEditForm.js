import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Custom labels
import DynamicRecEditForm_Save_SuccessMessage from '@salesforce/label/c.DynamicRecEditForm_Save_SuccessMessage';

export default class DynamicRecordEditForm extends LightningElement {
    label = {
        DynamicRecEditForm_Save_SuccessMessage
    }
    @api pdQuestion;
    @api recordId;

    falseVal = false;
    @api columns = 0;
    // @api fieldDetails = JSON.parse(
    //     '[{"name": "FirstName__c", "readOnly": false, "required": true}, {"name": "LastName__c", "readOnly": false, "required": true}, {"name": "MobNo__c", "readOnly": true, "required": true}, {"name": "Email__c", "readOnly": false, "required": false}]'
    // );  [{"label":"Full Name","fieldName":"FName__c","type":"Text","required":true,"editable":true},{"label":"Relationship with applicant","fieldName":"RelationWthApp__c","type":"Picklist","required":true,"editable":true,  "options": []},{"label":"Contact no","fieldName":"ContactNo__c","type":"Number","required":true,"editable":true},{"label":"Comments","fieldName":"Comments__c","type":"Text Area","required":true,"editable":true},{"label":"Address","fieldName":"Add__c","type":"Text","required":true,"editable":true}]
    fields = JSON.parse(
        '["FirstName__c", "LastName__c", "MobNo__c", "Email__c"]'
    );
    get colCSS() {
        return `slds-col slds-size_1-of-${this.columns}`;
    }
    get objectName() {
        return JSON.parse(this.pdQuestion.quesConfig).objectName;
    }
    get recordId() {
        if (this.pdQuestion.respId) {
            return this.pdQuestion.respId;
        } else {
            return null;
        }

    }
    get formTitle() {
        return this.pdQuestion.quesTitle;
    }
    get fieldDetails() {
        console.log('DynamicRecordEditForm', this.pdQuestion.quesConfig);
        let qconfig = JSON.parse(this.pdQuestion.quesConfig);
        console.log('DynamicRecordEditForm', qconfig.columns);
        return qconfig.columns;
    }

    connectedCallback() {
        console.log('dynamic Datatable pdQuestion ', this.pdQuestion);

    }
    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        //fields.FirstName__c = "Test Updated"; Any field value to update on submit
        this.template
            .querySelector("lightning-record-edit-form")
            .submit(fields);
    }

    handleSucess(event) {
        const updatedRecord = event.detail.id;
        console.log("onsuccess: ", updatedRecord);
        const successEvent = new ShowToastEvent({
            title: "Success",
            message: this.label.DynamicRecEditForm_Save_SuccessMessage,
            variant: "success",
            mode: "dismissable"
        });
        this.dispatchEvent(successEvent);
    }
}