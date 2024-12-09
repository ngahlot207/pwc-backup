import { LightningElement,track,api,wire } from 'lwc';
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanDetailsSummary';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'

import { formatDateFunction } from 'c/dateUtility';

export default class RcuPortalLoanDetails extends LightningElement {

    @api recordId;
    @api objectApiName="LoanAppl__c";

    @track applicationId;
    @track loginDate;
    @track branchName;
    @track city;
    @track product;
    @track schemeId;
    @track schemeCode;
    @track rMName;
    @track channelCode;
    @track channelName;
    @track ChannelRName;
    @track totalLoanAnt;
    @track loanPurpose;
    @track borowerTypeName;
    @track loanDetailsSummaryList=[];

@track loanAppId=null;


    connectedCallback(){
        this.initialize(this.recordId);
    }
    get showRcuLoanDetails(){
        return this.loanAppId !== null
    }

    initialize(caseId){
        let parameter = {
          ParentObjectName: 'Case',
          ChildObjectRelName: null,
          parentObjFields: ['Id','Loan_Application__c','RecordType.Name'],
          childObjFields: [],
          queryCriteria: ' where id = \'' + caseId + '\''
        }
      
        getSobjDataWIthRelatedChilds({ params: parameter })
        .then(result => {
            console.log('Case details RCU:::::75',result);   
          if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'RCU'){
             this.loanAppId = result.parentRecord.Loan_Application__c;
             console.log('this.loanAppId:::::77',this.loanAppId);
             
             this.getLoanDetails(this.loanAppId);
          }
 
        })
        .catch(error => {
            console.log('INTLIZE error : ',JSON.stringify(error));
        });
      }


      getLoanDetails(loanAppId){
        let parameter = {
          ParentObjectName: 'LoanAppl__c',
          ChildObjectRelName: null,
          parentObjFields: ['Id','Name','BrchName__c','LoginAcceptDate__c','City__c','Product__c',
            'SchemeId__c','SchmCode__c','RM__c','ChannelCode__c','ChannelName__c','ReqTenInMonths__c',
            'TotalLoanAmtInclInsurance__c','LoanPurpose__c'
          ],
          childObjFields: [],
          queryCriteria: ' where id = \'' + loanAppId + '\''
        }
      
        getSobjDataWIthRelatedChilds({ params: parameter })
        .then(result => {
            console.log('this.loanAppId:::::103',result);
            
          if(result.parentRecord.Id !== undefined){
             this.applicationId = result.parentRecord.Name;
             this.loginDate = formatDateFunction(result.parentRecord.LoginAcceptDate__c);
             this.branchName = result.parentRecord.BrchName__c;
             this.city = result.parentRecord.City__c;
             this.product = result.parentRecord.Product__c;
             this.schemeId = result.parentRecord.SchemeId__c;
             this.schemeCode = result.parentRecord.SchmCode__c;
             this.rMName = result.parentRecord.RM__c;
             this.channelCode = result.parentRecord.ChannelCode__c ? result.parentRecord.ChannelCode__c : '';
             this.channelName = result.parentRecord.ChannelName__c ?result.parentRecord.ChannelName__c : '';
             this.totalLoanAnt = result.parentRecord.TotalLoanAmtInclInsurance__c;
             this.loanPurpose = result.parentRecord.LoanPurpose__c;
          }
 
        })
        .catch(error => {
            console.log('getLoanDetails error : ',JSON.stringify(error));
        });
      }



@wire(getLoanDetailsSummary,{ recordId: '$loanAppId'})
getLoanDetailsSummary({ data, error }) {

    if (data) {
        this.loanDetailsSummaryList = data;
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

}