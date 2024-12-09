import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import LANRelookReason from "@salesforce/schema/LoanAppl__c.Reject_Review_Reason__c";
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import AddComments from "@salesforce/schema/LoanAppl__c.Additional_Comments__c";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
//custom label
import Relook_SuccessMessage from '@salesforce/label/c.Relook_SuccessMessage';
import Relook_ErrorMessage from '@salesforce/label/c.Relook_ErrorMessage';

export default class RelookApplication extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track userId = Id;
    @track currentDateTime;
    RelookReason;
    employeeRole;
    stage;
    substage;
    addcomm;
    addComp2;
    makeReasonRequired = true;
    @track retvalue = true;

    connectedCallback() {
        this.getUserRole();
        // if(!this.retvalue){
        //     this.dispatchEvent(new CloseActionScreenEvent());
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: "Error ",
        //             message: Relook_ErrorMessage,
        //             variant: "error",
        //             mode: "sticky"
        //         }),
        //     );
        // }
        this.updateCurrentDateTime();
        setTimeout(() => {
            this.showSpinner = false;
        }, 6000);
    }
    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);

    }
    @wire(getRecord, { recordId: '$recordId', fields: [LANRelookReason, AppStage, AppSubstage, AddComments] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.RelookReason = data.fields.Reject_Review_Reason__c.value;
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            this.addcomm = data.fields.Additional_Comments__c.value;

        } else if (error) {
            this.error = error;
        }
    }

    handleValueChange(event) {
        this.LANRelookReason = event.target.value;
    }
    @track statusVal;
    cancelStatus = 'Rejected';
    rejectStatus = 'Final Reject';
    getStatus() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanTAT__c',
            parentObjFields: ['Id', 'Status__c'],
            queryCriteria: ' where Status__c != \'' + this.rejectStatus + '\' AND Status__c != \'' + this.cancelStatus + '\' AND LoanApplication__c = \'' + this.recordId + '\'order by LastModifiedDate desc'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get status ', JSON.stringify(result));
                this.statusVal = result.parentRecords[0].Status__c;
                console.log('statusVal===>', this.statusVal);
                let obje = {
                    Id: this.recordId,
                    Status__c: this.statusVal
                }
                this.upsertLoanRecord(obje);
                console.log('resultprinted  in getStatus');

            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in getting prevStatus", error);

            });

    }
    handleaddCommentValue(event) {
        this.addComp2 = event.target.value;
        console.log('addComp2:' + event.target.value);
    }

    handleSuccess() {
        this.showSpinner = true;
        if (!this.validateForm()) {
            return;
        } else {
            if (this.retvalue === true) {
                const obj = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Reject_Review_Reason__c: this.LANRelookReason,

                }
                this.createUWDecesionRecord();
                this.upsertData(obj);
                // }else{
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //             title: "Error ",
                //             message: Relook_ErrorMessage,
                //             variant: "error",
                //             mode: "sticky"
                //         }),
                //     );
            }
        }

    }
    upsertData(obj) {
        console.log('objec ', obj);
        console.table(obj);
        let newArra = [];
        if (obj) {
            newArra.push(obj);
        }
        if (newArra) {
            console.log('new array is ', JSON.stringify(newArra));
            upsertSObjectRecord({ params: newArra })
                .then((result) => {
                    this.refreshPage = result;
                    console.log('result => ', result);
                    // this.showToastMessage('Success', Relook_SuccessMessage, 'success', '');
                    // this[NavigationMixin.Navigate]({
                    //     type: 'standard__recordPage',
                    //     attributes: {
                    //         recordId: this._loanAppId,
                    //         actionName: 'view'
                    //     }
                    // });

                    // setTimeout(() => {
                    //     location.reload();
                    // }, 1000);
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    // console.table(error);
                    // this.showToastMessage('Error', this.Customlabel.ApprovalTray_LAN_Update_ErrorMessage, 'error', 'sticky');
                    this.showSpinner = false;
                });
        }
    }
    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.employeeRole = result.parentRecords[0].EmpRole__c;
                    console.log('this.employeeRole is ', this.employeeRole);
                    if (this.employeeRole == 'UW' || this.employeeRole == 'ACM' || this.employeeRole == 'RCM' || this.employeeRole == 'ZCM' || this.employeeRole == 'NCM' || this.employeeRole == 'CH') {
                        this.retvalue = true;
                    }
                    else {
                        this.dispatchEvent(new CloseActionScreenEvent());
                        // this.retvalue = false;
                        this.showSpinner = false;

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error ",
                                message: Relook_ErrorMessage,
                                variant: "error",
                                mode: "sticky"
                            }),
                        );

                    }
                }
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    arr = [];
    createUWDecesionRecord() {
        let fields = {};
        fields['sobjectType'] = 'UWDecision__c';
        fields['LoanAppl__c'] = this.recordId;
        fields['DecisionDt__c'] = this.currentDateTime;
        fields['Date_Time__c'] = this.currentDateTime;
        fields['User__c'] = this.userId;
        fields['DecisionRmrks__c'] = this.LANRelookReason;
        fields['AddationalComm__c'] = this.addComp2;
        fields['Decision_Type__c'] = 'UW Decision';
        fields['Decision__c'] = 'Relook';
        this.upsertUwDecision(fields);
        console.log('this.upsertUwDecision(fields)', fields);
    }


    upsertUwDecision(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    this.getStatus();
                    this.createFeed();

                })
                .catch((error) => {
                    console.log('error in upserting uw decision ', JSON.stringify(error));

                });
        }
    }
    upsertLoanRecord(obj) {
        let newAr = [];
        if (obj) {
            newAr.push(obj);
        }
        if (newAr.length > 0) {
            console.log('new array is ', JSON.stringify(newAr));
            upsertSObjectRecord({ params: newAr })
                .then((result) => {
                    console.log('resultprinted LAN');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: Relook_SuccessMessage,
                            variant: 'success'
                        })
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());

                    setTimeout(() => {
                        location.reload();
                    }, 2000);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        },
                    });
                })
                .catch((error) => {
                    console.log('error in upserting LAN ', JSON.stringify(error));

                });
        }
    }
    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            console.log("custom lookup validity custom lookup >>>", isInputCorrect);
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log("custom lookup validity if false>>>", isInputCorrect);
            }
        });
        return isInputCorrect;
    }
    validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });
        if (!this.checkValidityLookup()) {
            isValid = false;
        }
        if (isValid === false) {
        }
        return isValid;
    }
    createFeed() {
        console.log('Hold Resone:' + this.unholdReason);
        console.log('Additional Comment:' + this.addComp2)
        if (this.addComp2 === undefined || this.addComp2 === '') {
            this.addComp2 = 'NA';
        }

        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        // fields['Body'] = 'Loan Application is on UNHOLD with reason: ' + this.unholdReason;
        fields['Body'] = 'Loan Application is on Relook Reason: ' + this.LANRelookReason + ' and with Remarks: ' + this.addComp2;
        this.upsertFeed(fields);

    }

    upsertFeed(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {
                    console.log('error in creating feed ', JSON.stringify(error));

                });
        }
    }

}