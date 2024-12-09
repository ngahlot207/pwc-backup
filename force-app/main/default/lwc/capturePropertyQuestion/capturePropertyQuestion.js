import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import retrieveAllPropQues from '@salesforce/apex/PropertyQuestionController.retrieveAllPropQues';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

//********LMS********//
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

export default class CapturePropertyQuestion extends LightningElement {
    @api hasEditAccess;
    @api applicantAssetId;
    @api genNormQuesList;
    @api propTypeQuesList;
    @api stage;
    @api subStage;
    showAccordian = false;
    isVisibleSectionA = false;
    isVisibleSectionB = false;
    gnrlCheckboxValue = false;
    propCheckboxValue = false;
    generalNormsQues;
    propSubtypeQues;
    propRespId;
    //@api isStageUW = false; //UW condition added in PropertyDetails
    possibleOptions;
    quesId;
    quesResp;
    quesTitle;
    respType;

    @track propertyQuestion = {};
    @track ChildRecords = [];

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }

    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        this.scribeToMessageChannel();
        console.log('hasEditAccess===>>>:', this.hasEditAccess);
        if (this.hasEditAccess === false) {
            this.showAccordian = false;
        } else {
            this.showAccordian = true;
        }
        if (this.applicantAssetId) {
            console.log('assetId===>>>:', this.applicantAssetId);
            retrieveAllPropQues({ assetId: this.applicantAssetId })
                .then((result) => {
                    console.log('Result===>>>:', JSON.stringify(result));

                    for (var i = 0; i < result.generalNormsQues.length; i++) {
                        console.log('stage print ', this.stage);
                        if (this.stage == 'DDE') {
                            result.generalNormsQues[i].isReqPortal = false;
                        }
                    }
                    for (var i = 0; i < result.propSubtypeQues.length; i++) {
                        if (this.stage == 'DDE') {
                            result.propSubtypeQues[i].isReqPortal = false;
                        }
                    }
                    this.genNormQuesList = result.generalNormsQues;
                    this.propTypeQuesList = result.propSubtypeQues;
                    this.propRespId = result.propRespId;
                    this.gnrlCheckboxValue = result.gnrlCheckboxValue;
                    this.propCheckboxValue = result.propCheckboxValue;

                    if (!this.isEmptyObject(this.genNormQuesList)) {
                        this.isVisibleSectionA = true;
                    }
                    if (!this.isEmptyObject(this.propTypeQuesList)) {
                        this.isVisibleSectionB = true;
                    }
                    console.log('genNormQuesList===>>>: ', this.genNormQuesList);
                    console.log('propTypeQuesList===>>>: ', this.propTypeQuesList);
                })
                .catch((err) => {
                    console.log('Error in Getting Property Questions', err);
                    //this.showToast("Error ", "error", "Error in Getting Property Questions " + err.message);
                }
                )
        }
    }

    genNormQuesfromChild(event) {
        const response = event.detail;
        const quesId = response.pdRespId.quesId;
        const quesResp = response.respVal;
        console.log("gnrlNormsResponse ==> ", JSON.stringify(this.genNormQuesList));

        const newQuesResp = event.detail.respVal;
        console.log("New quesResp ==> ", newQuesResp);

        const quesToUpdate = this.genNormQuesList.find(genQues => genQues.quesId === quesId);
        if (quesToUpdate) {
            console.log("handleValueChange recordToUpdate ==> ", quesToUpdate);
            quesToUpdate.quesResp = newQuesResp;

            //************for checkbox update***********//
            console.log("gnrlCheckboxValue 1 ==>>: ", this.gnrlCheckboxValue);
            const allYes = this.genNormQuesList.every(genQues => genQues.quesResp === 'Yes');
            console.log("allYes==>>: ", allYes);
            if (allYes) {
                this.gnrlCheckboxValue = true;
            }
            else {
                this.gnrlCheckboxValue = false;
            }
        }
    }

    @track allNA;
    subTypeQuesfromChild(event) {
        console.log("from child  To Pd Component updated val 2 ==> ", event.detail);
        const response = event.detail;
        const quesId = response.pdRespId.quesId;
        const quesResp = response.respVal;
        const { pdRespId, respVal } = event.detail;
        this.propTypeQuesList[pdRespId.quesId] = respVal;
        console.log("subTypeList ==> ", JSON.stringify(this.propTypeQuesList));

        const newPropQuesResp = event.detail.respVal;
        console.log("New quesResp ==> ", newPropQuesResp);

        const propQuesToUpdate = this.propTypeQuesList.find(propQues => propQues.quesId === quesId);
        if (propQuesToUpdate) {
            console.log("handleValueChange recordToUpdate ==> ", propQuesToUpdate);
            propQuesToUpdate.quesResp = newPropQuesResp;

            //************for checkbox update***********//
            console.log("propCheckboxValue 1 ==>>: ", this.propCheckboxValue);
            const someNo = this.propTypeQuesList.some(propQues => propQues.quesResp == 'No');
            this.allNA = this.propTypeQuesList.every(propQues => propQues.quesResp == 'NA');
            const allYesOrNA = this.propTypeQuesList.every(propQues => propQues.quesResp == 'Yes' || propQues.quesResp == 'NA');
            const hasAtLeastOneYes = this.propTypeQuesList.some(propQues => propQues.quesResp == 'Yes');
            console.log("Yes ==>>: ", allYesOrNA && hasAtLeastOneYes);
            console.log("someNo ==>>: ", someNo);
            console.log("allNA 1 ==>>: ", this.allNA);
            if (someNo) {
                this.propCheckboxValue = false;
            }
            else if (this.allNA) {
                this.propCheckboxValue = false;
                this.showToast("Error", "error", "Property Questions: NA cannot be selected in all the questions");
            }
            else if (allYesOrNA && hasAtLeastOneYes) {
                this.propCheckboxValue = true;
            }
        }
    }

    handleUpsert() {
        let recordsToUpsert = [];
        let propertyAsset = {};
        propertyAsset.sobjectType = 'ApplAsset__c';
        propertyAsset.AllPropGnrlNrmsMet__c = this.gnrlCheckboxValue;
        propertyAsset.AllPropSbtypNrmsMet__c = this.propCheckboxValue;
        propertyAsset.Id = this.applicantAssetId;
        recordsToUpsert.push(propertyAsset);
        console.log("genNormQuesList 1==> ", this.genNormQuesList);
        console.log("propTypeQuesList 1==> ", this.propTypeQuesList);

        this.genNormQuesList.forEach(ques => {
            recordsToUpsert.push({
                sobjectType: "PropQuesRespJn__c",
                Ques__c: ques.quesTitle,
                PropQuest__c: ques.quesId,
                Resp__c: ques.quesResp,
                Id: ques.respId,
                PropQuesResp__c: this.propRespId
            });
        });

        this.propTypeQuesList.forEach(ques => {
            recordsToUpsert.push({
                sobjectType: "PropQuesRespJn__c",
                Resp__c: ques.quesResp,
                Ques__c: ques.quesTitle,
                PropQuest__c: ques.quesId,
                Id: ques.respId,
                PropQuesResp__c: this.propRespId,
            });
        });

        upsertMultipleRecord({ params: recordsToUpsert })
            .then(result => {
                console.log('result ===>>>', JSON.stringify(result));
                this.propertyQuestion = result.parentRecord;
                //this.showToast('Success', 'success', 'Property Questions: Saved Successfully.');
            })
            .catch(error => {
                console.log('Error updating the question responses', error);
                this.showToast('Error', 'error', 'Property Questions: Error updating the question responses');
            })

    }

    showToast(title, variant, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
        this.showSpinner = false;
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        if (validate) {
            let isInputCorrect = this.checkReportValidity();
            console.log('Validate Form Questions ==>>', isInputCorrect);
            if (isInputCorrect === true) {
                console.log('handleSave If====', isInputCorrect);
                console.log('allNA 4==>>', this.allNA);
                if (this.allNA) {
                    console.log('allNA 5==>>', this.allNA);
                    this.showToast('Error', 'error', 'Property Questions: NA cannot be selected in all the questions.');
                }
                else {
                    this.handleUpsert();
                }
            }
            else {
                console.log('handleSave Else====', isInputCorrect);
                this.showToast('Error', 'error', 'Property Questions: Please fill all the required fields.');
            }
        } else {
            console.log('HandleSave else####');
            if (!this.allNA) {
                this.handleUpsert();
            }
            else {
                console.log('allNA##==>>', this.allNA);
                this.showToast('Error', 'error', 'Property Questions: NA cannot be selected in all the questions.');
            }
        }
    }


    checkReportValidity() {
        let valid = true;
        this.template.querySelectorAll('c-dynamic-form-filled').forEach(element => {
            if (!element.reportValidity()) {
                valid = false;
            }
        });
        console.log('isValid==>>', valid);
        return valid;
    }

    //method used to check empty object 
    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }
}