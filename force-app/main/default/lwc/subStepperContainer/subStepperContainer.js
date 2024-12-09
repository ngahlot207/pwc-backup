import { LightningElement, track, api } from 'lwc';
import ProgIndConfHanlde from "@salesforce/apex/ProgIndicConfigController.progIndConfHanlde";

import getDiplayConfigAsRoleNStatusNew from "@salesforce/apex/ShowMultipleComponentEnhancement.getDiplayConfigAsRoleNStatus";
import getAccess from "@salesforce/apex/RecordAccessController.getAccess";
import getsubStage from "@salesforce/apex/RecordAccessController.getsubStage";
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class SubStepperContainer extends LightningElement {

    @api loanAppId;
    @api stepper;
    @api applicantIdTab;
    @api currentTabId;
    @api hasEditAccess;
    subStepperStepList = [];
    currentSubsteperStep;

    subStepperAvailableOrNot;
    currentSubStageNumber;
    @track currentSubsteperStepLabel;
    @track allSubStageLength;
    @track metadata = [];
    @track showTabset;
    @track isFinalSubStep = false;
    @track isFirstSubStep = false;
    @track refreshComp = false;
    @track showBar;


    @track formFactor = formFactorPropertyName;
    @track desktopBoolean;
    @track phoneBolean = true;

    connectedCallback() {
        this.showBar = false;
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
        console.log('hasEditAccess in substepper set::::::', this.hasEditAccess);
        console.log('sub stepper applicantId  ', this.applicantIdTab);
        this.callsubStepperQueryConfi();
    }
    callsubStepperQueryConfi() {
        console.log('subStepperAvailableOrNot before', this.subStepperAvailableOrNot,
            "loanAppId ::", this.loanAppId,
            " stepperName:", this.stepper);


        ProgIndConfHanlde({
            loanAppId: this.loanAppId,
            stepperName: this.stepper,

        }).then((result) => {
            this.refreshComp = false;
            let subStepper = result;
            if (subStepper.length > 0) {
                this.subStepperStepList = subStepper;


                // this.subStepperStepList[0].isCurrent = true;
                // this.subStepperStepList[0].isInActive = false;
                // this.subStepperStepList[0].isCompleted = false;
                // this.subStepperStepList.forEach(element => {
                //     for(){

                //     }
                // });

                let arr = [];
                this.currentSubsteperStep = subStepper[0].value;
                this.currentSubsteperStepLabel = subStepper[0].label;
                this.subStepperAvailableOrNot = true;
                this.handleStages(subStepper[0]);
                this.currentSubStageNumber = 0;
                for (let i = 0; i < this.subStepperStepList.length; i++) {
                    arr.push(result[i]);
                    if (this.currentSubsteperStep === this.subStepperStepList[i].value) {

                        this.currentSubStageNumber = i;
                    }
                }
                this.allSubStageLength = arr.length;
                console.log(
                    "this.allSubStageLength NO IS======>" + this.allSubStageLength
                );
                this.isFirstSubStep = this.currentSubStageNumber === 0 ? true : false;
                this.isFinalSubStep =
                    this.currentSubStageNumber === this.allSubStageLength - 1
                        ? true
                        : false;
                this.currentSubsteperStep =
                    this.subStepperStepList[this.currentSubStageNumber].value;
                this.currentSubsteperStepLabel =
                    this.subStepperStepList[this.currentSubStageNumber].label;
                this.refreshComp = true;
            } else {
                this.subStepperAvailableOrNot = false;
                this.currentSubsteperStep = null;
                this.currentSubsteperStepLabel = null;
                this.subStepperStepList = null;
            }
            console.log(
                "result is =====>" + JSON.stringify(this.currentSubsteperStep)
            );
            console.log(
                "subStepperStepList  =====>" + JSON.stringify(this.subStepperStepList)
            );
            this.showBar = true;
            this.fetchRecordAccess();
            //this.handleMetadeta();
        });


    }
    @track currentStep;
    handleStages(stagesAre) {
        console.log(" ProgressIndicatorPath  subscribe stages are from path child", JSON.stringify(stagesAre));
        console.log(this.subStepperStepList);
        let stage = stagesAre;
        this.currentStep = stage.value;

        var index = this.subStepperStepList.map(function (e) { return e.value; }).indexOf(this.currentStep);
        let tempArrayStepList = [...this.subStepperStepList];
        for (var i = 0; i < tempArrayStepList.length; i++) {
            if (i < index) {
                tempArrayStepList[i].isCompleted = true;
                tempArrayStepList[i].isInActive = false;
                tempArrayStepList[i].isCurrent = false;
            } else if (i == index) {
                tempArrayStepList[i].isCurrent = true;
                tempArrayStepList[i].isInActive = false;
                tempArrayStepList[i].isCompleted = false;
            } else {
                tempArrayStepList[i].isInActive = true;
                tempArrayStepList[i].isCompleted = false;
                tempArrayStepList[i].isCurrent = false;
            }
        }
        this.subStepperStepList = [];
        this.subStepperStepList = [...tempArrayStepList];
        console.log(" ProgressIndicatorPath  subscribe current Stage", this.currentStep);
    }



    handleMetadeta() {
        this.metadata = [];
        console.log(" handleMetadeta loanAppId  ", this.loanAppId,
            "  currentSubStg: ", this.stepper,
            "  currentSubStepper  ", this.currentSubsteperStep);

        if (this.currentSubsteperStep !== null) {
            getDiplayConfigAsRoleNStatusNew({
                loanAppId: this.loanAppId,
                currentStepper: this.stepper,
                currentSubStepper: this.currentSubsteperStep,
                applicantId: null
            }).then((result) => {
                this.showTabset = false;

                let arr = JSON.parse(result[1]);
                console.log('Meta getDiplayConfigAsRoleNStatusNew  new ', arr);
                this.metadata = [];
                this.metadata = arr;

                if (this.recordAccess == false) {
                    this.hasEditAccess = false;
                } else {
                    if (this.metadata[0] != undefined) {
                        this.hasEditAccess = this.metadata[0].editFlag !== undefined ? this.metadata[0].editFlag : this.recordAccess;
                    }

                }
                this.refreshComp = true;
            });
        }


    }

    fetchRecordAccess() {
        getAccess({
            recordId: this.loanAppId
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




    handleNextSubStepper() {
        this.refreshComp = false;
        let value = this.currentSubStageNumber + 1;
        this.currentSubStageNumber = value;
        let refreshSubStage =
            this.subStepperStepList[this.currentSubStageNumber].value;
        this.currentSubsteperStepLabel = this.subStepperStepList[this.currentSubStageNumber].label;
        this.currentSubsteperStep = refreshSubStage;
        this.isFirstSubStep = false;

        if (this.currentSubStageNumber === this.allSubStageLength - 1) {
            this.isFinalSubStep = true;
        }
        this.refreshComp = true;
        this.fetchRecordAccess();
        //this.handleMetadeta();
        this.handleStages(this.subStepperStepList[this.currentSubStageNumber]);
    }

    handlePreviousSubStepper() {
        this.refreshComp = false;

        if (this.currentSubStageNumber <= this.allSubStageLength) {
            this.currentSubStageNumber = this.currentSubStageNumber - 1;
            let refreshSubStage =
                this.subStepperStepList[this.currentSubStageNumber].value;
            this.isFinalSubStep = false;

            if (this.currentSubStageNumber === 0) {
                this.isFirstSubStep = true;
            }
            this.currentSubsteperStep = refreshSubStage;
            this.currentSubsteperStepLabel = this.subStepperStepList[this.currentSubStageNumber].label;
            this.showTabset = false;
            this.showTabset = true;
        }

        this.handleStages(this.subStepperStepList[this.currentSubStageNumber]);
        this.fetchRecordAccess();
        //this.handleMetadeta();
    }

    handleStageclick(event) {
        this.refreshComp = false;
        let index = event.currentTarget.dataset.index;
        let clickedStage = this.subStepperStepList[index].label;
        let clickedStageApi = this.subStepperStepList[index].value;
        for (let i = 0; i < this.subStepperStepList.length; i++) {
            if (this.subStepperStepList[i].value === clickedStageApi) {
                let value = i + 1;
                this.currentSubStageNumber = value - 1;
                if (this.currentSubStageNumber + 1 === this.allSubStageLength) {
                    this.isFirstSubStep = false;
                    this.isFinalSubStep = true;
                } else if (this.currentSubStageNumber === 0) {
                    this.isFirstSubStep = true;
                    this.isFinalSubStep = false;
                } else {
                    this.isFirstSubStep = false;
                    this.isFinalSubStep = false;
                }
            }
        }


        this.currentSubsteperStep = clickedStageApi;
        this.currentSubsteperStepLabel = this.subStepperStepList[this.currentSubStageNumber].label;
        console.log('currentSubsteperStep in handle click is', this.currentSubsteperStep);

        //this.handleMetadeta();
        this.fetchRecordAccess();
        this.handleStages(this.subStepperStepList[this.currentSubStageNumber]);

    }
    @track cloneStatus; //LAK-496
    getStageSubstage() {
        getsubStage({
            recordId: this.loanAppId
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
                if (this.status === 'Cancelled' || this.status === 'Hold' || this.status === 'Rejected' || this.status === 'BRE Reject' || this.status === 'Final Reject' || this.status === 'Finnone Pending') {
                    this.recordAccess = false;
                }
                 //LAK-496
                 if (this.cloneStatus && this.cloneStatus == 'In Progress') {
                       this.showToastMessage("Error", 'Loan cloning is In progress, you cannot edit this loan application till cloning is completed!', "error",'sticky');
                     this.recordAccess = false;
                 }
                 // LAK-496
                this.handleMetadeta();
                //this.queryHorizontalSteps();
                //Added for Disabling Return to RM and Login Acceptance Buttons



            })
            .catch((error) => {
                console.log('ERROR IN HOST CONTAINER RECORD ACCEESS', error);
            });
    }
}