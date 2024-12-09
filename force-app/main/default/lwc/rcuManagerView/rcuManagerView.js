import { LightningElement, track, wire, api } from "lwc";
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import DOC_DETL_OBJECT from "@salesforce/schema/DocDtl__c";

import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';

import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import updateStatus from "@salesforce/apex/UpdateRCUStatusAfterRCUManager.updateStatus";
import getSobjectData1 from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';

import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe,publish,MessageContext,unsubscribe,releaseMessageContext} from "lightning/messageService";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";

export default class RcuManagerView extends LightningElement {


    @track showSpinner = false;
    @track _loanAppId;
    @api get recordId() {
      return this._loanAppId;
    }
    set recordId(value) {
      this._loanAppId = value;
      this.setAttribute("_loanAppId", value);
      this.fetchLoanDetails();
      this.getCaseData(value);
      this.getHunterData(value);
      this.getApplicaWithAddressDetails(value);
    }

    @track renderCaseDetails=false;
    @track rcuStatOptions=[];
    @track vendorVerfOptions=[];
    @track agcStatOptions=[];
  
@track finalRCURemark;    
@track managerRemarks;

get disableMode(){
  return this.finalRCURemark !== '';
}

    connectedCallback() {
      
       console.log('rcuUser id in RCU::::29',this._loanAppId, this.rcuUser, this.recordId);
         this.sunscribeToMessageChannel();
      }
    
      @wire(MessageContext)
      MessageContext;

      
      sunscribeToMessageChannel() {
        this.subscription = subscribe(
          this.MessageContext,
          SaveProcessCalled,
          (values) => this.handleSaveThroughLms(values)
        );
      }
    
      @track verifierColumns = [
        {
            label: 'Case No',
            fieldName: 'CaseNumber',
            type: 'text',
            editable: false
        },
        {
            label: 'RCU Initiation Date',
            fieldName: 'DateTimeInitiation__c',
            type: 'date',
            typeAttributes: {
              year: 'numeric',
              month: 'short',
              day: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
              hour12: true
            },
            cellAttributes: {
              class: { fieldName: 'closedDateClass' }
          },
            editable: false
        },
        {
            label: 'RCU Sampler Name',
            fieldName: 'RCU Sampler Name',
            type: 'text',
            editable: false
        },
        {
            label: 'RCU Agency Name',
            fieldName: 'agcList',
            type: 'text',
            editable: false
        },
        {
            label: 'Total No of Sampled Documents',
            fieldName: 'noOfDoc',
            type: 'number',
            editable: false
        },
        {
            label: 'RCU Case Status',
            fieldName: 'Status',
            type: 'text',
            editable: false
        },
        {
            label: 'Actions',
            type: 'button',
            typeAttributes: {
                label: 'View',
                name: 'View',
                variant: 'success'
            }
        },
        {
            label: 'Agency RCU Report Status',
            fieldName: 'AgcRCUReportStatus__c',
            type: 'text',
            editable: false
        },
        {
            label: 'Report Date',
            fieldName: 'ClosedDate',
            type: 'date',
            typeAttributes: {
              year: 'numeric',
              month: 'short',
              day: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
              hour12: true
            },
            editable: false
        },
        {
            label: 'TAT',
            fieldName: 'TAT__c',
            type: 'text',
            editable: false
        }
    ];
    
    handleVerifierAction(event) {
      const actionName = event.detail.action.name;
      const row = event.detail.row;
      // Handle different actions based on the button clicked
      if (actionName === 'View') {
            this.handleVerifierView(row, actionName)
          console.log('View action on record:', row.Id);
      }
    }

    handleVerifierView(row,actionName) {
      this.actionName='';
      this.docIds=[];
      this.addrIds=[];
      this.viewDoc =false;
      let dataValue = actionName;
      this.actionName=actionName;
      this.showSpinner=true;
      this.viewCaseId= ''
      // To View Cases under RCU Verifiers
      if (dataValue === "View") {
        let caseid= row.Id;
        this.viewCaseId= caseid;
        // this.caseId= caseid;
        if(!this.caseRecordId){
          this.caseRecordId = row.Id;
          console.log("caseRecordId ", this.caseRecordId);
          this.fetchCaseDoc(this.caseRecordId);
          this.getAgencyCaseData(this.caseRecordId);
          this.renderCaseDetails = true;
        }else {
          if(this.caseRecordId === row.Id){
            this.renderCaseDetails = false;
            this.caseRecordId=null
            this.showSpinner=false;
          }else{
            this.caseRecordId='';
            this.caseRecordId = row.Id;
            this.fetchCaseDoc(this.caseRecordId);
            this.getAgencyCaseData(this.caseRecordId);
            this.renderCaseDetails = true;
          }
        }
          
      }
    
    
      
    }
      @wire(getObjectInfo, { objectApiName: DOC_DETL_OBJECT })
      objInfo3;  
      @wire(getPicklistValuesByRecordType, {
        objectApiName: DOC_DETL_OBJECT,
        recordTypeId: "$objInfo3.data.defaultRecordTypeId"
      })
      DocDtlPicklistHandler({ data, error }) {
        if (data) {
          this.rcuStatOptions = [...this.generatePicklist(data.picklistFieldValues.RCUFileStatus__c)];
          this.vendorVerfOptions=[...this.generatePicklist(data.picklistFieldValues.VendorVerification__c)];
          this.agcStatOptions=[...this.generatePicklist(data.picklistFieldValues.AgencyDocStatus__c)];
        }
        if (error) {
          console.error("error im getting TSR picklist values are", error);
        }
      }

      fetchLoanDetails() {
        let loanDetParams = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Name", "FinalRCUManagerRemarks__c"],
            childObjFields: [],
            queryCriteria: " where Id = '" + this._loanAppId + "' limit 1"
          };
          getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
             // this.wiredDataCaseQry=result;
              console.log("result RCU LOAN DETAILS #841>>>>>", result);
              if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
              
                this.finalRCURemark = result.parentRecords[0].FinalRCUManagerRemarks__c ? result.parentRecords[0].FinalRCUManagerRemarks__c : '';
                this.getCaseData();
           
              }
            })
            .catch((error) => {
              console.log("RCU LOAN Details Error#856", error);
            });
        }

    @track caseRecCopy=[]
    @track appModalData=[];
    @track addrVerData=[];
  @api getCaseData() {
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","Address_Type__c","Address_Line_2__c","Address_Line_1__c","ApplAddr__c","CaseNumber","AccountId","ContactId",
        "ClosedDate","ReportResult__c","Old_Agency__r.Name","Account.Name","Contact.Name","Status","Remarks_for_Technical_Agency__c",
        "CityId__c","Reason_for_reinitiated_FI__c","Reason_for_cancelation__c","Loan_Application__c","Applicant__c",
        "IsReinitiated__c",'DateTimeInitiation__c','Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c',
        'IsReinitiatedExpired__c','TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c','AgcRCUReportStatus__c'],

        queryCriteria:' where AccountId = null AND Loan_Application__c=\''+this._loanAppId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      console.log("getCaseData method 63", result);
      this.showSpinner=false;
      this.caseData = result;
      this.caseRecordsData = [];
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        //this.docDetailsAvl=true;
        result.parentRecords.forEach((item, index) => {
          if (item.Status === "Closed" || item.Status === "Cancelled") {
            item.isCanDis = true;
          } else {
           // this.agecnyFlag=false;
            item.isCanDis = this.hasEditAccess===true?false:true
            
          }

        });

        this.caseRecordsData = result.parentRecords;
        let caseIds=[];
      
        this.caseRecordsData.forEach(row1 => {
          const dateTime1 = new Date(row1.ClosedDate);
          const dateTime2 = new Date(row1.DateTimeInitiation__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
            const dateOfIntiation1 = `${formattedDate1}`;
            const dateOfIntiation2 = `${formattedDate2}`;
            row1.ClosedDate = dateOfIntiation1;
            row1.initiationDate = dateOfIntiation2;
            caseIds.push(row1.Id)
        });
        this.caseRecCopy = [...this.caseRecordsData];
        let element = this.caseRecCopy.pop();
        console.log('element:::::99',element);
        if(element.Status !== 'Closed'){
          this.openCaseOwner = element.Owner.Id
          this.openCaseId=element.Id;
          console.log('openCaseOwner:::::103',this.openCaseOwner);
        }
        console.log('case details on CPA / UW View::::105',this.caseRecordsData);
      this.getVerifierCaseData();
     // if(this.rcuUser){
        this.getSampledDocs(caseIds);
    //  }
      
      }
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }

  @track appData=[];
  @track addrData=[];
    getApplicaWithAddressDetails() {
      let paramsData = {
          ParentObjectName: 'Applicant__c',
          ChildObjectRelName: 'Applicant_Addresses__r',
          parentObjFields: ['Id', 'LoanAppln__c', 'TabName__c','FullName__c', 'MobNumber__c', 'PhoneNumber__c', 'Type_of_Borrower__c','ApplType__c','Constitution__c','CustProfile__c'],
          childObjFields: ['Id', 'FullAdrs__c', 'AddrTyp__c', 'City__c', 'CityId__c','RCUProfChecked__c','IsDeleted__c','SamplingDateTime__c','RCUUnHoldDateTime__c','RCURemarks__c',
            'RCUInitiDateTime__c','AgencyAssigned__c','RCUFileStatus__c','AgencyDocStatus__c'],
          queryCriteria: '  where LoanAppln__c = \'' + this._loanAppId + '\''
      }
      // queryCriteria: '  where Type_of_Borrower__c = \'' + this.typeOfBorrower + '\' AND LoanAppln__c = \'' + this.loanAppId + '\''
      getAllSobjectDatawithRelatedRecords({ params: paramsData })
          .then((result) => {
            this.docDetailsAvl=false
              this.addrData=[];
              this.addrVerData=[];
              this.appData = result;
              console.log(' getApplicaWithAddressDetails result is in RCU Manager View 198', JSON.stringify(result));
              if (this.appData) {
                  this.appData.forEach(item => {
                      if (item.parentRecord) {
                          if (item.ChildReords) {
                              item.ChildReords.forEach(childitem => {
                                if(!(childitem.RCUProfChecked__c && childitem.IsDeleted__c)){
                                  let obj = {};
                                  obj.appId = item.parentRecord.Id;
                                  obj.loanAppId = this._loanAppId;
                                  obj.appName = item.parentRecord.FullName__c;
                                  obj.appAdrrsId = childitem.Id;
                                  obj.appAddrType = childitem.AddrTyp__c;
                                  obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                                  obj.addrCity = childitem.City__c;
                                  obj.fullAddr=childitem.FullAdrs__c;
                                  obj.selectCheckbox = false;
                                  this.addrData.push(obj);
                                }
                              })
                          }
  
                      }
                  });
             
              }
              if (result.error) {
                  console.error('appl result getting error=', result.error);
              }
          })
  
  }
  @track verifCaseRecords=[];
  getSampledDocs(caseIds){
    let caseDocParams = {
      ParentObjectName: "CaseDoc__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Case__c", "DocDetail__c","DocDetail__r.RCUFileStatus__c","ApplAddr__c","Case__r.AccountId",
        "Case__r.Account.Name","Case__r.AgcRCUReportStatus__c"
      ],
      childObjFields: [],
      queryCriteria: ' where Case__c IN  (\''+caseIds.join('\', \'') + '\') '
    };
    let mapCaseDocs = new Map();
    getSobjectDataNonCacheable({params: caseDocParams}).then((result) => {
      this.showSpinner=false;
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
        console.log('case details on Verifier View in getSampledDocs:::921',result.parentRecords);
        let caseDocs = result.parentRecords;
        caseDocs.forEach(item=>{
          let key = item.Case__c;
          if (!mapCaseDocs.has(key)) {
           let statusList=[]
           if(item.DocDetail__c && item.DocDetail__r.RCUFileStatus__c ==='Sampled'){
            statusList.push(item)
           }
              mapCaseDocs.set(key, statusList);
          } else {
            const templist= mapCaseDocs.get(key)
            if(item.DocDetail__c && item.DocDetail__r.RCUFileStatus__c ==='Sampled'){
              templist.push(item)
             }
              mapCaseDocs.set(key, templist);
          } 
     
        })
        this.mapCaseDocs=mapCaseDocs;
        console.log('mapCaseDocs  is 550 ', this.mapCaseDocs);
        this.getAgencyCaseName(caseIds,mapCaseDocs);
     //  console.log('Object.keys(mapOfMonthWithTax):::::',Object.keys(this.mapCaseDocs));
     

    console.log('case details on verifier view  is 952 ', this.verifCaseRecords);
   
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      
      console.log("TECHNICAL PROP CASE QUERIES #766", error);
    });
  }


  getAgencyCaseName(caseid,mapCaseDocs) {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","CaseNumber","AccountId","ContactId","Account.Name","Case__c"
      ],
        queryCriteria:' where Case__c In (\''+caseid.join('\', \'') + '\') AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.showSpinner=false;
      console.log(' getAgencyCaseData method 1100', result);
     let agcCases=result.parentRecords;
      let mapCaseAgency= new Map();
      if(agcCases && agcCases.length>0){
        agcCases.forEach(item=>{
          let key = item.Case__c;
          if(!mapCaseAgency.has(key)){
            let agencyList=[];
            if(item.AccountId){
              agencyList.push(item.Account.Name);
             }
             mapCaseAgency.set(key, agencyList);
            } else {
              const acclist= mapCaseAgency.get(key)
              if(item.AccountId){
                acclist.push(item.Account.Name)
               }
               mapCaseAgency.set(key, acclist);
          }
        })
   
      }
      this.mapCaseDocs=mapCaseDocs;
      this.mapCaseAgency=mapCaseAgency;
      console.log('mapCaseAgency  is 1018 ', this.mapCaseAgency);
      console.log('caseRecordsData:::::944',this.caseRecordsData);
      let arr=this.caseRecordsData
      this.verifCaseRecords=[];
       arr.forEach(element=>{
        // if(element.OwnerId === this.currentUserId){
           let obj={}
           const index = this.mapCaseDocs.get(element.Id).length;
           let temarr;
           temarr = this.getCommaSeparatedValues(this.mapCaseAgency,element.Id);
           let unqArr
           if(temarr){
           unqArr = [...new Set(temarr.split(','))].toString();
           }
           console.log('mapCaseAgency  is 1116 ', unqArr);
           obj = {...element, 'noOfDoc': index, 'agcList': unqArr}
           this.verifCaseRecords.push(obj);
      //   }
        
       })
  
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }

  getCommaSeparatedValues(array, targetId) {
    for (let item of array) {
        let id = item[0];
        let values = item[1];
        if (id === targetId) {
            return values.join(', ');
        }
    }
    return null;
}


@track caseAgencyData=[]
  @api getVerifierCaseData() {
    console.log("loanappId in RCU component", this.loanAppId);
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","Address_Type__c","Address_Line_2__c","Address_Line_1__c","ApplAddr__c","CaseNumber","AccountId","ContactId",
        "ClosedDate","ReportResult__c","Old_Agency__r.Name","Account.Name","Contact.Name","Status","Remarks_for_Technical_Agency__c",
        "CityId__c","Reason_for_reinitiated_FI__c","Reason_for_cancelation__c","Loan_Application__c","Applicant__c",
        "IsReinitiated__c",'DateTimeInitiation__c','Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c',
        'IsReinitiatedExpired__c','TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c'],

        queryCriteria:' where ContactId != null AND Loan_Application__c=\''+this._loanAppId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      console.log("result 542", result);
      this.showSpinner=false;
      this.caseAgencyData = [];
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        result.parentRecords.forEach((item) => {
          if (item.Status === "Closed" || item.Status === "Cancelled") {
            item.isCanDis = true;
          } else {
          
            item.isCanDis = this.hasEditAccess===true?false:true
            
          }

        });

        this.caseAgencyData = result.parentRecords;
       console.log('this.caseAgencyData::::531',this.caseAgencyData);
        this.caseAgencyData.forEach(row1 => {
          const dateTime1 = new Date(row1.ClosedDate);
          const dateTime2 = new Date(row1.DateTimeInitiation__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
            const dateOfIntiation1 = `${formattedDate1}`;
            const dateOfIntiation2 = `${formattedDate2}`;
            row1.ClosedDate = dateOfIntiation1;
            row1.initiationDate = dateOfIntiation2;
        });

      
      }
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }

  generatePicklist(data) {
    console.log('data in generatePicklist ', JSON.stringify(data));
    if (data.values) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }
    return null;
}

  @track hunterStaWhereMatchFondOptions = [];
  @wire(getPicklistValuesByRecordType, {
    objectApiName: 'HunterVer__c',
    recordTypeId: '$recordTypeId',
})
hunterPicklistHandler({ data, error }) {
    if (data) {
        console.log('data in PicklistHandler', JSON.stringify(data));
        this.hunterStaWhereMatchFondOptions = [...this.generatePicklist(data.picklistFieldValues.HunterStatWhereMatchFound__c)]
    }
    if (error) {
        console.error('error im getting picklist values are', error)
    }
}
@track recordTypeId;
@wire(getObjectInfo, { objectApiName: 'HunterVer__c' })
objectInfo({ data, error }) {
    if (data) {
        // Retrieve the default record type ID
        this.recordTypeId = data.defaultRecordTypeId;
    } else if (error) {
        console.error('Error fetching object info', error);
    }
}

  @track hunterData = [];
  getHunterData() {
      this.showSpinner = true;
      let params = {
          ParentObjectName: 'HunterVer__c',
          parentObjFields: ['ReqTime__c', 'ResTime__c', 'HunMatchSta__c', 'ClientReferenceId__c', 'IntegrationStatus__c', 'IntegrationErrorMessage__c', 'Id', 'Rem__c', 'RCUmanagerfeedback__c', 'HunterStatWhereMatchFound__c','FraudStatusDescription__c','WorkStatusDescription__c'],
          queryCriteria: ' where LoanAplcn__c = \'' + this._loanAppId + '\' AND IsLatest__c = true'
      }
      getSobjectData({ params: params })
          .then((result) => {
              // this.showSpinner = true;
              console.log('Hunter Data in RCU Manager 255::: ', JSON.stringify(result));
              if (result.parentRecords) {
                let obj={}
                  result.parentRecords.forEach(item => {
                    let ReqTime__c = '';
                    let ResTime__c = '';
                      if (item.ReqTime__c) {
                          ReqTime__c = formattedDateTimeWithoutSeconds(item.ReqTime__c);
                      }
                      if (item.ResTime__c) {
                          ResTime__c = formattedDateTimeWithoutSeconds(item.ResTime__c);
                      }
                      obj={...item, 'ReqTime__c': ReqTime__c,'ResTime__c':ResTime__c }
                  })
                  this.hunterData.push(obj);
                  console.log('this.hunterData in RCU Manager 277 ', this.hunterData);
              }
              this.showSpinner = false;
          })
          .catch((error) => {
              this.showSpinner = false;
              console.log('Error In getting Hunter Verification Data is ', error);
              //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
          });
  }

  get caseId(){
    let val=''
    if(this.caseRecordId){
      val = this.caseRecordId;
    }
    return val;
  }

  @track caseRecordId;
@track actionName;
@track viewDoc=false;
  handlebutton(event) {
    this.actionName='';
    this.docIds=[];
    this.addrIds=[];
    this.viewDoc =false;
    console.log("dataname is ", event.target.dataset.name);
    let dataValue = event.target.dataset.name;
    this.actionName=event.target.dataset.name;
    this.showSpinner=true;
    if (dataValue === "View") {
        if(!this.caseRecordId){
            this.caseRecordId = event.target.dataset.caseid;
            console.log("caseRecordId ", this.caseRecordId);
            this.fetchCaseDoc(this.caseRecordId);
            this.getAgencyCaseData(this.caseRecordId);
            this.renderCaseDetails = true;
          }else {
            if(this.caseRecordId === event.target.dataset.caseid){
              this.renderCaseDetails = false;
              this.caseRecordId=null
              this.showSpinner=false;
            }else{
              this.caseRecordId = event.target.dataset.caseid;
              this.fetchCaseDoc(this.caseRecordId);
              this.getAgencyCaseData(this.caseRecordId);
              this.renderCaseDetails = true;
            }
          }

       
    }
    
  }


  @track addrVerAssignData=[];
@track caseDocList=[]
@track docIds=[];
@track addrIds=[];
  fetchCaseDoc(caseid){
    let caseDocParams = {
      ParentObjectName: "CaseDoc__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Case__c", "DocDetail__c","ApplAddr__c"],
      childObjFields: [],
      queryCriteria: ' where Case__c = \''+ caseid + '\''
    };
    getSobjectDataNonCacheable({params: caseDocParams}).then((result) => {
      this.showSpinner=false;
      this.appModalData=[];
      this.addrVerData=[];
      this.addrVerAssignData=[];
      console.log('fetchCaseDoc result::::::1536',result);
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
        this.caseDocList = result.parentRecords;
        this.caseDocList.forEach((e)=>{
          if(e.DocDetail__c){
            this.docIds.push(e.DocDetail__c);
          }
          if(e.ApplAddr__c){
            this.addrIds.push(e.ApplAddr__c);
          }
          console.log('this.docIds:::::1495',this.docIds);
          console.log('this.addrIds:::::1496',this.addrIds);
        })
    if(this.docIds && this.docIds.length>0){
      if(this.actionName === 'View'){

        this.fetchDocDetlVerifier();
      } 
    }
   
    if(this.addrIds && this.addrIds.length>0){
      this.getRcuInitiatedProfile(this.appData);
     
    }
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      
      console.log("TECHNICAL PROP CASE QUERIES #766", error);
    });
  }


  fetchDocDetlVerifier() { 
    let docDetParams = {
      ParentObjectName: "DocDtl__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id","Name","LAN__c","DocTyp__c","File_Type__c","CreatedDate","DocSubTyp__c","ApplAsset__r.Id","Case__c",
        "RCUInitiated__c","Appl__r.FullName__c","ApplAsset__r.Name","ApplAsset__c","LAN__r.Name","RCUFileStatus__c",
        "AgencyAssigned__c","CreditReqSampling__c","DocValidStatus__c","RCUProfChecked__c","RCURemarks__c",
        "SampleTrigger__c","RCUHoldDateTime__c","RCUUnHoldDateTime__c","AgencyDocStatus__c",
        "RCUInitiDateTime__c","SamplingDateTime__c"
      ],
      childObjFields: [],
      queryCriteria: ' where ID IN (\''+this.docIds.join('\', \'') + '\')  AND RCUInitiated__c = true AND IsDeleted__c != true AND AgencyAssigned__c = true'
        };
    getSobjectDataNonCacheable({params: docDetParams}).then((result) => {
      this.showSpinner=false;
      console.log("RCU Details DOCUMENT DETAILS #765", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.appModalData = result.parentRecords;        
          console.log("RCU Details DOCUMENT DETAILS #773", this.appModalData);
          this.appModalData.forEach(item => {
            if(item.AgencyDocStatus__c === 'Positive' || item.AgencyDocStatus__c === 'Pending' || item.AgencyDocStatus__c === 'Refer'){
              item.disStatus=true;
            }
            const dateTime1 = new Date(item.ClosedDate);
            const dateTime2 = new Date(item.RCUInitiDateTime__c);
              const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
              const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
              const dateOfIntiation1 = `${formattedDate1}`;
              const dateOfIntiation2 = `${formattedDate2}`;
              item.ClosedDate = dateOfIntiation1;
              item.initiationDate = dateOfIntiation2;
          });
          this.initializeData1(this.appModalData);
        }
        

        this.docIds=[];
        
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("RCU Details DOCUMENT DETAILS #594", error);
      });
  }

  getRcuInitiatedProfile(appData){
    if (appData) {
      appData.forEach(item => {
          if (item.parentRecord) {
              if (item.ChildReords) {
                  item.ChildReords.forEach(childitem => {
                    if(childitem.RCUProfChecked__c && childitem.AgencyAssigned__c){
                      this.addrIds.forEach(i=>{
                        if(i===childitem.Id){
                          let obj = {};
                          obj.appId = item.parentRecord.Id;
                          obj.loanAppId = this._loanAppId;
                          obj.appName = item.parentRecord.FullName__c;
                          obj.appAdrrsId = childitem.Id;
                          obj.appAddrType = childitem.AddrTyp__c;
                          obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                          obj.addrCity = childitem.City__c;
                          obj.fullAddr=childitem.FullAdrs__c;
                          obj.RCUFileStatus__c=childitem.RCUFileStatus__c;
                          obj.SampleTrigger__c=childitem.SampleTrigger__c;
                          obj.RCURemarks__c=childitem.RCURemarks__c;
                          obj.RCUInitiDateTime__c=childitem.RCUInitiDateTime__c;
                          obj.AgencyDocStatus__c=childitem.AgencyDocStatus__c;
                          const dateTime2 = new Date(childitem.RCUInitiDateTime__c);
                            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                            const dateOfIntiation2 = `${formattedDate2}`;
                            obj.initiationDate = dateOfIntiation2;
                          this.addrVerData.push(obj);
                        }
                      })
                    
                    }
                    console.log('this.addrVerData is In RCU Manager view 662', this.addrVerData);
                    console.log('this.addrVerAssignData is In RCU Manager view 663', this.addrVerAssignData);
                  })
              }
  
          }
      });
  
  }
  }

  getAgencyCaseData(caseid) {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","CaseNumber","AccountId","ContactId","ClosedDate","ReportResult__c","Account.Name",
        "Contact.Name","Status","Remarks_for_Technical_Agency__c","Reason_for_cancelation__c",
        "Loan_Application__c","Applicant__c","IsReinitiated__c",'DateTimeInitiation__c',
        'Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c','IsReinitiatedExpired__c',
        'TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c'

      ],
        queryCriteria:' where Case__c =\'' +caseid+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.showSpinner=false;
      console.log(' getAgencyCaseData method in RCU Manager 691', result);
      this.caseData = result;
     // this.agencyCases = [];
      this.agencyCases=this.caseData.parentRecords;
      console.log(' this.agencyCases 963', this.agencyCases);
      if(this.agencyCases && this.agencyCases.length>0){
        this.agencyCases.forEach(row1 => {
          const dateTime1 = new Date(row1.ClosedDate);
          const dateTime2 = new Date(row1.DateTimeInitiation__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
            const dateOfIntiation1 = `${formattedDate1}`;
            const dateOfIntiation2 = `${formattedDate2}`;
            row1.ClosedDate = dateOfIntiation1;
            row1.initiationDate = dateOfIntiation2;
          });
      }
     
    
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error in RCU Manager=", result.error);
      }
    });
  }


  handleUpdate(){
    this.showSpinner=true;
    let isInputCorrect = this.validateForm();
    if (isInputCorrect) {
  
    let tempArr=[];
    if(this.docDetArr && this.docDetArr.length>0){
      this.docDetArr.forEach(i=>{
        delete i.ValidationStatus;
      })
     console.log('this.docDetArr:::in RCU Manager:728',this.docDetArr);
     
      let filterDocDtl=this.docDetArr.filter(item => item.OverrideByRCUManager__c === true);

      console.log('filterDocDtl:::in RCU Manager 732',filterDocDtl);
      filterDocDtl.forEach(i=>{
        let obj ={}
        obj.Id= i.Id;
        obj.AgencyDocStatus__c=i.AgencyDocStatus__c;
        obj.OverrideByRCUManager__c =i.OverrideByRCUManager__c;
        obj.User__c=i.User__c;
        obj.sobjectType='DocDtl__c';
        tempArr.push(obj);
      })
      console.log('docDetArr in RCU Manager:::::739',tempArr);
    }
    
      if(tempArr){
        this.upsertData(tempArr);
      }
      
    
      let tempAddrArr=[];
      let filterApplAddr=this.addrVerData.filter(item => item.OverrideByRCUManager__c === true);
      if(filterApplAddr && filterApplAddr.length>0){
        filterApplAddr.forEach(i=>{
          let obj ={}
          obj.Id= i.appAdrrsId;
          obj.AgencyDocStatus__c=i.AgencyDocStatus__c;
          obj.OverrideByRCUManager__c =i.OverrideByRCUManager__c;
          obj.User__c=i.User__c;
          obj.sobjectType='ApplAddr__c';
          tempAddrArr.push(obj);
        })
      }
      if(tempAddrArr){
        console.log('tempAddrArr:in RCU Manager:::::761',tempAddrArr);
        this.upsertData(tempAddrArr);
      }

         let tempLANArr=[];
          let obj ={}
          obj.Id= this._loanAppId;
          obj.FinalRCUManagerRemarks__c=this.managerRemarks;
          obj.sobjectType='LoanAppl__c';
          tempLANArr.push(obj);
          if(tempLANArr){
            this.upsertLoanData(tempLANArr);
          }
      this.getCaseData();
    }else{
      this.showSpinner=false;
    }
    
  }

  handleInputChange(event){
    this.managerRemarks = event.detail.value.toUpperCase();
  }
  upsertData(obj){
    if(obj){   
    console.log('Document Detail Records update ##2508', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Document Detail Records update ##2512', result);
        this.showToastMessage('Success', 'Document Details Updated Successfully', 'success', 'sticky');
        this.getApplicaWithAddressDetails();
        this.upsertCaseDocDtatus();// Updating Agency Doc Status in apex for all case documents
        this.renderCaseDetails=false;
        this.renderDocDetails=false;
        this.renderAddrDetails=false;
        this.viewCaseId=''
        this.docDetArr=[];
        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##2520', error)
    })
  }
  }

  upsertCaseDocDtatus(){
    updateStatus({ loanId: this._loanAppId })
    .then(result => {     
        console.log('Loan RCU Status Records Update in RCU Manager  ##811', result);
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU MANAGER DOC STATUS METHOD ##816', error)
    })
  
  }

  upsertLoanData(obj){
    if(obj){   
    console.log('LOAN RCU STATUS UPDATE in RCU Manager ##780', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Loan RCU Status Records Update in RCU Manager  ##783', result);
        this.renderCaseDetails=false;
        location.reload();
       // this.showToastMessage('Success', 'Parent Case status updated Successfully', 'success', 'sticky');
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##790', error)
    })
  }
  }
  validateForm() {
    let isValid = true;
    if(this.selectDoc){
      let filterArr= this.docSelctArr.filter(item => item.RCUInitiated__c === true || item.RCUProfChecked__c===true);
      console.log('filterArr::::::2625',filterArr);
      
      if (filterArr.length < 1 ) {
        isValid = false;
        this.showToastMessage('Error', this.label.Technical_Doc_ErrorMessage, 'error', 'sticky');
      
      }
    }

    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {
        //console.log('element passed combobox');
        //console.log('element if--'+element.value);
      } else {
        isValid = false;
        //console.log('element else--'+element.value);
      }
    });

    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (element.reportValidity()) {
        //console.log('element passed lightning input');
      } else {
        isValid = false;
      }
    });

      this.template.querySelectorAll("lightning-textarea").forEach((element) => {
        if (element.reportValidity()) {
          //console.log('element passed lightning input');
        } else {
          isValid = false;
          this.showToastMessage('Error', 'Please fill the required fields', 'error', 'sticky');
        }
      });
      return isValid;
    
   
  }


  handleClick(event) {
    console.log('HANDLE CLICK IN RCU1340  in RCU Manager', JSON.stringify(event.target.dataset));
    let docid = event.target.dataset.docid;
        if(event.target.dataset.label==='Agency RCU Status'){
              
          let indexId = event.target.dataset.index;
          let val = event.target.value;
          console.log('val ', val, 'docid ', docid,'indexId',indexId);

          let temp = this.appModalData[indexId];
          temp.AgencyDocStatus__c=val;
          temp.OverrideByRCUManager__c=true;
          temp.User__c=Id;
          this.appModalData[indexId] = {...temp};      

        let tempArray = [...this.appModalData];
        tempArray[event.target.dataset.index] = this.appModalData[indexId];
        this.appModalData = [...tempArray];

          this.docDetArr=[...tempArray];
          
        }
 
 console.log('this.appModalData FINAL in RCU Manager:::1811', this.appModalData,':::',this.appModalData.length)
}

  handleProfCheckClick(event) {
    console.log('HANDLE CLICK IN RCU 2069 ', event.target.dataset);
    let addrid = event.target.dataset.docid;
  
  if(event.target.dataset.label==='Agency RCU Status'){
      
    let indexId = event.target.dataset.index;
    let val = event.target.value;
    console.log('val ', val, 'addrid ', addrid,'indexId',indexId);
  
    let temp = this.addrVerData[indexId];
    temp.AgencyDocStatus__c=val;
    temp.OverrideByRCUManager__c=true;
    temp.User__c=Id;
    this.addrVerData[indexId] = {...temp};      
  
   let tempArray = [...this.addrVerData];
   tempArray[event.target.dataset.index] = this.addrVerData[indexId];
   this.addrVerData = [...tempArray];  
  }
  
 
       
  console.log('this.addrVerData FINAL in RCU Manager:::2137', this.addrVerData,':::',this.addrVerData.length)
  }
  handleViewDocument(event){
    this.showSpinner=true;
    this.viewDoc =false;
    this.docId=null;
    let dataValue = event.target.dataset.name;
   
    if (dataValue === "ViewDoc") {
        this.docId = event.target.dataset.docId; // Set new document ID
        this.hasDocId = true;
      console.log("docId ", this.docId);
  
        // Optionally, you can use a setTimeout to simulate asynchronous behavior
        setTimeout(() => {
            this.viewDoc = true; // Show document preview
            this.showSpinner = false; // Hide spinner after a short delay
        }, 1000);
  }
  }

  

  closeSplitDocModal(){
    this.viewDoc = false;
  }
  handleCloseModalEvent() {
        this.viewDoc = false;
        
    }
   
    
    showToastMessage(title, message, variant, mode) {
      const evt = new ShowToastEvent({
          title,
          message,
          variant,
          mode
      });
      this.dispatchEvent(evt);
  }
   //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
   tableOuterDivScrolled(event) {
    this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
    if (this._tableViewInnerDiv) {
      if (
        !this._tableViewInnerDivOffsetWidth ||
        this._tableViewInnerDivOffsetWidth === 0
      ) {
        this._tableViewInnerDivOffsetWidth =
          this._tableViewInnerDiv.offsetWidth;
      }
      this._tableViewInnerDiv.style =
        "width:" +
        (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) +
        "px;" +
        this.tableBodyStyle;
    }
    this.tableScrolled(event);
  }

  tableScrolled(event) {
    if (this.enableInfiniteScrolling) {
      if (
        event.target.scrollTop + event.target.offsetHeight >=
        event.target.scrollHeight
      ) {
        this.dispatchEvent(
          new CustomEvent("showmorerecords", {
            bubbles: true
          })
        );
      }
    }
    if (this.enableBatchLoading) {
      if (
        event.target.scrollTop + event.target.offsetHeight >=
        event.target.scrollHeight
      ) {
        this.dispatchEvent(
          new CustomEvent("shownextbatch", {
            bubbles: true
          })
        );
      }
    }
  }

//******************************* RESIZABLE COLUMNS FOR CASE TABLE *************************************//
handlemouseup(e) {
  this._tableThColumn = undefined;
  this._tableThInnerDiv = undefined;
  this._pageX = undefined;
  this._tableThWidth = undefined;
}

handlemousedown(e) {
  if (!this._initWidths) {
    this._initWidths = [];
    let tableThs = this.template.querySelectorAll(
      "table thead .dv-dynamic-width"
    );
    tableThs.forEach((th) => {
      this._initWidths.push(th.style.width);
    });
  }

  this._tableThColumn = e.target.parentElement;
  this._tableThInnerDiv = e.target.parentElement;
  while (this._tableThColumn.tagName !== "TH") {
    this._tableThColumn = this._tableThColumn.parentNode;
  }
  while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
    this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
  }
  // console.log(
  //   "handlemousedown._tableThColumn.tagName => ",
  //   this._tableThColumn.tagName
  // );
  this._pageX = e.pageX;

  this._padding = this.paddingDiff(this._tableThColumn);

  this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
  // console.log(
  //   "handlemousedown._tableThColumn.tagName => ",
  //   this._tableThColumn.tagName
  // );
}

handlemousemove(e) {
  // console.log("mousemove._tableThColumn => ", this._tableThColumn);
  if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
    this._diffX = e.pageX - this._pageX;

    this.template.querySelector("table").style.width =
      this.template.querySelector("table") - this._diffX + "px";

    this._tableThColumn.style.width = this._tableThWidth + this._diffX + "px";
    this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

    let tableThs = this.template.querySelectorAll(
      "table thead .dv-dynamic-width"
    );
    let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    let tableBodyTds = this.template.querySelectorAll(
      "table tbody .dv-dynamic-width"
    );
    tableBodyRows.forEach((row) => {
      let rowTds = row.querySelectorAll(".dv-dynamic-width");
      rowTds.forEach((td, ind) => {
        rowTds[ind].style.width = tableThs[ind].style.width;
      });
    });
  }
}

handledblclickresizable() {
  let tableThs = this.template.querySelectorAll(
    "table thead .dv-dynamic-width"
  );
  let tableBodyRows = this.template.querySelectorAll("table tbody tr");
  tableThs.forEach((th, ind) => {
    th.style.width = this._initWidths[ind];
    th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
  });
  tableBodyRows.forEach((row) => {
    let rowTds = row.querySelectorAll(".dv-dynamic-width");
    rowTds.forEach((td, ind) => {
      rowTds[ind].style.width = this._initWidths[ind];
    });
  });
}
paddingDiff(col) {
  if (this.getStyleVal(col, "box-sizing") === "border-box") {
    return 0;
  }

  this._padLeft = this.getStyleVal(col, "padding-left");
  this._padRight = this.getStyleVal(col, "padding-right");
  return parseInt(this._padLeft, 10) + parseInt(this._padRight, 10);
}

getStyleVal(elm, css) {
  return window.getComputedStyle(elm, null).getPropertyValue(css);
}

}