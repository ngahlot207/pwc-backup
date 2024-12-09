import { LightningElement, api, wire, track } from "lwc";
import fetchRecords from "@salesforce/apex/ReusableLookupController.fetchRecords";
/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;
export default class FlowCustomLookup extends LightningElement {

  

  @api label;
  @api required;
  @api selectedIconName;
  @api objectLabel;
  @api disabled;
  @api recordsList = [];
  @api selectedRecordName;
  @api selectedRecordRole;
  @api objectApiName;
  @api fieldApiName;
  @api searchString = "";
  @api empRole;
  @api currentUser;
  @api empBranch = [];
  // @api selectedRecordId;
  @api parentRecordId;
  @api parentFieldApiName;
  @api fieldName;
  @api disabledFlag;
  @api filterCondn = '';


  @api selectedFields;
  @track isLookup;
  @api keyId;
  @api selectedFieldName;
  @api otherFieldApiName;
  @api index;
  @api readOnly;
  @api variant;
  @api astrikHide;
  @api helpTextVal;
  @api showHelpText;
  preventClosingOfSerachPanel = false;

  @track showHelpMessage = false;
    

  @track _selectedRecordId;
  @api get selectedRecordId() {
    return this._selectedRecordId;
  }

  @track showSearchField = false;
  set selectedRecordId(value) {
    this._selectedRecordId = value;
    if(this._selectedRecordId != null && this._selectedRecordId != undefined && this._selectedRecordId){
      this.showSearchField = false;
    }else{
      this.showSearchField = true;
    }
    this.setAttribute("selectedRecordId", value);
    this.fetchSobjectRecords(true);
  }

  //getting the default selected record
  connectedCallback() {
    //console.log("this.selectedFieldName>>>>>>>>>",this.selectedFieldName,"::::",this._selectedRecordId,this.disabled);
    
    if (this._selectedRecordId) {

      this.fetchSobjectRecords(true);
     
    }
  }


  // handleKeyDown(event){
  //   console.log('In evenet!!! '+JSON.stringify(event.currentTarget.dataset))
  //   const items = this.template.querySelectorAll('.customLookupOptionClass');
  //   let currentIndex;

    
  //   items.forEach((item, index) => {
  //     if (item === document.activeElement) {
  //       currentIndex = index;
  //     }
  //   });
  //   console.log('Items found evenet!! '+JSON.stringify(items) + currentIndex);
  // }
  @track empBranchString = '';   
  @track filterCond = '';
  filterCondition(){
    this.empBranchCollection();
    
    this.filterCond = '((isActive__c=true';
    this.filterCond += this.empRole ? ' AND EmpRole__c in (' + this.empRole + ') ' : '';
    this.filterCond += this.currentUser ?  ' AND Employee__c != \''  + this.currentUser + '\'' : '';
    this.filterCond += this.empBranchString ? ' AND EmpBrch__c in (' + this.empBranchString + ')' : '';
    this.filterCond += ')';
    this.filterCond += this.filterCondn ? ' '+this.filterCondn : '';
    this.filterCond += ')';
    console.log('in filtercondition',this.filterCond, this.empBranchString);
    console.log('fieldAPiName', this.fieldApiName);
    
  }

  empBranchCollection(){
    this.empBranchString='';
    this.empBranch.forEach((branch, index) => {
      console.log('this.branch',branch);
      this.empBranchString += `'${branch}'`;
      
      if (index < this.empBranch.length - 1) {
          this.empBranchString += ', ';
      }
  });
  }

  get methodInput() {
    return {
      objectApiName: this.objectApiName,
      fieldApiName: this.fieldApiName,
      searchString: this.searchString,
      selectedRecordId: this._selectedRecordId,
      parentRecordId: this.parentRecordId,
      parentFieldApiName: this.parentFieldApiName,
      filterConditions: this.filterCond,
      selectFields: this.selectedFields,
      keyId: this.keyId,
      selecetdFieldName: this.selectedFieldName,
    };
  }

  get showRecentRecords() {
    if (!this.recordsList) {
      return false;
    }
    return this.recordsList.length > 0;
  }

  fetchSobjectRecords(loadEvent) {
    this.recordsList = [];
    fetchRecords({
      inputWrapper: this.methodInput
    })
      .then((result) => {
        //console.log("result>>>>>", result);
        if (loadEvent && result) {
          this.selectedRecordName = result[0].mainField;
          // this.selectedRecordRole = result[0].record.EmpRole__c;
          console.log("this.selectedRecordName>>>>>>", this.selectedRecordName);
        } else if (result) {
          this.recordsList = JSON.parse(JSON.stringify(result));
          console.log("this.recordsList>>>>>>>", this.recordsList);
        } else {
          this.recordsList = [];
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  get isValueSelected() {
    //console.log(this._selectedRecordId != null && this._selectedRecordId != undefined && this._selectedRecordId);
    return this._selectedRecordId != null && this._selectedRecordId != undefined && this._selectedRecordId != ''?true:false;
  }
  get astericHide (){
    return this.variant !== 'label-hidden';
  }

  //handler for calling apex when user change the value in lookup
  @track onChangeValue;

  handleChange(event) {
    this.onChangeValue = event.detail.value;
    this.searchString = "";
    this.searchString = event.target.value;
    if (this.searchString) {
      this.filterCondition();
      this.fetchSobjectRecords(false);
    }
  }

  //handler for clicking outside the selection panel
  handleBlur() {
    this.recordsList = [];
    this.preventClosingOfSerachPanel = false;
    
  }

  //handle the click inside the search panel to prevent it getting closed
  handleDivClick() {
    this.preventClosingOfSerachPanel = true;
  }

  //handler for deselection of the selected item
  handleCommit() {
    this.showSearchField = true;
    this._selectedRecordId = "";
    this.selectedRecordName = "";
    this.selectedRecordRole = "";
    this.lookupFieldAPIName = "";
    let selectedRecord = {
      mainField: null,
      subField: null,
      id: null,
      lookupFieldAPIName: this.fieldName
    };
    const selectedEvent = new CustomEvent("select", {
      detail: selectedRecord
    });

    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
    //console.log("Value is removed from lookup");
  }

  //handler for selection of records from lookup result list
  handleSelect(event) {

    let index = event.currentTarget.dataset.index;
    let lookUpRec = this.recordsList[index].record;
    let selectedRecord = {
      mainField: event.currentTarget.dataset.mainfield,
      subField: event.currentTarget.dataset.subfield,
      id: event.currentTarget.dataset.id,
      lookupFieldAPIName: this.fieldName,
      record:lookUpRec
    };
    this._selectedRecordId = selectedRecord.id;
    this.selectedRecordName = selectedRecord.mainField;
    this.selectedRecordRole = selectedRecord.record.EmpRole__c;
    this.lookupFieldAPIName = selectedRecord.parentName;
    this.showSearchField = false;
    //console.log("this.lookupFieldAPIName>>>>>>>", this.lookupFieldAPIName);
    this.recordsList = [];
    // Creates the event
    const selectedEvent = new CustomEvent("select", {
      detail: selectedRecord
    });

    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
  }

  //to close the search panel when clicked outside of search input
  handleInputBlur(event) {
    // Debouncing this method: Do not actually invoke the Apex call as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      if (!this.preventClosingOfSerachPanel) {
        this.recordsList = [];
      }
      this.preventClosingOfSerachPanel = false;
      this.checkValidityLookup();
    }, DELAY);
    const selectedEvent = new CustomEvent("lookupblur", {
      detail: this.searchString
    });
    this.dispatchEvent(selectedEvent);
  }


  @track errorMsg;
  @api checkValidityLookup() {
    let isInputCorrect;
    if(this.onChangeValue){
      isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
        if (!this._selectedRecordId) {
          inputField.setCustomValidity("Please Enter Valid Input");
        } else {
          inputField.setCustomValidity("");
        }
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    }else{
      isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
        inputField.setCustomValidity("");
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    }

    
    //console.log("return in custom lookup>>>", isInputCorrect);
    return isInputCorrect;
    //console.log('Data value@@@ !!! '+this.onChangeValue);

    // const isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
    //   if (!this._selectedRecordId && this.required) {
    //     inputField.setCustomValidity("Please Enter Valid Input");
    //   } else {
    //     inputField.setCustomValidity("");
    //   }
    //   inputField.reportValidity();

    //   return validSoFar && inputField.checkValidity();
    // }, true);
    // console.log("return in custom lookup>>>", isInputCorrect);

    // return isInputCorrect;

  }
  showHelp() {
    this.showHelpMessage = true;
  }
  hideHelp() {
    this.showHelpMessage = false;
  }

}