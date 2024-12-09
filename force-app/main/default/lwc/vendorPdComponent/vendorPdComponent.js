import { LightningElement, api, track, wire } from 'lwc';
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { publish, subscribe, MessageContext } from "lightning/messageService";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
export default class VendorPdComponent extends LightningElement {
    @track pdId;
    @track pdType;
    @track applicantId;
    @track loanAppId;
    subscription = null;
    @wire(MessageContext)
    MessageContext;
    @track pdDetail = [];
    @api currentTabValue;
    @track hasEditAccessForPd = true;
    layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    };
    @track pdAssignedTo;
    @api recordId;
    pdId;
    isLoading = true;
    showPdComponent = false;

    get pdStatue() {
        if (this.pdDetail.length > 0 && this.pdDetail[0].PDStatus__c) {
            this.hasEditAccessForPd = this.pdDetail[0].IsCompleted__c ? false : true;
            return this.pdDetail[0].PDStatus__c;
        } else {
            return 'Not Completed';
        }

    }

    connectedCallback() {
        console.log(' Vendor Pd Viewing Connected recordId', this.recordId);
        this.isLoading = false;
        this.showPdComponent = false;
        this.getCaseDetails();
        //this.getPDdata();
        this.subscribeToMessageChannel();

    }
    getCaseDetails() {
        let params = {
            ParentObjectName: 'Case',
            ChildObjectRelName: '',
            //select id ,RecordType.name,AccountId, ContactId,Personal_Discussion__c,   CaseNumber from case where CreatedDate = today 
            parentObjFields: ['Id', 'RecordType.name', 'AccountId', 'ContactId', 'Personal_Discussion__c', "CaseNumber"],
            childObjFields: [],

            queryCriteria: ' where Id = \'' + this.recordId + '\' ORDER BY CreatedDate'
        }//'\' AND PDStatus__c = \'' + pdStatusVal + '\' AND IsCompleted__c = false  AND PdTyp__c = \'' + this.TypeOfPDValue +
        getAssetPropType({ params: params })
            .then((res) => {

                console.log(" case record details  === ", res);
                if (res && res.parentRecords[0] && res.parentRecords[0].RecordType.Name === 'PD' && res.parentRecords[0].Personal_Discussion__c != null) {
                    this.pdId = res.parentRecords[0].Personal_Discussion__c;
                    console.log(" case record details 1 === ", res);
                    this.getPDdata();

                }
            })
            .catch(error => {

                console.log(" Error occured in getting Pd__c=== ", error);

            })
    }
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            LOSSAVEBUTTONDISABLE,
            (values) => this.handleDisableButton(values)
        );
    }
    reloadPd() {
        console.log('reloadPd');
        this.getPDdata();
    }
    getPDdata() {
        let params = {
            ParentObjectName: 'PD__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'LoanAppl__c', 'PDStatus__c', 'PdTyp__c', 'Appl__c', "IsCompleted__c", "Appl__r.CustProfile__c", "Appl__r.Type_of_Borrower__c", "AsgnTo__r.Id", " AsgnTo__r.name"],
            childObjFields: [],

            queryCriteria: ' where Id = \'' + this.pdId + '\' ORDER BY CreatedDate'
        }//'\' AND PDStatus__c = \'' + pdStatusVal + '\' AND IsCompleted__c = false  AND PdTyp__c = \'' + this.TypeOfPDValue +
        getAssetPropType({ params: params })
            .then((res) => {
                console.log('PD__c result', res);

                let result = res.parentRecords[0];
                if (result) {
                    this.pdId = result.Id;
                    this.loanAppId = result.LoanAppl__c;
                    this.pdType = result.PdTyp__c ? result.PdTyp__c : '';
                    this.pdDetail = [result];
                    this.applicantId = result.Appl__c ? result.Appl__c : '';
                    this.pdAssignedTo = result.AsgnTo__r ? result.AsgnTo__r.name : '';
                    this.showPdComponent = true;
                } else {
                    this.showPdComponent = false;
                }

            })
            .catch(error => {

                console.log(" Error occured in getting Pd__c=== ", error);

            })
    }
    saveLabel = 'Submit PD';
    handleSave(event) {
        console.log('handle save clicked ');

        let label = event.target.label;
        console.log('handle save clicked ', label);

        if (label === this.saveLabel) {
            const payload = {
                recordId: this.loanAppId,
                validateBeforeSave: true,
                currentStapperApiName: this.stepper,
                currentSubStapperApiName: this.subStepper,
                tabId: this.currentTabId
            };
            console.log('save lms called 0', JSON.stringify(payload));
            publish(this.MessageContext, SaveProcessCalled, payload);
            console.log('save lms called 1', JSON.stringify(payload));
        } else {
            const payload = {
                recordId: this.loanAppId,
                validateBeforeSave: false,
                currentStapperApiName: this.stepper,
                currentSubStapperApiName: this.subStepper,
                tabId: this.currentTabId
            };
            console.log('save lms called 0.0', JSON.stringify(payload));
            publish(this.MessageContext, SaveProcessCalled, payload);
            console.log('save lms called 1.1', JSON.stringify(payload));
        }


    }

}