import { LightningElement, wire, api, track } from "lwc";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import LOS_MESSAGES from "@salesforce/messageChannel/Los_messages__c";
import LOS_COMMUNICATION from "@salesforce/messageChannel/Los_Communication__c";

//import RedirectToCoApp from "@salesforce/messageChannel/Redirect_To_Co_Applicant_Stages__c";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import STEPSMASTER from "@salesforce/apex/ProgressIndicatorConfig.progressDetails";
import crntSubStagesUpdate from "@salesforce/apex/CurrentStageRefreshing.crntSubStagesUpdate";
import subStageNameUpd from "@salesforce/apex/CurrentStageRefreshing.subStageNameUpd";
import getScreenConfiMetdata from "@salesforce/apex/FetchApplicantDetails.getScreenConfiMetdata";
import applicantDetails from "@salesforce/apex/FetchApplicantDetails.fetchApplicantDetailsMethod";

import {
    subscribe as empSubscribe,
    unsubscribe as empUnsubscribe,
    onError as empOnError,
    setDebugFlag as empSetDebugFlag,
    isEmpEnabled as empIsEmpEnabled
} from "lightning/empApi";

export default class hostComponentButtons extends LightningElement {
    //add any api property here
    @api recordId;

    @api channelName = "/event/IntRespEvent__e";
    //add any track property here
    @track applicantId;
    @track coApplicantId;
    @track stageName;
    @track objectName;
    @track showTabset = false;
    @track subSteps = [];
    @track callScreenConfig = false;
    @track tabContentType;
    @track clickedStageName;
    @track allStageLength;
    @track refreshHost = true;

    @track redirectToCoApp;

    isFinalStep = false;
    isFirstStep = false;
    currentStageNumber;
    horizontalstepList;
    subscription = null;

    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        this.queryHorizontalSteps();
        this.subscribeClieckedStages();
        // this.handleSubscribe();
    }

    async queryHorizontalSteps() {
        this.stageName = await subStageNameUpd({
            loanApplnId: this.recordId
        });
        STEPSMASTER({ loanAppId: this.recordId }).then((result) => {
            let arr = [];
            this.currentStageNumber = 0;
            for (let i = 0; i < result.length; i++) {
                arr.push(result[i]);
                if (this.stageName === result[i].label) {
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
                this.horizontalstepList[this.currentStageNumber].label;

            console.log(
                "result is =====>" + JSON.stringify(this.horizontalstepList)
            );

            this.callMessegingServiceHandler();
            this.getTabsetValues();
        });
    }

    callMessegingServiceHandler() {
        console.log(
            "messaging service called",
            this.horizontalstepList[this.currentStageNumber]
        );
        //let pld = "new patydsa";
        const payload = {
            horizontalCurrentStage:
                this.horizontalstepList[this.currentStageNumber]
        };
        // publish(this.MessageContext, LOS_MESSAGES, pld);
        publish(this.MessageContext, LOS_MESSAGES, payload);
        console.log("messaging service end");
    }

    // this event handler is not used currently
    valueFromChild() { }

    handleNext() {
        this.resetValues();
        this.publishNextEvent(); ///optional
        console.log("applicantID IS========>" + this.applicantId);
        // getSobjectId({
        //     ApplicantId: this.applicantId,
        //     objectApiName: this.objectName
        // })
        //     .then((result) => {
        //         let sobjectIds = result;
        //         this.sobjectIdsforStage = sobjectIds;
        //         console.log("HANDLE NEXT NEW SOBJECT ID======>" + sobjectIds);
        //         console.log("OBJECT NAME IS========>" + this.objectName);
        //         if (sobjectIds == null) {
        //             const showToastMessageError = new ShowToastEvent({
        //                 title: "error",
        //                 message: "Error - Please Enter the Details",
        //                 variant: "error",
        //                 mode: "dismissable"
        //             });
        //             this.dispatchEvent(showToastMessageError);
        //         } else {
        //             this.publishNextEvent();
        //         }
        //     })
        //     .catch((err) => {
        //         console.log("error===", err);
        //         // this.ShowToast("Error!!", err, "error", "dismissable");
        //     })
        //     .finally(() => {});
    }

    publishNextEvent() {
        this.currentStageNumber = this.currentStageNumber + 1;
        let refreshSubStage =
            this.horizontalstepList[this.currentStageNumber].label;
        crntSubStagesUpdate({
            currentSubStage: refreshSubStage,
            loanApplnId: this.recordId
        });
        //const number = this.currentStageNumber - 1;
        const payload = {
            //horizontalStages: this.horizontalstepList,
            horizontalCurrentStage:
                this.horizontalstepList[this.currentStageNumber]
        };
        console.log("CURRENT SETP NO IS======>" + this.currentStageNumber);
        publish(this.MessageContext, LOS_MESSAGES, payload);
        this.isFirstStep = false;

        if (this.currentStageNumber === this.allStageLength - 1) {
            this.isFinalStep = true;
            this.isDisable = false;
        }
        this.stageName = refreshSubStage;
        this.getTabsetValues();
    }

    handlePrevious() {
        this.resetValues();
        if (this.currentStageNumber <= this.allStageLength) {
            this.currentStageNumber = this.currentStageNumber - 1;
            let refreshSubStage =
                this.horizontalstepList[this.currentStageNumber].label;
            crntSubStagesUpdate({
                currentSubStage: refreshSubStage,
                loanApplnId: this.recordId
            });
            //const number = this.currentStageNumber - 1;
            const payload = {
                //horizontalStages: this.horizontalstepList,
                horizontalCurrentStage:
                    this.horizontalstepList[this.currentStageNumber]
            };
            console.log("CURRENT SETP NO IS======>" + this.currentStageNumber);
            publish(this.MessageContext, LOS_MESSAGES, payload);
            this.isFinalStep = false;
            this.isDisable = false;
            if (this.currentStageNumber === 0) {
                this.isFirstStep = true;
            }
            this.stageName = refreshSubStage;
        }
        this.getTabsetValues();
    }

    resetValues() {
        this.showTabset = false;
        this.subSteps = [];
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

    getTabsetValues() {
        this.showTabset = !this.showTabset;
        console.log(
            "getScreenConfiMetdata called 1",
            this.recordId,
            "-----",
            this.stageName,
            " ---",
            this.showTabset
        );
        getScreenConfiMetdata({
            loanAppId: this.recordId,
            //StageName: this.stageName
            stageName: this.horizontalstepList[this.currentStageNumber].label
        }).then((result) => {
            console.log("getScreenConfiMetdata resullt1 ", result);
            let res = JSON.parse(result);
            let showTabset = res[0].Show_Tabset__c;

            console.log("getScreenConfiMetdata resullt2 ", showTabset);
            applicantDetails({ recordId: this.recordId }).then((result2) => {
                console.log(
                    "getScreenConfiMetdata result of applicantDetails == " +
                    result2
                );
                let res2 = JSON.parse(result2);
                // this.metadataDetails = res;
                console.log(
                    "getScreenConfiMetdata result of applicant details==>" +
                    JSON.stringify(res2)
                );
                //subStepsLocal=[];
                let i;
                for (i = 0; i < res2.length; i++) {
                    let step = {
                        label:
                            res2[i].FirstName__c +
                            "  " +
                            res2[i].LastName__c +
                            "  (" +
                            res2[i].Type__c +
                            ") ",
                        value: res2[i].Id,
                        type: res2[i].Type__c
                    };
                    //subStepsLocal.push(step);
                    this.subSteps.push(step);

                    console.log("getScreenConfiMetdata Step data is ==>", step);
                    if (res2[i].Type__c === "Applicant") {
                        this.applicantId = res2[i].Id;
                    } else if (res2[i].Type__c === "Co-Applicant") {
                        this.coApplicantId = res2[i].Id;
                    }
                }
                if (this.subSteps.length === 0) {
                    console.log("empty");
                    // this.subSteps = subStepsLocal;
                }
                console.log(
                    "applicant ids ",
                    this.applicantId,
                    this.coApplicantId
                );
                if (showTabset === true) {
                    this.showTabset = showTabset;
                } else {
                    this.showTabset = false;
                }

                console.log(
                    " getScreenConfiMetdata substeps data==>",
                    this.subSteps
                );
            });

            //this.callScreenConfig = true;
        });
    }

    handleActive(event) {
        console.log("Applciant value==>" + event.target.value);
        console.log("Applciant label==>" + event.target.label);
        // console.log('Applciant type==>'+event.target.type);

        this.callScreenConfig = false;
        this.tabContentType = event.target.value;
        this.callScreenConfig = true;
    }

    subscribeClieckedStages() {
        this.subscription = subscribe(
            this.MessageContext,
            LOS_COMMUNICATION,
            (stagesAre) => this.handleClickedStages(stagesAre)
        );
        this.subscription = subscribe(
            this.MessageContext,
            RedirectToCoApp,
            (stagesAre) => this.handleStages(stagesAre)
        );
    }

    handleClickedStages(stagesAre) {
        console.log("SUBSCRIPTION CALLED");
        this.subSteps = [];
        this.stageName = stagesAre.clickedStage;
        console.log("this.stageName==", this.stageName);
        for (let i = 0; i < this.horizontalstepList.length; i++) {
            if (this.stageName === this.horizontalstepList[i].label) {
                this.currentStageNumber = i;
            }
        }
        this.isFirstStep = this.currentStageNumber === 0 ? true : false;
        console.log("this.isFirstStep==", this.isFirstStep);
        //this.isFinalStep = false;
        this.isFinalStep =
            this.currentStageNumber === this.allStageLength - 1 ? true : false;

        this.getTabsetValues();

        console.log(
            "crntSubStagesUpdate CALEED 1:::::::::::::",
            this.stageName
        );
        crntSubStagesUpdate({
            currentSubStage: this.stageName,
            loanApplnId: this.recordId
        });
        console.log("crntSubStagesUpdate CALEED 2::::::::::::");
    }
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        let messageCallback = function (response) {
            console.log(
                " Recieved  Plateform Event in Host Comp: ",
                JSON.stringify(response)
            );
            console.log("Recieved  Plateform Event in Host Comp: ", response);

            let obj = JSON.parse(JSON.stringify(response));
            let payload = obj.data.payload;
            let statusRes = JSON.parse(payload.coutResp__c);
            let finStstus = statusRes.Status;
            let finService = statusRes.ServiceName;
            let loanAppId = statusRes.loanAppId;
            let appId = statusRes.appId;
            self.refreshUiOnPlatEvent(appId, loanAppId, finStstus);

            // alert('responce came '+finStstus+'  '   +finService+ ' this.updatedStatus  '+ this.updatedStatus+' this.updatedService  '+this.updatedService);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        empSubscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            // console.log("custom event responce: ", JSON.stringify(response));
            // this.subscription = response;
            // this.responseesAre = JSON.stringify(response);
            // this.updateUiOnResponce(response);
        });
    }
    refreshUiOnPlatEvent(applicantId, loanAppId, status) {
        console.log(
            "plateform event called in Host Component ",
            applicantId,
            loanAppId,
            status,
            " Local ",
            this.recordId,
            "appid ",
            this.applicantId
        );
        if (
            loanAppId == this.recordId &&
            applicantId == this.applicantId &&
            status == "Responded"
        ) {
            console.log("Refresh the Host Comp");
            this.refreshHost = false;
            this.refreshHost = true;
        }
    }


    handleStages(stagesAre) {
        console.log("called in Host Component by stage validation ", JSON.stringify(stagesAre));

        let stage = stagesAre.redirectToCoApp;
        // this.currentStep = stage.value;
        this.redirectToCoApp = stage;
        console.log("message from velidation", stage);
    }
}