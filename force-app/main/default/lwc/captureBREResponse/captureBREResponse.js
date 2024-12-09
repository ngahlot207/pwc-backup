/*
  HOTFIX
  LAK-6471:- BRE Response from Call 1, 2 , 3 to be displayed
  Developed By : Dhananjay Gadekar
*/

import { LightningElement, api, track, wire} from 'lwc';
//Standard uiRecordApi(LDS) to get record
import { getRecord } from 'lightning/uiRecordApi';

//Apex methods
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

//Date utility function
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';

//Import Stage PicklistValue
import LOAN_APPL_STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';
import LOAN_APPL_SUBSTAGE from '@salesforce/schema/LoanAppl__c.SubStage__c';
import REQUESTED_LOAN_AMOUNT from '@salesforce/schema/LoanAppl__c.ReqLoanAmt__c';
import PRODUCT from '@salesforce/schema/LoanAppl__c.Product__c';
import STATUS from '@salesforce/schema/LoanAppl__c.Status__c';
//Refresh wire adapter
import { refreshApex } from '@salesforce/apex';

//Custom label required for charges calculation
import ApplScorecardRemarkMapping from '@salesforce/label/c.ApplicationScorecardRemarkMapping';

export default class CaptureBREResponse extends LightningElement {
    @track label = {
        ApplScorecardRemarkMapping
    }

    @track showDeviationTable=false;
    @track applScorecardResultvalue;
    @track deviationRecords=[];
    @track wiredBREResult;
    @track loanApplStage;
    @track loanApplSubStage;
    @track loanApplReqLoanAmt;
    @track loanApplproduct;
    @track BREDecision;
    @track AppScorecardResult;
    @track isCallId2 = false;
    @track showDevCodeLevel = false;
    @track showFinancialData=true;
    @track breDataArray=[];
    @track islatestTrue = true;
    @track eligibleType = 'Application';
    @track showBREDataTable =  false;
    @track applScorecardRemrkStage1 = '';
    @track applScorecardRemrk=[];
    @track loanStatus;
   
    //Getter Setter to get Loan Application Id
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange(value);
    }

    @track
    breParameter = {
      ParentObjectName: 'BRE__c ',
      ChildObjectRelName: 'Deviations__r',
      parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c', 'DecisionScrecardStg2__c', 'DecisionScrecardStg1__c', 'EligibilityType__c', 'IsLatest__c', 'CreatedDate', 'Decision__c', 'LastModifiedDate','AppScorecardResult__c'],
      childObjFields: ['Id', 'Deviation__c', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Dev_DescrId__c'],
      queryCriteria: 'WHERE LoanAppl__c=\'' + this.loanAppId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'AND IsLatest__c=' + this.islatestTrue + ' ORDER BY LastModifiedDate DESC LIMIT 1'
    }
  
    //To set BRE response query on the basis of latest LAN Id
    handleRecordIdChange() {
      let tempParams = this.breParameter;
      tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanAppId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\' AND IsLatest__c=' + this.islatestTrue + ' ORDER BY LastModifiedDate DESC LIMIT 1';
      this.breParameter = { ...tempParams };
    }

    //To get BRE response details with related deviations
    @wire(getSobjectDatawithRelatedRecords, { params: '$breParameter' })
    handleBREResponse(result) {
        const { data, error } = result;
        this.wiredBREResult = result;
        console.log('this.wiredBREResult---------->',JSON.stringify(this.wiredBREResult));
        if (data) {
                if (data.parentRecord) {
                    let tempBREArr=[];
                    this.applScorecardResultvalue = data.parentRecord.DecisionScrecardStg1__c ? data.parentRecord.DecisionScrecardStg1__c : null;
                    this.AppScorecardResult = data.parentRecord.AppScorecardResult__c ? data.parentRecord.AppScorecardResult__c : null;
                    this.BREDecision = data.parentRecord.Decision__c ? data.parentRecord.Decision__c : null;
                    tempBREArr.push(data.parentRecord);
                    if(tempBREArr && tempBREArr.length > 0){
                        this.getBreDecisionRemark();
                        this.showBREDataTable = true;
                        this.breDataProcessor(tempBREArr);
                    }          
                }         
                if (data.parentRecord && data.parentRecord.Deviations__r && data.parentRecord.Deviations__r.length > 0) {
                    this.showDeviationTable = true;
                    this.deviationRecords = data.parentRecord.Deviations__r;
                }              
                    
        }
        else if (error) {
            console.log('Error from handle BRE Response', JSON.stringify(error));
        }
    }

    //Process BRE data to show on UI & modify date as well as set value of scorecard remark 
    breDataProcessor(tempBREArr){
        this.breDataArray=[];
        this.deviationRecords=[];

        this.breDataArray = tempBREArr.map(record => {
            let modifiedRecord = { ...record };       
            if (modifiedRecord && modifiedRecord.LastModifiedDate) {
                const formattedDate1 = formattedDateTimeWithoutSeconds(modifiedRecord.LastModifiedDate); 
                const orderDate = `${formattedDate1}`;
                modifiedRecord.LastModifiedDate =  orderDate;
            }
            if (modifiedRecord && modifiedRecord.CreatedDate) {
                const formattedDate2 = formattedDateTimeWithoutSeconds(modifiedRecord.CreatedDate); 
                const createdDate2 = `${formattedDate2}`;
                modifiedRecord.CreatedDate = createdDate2;
            }
            return modifiedRecord; // Return the modified record
        });

        // this.applScorecardRemrk = JSON.parse(this.label.ApplScorecardRemarkMapping);
        // if(this.applScorecardRemrk && this.applScorecardRemrk.length > 0 && this.applScorecardResultvalue !=null){
        //     let scorecardRemark = [...this.applScorecardRemrk];
             
        //     // scorecardRemark.forEach(element => {
        //     //     if(element.scoreResult == this.applScorecardResultvalue.toLowerCase()){
        //     //         this.applScorecardRemrkStage1 = element.scoreRemark;
        //     //     }
        //     // });
        // }
    }

    //LAK-63
    getBreDecisionRemark(){
        let breDecisionParameter = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Product__c', 'Stage__c','Application_Scorecard_Decision__c', 'Min__c','Max__c', 'Bre_Decision__c','BRE_Remarks__c'],
            childObjFields: [],
            queryCriteria: ' where Type__c = \'Bre Decision Remark\''
        }
        getSobjectData({
                params: breDecisionParameter
            })
            .then((result) => {
                if(result.parentRecords && result.parentRecords.length > 0){
                console.log('result in getBreDecisionRemark method', JSON.stringify(result.parentRecords.length))
                console.log('loanApplStage,loanApplSubStage,loanApplReqLoanAmt,AppScorecardResult,loanApplproduct,BREDecision ', this.loanApplStage,this.loanApplSubStage,this.loanApplReqLoanAmt,this.AppScorecardResult,this.loanApplproduct,this.BREDecision)
                let filteredRecords = result.parentRecords.filter(record => {
                    return  record.Product__c.toLowerCase().includes(this.loanApplproduct.toLowerCase()) &&
                            record.Bre_Decision__c.toLowerCase() === this.BREDecision.toLowerCase() &&
                            record.Stage__c.toLowerCase().includes(this.loanApplStage.toLowerCase()) &&
                            record.Application_Scorecard_Decision__c.toLowerCase().includes(this.AppScorecardResult.toLowerCase()) &&
                            record.Min__c < this.loanApplReqLoanAmt &&
                            record.Max__c > this.loanApplReqLoanAmt;
                });

                if (filteredRecords.length > 0) {
                    this.applScorecardRemrkStage1 = filteredRecords[0].BRE_Remarks__c;
                }
            }
            })
            .catch((error) => {
                console.log('Error in getFOIR method', JSON.stringify(error))
            })

    }

    //To get Loan Application Stage
    @wire(getRecord, { recordId: '$_loanAppId', fields: [LOAN_APPL_STAGE, LOAN_APPL_SUBSTAGE, REQUESTED_LOAN_AMOUNT, PRODUCT,STATUS] })
    StagePicklistValue({ data, error }) {
        if (data) {
            this.loanApplStage = data.fields.Stage__c.value ? data.fields.Stage__c.value : null;
            this.loanApplSubStage = data.fields.SubStage__c.value ? data.fields.SubStage__c.value : null;
            this.loanApplReqLoanAmt = data.fields.ReqLoanAmt__c.value ? data.fields.ReqLoanAmt__c.value : 0;
            this.loanApplproduct = data.fields.Product__c.value ? data.fields.Product__c.value : null;
            this.loanStatus=data.fields.Status__c.value?data.fields.Status__c.value:null;

            if(this.loanApplStage && this.loanApplStage === 'QDE' && this.loanStatus &&(this.loanStatus==='BRE Soft Reject' ||this.loanStatus==='BRE Hard Reject')){//&& this.loanApplSubStage && (this.loanApplSubStage ==='Additional Data Entry' || this.loanApplSubStage ==='Additional Data Entry Pool')
                this.isCallId2 = true;
            }

            if(this.loanApplStage && this.loanApplStage === 'QDE' && this.loanApplSubStage && (this.loanApplSubStage ==='Additional Data Entry' || this.loanApplSubStage ==='Additional Data Entry Pool')){
                this.showDevCodeLevel = true;
            }
            this.getBreDecisionRemark();
        }
        if (error) {
            console.log('Error in getting Loan Appl Stage',JSON.stringify(error));
        }
    }

    renderedCallback(){
        refreshApex(this.wiredBREResult);
    }

}