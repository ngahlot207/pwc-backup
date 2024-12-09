import { LightningElement, track, api, wire } from 'lwc';

import INTG_MSG from "@salesforce/schema/IntgMsg__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { createRecord } from "lightning/uiRecordApi";
export default class DynamicDatatableTestSample extends LightningElement {

  @api loanAppId = 'a08C4000007Kw2EIAS';
  // @track tableName;
  @track queryParam = [];
  @track params = {};
  @track paramsAppl = {};
  //@track title = 'Smart Witz Data';
  @track columnsDataForTable = [
    {
      "label": "Record ID",
      "fieldName": "RecId__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulator Competent Authority Name",
      "fieldName": "RegCompAuthName__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Date of Order",
      "fieldName": "OdrDt__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter Code",
      "fieldName": "DefCode__c",
      "type": "boolean",
      "Editable": false
    },
    {
      "label": "Defaulter Name",
      "fieldName": "DefName__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter Type Company Person",
      "fieldName": "DefTypCmpyPrsn__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter New Name1",
      "fieldName": "DefNewNme1__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter Old Name1",
      "fieldName": "DefOldNme1__c	",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter Merged With",
      "fieldName": "DefMrgWth__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "PAN CIN DIN",
      "fieldName": "PanCinDin__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Defaulter Other Details",
      "fieldName": "DefOthrDtls__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Other Entities associated with Defaulter",
      "fieldName": "OthrEntAssosWthDefEnt__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Associated Entity Person",
      "fieldName": "AssocEntPrsn__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulatory Charges",
      "fieldName": "RegChngs__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulatory Actions",
      "fieldName": "RegActns__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulatory Action Source1",
      "fieldName": "RegActnSrc1__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulatory Action Source2",
      "fieldName": "RegActnsSrc2__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Regulatory Action Source3",
      "fieldName": "RegActnsSrc3__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Result Relevance",
      "fieldName": "RsltRelvn__c",
      "type": "text",
      "Editable": false
    },
    {
      "label": "Internal Dedupe result remark",
      "fieldName": "IntDedRsltRmrks__c",
      "type": "text",
      "Editable": false
    }
  ];
  // @track activeSection = ["A"];
  @track isModalOpen = false;
  @track appData;
  @track appRecordsData = [];
  @track queryData = 'SELECT RecId__c,RegCompAuthName__c,OdrDt__c,DefCode__c,DefName__c,DefTypCmpyPrsn__c,DefNewNme1__c,DefOldNme1__c,DefMrgWth__c,PanCinDin__c,DefOthrDtls__c,OthrEntAssosWthDefEnt__c,AssocEntPrsn__c,RegChngs__c,RegActns__c,RegActnSrc1__c,RegActnsSrc2__c,RegActnsSrc3__c,RsltRelvn__c,IntDedRsltRmrks__c,Id FROM WoutInvstr__c WHERE LoanAplcn__c =: loanAppId ';
  connectedCallback() {
    // this.tableName = 'Account_List';
    let paramVal = [];
    paramVal.push({ key: 'loanAppId', value: this.loanAppId })
    this.queryParam = paramVal;
    console.log('map data:::', this.queryParam);
    this.params = {
      columnsData: this.columnsDataForTable,
      queryParams: this.queryParam,
      query: this.queryData
    }
  }

  handleIntialization() {
    this.isModalOpen = true;
    // this.getLoanApplicationData()
    // let columnsDataForTableForApps = [
    //   {
    //     "label": "Name",
    //     "fieldName": "Name",
    //     "type": "text",
    //     "Editable": false
    //   },
    //   {
    //     "label": "Select",
    //     "fieldName": "CheckBox",
    //     "type": "boolean",
    //     "Editable": true
    //   }
    // ];
    // queryDataForApps = 'SELECT Name,Id FROM Applicant__c WHERE LoanAppln__c =: loanAppId';

    // let paramVal = [];
    // paramVal.push({ key: 'loanAppId', value: this.loanAppId });
    // this.paramsAppl = {
    //   columnsData: columnsDataForTableForApps,
    //   queryParams: queryDataForApps,
    //   query: paramVal,
    //   tableTitle: 'Applicant Details'
    // }
  }
  @track showSpinner = false;
  // handleSpinner(event) {
  //   this.isModalOpen = false;

  // }
  closeModal() {
    console.log('isModalOpen ', this.isModalOpen);
    this.isModalOpen = false;
  }

  getLoanApplicationData() {
    let paramsLoanApp = {
      ParentObjectName: 'Applicant__c',
      parentObjFields: ['Name', 'TabName__c'],
      queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
    }
    getSobjectData({ params: paramsLoanApp })
      .then((result) => {
        this.appData = result;
        console.log('result is', JSON.stringify(result));
        if (result.parentRecords && result.parentRecords.length > 0) {
          this.appRecordsData = result.parentRecords;
          console.log('this.appRecordsData before', JSON.stringify(this.appRecordsData));
          console.log(' type of this.appRecords Data', typeof this.appRecordsData);
          console.log('this.appRecordsData length', this.appRecordsData.length);
          this.appRecordsData.forEach(item => {
            item['selectCheckbox'] = false;
          })
          console.log('this.appRecordsData after', JSON.stringify(this.appRecordsData));
        }
        if (result.error) {
          console.error('appl result getting error=', result.error);
        }
      })
  }

  selectedRecords = [];
  handleClick(event) {
    console.log('record ', event.target.dataset.recordid);
    let selectedRecordId = event.target.dataset.recordid;
    console.log('value is', event.target.checked);
    let val = event.target.checked;
    let recordData = {};
    let searchDoc = this.selectedRecords.find((doc) => doc.Id == selectedRecordId);
    if (searchDoc) {
      console.log('searchDoc', searchDoc);
      searchDoc['selectCheckbox'] = val;
    }
    else {
      recordData['Id'] = selectedRecordId;
      recordData['selectCheckbox'] = val;
      this.selectedRecords.push(recordData);
    }
    console.log('All selected Records', JSON.stringify(this.selectedRecords));
  }

  handleReIntialization() {
    console.log('handle reintialization called');
    let filteredData = this.selectedRecords.filter(item => item.selectCheckbox === true);
    console.log('All filteredData Records', JSON.stringify(filteredData));
    this.isModalOpen = false;
  }

  handleCustomEvent(event) {
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
      const evt = new ShowToastEvent({
        title: titleVal,
        variant: variantVal,
        message: messageVal
      });
      this.dispatchEvent(evt);
    }


  }


}