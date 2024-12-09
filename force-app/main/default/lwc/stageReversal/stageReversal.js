import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { RefreshEvent } from 'lightning/refresh';
// Custom labels
import ReturnTo_SuccessMessage from '@salesforce/label/c.ReturnTo_SuccessMessage';

export default class StageReversal extends NavigationMixin(LightningElement) {
    customLabel = {
        ReturnTo_SuccessMessage
    }
    @track userId = Id;
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track isReadOnly = false;
    stage;
    substage;
    cpaQueueId;
    uwQueueId;
    @track currentDateTime;
    stageOpt = [];
    arr = [];
    arr2 = [];
    arr3 = [];
    arr4 = [];
    arr5 = [];
    arr6 = [];
    arr7 = [];
    arr8 = [];

    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);

    }

    @wire(getRecord, { recordId: '$recordId', fields: [AppStage, AppSubstage] })
    currentRecordInfo({ error, data }) {
        if (data) {
            this.arr = [];
            this.arr2 = [];
            this.arr3 = [];
            this.arr4 = [];
            this.arr5 = [];
            this.arr6 = [];
            this.arr7 = [];
            this.arr8 = [];
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            console.log('stage', this.stage);
            this.arr = [];
            if ((this.stage === 'UnderWriting' && this.substage === 'Credit Appraisal') || (this.stage === 'DDE' && this.substage === 'Quality Check')) {
                this.arr2 = [{
                    value: "DDE", label: "DDE"

                }]

                this.arr = [...this.arr2, ...this.arr];

            } console.log('arr', this.arr);
            if (this.stage == 'Soft Sanction' && this.substage == 'Additional Data Entry') {
                this.arr3 = [
                    { value: "DDE", label: "DDE" },
                    { value: "UnderWriting", label: "UnderWriting" }
                ]

                this.arr = [...this.arr3, ...this.arr];
            }
            if (this.stage == 'Soft Sanction' && this.substage == 'UW Approval') {
                this.arr4 = [
                    { value: "DDE", label: "DDE" },
                    { value: "UnderWriting", label: "UnderWriting" },
                    { value: "Soft Sanction", label: "Soft Sanction-Additional Data Entry Pool" }
                ]

                this.arr = [...this.arr4, ...this.arr];
            }
            if (this.stage == 'Post Sanction' && this.substage == 'Data Entry') {
                this.arr5 = [
                    { value: "DDE", label: "DDE" },
                    { value: "UnderWriting", label: "UnderWriting" }

                ]

                this.arr = [...this.arr5, ...this.arr];
            }
            //LAK-7332 - BIL UW Decision
            if (this.stage == 'Post Sanction' && this.substage == 'Data Entry Pool') {
                this.arr8 = [
                    { value: "UnderWriting", label: "UnderWriting" }

                ]

                this.arr = [...this.arr8, ...this.arr];
            }
            if (this.stage == 'Post Sanction' && this.substage == 'UW Approval') {
                this.arr6 = [
                    { value: "DDE", label: "DDE" },
                    { value: "UnderWriting", label: "UnderWriting" },
                    { value: "Post Sanction", label: "Post Sanction-Data Entry Pool" }

                ]

                this.arr = [...this.arr6, ...this.arr];
            }
            if (this.stage == 'Disbursement Initiation' && this.substage == 'DI Check') {
                this.arr7 = [
                    { value: "Post Sanction", label: "Post Sanction" }
                ]

                this.arr = [...this.arr7, ...this.arr];
            }
            this.stageOpt = [...this.arr, ...this.stageOpt];


        } else if (error) {
            this.error = error;
        }

    }

    connectedCallback() {
        this.getqueue();
        this.updateCurrentDateTime();
        this.fetchLoanDetails();
        this.fetchTeamDetails();
        // this.displayStageOptions();
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
        }
        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        // let gpName = 'UW Pool'
        // let grpName = 'CPA POOL';
        // let type = 'Queue';
        // let params = {
        //     ParentObjectName: 'Group',
        //     parentObjFields: ["Id", "Name"],
        //     queryCriteria: ' where name = \'' + grpName + '\' AND Type = \'' + type + '\''

        //     // queryCriteria: ' where name IN(\'' + this.grpName + '\',\'' + this.gpName + '\') '+'AND Type = \'' + type + '\''
        // };
        // console.log("params", params);
        // getSobjectDatawithRelatedRecords({ params: params })
        //     .then((res) => {
        //         console.log('in get queue', res);
        //         console.table(res);
        //         // this.loanApplicationQueueId = res.parentRecord.Id;
        //         // console.log('loanApplicationQueueId', this.loanApplicationQueueId);

        //     })


    }
    que;


    getqueue() {
        let type = 'Queue';
        let paramsLoanApp = {
            ParentObjectName: 'Group',
            parentObjFields: ['Id', 'Name'],
            queryCriteria: ' where Type = \'' + type + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                //     let result;
                // let resultNew = res.parentRecords;
                //     console.log('result is get q==> ', JSON.stringify(resultNew));
                //     if (resultNew.length > 0) {
                //         result = resultNew.filter(item => item.Name == 'CPA POOL')
                //     }
                //     console.log('result is', result, result.length);
            //LAK-7332 - BIL UW Decision

                if(result.parentRecords && result.parentRecords > 0) {
                    result.parentRecords.array.forEach(item => {
                        if(item.Name === 'CPA Pool'){
                            this.cpaQueueId = item.Id;
                        }
                        if(item.Name === 'UW Pool' ){
                            this.uwQueueId = item.Id;
                        }
                        
                    });
                    
                }

                console.log('cpaQueueId===>', this.cpaQueueId);
                console.log('uwQueueId===>', this.uwQueueId);
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in getting q", error);

            });



    }
    handleChange(event) {
        this.stageVal = event.detail.value;
    }
    onChange(event){
        this.returRemarks = event.detail.value;
    }
    handleSuccess(e) {
        if (this.stageVal === 'DDE') {
            
            if(this.userRole === 'QCPA'){
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Stage__c: 'DDE',
                    SubStage__c: 'Vendor Query',
                    OwnerId: this.vcpa,
    
                }
                console.log('in Return to from QCPA => ', obje);
                this.upsertDataMethod(obje);
            }else{
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Stage__c: 'DDE',
                    SubStage__c: 'Query Pool',
                    // Return_Remarks__c: this.returRemarks,
                    OwnerId: this.cpaQueueId,
    
                }
                console.log('in Return to DDE => ', obje);
                this.upsertDataMethod(obje);
            }
           
          
            
        }
        else if (this.stageVal === 'UnderWriting') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'UnderWriting',
                SubStage__c: 'UW Pool',
                OwnerId: this.uwQueueId,
                // Return_Remarks__c: this.returRemarks,

            }
            console.table(obje);
            console.log('in Return to UW => ', obje);
            this.upsertDataMethod(obje);
           
        }

        else if (this.stageVal === 'Soft Sanction') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'Soft Sanction',
                SubStage__c: 'Additional Data Entry Pool',
                OwnerId: this.cpaQueueId,
                // Return_Remarks__c: this.returRemarks,

            }
            console.table(obje);
            console.log('in Return to SoftSanction => ', obje);
            this.upsertDataMethod(obje);

        }
        // else if (this.stageVal == 'Soft Sanction-Additional Data Entry Pool') {
        //     const obje = {
        //         sobjectType: "LoanAppl__c",
        //         Id: this.recordId,
        //         Stage__c: 'Soft Sanction',
        //         SubStage__c: 'Additional Data Entry Pool',
        //         OwnerId: this.cpaQueueId,

        //     }
        //     console.table(obje);
        //     console.log('in Return to SoftSanction => ', obje);
        //     this.upsertDataMethod(obje);

        // }
        else if (this.stageVal === 'Post Sanction') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'Post Sanction',
                SubStage__c: 'Ops Query Pool',
                OwnerId: this.cpaQueueId,
                // Return_Remarks__c: this.returRemarks,

            }
            console.table(obje);
            console.log('in Return to Post Sanction => ', obje);
            this.upsertDataMethod(obje);

        }
        else if (this.stageVal === 'Disbursement Initiation') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'Post Sanction',
                SubStage__c: 'Ops Query Pool',
                OwnerId: this.cpaQueueId,
                // Return_Remarks__c: this.returRemarks,

            }
            console.table(obje);
            console.log('in Return to Post Sanction => ', obje);
            this.upsertDataMethod(obje);

        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
         //dispatching the custom event
      const selectedEvent = new CustomEvent("select", {
        detail: false
      });
      this.dispatchEvent(selectedEvent);
    }
    upsertDataMethod(obje) {
        this.createUWDecesionRecord();
        console.log('objec ', obje);
        console.table(obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    console.log('Result====>',result);
                    this.createFeed();
                    this.refreshPage = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ReturnTo_SuccessMessage,
                            variant: "success",
                            mode: "sticky"
                        }),
                    );
                    setTimeout(() => {
                        location.reload();
                      }, 3000);
                      this.navigateToListView();
                    // this[NavigationMixin.Navigate]({
                    //     type: 'standard__recordPage',
                    //     attributes: {
                    //         recordId: this.recordId,
                    //         actionName: 'view'
                    //     }
                    // });
                                    
                    
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error while updating the record",
                            message: error.body.message,
                            variant: "error",
                            mode: "sticky"
                        }),
                    );
                    this.showSpinner = false;
                });
        }
    }
   @track returnStage;
   @track returnRemarks;
getDecisionRecord(){
    let params = {
                ParentObjectName: 'UWDecision__c',
                parentObjFields: ['Id', 'Stage__c','DecisionRmrks__c'],
                queryCriteria: ' where LoanAppl__c = \'' + this.recordId + '\' order by CreatedDate desc '
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('result is get decision record ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.returnStage = result.parentRecords[0].Stage__c;
                        this.returnRemarks = result.parentRecords[0].DecisionRmrks__c;

                        console.log('this.returnStage is ', this.returnStage);
                        console.log('this.returnRemarks is ', this.returnRemarks);

                    }
                })
                .catch((error) => {
    
                    this.showSpinner = false;
                    console.log("error occured in get decision Record", error);
    
                });
    }
createFeed(){
    // getFeed({ loanAppId: this.recordId })
    // .then(res => {
    //     console.log('Feed Result',res);
    // })
    // .catch(error => {
    //     console.error('Error calling Apex method: ', error);
    // });
            let fields = {};
            fields['sobjectType'] = 'FeedItem';
            fields['ParentId'] = this.recordId;
            fields['Body'] = 'Loan Application is returned to ' + this.returnStage + ' with remarks: ' + this.returnRemarks;
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
createUWDecesionRecord() {
    let fields = {};
    fields['sobjectType'] = 'UWDecision__c';
    fields['LoanAppl__c'] = this.recordId;
    if (this.stageVal == 'DDE') {
        fields['Stage__c'] =  'DDE';
        fields['SubStage__c'] = 'Query Pool';
    } else if (this.stageVal == 'UnderWriting') {
        fields['Stage__c'] =  'UnderWriting';
        fields['SubStage__c'] = 'UW Pool';
    } else if (this.stageVal == 'Soft Sanction') {
        fields['Stage__c'] = 'Soft Sanction';
        fields['SubStage__c'] = 'Additional Data Entry Pool';
    }
    else if (this.stageVal == 'Post Sanction') {
        fields['Stage__c'] = 'Post Sanction';
        fields['SubStage__c'] = 'Ops Query Pool';
    }
    else if (this.stageVal == 'Disbursement Initiation') {
        fields['Stage__c'] = 'Post Sanction';
        fields['SubStage__c'] = 'Ops Query Pool';
    }
    //LAK-8497 - Jayesh
    this.returnStage = fields['Stage__c'];
    this.returnRemarks = this.returRemarks ? this.returRemarks : '';
    fields['Date_Time__c'] = this.currentDateTime;
    fields['User__c'] = this.userId;
    fields['DecisionRmrks__c'] = this.returRemarks ? this.returRemarks : '';
    fields['Decision_Type__c'] = 'Stage Reversal';
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
            this.getDecisionRecord();
        })
        .catch((error) => {
            console.log('error in upserting uw decision ', JSON.stringify(error));

        });
}
}
navigateToListView() {
    this[NavigationMixin.Navigate]({
        type: "standard__objectPage",
        attributes: {
            objectApiName: "LoanAppl__c",
            actionName: "list"
        },
        state: {

            filterName: "Recent"
        }
    });
}

@track vcpa;
fetchLoanDetails() {
  let loanDetParams = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Name","VendorCPA__c"],
      childObjFields: [],
      queryCriteria: " where Id = '" + this.recordId + "' limit 1"
    };
    getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result Save Button DETAILS #263>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.vcpa = result.parentRecords[0].VendorCPA__c;
         
        }
      })
      .catch((error) => {
        console.log("RCU LOAN Details Error#856", error);
      });
  }


@track userRole;

fetchTeamDetails() {
   let teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c=\''+Id+'\''
        }              
    getSobjectDataNonCacheable({params: teamHierParam}).then((result) => {
  
        console.log("result STAGE REVERSAL COMP #482>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.userRole = result.parentRecords[0].EmpRole__c;
        
        }
      })
      .catch((error) => {
        console.log("Error in STAGE REVERSAL COMP #489", error);
      });
  }
}