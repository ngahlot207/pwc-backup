import { LightningElement, wire, api, track } from "lwc";

import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import LOS_MESSAGES from "@salesforce/messageChannel/Los_messages__c";
import LOS_COMMUNICATION from "@salesforce/messageChannel/Los_Communication__c";
//import LANDATA_MESSAGECHANNEL from "@salesforce/messageChannel/LANDataMessageChannel__c";


import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import crntSubStagesUpdate from "@salesforce/apex/CurrentStageRefreshing.crntSubStagesUpdate";
import subStageNameUpd from "@salesforce/apex/CurrentStageRefreshing.subStageNameUpd";
import getAccess from "@salesforce/apex/RecordAccessController.getAccess";
import getsubStage from "@salesforce/apex/RecordAccessController.getsubStage";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi'
import STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';
import SUBSTAGE from '@salesforce/schema/LoanAppl__c.SubStage__c';
import FILE_ACCEPTANCE from '@salesforce/schema/LoanAppl__c.FileAcceptance__c';
//New Implementation
import ProgIndConfHanlde from "@salesforce/apex/ProgIndicConfigController.progIndConfHanlde";
import getDiplayConfigAsRoleNStatusNew from "@salesforce/apex/ShowMultipleComponentEnhancement.getDiplayConfigAsRoleNStatus";
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';

import { CPARoles } from 'c/globalConstant';

const Fileds = [STAGE, SUBSTAGE, FILE_ACCEPTANCE];

import { NavigationMixin } from "lightning/navigation";
import { RefreshEvent } from 'lightning/refresh';
//refresh wire adapter
import { refreshApex } from '@salesforce/apex';
// Custom labels
import HostContainer_FileAccpt_ErrorMessage from '@salesforce/label/c.HostContainer_FileAccpt_ErrorMessage';
import HostContainer_CoAppl_ErrorMessage from '@salesforce/label/c.HostContainer_CoAppl_ErrorMessage';

import Id from "@salesforce/user/Id";
export default class HostContainer extends NavigationMixin(LightningElement) {
    CustomLabel = {
        HostContainer_FileAccpt_ErrorMessage,
        HostContainer_CoAppl_ErrorMessage

    }
    @track userId = Id;
    @api recordId;

    @track refreshHost = true;
    @track refreshScrConfigView = false;
    @track stageName;
    @track applicantId;
    @track metadata;
    @track isFinalStep = false;
    @track isFirstStep = false;
    @track allStageLength;

    currentStageNumber;
    horizontalstepList;
    subscription = null;
    @track recordAccess;
    @track hasReadAccess;
    @track hasEditAccess;
    @track stage;
    @track substage;
    @track fileAccept;
    @track status;
    @track showSpinner = false;
    @wire(MessageContext)
    MessageContext;

    @track isCpa = false;
    @track disableButtons = false;
    @track disableFileAccpt = false;
    @track isReturnToRM = false;
    // @track wiredData = {};
    // @wire(getRecord, { recordId: '$recordId', fields: Fileds })
    // recordHandler({ data, error }) {

    //     if (data) {
    //         this.wiredData = data;
    //         console.log('STAGE SUBSTAGE RECORDS:::::::', data);
    //         this.stage = data.fields.Stage__c.value;
    //         this.substage = data.fields.SubStage__c.value;
    //         this.fileAccept = data.fields.FileAcceptance__c.value;
    //         console.log('Before If Else Condn::::: ', this.stage, this.substage, this.fileAccept);
    //         if (this.stage === 'QDE' && this.substage === 'Additional Data Entry Pool') {
    //             this.hasEditAccess = false;
    //         }
    //         else if (this.stage === 'QDE' && this.substage === 'Additional Data Entry' && this.fileAccept === false) {

    //             this.hasEditAccess = false;
    //             console.log('IN ELSE IF CONDN TO HASEDIT ACCESS TO FALSE ', this.hasEditAccess);
    //         }
    //         if (this.substage === 'Additional Data Entry') {
    //             this.isCpa = true;
    //         }

    //     } if (error) {
    //         console.log('ERROR:::::::', error);
    //     }
    // }

    connectedCallback() {
        //console.log('Message Context:', this.messageContext);
        //this.queryHorizontalSteps();
        this.subscribeClieckedStages();
        this.fetchRecordAccess();
        //this.handleLANDataSubscribe();
    }

    // @track currApplId = '';
    // handleLANDataSubscribe() {
    //     if (this.subscription) {
    //         return;
    //     }
    //     this.subscription = subscribe(this.MessageContext, LANDATA_MESSAGECHANNEL, (message) => {
    //         this.currApplId = message.currApplTabId;
    //     }, { scope: APPLICATION_SCOPE });
    // }

    async queryHorizontalSteps() {
        this.stageName = await subStageNameUpd({
            loanApplnId: this.recordId
        });

        console.log('first time  this.stageName is ', this.stageName);
        ProgIndConfHanlde({ loanAppId: this.recordId, stepperName: null })
            .then((result) => {
                console.log('ProgIndConfHanlde  in host ', result);
                if (result.length > 0) {
                    let arr = [];
                    this.currentStageNumber = 0;
                    for (let i = 0; i < result.length; i++) {
                        arr.push(result[i]);
                        if (this.stageName === result[i].value) {
                            this.currentStageNumber = i;
                        }
                    }
                    this.allStageLength = arr.length;
                    console.log(
                        "this.allStageLength NO IS======>" + this.allStageLength
                    );
                    this.isFirstStep = this.currentStageNumber === 0 ? true : false;
                    this.isFinalStep =
                        this.currentStageNumber === this.allStageLength - 1
                            ? true
                            : false;
                    this.horizontalstepList = arr;
                    this.stageName =
                        this.horizontalstepList[this.currentStageNumber].value;
                    console.log(
                        "result is =====>" + JSON.stringify(this.horizontalstepList)
                    );

                    this.callMessegingServiceHandler();

                    this.handleMetadeta();
                } else {
                    console.log(' NO Stage Found ');
                }

            });
    }
    callMessegingServiceHandler() {
        console.log(
            "messaging service called",
            this.horizontalstepList[this.currentStageNumber]
        );

        const payload = {
            horizontalCurrentStage:
                this.horizontalstepList[this.currentStageNumber]
        };

        publish(this.MessageContext, LOS_MESSAGES, payload);
        console.log("Publish messaging service end ", JSON.stringify(payload));
    }
    handleNext() {
        this.publishNextEvent();
        console.log("applicantID IS========>" + this.applicantId);
    }

    handleMetadeta() {
        this.metadata = [];
        console.log(" handleMetadeta loanAppId  ", this.recordId,
            "  currentSubStg: ", this.stageName,
            "  currentSubStepper  ", this.currentSubsteperStep);
        this.refreshScrConfigView = false;
        getDiplayConfigAsRoleNStatusNew({
            loanAppId: this.recordId,
            currentStepper: this.stageName,
            currentSubStepper: this.currentSubsteperStep,
            applicantId: null
        }).then((result) => {
            console.log('Meta getDiplayConfigAsRoleNStatusNew  raw   ', result);
            console.log('Meta getDiplayConfigAsRoleNStatusNew responce   ', result[0]);
            let arr = JSON.parse(result[1]);
            console.log('Meta getDiplayConfigAsRoleNStatusNew  new ', arr);
            let index = 0;
            let tempArr = arr.map(x => {
                x.index = 'ScreenConfig' + index;
                index++;
                return x;
            })
            this.metadata = [];
            this.metadata = tempArr;


            if (this.recordAccess == false) {
                this.hasEditAccess = false;
            } else {
                if (this.metadata[0] != undefined) {
                    this.hasEditAccess = this.metadata[0].editFlag !== undefined ? this.metadata[0].editFlag : this.recordAccess;
                }

            }

            //console.log(' this.metadata[0].editFlag #174 ', this.metadata[0].editFlag );
            console.log(' this.hasEditAccess #174 ', this.hasEditAccess);
            this.refreshScrConfigView = true;
        })
        .catch((error) => {
            console.log('getDiplayConfigAsRoleNStatusNew', error);
        });

    }

    publishNextEvent() {
        this.currentStageNumber = this.currentStageNumber + 1;
        let refreshSubStage =
            this.horizontalstepList[this.currentStageNumber].value;
        crntSubStagesUpdate({
            currentSubStage: refreshSubStage,
            loanApplnId: this.recordId
        });

        const payload = {

            horizontalCurrentStage:
                this.horizontalstepList[this.currentStageNumber]
        };
        console.log("CURRENT SETP NO IS======>" + this.currentStageNumber);
        publish(this.MessageContext, LOS_MESSAGES, payload);
        console.log("Publish on Next press======>", JSON.stringify(payload));

        this.isFirstStep = false;

        if (this.currentStageNumber === this.allStageLength - 1) {
            this.isFinalStep = true;
            this.isDisable = false;
        }

        this.stageName = refreshSubStage;
        this.showSubStepperProgress = false;
        console.log('updated stageName ', this.stageName);
        this.showSubStepperProgress = true;

        this.handleMetadeta();

    }

    handleStageclick(event) {
        let clickedStage = event.target.label;
        let clickedStageApi = event.target.value;
        this.currentSubsteperStep = clickedStageApi;
    }

    handlePrevious() {


        if (this.currentStageNumber <= this.allStageLength) {
            this.currentStageNumber = this.currentStageNumber - 1;
            let refreshSubStage =
                this.horizontalstepList[this.currentStageNumber].value;
            crntSubStagesUpdate({
                currentSubStage: refreshSubStage,
                loanApplnId: this.recordId
            });

            const payload = {

                horizontalCurrentStage:
                    this.horizontalstepList[this.currentStageNumber]
            };
            console.log("CURRENT SETP NO IS======>" + this.currentStageNumber);
            publish(this.MessageContext, LOS_MESSAGES, payload);
            console.log("Publish on Previous press======>", JSON.stringify(payload));
            this.isFinalStep = false;
            this.isDisable = false;
            if (this.currentStageNumber === 0) {
                this.isFirstStep = true;
            }
            this.stageName = refreshSubStage;
            this.showSubStepperProgress = false;
            console.log('updated stageName ', this.stageName);
            this.showSubStepperProgress = true;
        }

        this.handleMetadeta();
    }

    showToastMessage(title, message, variant) {
        const showToastMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: "dismissable"
        });
        this.dispatchEvent(showToastMessage);
    }


    subscribeClieckedStages() {
        this.subscription = subscribe(
            this.MessageContext,
            LOS_COMMUNICATION,
            (stagesAre) => this.handleClickedStages(stagesAre)
        );

    }

    handleClickedStages(stagesAre) {
        console.log("SUBSCRIPTION CALLED", stagesAre);

        this.stageName = stagesAre.clickedStageApi;
        console.log("this.stageName==", this.stageName);
        for (let i = 0; i < this.horizontalstepList.length; i++) {
            if (this.stageName === this.horizontalstepList[i].value) {
                this.currentStageNumber = i;
            }
        }
        this.isFirstStep = this.currentStageNumber === 0 ? true : false;
        console.log("this.isFirstStep==", this.isFirstStep);

        this.isFinalStep =
            this.currentStageNumber === this.allStageLength - 1 ? true : false;



        console.log(
            "crntSubStagesUpdate CALEED 1:::::::::::::",
            this.stageName
        );
        crntSubStagesUpdate({
            currentSubStage: this.stageName,
            loanApplnId: this.recordId
        });

        this.handleMetadeta();


    }

    fetchRecordAccess() {
        getAccess({
            recordId: this.recordId
        })
            .then((result) => {
                console.log("result IN HOST CONTAINER RECORD ACCEESS>>>>>", result);
                this.recordAccess = result.isEditAccess;
                this.hasReadAccess = result.isReadAccess;
                this.getStageSubstage();
                //refreshApex(this.wiredData);

            })
            .catch((error) => {
                console.log('ERROR IN HOST CONTAINER RECORD ACCEESS', error);
            });
    }

    @track disableLoginAcceptance = false;
    @track disabledReturnToRM = false;
    @track cloneStatus; //LAK-496
    getStageSubstage() {
        getsubStage({
            recordId: this.recordId
        })
            .then((result) => {
                console.log("result IN HOST CONTAINER getSubstage method>>>>>", result);
                this.stage = result.stage;
                this.substage = result.subStage;
                this.fileAccept = result.fileAccept;
                this.status = result.status;
                this.cloneStatus = result.cloneStatus ? result.cloneStatus : '';// For LAK-496

                if (this.stage === 'QDE' && this.substage === 'Additional Data Entry Pool') {
                    this.recordAccess = false;
                }
                else if (this.stage === 'QDE' && this.substage === 'Additional Data Entry' && this.fileAccept === false) {

                    this.recordAccess = false;
                    console.log('IN ELSE IF CONDN TO HASEDIT ACCESS TO FALSE ', this.recordAccess);
                }

                //exceuted below condition in last to supersede any decision from above
                if (this.status === 'Cancelled' || this.status === 'Hold' || this.status === 'Rejected' || this.status === 'BRE Reject' || this.status === 'Final Reject' || this.status === 'Finnone Pending' || this.status === 'BRE Hard Reject') {
                    this.recordAccess = false;
                }
                //LAK-496
                if (this.cloneStatus && this.cloneStatus == 'In Progress') {
                    this.showToastMessage("Error", 'Loan cloning is In progress, you cannot edit this loan application till cloning is completed!', "error",'sticky');
                    this.recordAccess = false;
                }
                // LAK-496
                if ((this.substage === 'Additional Data Entry' || this.substage === 'Additional Data Entry Vendor Processing')&& this.stage === 'QDE') {
                    // this.isCpa = true;
                    this.getTeamHierarchyData();
                    // if (!this.hasEditAccess) {
                    //     this.disableButtons = true;
                    //     this.disableFileAccpt = true;
                    // }
                    // if (this.fileAccept) {
                    //     this.disableFileAccpt = true;
                    // }
                }
                this.queryHorizontalSteps();
                //Added for Disabling Return to RM and Login Acceptance Buttons

                if (this.userId === result.ownerId && this.status !== 'BRE Reject') {
                    this.disabledReturnToRM = false;
                } else {
                    this.disabledReturnToRM = true;
                }

                if (this.userId === result.ownerId && this.fileAccept && this.status !== 'BRE Reject') {
                    this.disableLoginAcceptance = false;
                } else {
                    this.disableLoginAcceptance = true;
                }

            })
            .catch((error) => {
                console.log('ERROR IN HOST CONTAINER RECORD ACCEESS', error);
            });
    }

    @track isFileAcceptance = false;
    @track isLoginAcceptance = false;


    handlebuttonclicked(event) {
        let name = event.target.dataset.name;
        console.log('name selected is==>>>', name);
        if (name == 'Return To RM') {
            // this.isReturnToRM = true;
              this.getLoanAppData();
        }
        if (name == 'File Acceptance') {
            this.isFileAcceptance = true;
        }
        if (name == 'Login Acceptance') {
            console.log('login acceptance clicked');
            // check at least one coapplicant or guirentor is added
            if (this.fileAccept == true) {
                // this.isLoginAcceptance = true;

                this.getCoApplicantAvailable();
            } else {
                this.showToastMessage("Error", this.CustomLabel.HostContainer_FileAccpt_ErrorMessage, "error");
            }
        }
    }

    @track loanProduct = [];
    @track selectedValue = [];
      getLoanAppData(){
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Product__c','ReturnRMRemarks__c'],
            queryCriteria: ` where Id = '${this.recordId}'`
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Loan App data ', JSON.stringify(result));
                if (result.parentRecords) {
                    if (result.parentRecords[0].Product__c) {
                        this.loanProduct.push(result.parentRecords[0].Product__c);
                    }
                    if (result.parentRecords[0].ReturnRMRemarks__c) {
                        this.selectedValue = result.parentRecords[0].ReturnRMRemarks__c.split(';');
                    } else {
                        this.selectedValue = []; 
                    }
                }
               this.getReturnToRMOptions();
            })
            .catch((error) => {
                this.showSpinner =false;
                console.log('Error In getting Loan App Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
@track returnToRmOptions = [];
    getReturnToRMOptions(){
        let type = 'Return RM Remarks';
        let params = {
            ParentObjectName: 'MasterData__c',
            parentObjFields: ['Id', 'SalesforceCode__c','Name','Type__c'],
            queryCriteria: ` where Type__c = '${type}' AND Product__c INCLUDES ('${this.loanProduct.join("', '")}')`
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Master data ', JSON.stringify(result));
                if (result.parentRecords) {
                    let arr = [];
                    result.parentRecords.forEach(item => {
                        let obj = {};
                        obj.label = item.Name;
                        obj.value = item.Name;
                        arr.push(obj);
                    })
                    if (arr && arr.length > 0) {
                        this.returnToRmOptions = [...arr];
                    }
                    console.log('returnToRmOptions are ', this.returnToRmOptions);
                }
               // this.fireCustomEvent(null, null, null);
               if(this.returnToRmOptions && this.returnToRmOptions.length > 0){
                this.isReturnToRM = true;
               }
               this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Master Data is ', error);
               
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    getCoApplicantAvailable() {

        let paramsApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'ApplType__c'],
            childObjFields: [],
            queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\'' + ' AND ((ApplType__c  = \'' + 'C' + '\'' + ') OR (ApplType__c  = \'' + 'G' + '\'' + ' ))'
        }
        console.log('getCoApplicantAvailable', paramsApp);
        getAssetPropType({ params: paramsApp })
            .then((result) => {

                console.log('result for co-applicant ', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.isLoginAcceptance = true;
                } else {
                    this.showToastMessage("Error", this.CustomLabel.HostContainer_CoAppl_ErrorMessage, "error");
                    console.log('No Coapplicant Found ');
                }
            })
            .catch((error) => {
                console.log("error occured in getAssetPropType", error);

            });
    }


    handleReturnToRm(event) {
        this.isReturnToRM = false;
        this.isFileAcceptance = false;
        this.isLoginAcceptance = false;

        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        let fromVal = event.detail.from;
        console.log('val from return is', event);
        if (titleVal && variantVal && messageVal) {
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal,
                mode: "sticky"
            });
            this.dispatchEvent(evt);
        }
        if ((titleVal && titleVal === "Success") && (fromVal == 'ReturnToRM' || fromVal == 'LoginAcceptance')) {
            this.showSpinner = false;
            // this.navigateToListView();
            this.navigateToLoanPage();
        } else if (titleVal && titleVal === "Success" && fromVal === 'fileacceptance') {
            // this.dispatchEvent(new RefreshEvent());
            this.navigateToLoanPage();
            this.showSpinner = false;
        } else {
            this.showSpinner = false;
        }
    }

    handleSpinner(event) {
        console.log('spinner value', event.detail);
        if (event.detail == true) {
            this.showSpinner = true;
        }
    }
    // handleSpinnerFile(event) {
    //     console.log('spinner value', event.detail);
    //     if (event.detail == true) {
    //         this.showSpinner = true;
    //     }
    // }

    navigateToLoanPage() {
        console.log('navigateToListView called ');
        location.reload();
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         objectApiName: 'LoanAppl__c',
        //         actionName: 'edit'
        //     },
        // });
    }
    navigateToListView() {
        console.log('navigateToListView called ');
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "LoanAppl__c",
                actionName: "list"
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: "Recent" // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }
    get isFinancialStage() {
        console.log(this.stageName, 'fdsadsa');
        return this.stageName == 'FinancialDetails' ? true : false;
    }


    //FOR LAK-5065
    getTeamHierarchyData() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectDatawithRelatedRecords({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecord) {
                    console.log('team hierarchy data ', result.parentRecord);
                    if (this.substage === 'Additional Data Entry' && this.stage === 'QDE' && (CPARoles && CPARoles.includes(result.parentRecord.EmpRole__c))) {   //LAK-9244
                        this.isCpa = true;
                    }else if (this.substage === 'Additional Data Entry Vendor Processing' && this.stage === 'QDE' && result.parentRecord.EmpRole__c === 'VCPA') {
                        this.isCpa = true;
                    }else {
                        this.isCpa = false;
                    }
                } else {
                    this.isCpa = false;
                }
            })
            .catch((error) => {
                console.log("error occured in fetchId", error);
            });
    }
    //FOR LAK-5065
}