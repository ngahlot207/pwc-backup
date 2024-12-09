import { LightningElement, track, api, wire } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { publish, subscribe, MessageContext } from "lightning/messageService";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
import CURRENTUSERID from '@salesforce/user/Id';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import loan_Application_Current_User_Error_message from '@salesforce/label/c.loan_Application_Current_User_Error_message';

import Id from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SaveBtnComponent extends LightningElement {

    customeLabel = {
        loan_Application_Current_User_Error_message

    }

    @api loanAppId;
    @api forStepper;
    @api stepper;
    @api subStepper;
    @api hasEditAccess;
    @api hideSaveAsDraft;
    @api saveBtnLabel;
    @api currentTforStepperabId;
    @api showQueryButton = false;
    @api queryScreen;
    @api currentTabId;
    @api assignedUser;//LAK-7654
    @track saveLabel = "Save";
    @track _label;

    @track disableMode;

    subscription = null;
    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        if (this.saveBtnLabel) {
            this.saveLabel = this.saveBtnLabel;
        } else {

        }
        console.log('SaveBtnComponent   loanAppId', this.loanAppId, this.currentTabId, this.hasEditAccess);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
        this.subscribeToMessageChannel();
        this.fetchLoanTeam();
        this.fetchLoanDetails();
        this.fetchTeamDetails();
    }
    
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            LOSSAVEBUTTONDISABLE,
            (values) => this.handleDisableButton(values)
        );
    }
    handleDisableButton(values) {
        this.disableMode = values.disableSaveButton;
        //LAK-8799
        if(values.assignedTo){
            this.cvAssignedTo = values.assignedTo;
        }
        else{
            this.cvAssignedTo = null;
        }

    }
    handleSave(event) {
        this.disableMode = true;
        let parameter = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'OwnerId', 'Stage__c', 'SubStage__c', 'RMSMName__c', 'OpsUser__c', 'CPA_User__c'],
            childObjFields: [],
            queryCriteria: ' where id = \'' + this.loanAppId + '\''
        }

        this._label = event.target.label;
        console.log('this._label>> '+this._label);

        getSobjectDataNonCacheable({ params: parameter }).then((result) => {
            console.log('current loan app detail :', JSON.stringify(result));
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                if (result.parentRecords[0].OwnerId === CURRENTUSERID) {
                    console.log('Current User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && result.parentRecords[0].RMSMName__c === CURRENTUSERID && result.parentRecords[0].Stage__c === 'Post Sanction' && (result.parentRecords[0].SubStage__c === 'Data Entry' || result.parentRecords[0].SubStage__c === 'Data Entry Pool' || result.parentRecords[0].SubStage__c === 'Ops Query' || result.parentRecords[0].SubStage__c === 'Ops Query Pool')) {
                    console.log('RM SM User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && result.parentRecords[0].RMSMName__c === CURRENTUSERID && result.parentRecords[0].Stage__c === 'Soft Sanction' && (result.parentRecords[0].SubStage__c === 'Additional Data Entry Pool' || result.parentRecords[0].SubStage__c === 'Additional Data Entry')) {
                    console.log('RM SM User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && result.parentRecords[0].OpsUser__c === CURRENTUSERID && result.parentRecords[0].Stage__c === 'Disbursed' && result.parentRecords[0].SubStage__c === 'Additional Processing') {
                    console.log('Ops User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && result.parentRecords[0].CPA_User__c === CURRENTUSERID && result.parentRecords[0].Stage__c === 'Disbursed' && result.parentRecords[0].SubStage__c === 'DI Check') {
                    console.log('Ops User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && this.assignedUser != null && this.assignedUser === CURRENTUSERID) {// LAK-7654
                    console.log('PD Assigned User');
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && this.cvAssignedTo != null && this.cvAssignedTo === CURRENTUSERID) {// LAK-7654
                    console.log('CV Assigned User'); //LAK-8799
                    this.saveMethod(this._label);
                } else if (result.parentRecords[0].OwnerId !== CURRENTUSERID && this.shareResn ==='HubManager__c') {// LAK-7654
                    console.log('Hub Manager User');
                    this.saveMethod(this._label);
                }
                 else {
                    console.log('Another user');
                    this.disableMode = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: this.customeLabel.loan_Application_Current_User_Error_message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                }

            }

        })

            .catch((error) => {
                this.disableMode = false;
                console.log('Error while submit button:' + JSON.stringify(error));
            });

    }



    saveMethod(label) {

        if (label === this.saveLabel) {
            const payload = {
                recordId: this.loanAppId,
                validateBeforeSave: true,
                currentStapperApiName: this.stepper,
                currentSubStapperApiName: this.subStepper,
                tabId: this.currentTabId
            };
            publish(this.MessageContext, SaveProcessCalled, payload);
            console.log('save lms called ', JSON.stringify(payload));
        } else {
            const payload = {
                recordId: this.loanAppId,
                validateBeforeSave: false,
                currentStapperApiName: this.stepper,
                currentSubStapperApiName: this.subStepper,
                tabId: this.currentTabId
            };
            publish(this.MessageContext, SaveProcessCalled, payload);
            console.log('save lms called ', JSON.stringify(payload));
        }
        if (this.loanAppId) {
            this.getAPiCallouDta();
        }

    }


    intRecords = [];
    getAPiCallouDta() {
        console.log('loanappId in Savebtn component', this.loanAppId);
        let apiName = 'Crif Auth Login';
        let paramsLoanApp = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'LtstRespCode__c', 'IsInvalid__c'],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('api callout tracker data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    if (!result.parentRecords[0].IsInvalid__c) {
                        let fields = {};
                        fields['sobjectType'] = 'APICoutTrckr__c';
                        fields['Id'] = result.parentRecords[0].Id;
                        fields['IsInvalid__c'] = true;
                        this.intRecords.push(fields);
                        console.log(JSON.stringify(this.intRecords));
                        this.upsertIntRecord(this.intRecords);
                    }
                    else{
                        this.disableMode = false;
                    }
                }
                else{
                    this.disableMode = false;
                }
                
            })
            .catch((error) => {
                this.disableMode = false;
                console.log('Error In getting api callout Record', error);
            });
    }
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after updating api callout tracker record is ', JSON.stringify(result));
                this.intRecords = [];
                this.disableMode = false;
            })
            .catch((error) => {
                this.disableMode = false;
                console.log('Error In Updating api callout tracker Record', error);
            });
            this.disableMode = false;
    }

//LAK-551 TSR Report for 
    @track shareResn;

    fetchLoanTeam() {
      let loanTeamParam = {
            ParentObjectName: 'LoanTeam__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','LoanApplication__c','User__c','ShareReason__c'],
            childObjFields: [],
            queryCriteria: ' where LoanApplication__c = \'' + this.loanAppId + '\' AND User__c = \'' + CURRENTUSERID + '\' limit 1' 
            }
        getSobjectDataNonCacheable({params: loanTeamParam}).then((result) => {
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
              this.shareResn = result.parentRecords[0].ShareReason__c;
            }
          })
          .catch((error) => {
            console.log("SaveButton #234", error);
          });
      }


      @track showQtChk=false;
      @track lanStage;
      @track lanSubStage;
      @track lanOwner;
      fetchLoanDetails() {
        let loanDetParams = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Name","OwnerId","Stage__c","SubStage__c","BrchCode__c","Product__c",
              "BrchName__c"],
            childObjFields: [],
            queryCriteria: " where Id = '" + this.loanAppId + "' limit 1"
          };
          getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
             // this.wiredDataCaseQry=result;
              console.log("result Save Button DETAILS #263>>>>>", result);
              if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.lanOwner = result.parentRecords[0].OwnerId;
                this.lanStage = result.parentRecords[0].Stage__c;
                this.lanSubStage = result.parentRecords[0].SubStage__c;
                this.brchCode= result.parentRecords[0].BrchCode__c;
                // this.branchName=result.parentRecords[0].BrchName__c;
                if((CURRENTUSERID === this.lanOwner) && (this.lanStage === 'DDE' &&  this.lanSubStage === 'CPA Vendor Data Entry')){
                  this.showQtChk=true;
                }	
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
              console.log('query in save button::::',teamHierParam);
              
          getSobjectDataNonCacheable({params: teamHierParam}).then((result) => {
             // this.wiredDataCaseQry=result;
              console.log("result Save Button DETAILS #92>>>>>", result);
              if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.userRole = result.parentRecords[0].EmpRole__c;
              
              }
            })
            .catch((error) => {
              console.log("Error in Save button DETAILS #99", error);
            });
        }
    
        get showQalityChk(){
            return this.userRole ==='VCPA' && this.showQtChk;
        }

        @track modalOpen=false;
        handleQualtyCheck(){
            this.modalOpen=true;
        }
        
        closeModal(){
            this.lookupId=''
            this.modalOpen=false;
        }

        handleYesClick(){
            let isInputCorrect = this.validateForm();
            console.log("isInputCorrect if false>>>#320", isInputCorrect);
            if (isInputCorrect === true) {
                let tempLanArr=[];
                let obj={};
                obj.sobjectType='LoanAppl__c';
                obj.Id=this.loanAppId;
                obj.OwnerId=this.lookupId;
                obj.Stage__c ='DDE';
                obj.SubStage__c ='Quality Check';
                tempLanArr.push(obj);
                console.log('tempCaseArr:::::::330',tempLanArr);
               
                upsertMultipleRecord({ params: tempLanArr })
                .then(result => {     
                    console.log('Loan Save Btn Status Records Update ##334', result);
                    this.modalOpen=false;
                    this.showToastMessage('Success', 'Loan Application Sent to Quality Check Successfully', 'success', 'sticky');
                   location.reload();
                })
                .catch(error => {
                  this.showSpinner = false;
                  console.error('SAVE Btn DETAILS ##366', error)
                })
                      

            } else {
                this.showSpinnerModal=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select required fields',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );

            }
        }
@track lookUpRec;
@track lookupId;
@track BrchCode
  handleLookupFieldChange(event) {
    if (event.detail) {
      this.lookUpRec= event.detail;
      this.lookupId = event.detail.id;
    
    } 
    console.log('lookUpRec::::::',JSON.stringify(this.lookUpRec));
}

@track brchCode
@track vqcRole=['QCPA'];
get filterCondn(){
  let val;
   val= 'EmpRole__c =\''+this.vqcRole+'\' AND BranchCode__c = \'' + this.brchCode + '\' AND Employee__r.IsActive =true';
   console.log('val',val);
  return val;
}



  validateForm() {
    let isInputCorrect = true; 
    let allChilds = this.template.querySelectorAll("c-custom-lookup");
    console.log("custom lookup allChilds>>>", allChilds);
    allChilds.forEach((child) => {
        console.log("custom lookup child>>>", child);
        console.log(
            "custom lookup validity custom lookup >>>",
            isInputCorrect
        );
        if (!child.checkValidityLookup()) {
            child.checkValidityLookup();
            isInputCorrect = false;
            console.log(
                "custom lookup validity if false>>>",
                isInputCorrect
            );
        }
    });
    console.log('isInputCorrect',isInputCorrect);
    return isInputCorrect;
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