import { LightningElement, api, wire, track } from "lwc";

import { subscribe, publish, MessageContext } from "lightning/messageService";
import LOS_COMMUNICATION from "@salesforce/messageChannel/Los_Communication__c";
import LOS_MESSAGES from "@salesforce/messageChannel/Los_messages__c";

import STEPSMASTER from "@salesforce/apex/ProgressIndicatorConfig.progressDetails";
import formFactorPropertyName from "@salesforce/client/formFactor";

export default class horizontalProgressBarComponent extends LightningElement {
    @api stepList;
    @api currentStep;
    @api recordId;

    showBar;
    subscription = null;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean;
    @track phoneBolean = true;
    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        this.showBar = false;
        this.subscribeToMessageChannel();


        console.log("Form Factor Property Name ", this.formFactor);
        console.log("formFactorPropertyName ", formFactorPropertyName);
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

        console.log('Before STEPSMASTER:: ', this.recordId);
        STEPSMASTER({ loanAppId: this.recordId })
            .then((result) => {
                var arr = [];
                for (var i = 0; i < result.length; i++) {
                    arr.push(result[i]);
                }
                this.stepList = arr;
                console.log('stepList:: ', this.stepList);
                this.showBar = true;
            })
            .catch((err) => {
                console.log("error===", err);
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
        console.log("stages are from path child", JSON.stringify(stagesAre));
        console.log(this.stepList);
        let stage = stagesAre.horizontalCurrentStage;
        this.currentStep = stage.value;
        console.log("current Stage", this.currentStep);
    }

    handleStageclick(event) {
        let clickedStage = event.target.label;
        let clickedStageApi = event.target.value;
        this.currentStep = clickedStageApi;


        const payload = {
            clickedStage: clickedStage,
            clickedStageApi: clickedStageApi
        };
        console.log("clicked Stage=====>", JSON.stringify(payload));
        publish(this.MessageContext, LOS_COMMUNICATION, payload);

    }
}