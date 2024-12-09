import { LightningElement, api, wire, track } from 'lwc';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getAllSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { formattedDate, formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
export default class LitigationCheckDetails extends LightningElement {
    @api loanAppId;
    @api applicantId
    @api hasEditAccess;
    @track showSpinner = false;
    @track disableMode;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track lanStage;
    @track lanSubStage;
    @track APIVerficationRec;
    @track APIVerfiDetailRecs;
    @track manualLitigationTri
    @track ApplicantRecs
    @track LoanAppData;
    AllApplicantesRecs;
    @track reInitiateDis=true
    @track isModalOpen;
    connectedCallback(){
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
          this.disableMode = false;
          //this.manualLitigationTri=false
      }
      else {
          this.disableMode = true;
          //this.manualLitigationTri=true
      }
        this.fetchLoanAndApplicantDetails();
        this.fetchAPIVerficationRec();
    }
    fetchLoanAndApplicantDetails() {
        let  loanDetParams = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "Applicants__r",
            parentObjFields: ["Id", "Name", "ReqLoanAmt__c","NoCasesNeedToRaised__c","OwnerId","Stage__c","SubStage__c"],
            childObjFields: ['Id','Constitution__c', 'Name', 'IntegrationStatus__c', 'UCID__c'],
            queryCriteria: ' where Id= \'' + this.loanAppId + '\''
          };
        
          getAllSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
             // this.wiredDataCaseQry=result;
              //this.LoanAppData=result
              console.log("result TECHNICAL PROP LOAN DETAILS #722>>>>>", result);
              if (result[0].parentRecord !== undefined && result.length > 0) {
                this.lanStage = result[0].parentRecord.Stage__c;
                this.lanSubStage = result[0].parentRecord.SubStage__c;
                /*if(this.lanStage=='DDE'){
                  this.manualLitigationTri=true
                }else{
                  this.manualLitigationTri=this.manualLitigationTri ==true ? true: false
                }*/
                console.log('this.lanStage'+this.lanStage)
                
              }
              if (result.length > 0) {
                this.LoanAppData = result.map(record => record.parentRecord);
              }
              let AllApplicantesRecs=[];
              if(this.LoanAppData.length >0){
                for(const record of this.LoanAppData){
                  if(record.Applicants__r){
                    for(const deRec of record.Applicants__r){
                      AllApplicantesRecs.push(deRec);
                    }
                  }
                }
              }
              this.AllApplicantesRecs=AllApplicantesRecs;
            })
            .catch((error) => {
              console.log("TECHNICAL PROP LOAN DETAILS #731", error);
        });
    }
    

    get options() {
      return [
          { label: 'Very High Risk', value: 'Very High Risk' },
          { label: 'High Risk', value: 'High Risk' },
          { label: 'Average Risk', value: 'Average Risk' },
          { label: 'Low Risk', value: 'Low Risk' },
          { label: 'No Risk', value: 'No Risk' },
         
      ];
  }
  applicantRecsIDForPop;
  applicantRecsForPopUp=[];
  applicantRecForError=[];
  @track showErrorMessage
 fetchAPIVerficationRec() {

      let  getApiVeriRecs = {
            ParentObjectName: "APIVer__c",
            ChildObjectRelName: "API_Verification_Details__r",
            parentObjFields: ["Id",'CrimeCheckAddReportError__c', "CrimeCheckCallbackStatus__c","CrimeCheckAddReportStatus__c", "ReportMode__c","DownloadLink__c","Name",'Appl__r.FullName__c', 'Appl__r.Constitution__c','Appl__c','IntegrationStatus__c','CreatedDate','Appl__r.TabName__c','toLabel(Appl__r.ApplType__c)','tolabel(ApplTyp__c)',"RiskSum__c","numOfCases__c","CrimeCheckPdfReportStatus__c","RiskType__c","ApplNme__c","CreatedById","LoanAplcn__c","Verification_Status__c","ResTime__c","ReqTime__c"],
            childObjFields: ["Id", "Type__c", "ApiVerDetails__r.Type__c", "ApiVerDetails__r.CaseTypeName__c", "ApiVerDetails__r.CourtName__c", "ApiVerDetails__r.District__c", "ApiVerDetails__r.RespondentAdrs__c", "ApiVerDetails__r.PetitionerAdrs__c", "ApiVerDetails__r.CaseYear__c", "ApiVerDetails__r.CaseNum__c", "ApiVerDetails__r.JudgementLink__c", "ApiVerDetails__r.FirLink__c", "ApiVerDetails__r.CaseStatus__c"],
            queryCriteriaForChild: ' where ApiVerDetails__c != \'\'',   
            queryCriteria: ' where LoanAplcn__c= \'' + this.loanAppId + '\' AND RecordType.DeveloperName = \'CrimeCheck\' AND IsLatest__c  = True'
          };
          
          getAllSobjectDataNonCacheable({params: getApiVeriRecs}).then((result) => {
              let apiVeriRecs=[];
              let parentRecords=[];
              let applicantRecsIDForPop=[]
              let applicantRecForError=[]
              let RiskRec=[]
              let InprocessApis=[];
              /*if (result.length > 0) {
                parentRecords = result.map(record => record.parentRecord);
              }*/
                if (result.length > 0) {
                  apiVeriRecs = result.map(record => record.parentRecord);
                }
                for(const apiVer of apiVeriRecs){
                  if(apiVer.Appl__r.ApplType__c == 'APPLICANT' || apiVer.Appl__r.ApplType__c == 'CO-APPLICANT' || apiVer.Appl__r.ApplType__c == 'GUARANTOR'){
                    parentRecords.push(apiVer);
                  }
                }
              
              
              for(const apiVer of parentRecords){
                if(apiVer.CrimeCheckAddReportStatus__c =='Failure'){
                  applicantRecsIDForPop.push(apiVer.Appl__c);
                  const error={"nameOfApplicant": apiVer.Appl__r.FullName__c, "errorMessage": apiVer.CrimeCheckAddReportError__c}
                  applicantRecForError.push(error);
                  RiskRec.push(apiVer.Appl__c);
                }
                if((apiVer.RiskType__c =='Very High Risk' || apiVer.RiskType__c =='High Risk' || apiVer.RiskType__c =='Average High Risk') && apiVer.ReportMode__c=='realTimeHighAccuracy'){
                    //RiskRec.push(apiVer.Appl__c);
                    apiVer.riskLitigationDis = false;
                }else{
                  apiVer.riskLitigationDis = true;
                }
                
                if(typeof apiVer.CrimeCheckCallbackStatus__c ==='undefined' ){
                  InprocessApis.push(apiVer.Appl__c);
                }
              }
              for(const apiVer of parentRecords){
                console.log('apiVer.ReqTime__c>>>>>>>>>>>'+apiVer.ReqTime__c)
                console.log('apiVer.ResTime__c'+apiVer.ResTime__c)
                if(apiVer.ReqTime__c && typeof apiVer.ReqTime__c !== 'undefined'){
                  const formattedDate1 = formattedDateTimeWithoutSeconds(apiVer.ReqTime__c);
                  const dateFinal = `${formattedDate1}`;
                  apiVer.ReqTime__c = dateFinal;
                }
                if(apiVer.ResTime__c && typeof apiVer.ResTime__c !== 'undefined'){
                  const formattedDate1 = formattedDateTimeWithoutSeconds(apiVer.ResTime__c);
                  const dateFinal = `${formattedDate1}`;
                  apiVer.ResTime__c = dateFinal;
                }
                if(apiVer.CreatedDate && typeof apiVer.CreatedDate !== 'undefined'){
                  const formattedDate2 = formattedDateTimeWithoutSeconds(apiVer.CreatedDate);
                  const dateFinal = `${formattedDate2}`;
                  apiVer.CreatedDate = dateFinal;
                }
                console.log('apiVer.CreatedDate>> '+apiVer.CreatedDate);
              }
              this.applicantRecForError=applicantRecForError;
              if(this.applicantRecForError.length>0){
                this.showErrorMessage=true
              }else{
                this.reInitiateDis=true
                this.showErrorMessage=false
              }
              console.log('tRiskRec'+RiskRec);

              this.applicantRecsIDForPop=RiskRec;
              if(this.applicantRecsIDForPop.length > 0 ){
                this.manualLitigationTri= this.manualLitigationTri==true ? true: false
              }else{
                this.manualLitigationTri=true
              }
              
              this.getApiRetriggerTrackerData();
              
             let APIVerfiDetailRecs=[];
              this.APIVerficationRec=parentRecords;
              //this.APIVerficationRec = this.APIVerficationRec.filter(record => record.CrimeCheckAddReportStatus__c !== 'Failure');
              if(this.APIVerficationRec.length >0){
                for(const record of this.APIVerficationRec){
                  console.log('recordrecord'+JSON.stringify(record));
                  /*if(record.ReportMode__c=='realTimeHighAccuracy'){

                  }else{*/
                      if(record.API_Verification_Details__r){
                        for(const deRec of record.API_Verification_Details__r){
                          APIVerfiDetailRecs.push(deRec);
                        }
                      }
                  //}
                  
                }
              }
              this.APIVerfiDetailRecs=APIVerfiDetailRecs;
             this.APIVerfiDetailRecs = this.APIVerfiDetailRecs.map((record, index) => {
                return { ...record, index: index + 1 };
              });
              /*if(this.applicantRecsIDForPop.length>0){
                this.getApplicantRec();
              }*/
              
            })
            .catch((error) => {
              console.log("TECHNICAL PROP LOAN DETAILS #731", error);
        });
    }
    getApplicantRec(){
        this.applicantRecsForPopUp = this.AllApplicantesRecs.filter(record => this.applicantRecsIDForPop.includes(record.Id));
    }

    handleInputChange(event){
      const url = event.target.dataset.url;
      if(url !='' && url != null){
        window.open(url, '_blank');
      }else{
        const evt = new ShowToastEvent({
          title: "Error",
          variant: "error",
          message: "There  is no file for download!"
      });
      this.dispatchEvent(evt);
      }
        
    }
    manualLitigationIntegration(){
      this.isModalOpen=true;
    }
    handleCustomEvent(event){
        this.isModalOpen = false;
        let spinnerValue = event.detail.spinner;
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            this.showSpinner = false;
        }
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
        if (titleVal && variantVal && messageVal) {
            this.handleRefreshClick();
            this.fetchAPIVerficationRec();
            setTimeout(() => {
              const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal,
                mode:"sticky"
            });
            this.dispatchEvent(evt);
            }, 6000);
            

        }
    
    }
    handleRefreshClick(){
      this.showSpinner = true;
      setTimeout(() => {
                this.showSpinner = false;
                this.fetchAPIVerficationRec();
            }, 6000);
    }
    getApiRetriggerTrackerData() {
      let apiName = ['Crime Add Report API - Individual', 'Crime Add Report API - Company'];
      console.log('loanappId in Reintiate component', this.loanAppId);
      let paramsLoanApp = {
          ParentObjectName: 'APIRetriggerTracker__c',
          parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
          queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + apiName.join('\', \'') + '\')'
         // queryCriteria: ' Where LAN__c = \'' + this.loanAppId + '\'  AND APIName__c  IN (\'' + apiName.join('\', \'') + '\') order by LastModifiedDate desc limit 1'
      }

      getSobjectData({ params: paramsLoanApp })
          .then((result) => {
              console.log('apiRetrgrTrcrData is in first method', result);

              
              if (result.parentRecords && result.parentRecords.length > 0) {
                  console.log('result.parentRecords', result.parentRecords.length);
                  result.parentRecords.forEach(item => {
                      if (item.App__c) {
                        this.applicantRecsIDForPop.push(item.App__r.Id);
                      }
                  })
              }
              this.getAppWithCallOutData();
              if (result.error) {
                  console.error('apiRetrgrTrcrData result getting error=', result.error);
              }
          })
      }
      applIds
    getAppWithCallOutData() {
      let apiName = ['Crime Add Report API - Individual', 'Crime Add Report API - Company'];
      
      let paramsLoanApp = {
          ParentObjectName: 'Applicant__c',
          ChildObjectRelName: 'API_Callout_Trackers__r',
          parentObjFields: ['Id'],
          childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
          queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + apiName.join('\', \'') + '\')',
          queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''

      }
      getAllSobjectDataNonCacheable({ params: paramsLoanApp })
          .then((result) => {
              console.log('AppWithCallOutData is', JSON.stringify(result));
              if (result && result.length > 0) {
                  result.forEach(item => {
                      if (item.ChildReords && item.ChildReords.length > 0) {
                          item.ChildReords.forEach(ite => {
                              if (ite.LtstRespCode__c != 'Success') {
                                  if (ite.Appl__c) {
                                      this.applicantRecsIDForPop.push(ite.Appl__r.Id);
                                      
                                  }
                              }
                          })
                      } else {
                          this.applicantRecsIDForPop.push(item.parentRecord.Id);
                      }
                  })
              }
              console.log('this.applicantRecsIDForPop'+this.applicantRecsIDForPop)
              this.applicantRecsIDForPop = [...new Set(this.applicantRecsIDForPop)];
              this.applIds = [...this.applicantRecsIDForPop];
              if(this.applicantRecsIDForPop.length > 0 ){
                this.manualLitigationTri= this.manualLitigationTri==true ? true: false
              }else{
                this.manualLitigationTri=true
              }
              if(this.applicantRecsIDForPop.length>0){
                this.getApplicantRec();
              }
              
              this.showSpinner = false;
              console.log('this.apiRetrgrTrcrData after second method', this.apiRetrgrTrcrData);
              console.log('this.appDataDisplay after second method', this.appDataDisplay);
              if (result.error) {
                  this.showSpinner = false;
                  console.error('apiRetrgrTrcrData result getting error=', result.error);
              }
          })
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
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
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
    
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv1");
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
        console.log(
          "handlemousedown._tableThColumn.tagName => ",
          this._tableThColumn.tagName
        );
        this._pageX = e.pageX;
    
        this._padding = this.paddingDiff(this._tableThColumn);
    
        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log(
          "handlemousedown._tableThColumn.tagName => ",
          this._tableThColumn.tagName
        );
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
      intRecords;
      LitigationIntegrationForRisk(event){
        console.log('event.target.dataset.index'+event.target.dataset.index)
        this.intRecords=[];
        debugger;
        let selectedRec = this.APIVerficationRec[event.target.dataset.index];
        let applicantConsiType=selectedRec.Appl__r.Constitution__c;
        let initRecos=[];
        let fieldsWo = {};
        fieldsWo['sobjectType'] = 'IntgMsg__c';
        fieldsWo['Name'] =  applicantConsiType == 'INDIVIDUAL' || applicantConsiType == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company'; //serviceName;//'KYC OCR'
        fieldsWo['BU__c'] = 'HL / STL';
        fieldsWo['IsActive__c'] = true;
        fieldsWo['Svc__c'] = applicantConsiType == 'INDIVIDUAL' || applicantConsiType == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company';
        fieldsWo['RefObj__c'] = 'Applicant__c';
        fieldsWo['RefId__c'] = selectedRec.Appl__c;
        fieldsWo['Status__c'] = 'New';
        fieldsWo['ApiVendor__c'] = 'CrimeCheck';
        fieldsWo['TriggerType__c'] = 'Manual';
        initRecos.push(fieldsWo);
        this.intRecords=initRecos
        if (this.intRecords.length > 0) {
            console.log('intRecords records are ', JSON.stringify(this.intRecords));
            this.upsertIntRecord(this.intRecords);
        }
      }
      upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                this.showToastMessage('Success', "Detail Litigation Check Started Successfully, Please Click on Refresh Button to See Details on Table", 'success', 'sticky');
               // this.showToastMessage("Success", "success", "Detail Litigation Check Started Successfully, Please Click on Refresh Button to See Details on Table", false);
                this.intRecords = [];
                // this.fireCustomEvent(null, null, null, false);
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showToastMessage('Error', "Error occured in upsertMultipleRecord " + error, 'error', 'sticky');
                
            });
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

      
    
}