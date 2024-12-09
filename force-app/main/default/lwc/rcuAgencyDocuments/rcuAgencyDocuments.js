import { LightningElement, track, wire, api } from 'lwc';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import VerifierFirstScrSize from '@salesforce/label/c.VerifierFirstScrSize';
import DOC_DETL_OBJECT from "@salesforce/schema/CaseDoc__c";
import RCU_STATUS from "@salesforce/schema/CaseDoc__c.AgencyDocStatus__c";

export default class RcuAgencyDocuments extends LightningElement {

@api recordId;
@track loanAppId;
@track parentCaseId;
@track rcuAgency=false;
@track caseStatus;
@track agencyRcuStatus;
@track appList =[];
@track rcuStatOptions=[];
@track appModalData=[];
@track appAddrData=[];

@track leftScreen=12
@track rightScreen;
@track showSpinner=false;
label = {
  VerifierFirstScrSize
}
connectedCallback(){
    this.initialize(this.recordId);
    this.fetchCaseDoc(this.recordId);
}

get disableMode(){
  return this.caseStatus === 'Closed';
}

    initialize(caseId){
        let parameter = {
          ParentObjectName: 'Case',
          ChildObjectRelName: null,
          parentObjFields: ['Id','RecordType.Name','Case__c','Loan_Application__c','Loan_Application__r.Applicant__c','Status','AgcRCUReportStatus__c'],
          childObjFields: [],
          queryCriteria: ' where id = \'' + caseId + '\''
        }
      
        getSobjDataWIthRelatedChilds({ params: parameter })
        .then(result => {
          if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'RCU'){
             console.log('Case Detail 50:',result);
             this.rcuAgency = true;
             this.loanAppId = result.parentRecord.Loan_Application__c;
             this.parentCaseId= result.parentRecord.Case__c;
             this.caseStatus = result.parentRecord.Status;
             this.agencyRcuStatus= result.parentRecord.AgcRCUReportStatus__c ? result.parentRecord.AgcRCUReportStatus__c : '';
             this.getApplDetails(this.loanAppId);
             console.log('Case this.agencyRcuStatus 56:'+this.agencyRcuStatus);
          }
 
        })
        .catch(error => {
            console.log('INTLIZE error : ',JSON.stringify(error));
        });
      }
      

      getApplDetails(loanAppId){
        let applParams = {
          ParentObjectName: "Applicant__c",
          ChildObjectRelName: "",
          parentObjFields: [
            "Id","Name","LoanAppln__c","FullName__c","ApplType__c","RCUProfChecked__c","CustProfile__c"
          ],
          childObjFields: [],
          queryCriteria: ' where LoanAppln__c = \''+ loanAppId + '\' AND RCUProfChecked__c= true'
        };
      
        getSobjectDataNonCacheable({params: applParams}).then((result) => {
          this.showSpinner=false;
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
              this.appList = result.parentRecords; 
              this.appList.forEach(i=>{
                if(i.ApplType__c==='P'){
                  i.ApplType__c= 'PRIMARY';
              }
              if(i.ApplType__c==='C'){
                  i.ApplType__c='CO-APPLICANT'
              }
              if(i.ApplType__c==='G'){
                  i.ApplType__c='GUARANTOR'
              }
              if(i.ApplType__c==='N'){
                  i.ApplType__c='NOMINEE'
              }
              if(i.ApplType__c==='A'){
                  i.ApplType__c='APPOINTEE'
              }
              })
                
            }
          })
        .catch(error => {
            console.log('INTLIZE error : ',JSON.stringify(error));
        });
      }
      

@track caseDocList=[]
  fetchCaseDoc(caseid){
    let caseDocParams = {
      ParentObjectName: "CaseDoc__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Case__c", "DocDetail__c","ApplAddr__c","DocDetail__r.Appl__r.FullName__c",
        "DocDetail__r.DocTyp__c","DocDetail__r.DocSubTyp__c","DocDetail__r.SampleTrigger__c",
        "DocDetail__r.RCUFileStatus__c","DocDetail__r.RCURemarks__c","ApplAddr__r.Applicant__r.FullName__c",
      "ApplAddr__r.AddrTyp__c","ApplAddr__r.FullAdrs__c","ApplAddr__r.SampleTrigger__c","ApplAddr__r.RCUFileStatus__c",
    "ApplAddr__r.RCURemarks__c","ApplAddr__r.AgencyDocStatus__c","DocDetail__r.AgencyDocStatus__c","AgencyDocStatus__c",
  ],
      childObjFields: [],
      queryCriteria: ' where Case__c = \''+ caseid + '\''
    };
    getSobjectDataNonCacheable({params: caseDocParams}).then((result) => {
      
      console.log('result:::::::104',result);
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
         this.appModalData=[];
         this.appAddrData=[];
        this.caseDocList = result.parentRecords;
        this.caseDocList.forEach((e)=>{
          if(e.DocDetail__c){
            this.appModalData.push(e);
            console.log('RCU Agency Docuemnts this.appModalData:::::116',this.appModalData);
          }
          if(e.ApplAddr__c){
            this.appAddrData.push(e);
            console.log('RCU Agency Docuemnts this.addrIds:::::120',this.appAddrData);
          }
          
        })

      }
    })
    .catch((error) => {
      console.log("RCU AGENCIES VENDOR PORTAL ERROR #766", error);
    });
  }



       generatePicklist(data) {
        return data.values.map((item) => ({
          label: item.label,
          value: item.value
        }));
      }

      
       @wire(getObjectInfo, { objectApiName: DOC_DETL_OBJECT })
       objInfo1;
       @wire(getPicklistValues, {
         recordTypeId: "$objInfo1.data.defaultRecordTypeId",
         fieldApiName: RCU_STATUS
       })
       RcuStatusPicklistHandler({ data, error }) {
         if (data) {
           console.log("RCU STATUS PICKLIST DATA::::: #608", data);
           this.rcuStatOptions = [...this.generatePicklist(data)];
         }
         if (error) {
           console.log(error);
         }
       }

@track caseDocArr=[];
  @track viewDoc;
  @track contVersDataList;
  @track hasDocId=true;
  handlebutton(event) {
    console.log("dataname is ", event.target.dataset.name,  event.target.dataset.docId);
    let dataValue = event.target.dataset.name;
    this.showSpinner=true;
    if (dataValue === "ViewDoc") {
        this.docId = event.target.dataset.docId;
        this.leftScreen=this.label.VerifierFirstScrSize;
        this.rightScreen= 12-this.leftScreen
        this.viewDoc = true;
        this.showSpinner=false;    
    }

  }
  handleRcuInit(event){
    let docid = event.target.dataset.docid;
    if(event.target.dataset.label==='Document Status'){ 
      let indexId = event.target.dataset.index;
      let val = event.target.value;
      console.log('val ', val, 'docid ', docid,'indexId',indexId);

      let temp = this.appModalData[indexId];
      temp.AgencyDocStatus__c=val;
      this.appModalData[indexId] = {...temp};      

     let tempArray = [...this.appModalData];
     tempArray[event.target.dataset.index] = this.appModalData[indexId];
     this.appModalData = [...tempArray];
     this.caseDocArr=[...tempArray];
  }
  if(event.target.dataset.label==='Remarks'){ 
    let indexId = event.target.dataset.index;
    let val = event.target.value.toUpperCase();
    console.log('val ', val, 'docid ', docid,'indexId',indexId);

    let temp = this.appModalData[indexId];
    temp.RCUAgencyRemarks__c=val;
    this.appModalData[indexId] = {...temp};      

   let tempArray = [...this.appModalData];
   tempArray[event.target.dataset.index] = this.appModalData[indexId];
   this.appModalData = [...tempArray];
   this.caseDocArr=[...tempArray];
}
  console.log('this.appModalData FINAL :::263', this.appModalData,':::',this.appModalData.length)
  }



  handleProfileCheck(event){
 let docid = event.target.dataset.docid;
    if(event.target.dataset.label==='Document Status'){ 
      let indexId = event.target.dataset.index;
      let val = event.target.value;
      console.log('val ', val, 'docid ', docid,'indexId',indexId);

      let temp = this.appAddrData[indexId];
      temp.AgencyDocStatus__c=val;
      this.appAddrData[indexId] = {...temp};      

     let tempArray = [...this.appAddrData];
     tempArray[event.target.dataset.index] = this.appAddrData[indexId];
     this.appAddrData = [...tempArray];
     this.caseDocArr=[...tempArray];
  }
  if(event.target.dataset.label==='Remarks'){ 
    let indexId = event.target.dataset.index;
    let val = event.target.value.toUpperCase();
    console.log('val ', val, 'docid ', docid,'indexId',indexId);

    let temp = this.appAddrData[indexId];
    temp.RCURemarks__c=val;
    this.appAddrData[indexId] = {...temp};      

   let tempArray = [...this.appAddrData];
   tempArray[event.target.dataset.index] = this.appAddrData[indexId];
   this.appAddrData = [...tempArray];
   this.caseDocArr=[...tempArray];
}
  console.log('this.appModalData FINAL :::263', this.appAddrData,':::',this.appAddrData.length)
  }

  @track docIds=[];
  @track addrIds=[];

  handleUpdate(){
    this.showSpinner=true;
    let isInputCorrect= this.validateForm();
    if(isInputCorrect){    
    let tempArr=[];
    this.caseDocArr.forEach(i=>{
        let obj ={}
        obj.Id= i.Id;
        obj.AgencyDocStatus__c=i.AgencyDocStatus__c;
        obj.RCUAgencyRemarks__c=i.RCUAgencyRemarks__c;
        obj.sobjectType='CaseDoc__c';
        tempArr.push(obj);
      })
      console.log('docDetArr:::::1815',tempArr);
    
    
      if(tempArr && tempArr.length>0){
        this.upsertDataCaseDoc(tempArr);
      }else{
        this.showSpinner=false;
      }
    }else{
      this.showSpinner=false;
    }
  }
  validateForm() {
    let isValid = true;
   
    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {
        //console.log('element passed combobox');;
      } else {
        isValid = false;
        this.showToastMessage('Error', 'Please Update Document Status', 'error', 'sticky');
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

  getReportStatus(){
    this.caseDocArr=[...this.appModalData,...this.appAddrData];
    let agencycStatus=''
    let fraudCount = 0
    let negativeCount=0;
    let referCount=0;
    let pendingCount=0;
    let positiveCount=0;
    this.caseDocArr.forEach(c=>{
      console.log('c.AgencyDocStatus__c:::320',c.AgencyDocStatus__c);
      if(c.AgencyDocStatus__c === 'Fraud'){
        fraudCount++;
      }
      else if(c.AgencyDocStatus__c !== 'Fraud' && c.AgencyDocStatus__c === 'Negative'){
        negativeCount++;
      }
      else if(!(c.AgencyDocStatus__c === 'Fraud' && c.AgencyDocStatus__c === 'Negative') && c.AgencyDocStatus__c === 'Refer'){
        referCount++;
      }
      else if(!(c.AgencyDocStatus__c === 'Fraud' && c.AgencyDocStatus__c === 'Negative' && c.AgencyDocStatus__c === 'Refer') && c.AgencyDocStatus__c === 'Pending'){
        pendingCount++;
      }
      else if(!(c.AgencyDocStatus__c === 'Fraud' && c.AgencyDocStatus__c === 'Negative' && c.AgencyDocStatus__c === 'Refer' && c.AgencyDocStatus__c === 'Pending') && c.AgencyDocStatus__c === 'Positive'){
        positiveCount++;
      }
      })
console.log('fraudCount::344',fraudCount, 'negativeCount::',negativeCount,  'referCount::',referCount,  'pendingCount::',pendingCount, 'positiveCount::',positiveCount);

      if(fraudCount > 0){
        agencycStatus = 'FRAUD';
        return agencycStatus;
      }else if(negativeCount > 0){
        agencycStatus = 'NEGATIVE';
        return agencycStatus;
      }else if(referCount > 0){
        agencycStatus = 'REFER';
        return agencycStatus;
      }else if(pendingCount > 0){
        agencycStatus = 'PENDING';
        return agencycStatus;
      }else if(positiveCount > 0){
        agencycStatus = 'POSITIVE';
        return agencycStatus;
      }
      return agencycStatus;
  }

  upsertDataCaseDoc(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##349', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Document Detail Records insert for ApplAddr ##353', result);
        this.showToastMessage('Success', 'Case Document Details updated Successfully', 'success', 'sticky');
        let agencycStatus= this.getReportStatus();
    
        let tempCaseArr=[];
        let objCas={};
        objCas.sobjectType='Case';
        objCas.Id=this.recordId;
        objCas.AgcRCUReportStatus__c=agencycStatus;
        tempCaseArr.push(objCas);
        console.log('tempCaseArr:::::::363',tempCaseArr);
        this.upsertDataCase(tempCaseArr);
        this.caseDocArr=[];
        let docArr=[]
        this.appModalData.forEach(i=>{
          let objDoc ={}
          objDoc.Id= i.DocDetail__c;
          objDoc.AgencyDocStatus__c=i.AgencyDocStatus__c;
          objDoc.RCURemarks__c=i.RCUAgencyRemarks__c;
          objDoc.sobjectType='DocDtl__c';
          docArr.push(objDoc);
        })
        if(docArr){
          this.upsertData(docArr);
        }
        

        let addArr=[]
        this.appAddrData.forEach(i=>{
          let objAdd ={}
          objAdd.Id= i.ApplAddr__c;
          objAdd.AgencyDocStatus__c=i.AgencyDocStatus__c;
          objAdd.RCURemarks__c=i.RCURemarks__c;
          objAdd.sobjectType='ApplAddr__c';
          addArr.push(objAdd);
        })
        if(addArr){
          this.upsertData(addArr);
        }
        setTimeout(() => {
          this.showSpinner=false;
        }, 3000
        )
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU to update Case Document on Vendor  DETAILS ##400', error)
    })
  }
  }


  upsertData(obj){
    if(obj){   
    console.log('Document Detail  or Appl addrr Records update ##408', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Document Detail & Applicant address Records insert for ApplAddr ##412', result);
        this.showToastMessage('Success', 'Document Details file status updated Successfully', 'success', 'sticky');
        this.appModalData=[];
        this.appAddrData=[];
        this.fetchCaseDoc(this.recordId);
        setTimeout(() => {
          this.showSpinner=false;
        }, 3000
        )
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU Vendor to update Appl add and Doc Dtl DETAILS ##425', error)
    })
  }
  }


@track agcrReportStatus;
  upsertDataCase(obj){
    if(obj){   
    console.log('Case Records update ##434', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Records Update for ApplAddr ##438', result);
        this.agcrReportStatus=result[0].AgcRCUReportStatus__c;
        this.showToastMessage('Success', 'Document Details file status updated Successfully', 'success', 'sticky');
        this.fetchCaseDoc(this.recordId);
        
       
        setTimeout(() => {
          this.getParentCaseData(this.parentCaseId);
          this.showSpinner=false;
        }, 3000
        )
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU Vendor to update Parent Case ##453', error)
    })
  }
  }
  
@track parentCaseData=[];

  getParentCaseData(caseId){
    let recordType = 'RCU'
    let parameter = {
      ParentObjectName: "Case",
      ChildObjectRelName: "",
      parentObjFields: ['Id','RecordType.Name','CaseNumber','AgcRCUReportStatus__c','Case__c','Status'],
      childObjFields: [],
      queryCriteria: ' where Case__c = \'' + caseId + '\' AND RecordType.DeveloperName = \''+recordType+ '\''
    };
  
    getSobjectDataNonCacheable({params: parameter}).then((result) => {
      this.showSpinner=false;
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
         
          this.parentCaseData=result.parentRecords
          //console.log('Case Detail this.parentCaseData 469 :',this.parentCaseData);
          let agencycStatus =this.getParentReportStatus();
          console.log('Case Detail agencycStatusd 474 :',agencycStatus);
          let tempCaseArr=[];
          let objCas={};
          objCas.sobjectType='Case';
          objCas.Id=this.parentCaseId;
          objCas.AgcRCUReportStatus__c = agencycStatus ? agencycStatus : this.agcrReportStatus;
          tempCaseArr.push(objCas);
          //console.log('tempCaseArr:::::::521',tempCaseArr);
          if(tempCaseArr){
            this.upsertParentCase(tempCaseArr);
          }
        }
      })
    .catch(error => {
        console.log('INTLIZE error : ',JSON.stringify(error));
    });
  }

  getParentReportStatus(){
    let agencycStatus=''
    let fraudCount = 0
    let negativeCount=0;
    let referCount=0;
    let pendingCount=0;
    let positiveCount=0;
    //console.log(' this.parentCaseData::::494', this.parentCaseData);
    this.parentCaseData.forEach(c=>{
      //console.log(' this.c::::497', c.AgcRCUReportStatus__c);
      if(c.AgcRCUReportStatus__c === 'FRAUD'){
        fraudCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD') && c.AgcRCUReportStatus__c === 'NEGATIVE'){
        negativeCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE') && c.AgcRCUReportStatus__c === 'REFER'){
        referCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER') && c.AgcRCUReportStatus__c === 'PENDING'){
        pendingCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER' && c.AgcRCUReportStatus__c === 'PENDING') && c.AgcRCUReportStatus__c === 'POSITIVE'){
        positiveCount++;
      }
      })
      console.log('fraudCount::539',fraudCount, 'negativeCount::',negativeCount,  'referCount::',referCount,  'pendingCount::',pendingCount, 'positiveCount::',positiveCount);

      if(fraudCount > 0){
        agencycStatus = 'FRAUD';
        return agencycStatus;
      }else if(negativeCount > 0){
        agencycStatus = 'NEGATIVE';
        return agencycStatus;
      }else if(referCount > 0){
        agencycStatus = 'REFER';
        return agencycStatus;
      }else if(pendingCount > 0){
        agencycStatus = 'PENDING';
        return agencycStatus;
      }else if(positiveCount > 0){
        agencycStatus = 'POSITIVE';
        return agencycStatus;
      }
      return agencycStatus;
  }
  upsertParentCase(obj){
    if(obj){   
    console.log('Parent Case Records update ##525', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Records Update ##529', result);
       // this.showToastMessage('Success', 'Parent Case status updated Successfully', 'success', 'sticky');
        setTimeout(() => {
          this.showSpinner=false;
          this.getLoanParentCases(this.loanAppId)
        }, 5000
        )
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU  to update Parent Case DETAILS ##540', error)
    })
  }
  }

@track LoanParentCases=[];
  getLoanParentCases(loanId){
    let recordType = 'RCU'
    let parameter = {
      ParentObjectName: "Case",
      ChildObjectRelName: "",
      parentObjFields: ['Id','RecordType.Name','CaseNumber','AgcRCUReportStatus__c','Case__c','AccountId','ContactId',
        'Loan_Application__c'
      ],
      childObjFields: [],
      queryCriteria: ' where Loan_Application__c = \'' + loanId + '\' AND RecordType.DeveloperName = \''+recordType+ '\' AND AccountId = null AND ContactId =null'
    };
  
    getSobjectDataNonCacheable({params: parameter}).then((result) => {
      this.showSpinner=false;
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
         
          this.LoanParentCases=result.parentRecords
          console.log('Case Detail this.LoanParentCases 559 :',this.LoanParentCases);
         
          let agencycStatus =this.getLoanParentRCUStatus();
          console.log('Case Detail agencycStatusd 566 :',agencycStatus);
          let tempLanArr=[];
          let obj={};
          obj.sobjectType='LoanAppl__c';
          obj.Id=this.loanAppId;
          obj.LANRCUStatus__c = agencycStatus ? agencycStatus : this.agcrReportStatus;
          tempLanArr.push(obj);
          console.log('tempCaseArr:::::::573',tempLanArr);
          if(tempLanArr){
            this.upsertLoanData(tempLanArr);
          }
        }
      })
    .catch(error => {
        console.log('Error to Update LAN RCU STatus 580 on Vendor Portal : ',JSON.stringify(error));
    });
  }

  getLoanParentRCUStatus(){
    let agencycStatus=''
    let fraudCount = 0
    let negativeCount=0;
    let referCount=0;
    let pendingCount=0;
    let positiveCount=0;
    console.log(' this.LoanParentCases::::586', this.LoanParentCases);
    this.LoanParentCases.forEach(c=>{
      console.log(' this.c::::585', c.AgcRCUReportStatus__c);
      if(c.AgcRCUReportStatus__c === 'FRAUD'){
        fraudCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD') && c.AgcRCUReportStatus__c === 'NEGATIVE'){
        negativeCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE') && c.AgcRCUReportStatus__c === 'REFER'){
        referCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER') && c.AgcRCUReportStatus__c === 'PENDING'){
        pendingCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER' && c.AgcRCUReportStatus__c === 'PENDING') && c.AgcRCUReportStatus__c === 'POSITIVE'){
        positiveCount++
      }
      })
      console.log('fraudCount::646',fraudCount, 'negativeCount::',negativeCount,  'referCount::',referCount,  'pendingCount::',pendingCount, 'positiveCount::',positiveCount);

      if(fraudCount > 0){
        agencycStatus = 'FRAUD';
        return agencycStatus;
      }else if(negativeCount > 0){
        agencycStatus = 'NEGATIVE';
        return agencycStatus;
      }else if(referCount > 0){
        agencycStatus = 'REFER';
        return agencycStatus;
      }else if(pendingCount > 0){
        agencycStatus = 'PENDING';
        return agencycStatus;
      }else if(positiveCount > 0){
        agencycStatus = 'POSITIVE';
        return agencycStatus;
      }
      return agencycStatus;
  }

  upsertLoanData(obj){
    if(obj){   
    console.log('LOAN RCU STATUS UPDATE ##612', obj); 

    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Loan RCU Status Records Update ##616', result);
       // this.showToastMessage('Success', 'Parent Case status updated Successfully', 'success', 'sticky');
       location.reload();
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##362', error)
    })
  }
  }
  closeModal() {
    this.viewDoc = false;
    this.leftScreen=12   
  }

  handleCloseModalEvent() {
    this.viewDoc = false;
    this.leftScreen=12
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
  
}