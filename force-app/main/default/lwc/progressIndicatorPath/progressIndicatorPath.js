import { LightningElement, track, api, wire } from 'lwc';
// calling apex class to fetch progress indicator details
import ProgIndConfHanlde from "@salesforce/apex/ProgIndicConfigController.progIndConfHanlde";

import { subscribe, publish, MessageContext } from "lightning/messageService";
import LOS_COMMUNICATION from "@salesforce/messageChannel/Los_Communication__c";
import LOS_MESSAGES from "@salesforce/messageChannel/Los_messages__c";
import Id from "@salesforce/user/Id";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';

import formFactorPropertyName from "@salesforce/client/formFactor";

export default class ProgressIndicatorPath extends LightningElement {
    @api stepList;
    @api currentStep;
    @api recordId;
    @api stepperName;

    showBar;
    subscription = null;

    @track userId = Id;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean;
    @track phoneBolean = true;

    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        this.showBar = false;
        this.subscribeToMessageChannel();
        this.getSalesHierMetadat();

        console.log("ProgressIndicatorPath Form Factor Property Name ", this.formFactor, ' formFactorPropertyName ', formFactorPropertyName);

        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }

        console.log(" ProgressIndicatorPath before ProgIndConfHanlde ", this.recordId, '  stepperName  ', this.stepperName);

        ProgIndConfHanlde({ loanAppId: this.recordId, stepperName: this.stepperName })
            .then((result) => {
                var arr = [];
                for (var i = 0; i < result.length; i++) {
                    arr.push(result[i]);
                }
                this.stepList = arr;
                console.log(' ProgressIndicatorPath stepList :: ', this.stepList);
                this.showBar = true;
            })
            .catch((err) => {
                console.log(" ProgressIndicatorPath error===", err);
            });
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            LOS_MESSAGES,
            (stagesAre) => this.handleStages(stagesAre)
        );
    }

    handleStages(stagesAre) {
        console.log(" ProgressIndicatorPath  subscribe stages are from path child", JSON.stringify(stagesAre));
        console.log(this.stepList);
        let stage = stagesAre.horizontalCurrentStage;
        this.currentStep = stage.value;

        var index = this.stepList.map(function(e) { return e.value; }).indexOf(this.currentStep);
        let tempArrayStepList = [...this.stepList];
        for(var i=0;i<tempArrayStepList.length;i++){
            if(i<index){
                tempArrayStepList[i].isCompleted= true;
                tempArrayStepList[i].isInActive= false;
                tempArrayStepList[i].isCurrent= false;
            }else if(i==index){
                tempArrayStepList[i].isCurrent= true;
                tempArrayStepList[i].isInActive= false;
                tempArrayStepList[i].isCompleted= false;
            }else{
                tempArrayStepList[i].isInActive= true;
                tempArrayStepList[i].isCompleted= false;
                tempArrayStepList[i].isCurrent= false;
            }
        }
        this.stepList = [...tempArrayStepList];
        console.log(" ProgressIndicatorPath  subscribe current Stage", this.currentStep);
    }

    handleStageclick(event) {
        let index = event.currentTarget.dataset.index;
        this.updatePath(index);
    }

    handleRelatedLinkClick(event) {
        const index = this.stepList.findIndex(link => link.value === event.currentTarget.dataset.value);
        if (index !== -1) {
            this.updatePath(index);
        }
    }

    updatePath(index) {

        //let index = event.currentTarget.dataset.index;
        let stepObj = this.stepList[index];
        let clickedStage = stepObj.label;
        let clickedStageApi = stepObj.value;
        /*let clickedStage = event.target.label;
        let clickedStageApi = event.target.value;*/
        
        this.currentStep = clickedStageApi;


        const payload = {
            clickedStage: clickedStage,
            clickedStageApi: clickedStageApi
        };
        console.log(" ProgressIndicatorPath  clicked Stage  publish=====>", JSON.stringify(payload));
        publish(this.MessageContext, LOS_COMMUNICATION, payload);
        
        let tempArrayStepList = [...this.stepList];
        for(var i=0;i<tempArrayStepList.length;i++){
            if(i<index){
                tempArrayStepList[i].isCompleted= true;
                tempArrayStepList[i].isInActive= false;
                tempArrayStepList[i].isCurrent= false;
            }else if(i==index){
                tempArrayStepList[i].isCurrent= true;
                tempArrayStepList[i].isInActive= false;
                tempArrayStepList[i].isCompleted= false;
            }else{
                tempArrayStepList[i].isInActive= true;
                tempArrayStepList[i].isCompleted= false;
                tempArrayStepList[i].isCurrent= false;
            }
        }
        this.stepList = [...tempArrayStepList];

    }


@track creditHierNewArr = [];
@track opsHierNewArr = [];
getSalesHierMetadat() {
    this.showSpinner = true;
    let develoeprNames = ['Credit', 'Ops'];
    let paramsLoanApp = {
        ParentObjectName: 'SharingHierarchy__mdt',
        parentObjFields: ['Id', 'BrchRoleSharing__c', 'SupervisoreRoleSharing__c', 'DeveloperName'],
        queryCriteria: ' where DeveloperName  IN (\'' + develoeprNames.join('\', \'') + '\')'
    }
    getSobjectData({ params: paramsLoanApp })
        .then((result) => {
            console.log('credit and ops hierarchy metadata is', JSON.stringify(result));
            if (result.parentRecords) {
                let credArr = result.parentRecords.find(item => item.DeveloperName === 'Credit');
                let opsArr = result.parentRecords.find(item => item.DeveloperName === 'Ops');
                if (credArr) {
                    let arrayFromString = credArr.BrchRoleSharing__c.split(',');
                    let arrayFromStringNew = [];
                    if (credArr.SupervisoreRoleSharing__c) {
                        arrayFromStringNew = credArr.SupervisoreRoleSharing__c.split(',');
                    }
                    let setFromArray = new Set([...arrayFromString, ...arrayFromStringNew]);
                    this.creditHierNewArr = Array.from(setFromArray);
                    console.log('this.creditHierNewArr', this.creditHierNewArr);
                }
                if (opsArr) {
                    let arrayFromStringOps = opsArr.BrchRoleSharing__c.split(',');
                    // let arrayFromStringNew = opsArr.SupervisoreRoleSharing__c.split(',');
                    let arrayFromStringNewOps = [];
                    if (opsArr.SupervisoreRoleSharing__c) {
                        arrayFromStringNewOps = opsArr.SupervisoreRoleSharing__c.split(',');
                    }
                    let setFromArrayOps = new Set([...arrayFromStringOps, ...arrayFromStringNewOps]);
                    this.opsHierNewArr = Array.from(setFromArrayOps);
                    console.log('this.opsHierNewArr', this.opsHierNewArr);
                }
                this.getTeamHierarchyData();
            }
        })
        .catch((error) => {
            this.showSpinner = false;
            console.log('Error In getting sales hierarchy details ', error);
        });
}



@track empRole;
@track showQuickLinks = false;

getTeamHierarchyData() {
    let paramsLoanApp = {
        ParentObjectName: 'TeamHierarchy__c',
        parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
        queryCriteria: ' where Employee__c = \'' + this.userId + '\' ORDER BY LastModifiedDate DESC'
    }
    getSobjectData({ params: paramsLoanApp })
        .then((result) => {
            console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
            
            if (result.parentRecords) {
                this.empRole = result.parentRecords[0].EmpRole__c;
                console.log('empRole', this.empRole);
            }
            if (this.empRole) {
                if (this.opsHierNewArr.includes(this.empRole) || this.creditHierNewArr.includes(this.empRole)) {
                    this.showQuickLinks = true;
                } 
            }
           
        })
        .catch((error) => {
            this.showSpinner = false;
            console.log('Error In getting team hierarchy details ', error);
            //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
        });
}
}