import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import { CurrentPageReference } from 'lightning/navigation';
import ID_FIELD from '@salesforce/schema/Lead.Id';
import CONSENT_TYPE_FIELD from '@salesforce/schema/Lead.ConsentType__c';
import DIGITAL_VERIFIED_FIELD from '@salesforce/schema/Lead.Digital_Verified__c';
import DIGITAL_CONSENT_DATETIME_FIELD from '@salesforce/schema/Lead.Digital_Consent_Date_Time__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import getLeadIdByTask from '@salesforce/apex/CreateLeadController.getLeadIdByTask';

import validateOtp from '@salesforce/apex/verifyCoApplicantDetailsController.validateOtp';
import IDAPP_FIELD from '@salesforce/schema/Applicant__c.Id';
import CONSENTAPP_TYPE_FIELD from '@salesforce/schema/Applicant__c.ConsentType__c';
import DIGITALAPP_VERIFIED_FIELD from '@salesforce/schema/Applicant__c.DigitalVerified__c';

import getApplicantIdByTask from '@salesforce/apex/verifyCoApplicantDetailsController.getApplicantIdByTask';
import getProductByLead from '@salesforce/apex/CreateLeadController.getProductByLead';
import updateLeadNdAppRec from '@salesforce/apex/verifyCoApplicantDetailsController.updateDigitalOtpConsent';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';


//export default class DigitalConsent extends LightningElement {
export default class DigitalConsent extends NavigationMixin(LightningElement) {

    @api id;
    @api taskId;

    
    @api leadId;
    leadRecordId;
    @track error;
    @track consentType;
    
    digitalVerified = false;
    digitalDateTime;
    ApplicantId
    otpValue = '';
    @track isTermsAccepted = false;

    @wire(MessageContext)
    messageContext;


    // Lifecycle hook that runs when the component is inserted into the DOM
    connectedCallback() {
        //this.handleUrlParameters();
        this.handleparams3();
        this.handleparams4();
        this.getProductType();
        
    }

    handleOtpChange(event){
        this.otpValue = event.target.value;
    }

    handleCheckboxChange(event) {
        this.isTermsAccepted = event.target.checked; // Update the boolean based on checkbox state
    }

    @track loanProductType;

    getProductType() {
        let parameterLoanApplication = {
            ParentObjectName: 'Lead',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Product__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.leadRecordId + '\''
        }

        
        getProductByLead({ leadId: this.leadRecordId })
            .then(result => {
                this.loanProductType = result;
                console.log('produccttttt: ', this.loanProductType);
            })
            .catch(error => {
                console.error('Error fetching product:', error);
                console.log('errorrrr: ', JSON.stringify(error));
            });

        // getSobjectData({ params: parameterLoanApplication })
        // .then((result) => {
            

        //     if (result && result.parentRecords && result.parentRecords.length > 0) {
        //         let loanRecord = result.parentRecords[0]; // Get the first loan application record
        //         //this.loanProductType = loanRecord.Product__c; // Store the Product__c value
        //         console.log('Product Type:', this.loanProductType);
                
        //     }

        //     if (result.error) {
        //         console.error('Error fetching Loan Application data:', result.error);
        //     }
        // })
        // .catch((error) => {
        //     console.error('Error fetching data:', error);
        // });

        
    }


    handleparams3(){
        console.log("window location: ", window.location);
        const mykeys= window.location.search;
        console.log("keys and values:", mykeys);

        const urlParams = new URLSearchParams(mykeys);
         this.taskId = urlParams.get('taskId');
        console.log("TASK IDDDDDDDD:>>>>>>", this.taskId);

        getLeadIdByTask({ taskId: this.taskId })
            .then(result => {
                this.leadRecordId = result;
                console.log('lead iddd: ', this.leadRecordId);
            })
            .catch(error => {
                console.error('Error fetching Lead Id:', error);
                console.log('errorrrr: ', JSON.stringify(error));
            });

    }

    // Method to handle click event of Accept button
    handleAccept() {

        if (!this.isTermsAccepted) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please accept the terms and conditions.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return; // Exit the function if terms are not accepted
        }


        validateOtp({ taskId: this.taskId, otp: this.otpValue })
            .then(response => {
                
                if (response) {
                    if (response == 'success') {
                        this.digitalDateTime = new Date().toISOString();
                        debugger
                        const fields = {};
                        let recordId=''
                        if(this.leadRecordId && this.leadRecordId !=='' && this.leadRecordId !==null){
                            recordId=this.leadRecordId;
                            
                        }else if(this.ApplicantId && this.ApplicantId !=='' && this.ApplicantId !==null){
                            recordId=this.ApplicantId;
                            
                        }
                                 
                        this.digitalVerified = true;

                            updateLeadNdAppRec({ recordId: recordId })
                            .then(result => {
                                
                                console.log('recordUpdatedd>>>>>', result);
                            })
                            .catch(error => {
                                console.error('Error fetching Lead Id:', error);
                                console.log('errorrrr: ', JSON.stringify(error));
                            });


                        const evt = new ShowToastEvent(
                            {
                                title: 'Success',
                                message: 'OTP Verified. Terms and conditions accepted!',
                                variant: 'success',
                            }
                        );
                        this.dispatchEvent(evt);
                        console.log('Terms accepted!');
                        
                        
                    } else {
                        const evt = new ShowToastEvent(
                            {
                                title: 'Error',
                                message: 'OTP Validation Failed. Please enter correct OTP.',
                                variant: 'error',
                            }
                        );
                        this.dispatchEvent(evt);
                        console.log('Terms accepted!');
                        // otpElement.setCustomValidity('OTP Validation Failed. Kindly try again');
                        // this.showToastMessage('Error', this.customLabel.LeadOtp_Otp_ErrorMessage, 'error', 'sticky');
                    }
                    

                }
            })

        
        
        
        // this.digitalDateTime = new Date().toISOString();
        // debugger
        // const fields = {};
        // let recordId=''
        // if(this.leadRecordId && this.leadRecordId !=='' && this.leadRecordId !==null){
        //     recordId=this.leadRecordId;
            
        // }else if(this.ApplicantId && this.ApplicantId !=='' && this.ApplicantId !==null){
        //     recordId=this.ApplicantId;
            
        // }
       
        
      
        // this.digitalVerified = true;

        
       

        //     updateLeadNdAppRec({ recordId: recordId })
        //     .then(result => {
                
        //         console.log('recordUpdatedd>>>>>', result);
        //     })
        //     .catch(error => {
        //         console.error('Error fetching Lead Id:', error);
        //         console.log('errorrrr: ', JSON.stringify(error));
        //     });


        // const evt = new ShowToastEvent(
        //     {
        //         title: 'Success',
        //         message: 'Terms and conditions accepted!',
        //         variant: 'success',
        //     }
        // );
        // this.dispatchEvent(evt);

        
    


    }
    handleparams4(){
        console.log("window location: ", window.location);
        const mykeys= window.location.search;
        console.log("keys and values:", mykeys);

        const urlParams = new URLSearchParams(mykeys);
        this.taskId = urlParams.get('taskId');
        console.log("TASK IDDDDDDDD:", this.taskId);

        getApplicantIdByTask({ taskId: this.taskId })
            .then(result => {
                this.ApplicantId = result;
                console.log('ApplicantId iddd: ', this.ApplicantId);
            })
            .catch(error => {
                console.error('Error fetching Lead Id:', error);
                console.log('errorrrr: ', JSON.stringify(error));
            });

    }
    // publishMessage() {
    //     const message = { leadId: this.leadId, digitalVerified: this.digitalVerified };
    //     publish(this.messageContext, FIELD_UPDATE_CHANNEL, message);
    //     console.log('messageee ', JSON.stringify(message));
    //     console.log('digital verifiedddd ', this.digitalVerified);
    // }


    
    

}