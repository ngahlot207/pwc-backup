import { LightningElement, api, wire, track } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
// Custom labels
import CaseComponent_Reqfields_ErrorMessage from '@salesforce/label/c.CaseComponent_Reqfields_ErrorMessage';
import CaseComponent_Response_SuccessMessage from '@salesforce/label/c.CaseComponent_Response_SuccessMessage';
import CaseComponent_Upsert_ErrorMessage from '@salesforce/label/c.CaseComponent_Upsert_ErrorMessage';

export default class CaseComponent extends LightningElement {
    label = {
        CaseComponent_Reqfields_ErrorMessage,
        CaseComponent_Response_SuccessMessage,
        CaseComponent_Upsert_ErrorMessage

    }
    @api caseId;
    @api cvResp;
    @api cvDetail;
    @api hasEditAccess;
    @api layoutSize;
    @api applicantId;
    currentUserName;
    @track tableDataToUpdate = [];

    @track cvResponceList;
    @track visitDate = this.todaysDate;
    subscription = null;
    @wire(MessageContext)
    MessageContext;


    get todaysDate() {
        const today = new Date();
        return today.toISOString();
    }
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            console.log('currentUserInfo ', data);
            console.table(data);
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }
    connectedCallback() {
        this.sunscribeToMessageChannel();
        console.log('caseId', this.caseId, 'cvResp', this.cvResp, 'cvDetail', this.cvDetail);

        console.log('lastt', this.cvResp);

        // this.pdTypeId = updatedData;
        this.cvResponceList = this.cvResp;
        console.log('updatedData  ', JSON.stringify(this.cvResponceList));

    }
    // @track tableDataToUpdate = [];//[{ objectName: '', records: [{ Id: '' }] }];
    fromChildComp(event) {
        console.log("from child  To Case Compoennt updated val  ", JSON.stringify(event.detail));
        let val = JSON.parse(JSON.stringify(event.detail));
        // if (val.respType === 'Table') {
        //     if (this.tableDataToUpdate.length === 0) {
        //         let tData = {};
        //         tData['Id'] = val.tablevalue.Id;
        //         tData['sobjectType'] = val.objectName;
        //         tData['ApplAssetId__c'] = this.applicantId;
        //         tData[val.tablevalue.fieldName] = val.tablevalue.value;
        //         this.tableDataToUpdate.push(tData);
        //     } else {
        //         let index = this.tableDataToUpdate.findIndex(obj => obj.Id === val.tablevalue.Id);
        //         if (index >= 0) {
        //             this.tableDataToUpdate[index]['sobjectType'] = val.objectName;
        //             this.tableDataToUpdate[index][val.tablevalue.fieldName] = val.tablevalue.value;
        //         } else {
        //             let tData1 = {};
        //             tData1['Id'] = val.tablevalue.Id;
        //             tData1['sobjectType'] = val.objectName;
        //             tData1['ApplAssetId__c'] = this.applicantId;
        //             tData1[val.tablevalue.fieldName] = val.tablevalue.value;
        //             this.tableDataToUpdate.push(tData1);
        //         }
        //     }
        // } else {
        if (this.tableDataToUpdate.length === 0) {
            let tData = {};
            tData['Id'] = val.pdRespId.cvRespId;
            tData['Resp__c'] = val.respVal;
            this.tableDataToUpdate.push(tData);
        } else {
            let index = this.tableDataToUpdate.findIndex(obj => obj.Id === val.pdRespId.cvRespId);
            if (index >= 0) {
                this.tableDataToUpdate[index]['Id'] = val.pdRespId.cvRespId;
                this.tableDataToUpdate[index]['Resp__c'] = val.respVal;
            } else {
                let tData1 = {};
                tData1['Id'] = val.pdRespId.cvRespId;
                tData1['Resp__c'] = val.respVal;
                this.tableDataToUpdate.push(tData1);
            }
        }// {"pdRespId":{"cvRespId":"a1iC4000000CePvIAK","displaySeq":1,"isEditable":false,"isReqMobile":true,"isReqPortal":true,"quesId":"a17C400000Fb1pQIAR","quesTitle":"Product","respType":"Text"},"respVal":"asda"}
        // }
        console.log("from child  To Case Compoennt updated tableDataToUpdate  ", JSON.stringify(this.tableDataToUpdate));
    }
    handleInputChange(event) {
        let name = event.target.name;
        value = event.target.value;
        console.log("handleInputChange in Case Compoennt updated val   ", name, '   vall ::: ', value);

    }

    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }
    handleSaveThroughLms(values) {
        console.log('values to save through Lms  ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave)

    }
    handleSave(validate) {
        this.tableDataToUpdate.forEach(element => {
            if (element.Id.length > 18) {
                element.Id = '';
            }

        });
        console.log('before upsert ', JSON.stringify(this.tableDataToUpdate));
        if (validate) {
            let valid = this.checkReportValidity();
            if (!valid) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.label.CaseComponent_Reqfields_ErrorMessage,
                        variant: "error",
                    })
                );
                return;
            }
        }
        upsertMultipleRecord({ params: this.tableDataToUpdate })
            .then(result => {
                console.log('resultresultresultresultresult', JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.label.CaseComponent_Response_SuccessMessage,
                        variant: "success",
                    })
                );

            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.label.CaseComponent_Upsert_ErrorMessage,
                        variant: "error",
                    })
                );
                console.log('Error in upserting ', JSON.stringify(error));
            })
    }

    checkReportValidity() {
        let valid = true;
        this.template.querySelectorAll('c-dynamic-form-filled').forEach(element => {
            if (!element.reportValidity()) {
                valid = false;
            }
        });
        return valid;
    }

}