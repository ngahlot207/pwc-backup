import { LightningElement, api, wire, track } from 'lwc';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ReferenceDetForPDComponent extends LightningElement {
    @api pdQuestion;
    @track refDet = { Id: '', FName__c: '', Add__c: '', RelationWthApp__c: '', ContactNo__c: '', Comments__c: '' };
    @api hasEditAccess;
    @api layoutSize;
    @track showComp = true;
    @track quesConfig;


    connectedCallback() {
        console.log('from ReferenceDetForPDComponent this.referenceId 1', this.pdQuestion);
        this.quesConfig = JSON.parse(this.pdQuestion.quesConfig);


        console.log('from ReferenceDetForPDComponent this.referenceId 2', this.quesConfig);

        // if (this.pdQuestion.quesResp) {
        //     let params = {
        //         ParentObjectName: 'Ref__c',
        //         parentObjFields: ["Id", "FName__c", "Add__c", "RelationWthApp__c", "ContactNo__c", "Comments__c"],

        //         queryCriteria: ' where Id = \'' + this.pdQuestion.quesResp + '\''
        //     };
        //     getSobjectDatawithRelatedRecords({ params: params })
        //         .then((res) => {
        //             let result = res.parentRecord;
        //             console.log('result from Reference Object ', result);
        //             if (result) {
        //                 const clonedObject = JSON.parse(JSON.stringify(result));
        //                 this.refDet = clonedObject;
        //             }


        //         })
        //         .catch((err) => {
        //             this.showToast("Error", "error", "Error occured in geting ReferenceOnject " + err.message);
        //             console.log(" getSobjectDatawithRelatedRecords error===", err);
        //         });
        // }

    }

    // handleInputChange(event) {

    //     let fieldName = event.target.name;
    //     let value = event.target.value;

    //     this.refDet[fieldName] = value;


    //     let param = { pdRespId: this.pdQuestion, respVal: this.refDet, type: this.pdQuestion.respType }
    //     const selectEvent = new CustomEvent('passtoparent', {
    //         detail: param
    //     });
    //     console.log('refrence component in  passtoparent', param);
    //     this.dispatchEvent(selectEvent);
    // }
    // showToast(title, variant, message) {
    //     const evt = new ShowToastEvent({
    //         title: title,
    //         variant: variant,
    //         message: message
    //     });
    //     this.dispatchEvent(evt);
    // }
    passtoparent(event) {
        console.log('refrence component in  passtoparent', event.detail);
        // let qconfig = JSON.parse(json.stringify(this.pdQuestion));
        // qconfig.quesConfig = '';
        let param = { pdRespId: this.pdQuestion, respVal: event.detail }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        console.log('refrence component in  passtoparent', param);
        this.dispatchEvent(selectEvent);
        this.quesConfig.record[event.detail.field] = event.detail.respVal;
    }
    @api reportValidity() {
        let isValid = true
        this.template.querySelectorAll('c-reference-det-for-p-dshow-val').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed c-reference-det-for-p-dshow-val');
            } else {
                isValid = false;
            }
        });
        return isValid;
    }
}