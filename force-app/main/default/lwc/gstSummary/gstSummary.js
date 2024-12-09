import { LightningElement,api,wire,track} from 'lwc';
import getApplicantEmploymentDetail from '@salesforce/apex/ObligationDetailsSummaryController.getApplicantEmploymentDetail';
import getFilterRelRecordsWithOutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import getGstDetails from '@salesforce/apex/ObligationDetailsSummaryController.getGstDetails';
import { refreshApex } from '@salesforce/apex';

export default class GstSummary extends LightningElement {
  
     @track listFinancialYearRecord=[];
     @track showFinancialData = false;
     @track _activeFinancialTab;
     @track refreshKey = 0;
     @api isBlPl;
     @api applicantId;
     @api get activeFinancialTab() {
          return this._activeFinancialTab;
      }
      set activeFinancialTab(value) {
          this._activeFinancialTab = value; 
          this.setAttribute("activeFinancialTab", value);
          this.refreshKey += 1;  
      }

    @track _recordId;
     @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        if(this.isBlPl){
            this.ApplicantData();
        }
        else{
            this.getGstData();
        }
        // this.fetchTeamDetails();
    }

    connectedCallback(){
       
    }
    gstDetails;
    getGstData(){
        getGstDetails({recordId : this.recordId})
        .then((result)=>{
            console.log('Gst Details----------->');
            console.log(result);
            this.gstDetails = result;
        })
    }
    

    @track applData;
    @track appIds = [];
    ApplicantData(){
        const appData = {
            ParentObjectName: 'Applicant__c ',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Type_of_Borrower__c','Constitution__c', 'FullName__c','LoanAppln__c'],
            childObjFields: [],
            queryCriteria: ' where LoanAppln__c = \'' + this._recordId + '\' and Type_of_Borrower__c = \'Financial\' and Constitution__c != \'INDIVIDUAL\''
        }
        getSobjectDataNonCacheable({params : appData})
     .then((result)=>{
        console.log('Wire Applicant statement----------->');
        console.log(result);
        this.applData = result;
        this.applData.parentRecords.forEach((item)=>{
            if(item.Id){
             this.appIds.push(item.Id);
            }
        })  
        if(this.appIds.size()>0){
            this.SummDataOfCons();
        }
    } ).catch(error => {
        console.log(error);})
}

    @track financialGstDetails;
    @track showFinancialGstDetails = false;
    mapOfApplicantFinancial;
    OldConaolidateList
    ConsoliGSTRecForDelete
    SummDataOfCons(){
        const parametersAppFinCon = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__r.FullName__c', 'Loan_Applicant__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c','FilingDate__c','Gross_TO_NIL_Rated__c'],
           // queryCriteriaForChild: ' order by Index__c asc',
            queryCriteria: ' where Loan_Applicant__c IN (\'' + this.appIds.join('\', \'') + '\') and Type__c = \'Consolidate GST\''
            
        }
        getFilterRelRecordsWithOutCache({ params: parametersAppFinCon })
            .then((result) => {
                console.log('Result 82',result);
                this.financialGstDetails=result 
                this.mapOfApplicantFinancial=[];
                for(const record of this.financialGstDetails){
                    if(record.parentRecord.Applicant_Financial_Summary_s__r){
                        this.showFinancialGstDetails = true;
                        this.mapOfApplicantFinancial.push({key: [record.parentRecord.Loan_Applicant__c], value:record});

                    }
                }

            })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
    }


    sortAndReindex(records) {
        records.forEach(record => {
            if(record.parentRecord.Applicant_Financial_Summary_s__r){
                let financialSummary = record.parentRecord.Applicant_Financial_Summary_s__r;
    
            // Convert GST_Month_Year__c to Date for sorting
            financialSummary.sort((a, b) => {
                let dateA = this.convertToDate(a.GST_Month_Year__c);
                let dateB = this.convertToDate(b.GST_Month_Year__c);
                return dateA - dateB;
            });
    
            // Update Index__c based on sorted order
            financialSummary.forEach((item, index) => {
                item.Index__c = index + 1;
            });
            }
            
        });
        return records;
    }
 
    renderedCallback(){
        refreshApex(this.financialStatementData);
       
    }
        
}