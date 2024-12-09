import { LightningElement, track, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import getTeamHierData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import { publish, subscribe, MessageContext } from "lightning/messageService";
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
import Id from "@salesforce/user/Id";

export default class SubTabProperty extends LightningElement {
  @api applicantId;
  @api currentTabId;
  //@api loanAppId;
  @api layoutSize;
  @api hasEditAccess;
  @track value;
  @track currentUserId = Id;
  @track userRole;
  @track tabDefaultValue;
  @track reload = false;
  @track ifNoIdenProp = true
  stage;
  substage;
  @track disbursType;
  @track lanOwner;
  @track showCV = false;

  @track _loanAppId;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    this.setAttribute("loanAppId", value);
    //this.handleLoanRecordIdChange(value);
    this.handleteamHierIdChange();
  }

  @api refreshTab(event) {
    let evt = event.detail;
    if (evt) {
      this.reload = true;
      this.template.querySelector("c-technical-property-details").handleValueChangeChild();
      this.reload = false;
    }
    console.log("REFRESHTAB PARENT #25");
  }

  @wire(MessageContext)
  MessageContext;

  @track enableEditFlag = true;
get disableTechnical(){
  let flag;
if(!this.enableEditFlag){
  flag=true;
}else{
  flag= !this.disableMode
}
  return flag
}
@track teamHierParam = {
  ParentObjectName: 'TeamHierarchy__c',
  ChildObjectRelName: '',
  parentObjFields: ['Id','EmpRole__c','Employee__c'],
  childObjFields: [],
  queryCriteria: ''
  }

handleteamHierIdChange() {
  let tempParams = this.teamHierParam;
  tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
  this.teamHierParam = { ...tempParams };

}
@wire(getTeamHierData,{params : '$teamHierParam'})
teamHierHandler({data,error}){
    if(data){
        if(data.parentRecords !== undefined ){
            this.userRole = data.parentRecords[0].EmpRole__c   
        }
                  
    }
    if(error){
        console.error('ERROR CASE DETAILS:::::::#499',error)
    }
}

  getPropertyDetails() {
    let loanDetParam = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Stage__c", "SubStage__c","OwnerId","DisbursalType__c"],
      childObjFields: [""],
      queryCriteria: " where Id = '" + this._loanAppId + "' limit 1"
    };
    getSobjectData({ params: loanDetParam })
      .then((result) => {
        console.log("RESULT IN SUB TAB PROP #71", result);
        if (result) {
          this.stage = result.parentRecords[0].Stage__c;
          this.substage = result.parentRecords[0].SubStage__c;
          this.lanOwner=result.parentRecords[0].OwnerId;
          this.disbursType = result.parentRecords[0].DisbursalType__c;
          console.log(
            "STAGE AND SUBSTAGE IN SUB TAB PROP #75",
            this.stage,
            this.substage,
            this.lanOwner
          );
          if (
            this.stage === "UnderWriting" ||
            this.stage === "Soft Sanction" ||
            this.stage === "Post Sanction" ||
            this.stage === "Disbursed" || this.stage === "Disbursement Initiation"      //added for Shekhar LAK-7812 04/06/24
          ) {
            this.showCV = true;
          }
          if((this.currentUserId === this.lanOwner) && (this.stage === 'Disbursed' && (this.substage === 'Additional Processing' || this.substage === 'UW Approval')) && this.disbursType==='MULTIPLE'  ){
            this.enableEditFlag = false;
            console.log("enableEditFlag 111", this.enableEditFlag);
            const payload = {
              disableSaveButton: false
          };
          console.log(" Published Event>", JSON.stringify(payload));
          publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
          }
          
        }
      })
      .catch((error) => {
        console.error("Error in line ##50", error);
      });
  }

  connectedCallback() {
    console.log("enableEditFlag", this.enableEditFlag);
    console.log("Stage", this.stage);
    console.log("SubStage", this.substage);
    console.log("applicantId", this.applicantId);
    console.log("currentTabId", this.currentTabId);
    console.log("subtabloanAppId", this.loanAppId);
    console.log("layoutSize", this.layoutSize);
    this.getPropertyDetails();
    if (this.hasEditAccess === false) {
      this.disableMode = true;
    } else {
      this.disableMode = false;
    }
  }
  handleActive(event) {
    this.tabDefaultValue = event.target.value;
    console.log("tab default value ", this.tabDefaultValue);
    console.log(
      "handleActive  clicked  for ",
      event.target.label,
      "  and id is ",
      event.target.value
    );
    this.value = event.target.value;
    const payload = {
      disableSaveButton: this.disableMode
    };
    console.log(" Published Event>", JSON.stringify(payload));
    publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
    // console.log("handleActive ", JSON.stringify(this.componentsToRender));
    // this.showScreenConfig = false;
    // this.showScreenConfig = true;
  }

  get showTabOne() {
    return this.value === "one";
  }
  get showTabTwo() {
    return this.value === "two";
  }
  get showTabThree() {
    return this.value === "three";
  }
  get showTabFour() {
    return this.value === "four";
  }
  get showTabFive() {
    return this.value === "five";
  }
  get showTabSix() {
    return this.value === "six";
  }

  handlePropIdentiDropdown(event) {
    if (this.value === "one") {
      const selectedValue = event.detail.value;
      if (selectedValue === "No") {
        this.ifNoIdenProp = false
      } else {
        this.ifNoIdenProp = true
      }
    }
  }
}