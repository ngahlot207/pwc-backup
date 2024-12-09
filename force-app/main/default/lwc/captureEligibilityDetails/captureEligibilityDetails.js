import { LightningElement, api, wire, track } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, unsubscribe, releaseMessageContext, publish, createMessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import CURRENTUSERID from '@salesforce/user/Id';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

// Custom labels
import Eligibilty_SuccessMessage from '@salesforce/label/c.Eligibilty_SuccessMessage';
import Eligibilty_ErrorMessage from '@salesforce/label/c.Eligibilty_ErrorMessage';


export default class CaptureEligibilityDetails extends LightningElement {
    @api loanAppId;
    @api hasEditAccess;
    @track stage;
    @track substage;
    @track showDecision = false;
    @track showSpinner = false;
    @track eligibiltySave = false;



    subscription = null;
    context = createMessageContext();

    connectedCallback() {
        this.getLoanDetails();
        this.scribeToMessageChannel();
    }

    disconnectedCallback() {
        // Unsubscribe from the message channel when the component is disconnected
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
            releaseMessageContext(this.context);
        }
    }
    renderedCallback() {
    }
    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.context,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {

        if (values.recordId) {
            this.handleSave(values.validateBeforeSave, false);
        }
    }

    handleSave(validate) {
        console.log('validate for eligibility>>>', validate);
        this.showSpinner = true;
        if (validate) {
            let allValid = false;
            const sanctionDetail = this.template.querySelector('c-capture-sanction-details');
            const captureEligibilityBREComponent = this.template.querySelector('c-capture-eligibility-b-r-e-component');
            const deviationDetail = this.template.querySelector('c-deviation-component');
            if (sanctionDetail && captureEligibilityBREComponent && deviationDetail) {
                if (captureEligibilityBREComponent.validateForm() && deviationDetail.validateForm() && sanctionDetail.validateForm()) {
                    allValid = true;
                    if (captureEligibilityBREComponent.handleSave() && sanctionDetail.handleSaveClick() && deviationDetail.handleSave()) {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: Eligibilty_SuccessMessage,
                                variant: 'success',
                                mode: 'sticky'
                            }),
                        );
                        // deviationDetail.refreshData();
                    } else {
                        this.showSpinner = false;
                    }
                }
                else {
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: Eligibilty_ErrorMessage,
                            variant: "error",
                            mode: "sticky"
                        }),
                    );
                    
                }
            } else {
                this.showSpinner = false;
            }

        } else {
            let sanctionDetail = this.template.querySelector('c-capture-sanction-details');
            let captureEligibilityBREComponent = this.template.querySelector('c-capture-eligibility-b-r-e-component');
            let deviationDetail = this.template.querySelector('c-deviation-component');
            if (captureEligibilityBREComponent.handleSave() && sanctionDetail.handleSaveClick() && deviationDetail.handleSave()) {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: Eligibilty_SuccessMessage,
                        variant: 'success',
                        mode: 'sticky'
                    }),
                );
                // deviationDetail.refreshData();
            } else {
                this.showSpinner = false;
            }
        }
    }
    getLoanDetails() {
        let loanDetParam = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Stage__c", "SubStage__c"],
            childObjFields: [""],
            queryCriteria: " where Id = '" + this.loanAppId + "' limit 1"
        };
        getSobjectData({ params: loanDetParam })
            .then((result) => {
                if (result) {
                    this.stage = result.parentRecords[0].Stage__c;
                    this.substage = result.parentRecords[0].SubStage__c;
                    //LAK-5823(Decision Summary Table needs to be visible on Eligibility Screen post sanction onwards) Developer Name: Dhananjay Gadekar
                    if (
                           (this.stage === "UnderWriting" && this.substage === "Credit Appraisal") 
                        || (this.stage === "Soft Sanction" && (this.substage === "UW Approval" || this.substage === "UW Approval Pool"))
                        || (this.stage === "Post Sanction") 
                        || (this.stage === "Disbursement Initiation") 
                        || (this.stage === "Disbursed")
                       ) {
                          this.showDecision = true;
                    }
                    else {
                          this.showDecision = false;
                    }
                }
            })
            .catch((error) => {
                console.error("Error ", error);
            });
    }

}