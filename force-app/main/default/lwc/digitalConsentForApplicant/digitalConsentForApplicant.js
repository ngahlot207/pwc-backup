import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import { CurrentPageReference } from 'lightning/navigation';
import ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import CONSENT_TYPE_FIELD from '@salesforce/schema/Applicant__c.ConsentType__c';
import DIGITAL_VERIFIED_FIELD from '@salesforce/schema/Applicant__c.DigitalVerified__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
//import FIELD_UPDATE_CHANNEL from '@salesforce/messageChannel/FieldUpdateChannel__c';
import getApplicantIdByTask from '@salesforce/apex/verifyCoApplicantDetailsController.getApplicantIdByTask';
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
export default class DigitalConsentForApplicant extends LightningElement {
    @api id;
    @api taskId;

    
    @api ApplicantId;
    ApplicantRecordId;
    @track error;
    @track consentType;
    
    digitalVerified = false;
    digitalDateTime;

    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        this.handleparams3();
        
    }
    handleparams3(){
        console.log("window location: ", window.location);
        const mykeys= window.location.search;
        console.log("keys and values:", mykeys);

        const urlParams = new URLSearchParams(mykeys);
        this.taskId = urlParams.get('taskId');
        console.log("TASK IDDDDDDDD:>>>>>>>>>>", this.taskId);

        getApplicantIdByTask({ taskId: this.taskId })
            .then(result => {
                this.ApplicantId = result;
                console.log('lead iddd:>>>>>>>>>>>>>>>>> ', this.ApplicantId);
            })
            .catch(error => {
                console.error('Error fetching Lead Id:', error);
                console.log('errorrrr: ', JSON.stringify(error));
            });

    }
    handleAccept() {
        console.log('Terms accepted!>>>>>>>>>>>>>>>>');
      const fields = {};
        fields[ID_FIELD.fieldApiName] = this.ApplicantId;
        fields[DIGITAL_VERIFIED_FIELD.fieldApiName] = true; // Set to true for checkbox
        //fields[DIGITAL_CONSENT_DATETIME_FIELD.fieldApiName] = this.digitalDateTime; // Assign current timestamp
        fields[CONSENT_TYPE_FIELD.fieldApiName] = 'Digital Consent';
        console.log("fields: ", JSON.stringify(fields));
        this.digitalVerified = true;

        
        //const recordInput = { fields };
        /*updateRecord(recordInput)
            .then((result) => {
                console.log("result: ", JSON.stringify(result));
                 const evt = new ShowToastEvent(
            {
                title: 'Success',
                message: 'Terms and conditions accepted!',
                variant: 'success',
            }
            );
            this.dispatchEvent(evt);
                })
            .catch(error => {
                console.error('Error updating lead record:', JSON.stringify(error))
            });*/
            let obj =[];
            obj.push(fields);
            if(obj){   
                console.log('Comments Records create ##991', obj); 

                upsertMultipleRecord({ params: obj })
                .then(result => {     
                console.log('Comments Records create ##995', result);
                const evt = new ShowToastEvent(
            {
                title: 'Success',
                message: 'Terms and conditions accepted!',
                variant: 'success',
            }
            );
            this.dispatchEvent(evt);
            
                })
                .catch(error => {
                
                console.error('Line no RCU DETAILS ##2102', error)
                })

            }
       
    }
}