import { LightningElement, api, wire, track } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import retrievePD from "@salesforce/apex/PDController.retrievePD";
import savePdData from "@salesforce/apex/PDController.savePdData";
import savePdMultiselect from "@salesforce/apex/PDController.savePdMultiselect";
// Custom labels
import PdComponent_Permission_ErrorMessage from '@salesforce/label/c.PdComponent_Permission_ErrorMessage';
import PdComponent_ReqFields_ErrorMessage from '@salesforce/label/c.PdComponent_ReqFields_ErrorMessage';
import PdComponent_Response_SuccessMessage from '@salesforce/label/c.PdComponent_Response_SuccessMessage';
import PdComponent_Upsert_ErrorMessage from '@salesforce/label/c.PdComponent_Upsert_ErrorMessage';

export default class PdComponent extends LightningElement {
    customLabel = {
        PdComponent_Permission_ErrorMessage,
        PdComponent_ReqFields_ErrorMessage,
        PdComponent_Response_SuccessMessage,
        PdComponent_Upsert_ErrorMessage

    }
    @api pdTypeId;
    @api pdType;
    @api pDResp;
    @api pdDetail;
    @api hasEditAccess;
    @api currentTabValue;
    @api layoutSize;
    @api applicantId;
    @api loanAppId;

    @track pdResponceList;
    @track pdDoneDate = this.todaysDate;
    @track tableDataToUpdate = [];//[{ objectName: '', records: [{ Id: '' }] }];
    @track overrideData = [];
    @track nameOfEmpInPd;

    @track isModalOpen = false;
    @track submitModelMessage = ' You wont be able to edit the details after submit. Are you sure you want to Submit ? ';

    @track disableMode = false;
    @track showSpinner = false;


    subscription = null;
    @wire(MessageContext)
    MessageContext;
    get isReadOnly() {
        if (this.hasEditAccess) {
            return false;
        } else {
            return true;
        }
    }

    get todaysDate() {
        const today = new Date();
        return today.toISOString();
    }
    connectedCallback() {

        this.sunscribeToMessageChannel();
        console.log('pdTypeId', this.pdTypeId, 'pdType ', this.pdType, 'pdDetail ', 'pDResp', this.pDResp, 'pdDetail', this.pdDetail, 'layoutSize', this.layoutSize, 'hasEditAccess', this.hasEditAccess);
        if (this.pdTypeId) {
            this.getResp();
        }
        //this.uploadedDocuments.find((doc) => doc.docDetName == "PAN")
        let pd = this.pdDetail.find((doc) => doc.Id == this.pdTypeId);
        if (pd) {
            console.log('pd', JSON.stringify(pd));
            // this.nameOfEmpInPd = pd.AsgnTo__r.Name;
        }


    }
    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        console.log('disconnectedCallback  called');
        this.unsubscribeMC();

    }
    getResp() {
        retrievePD({ pdId: this.pdTypeId })
            .then((res) => {
                if (res) {
                    console.log("tableDataToUpdate initiate  ", this.tableDataToUpdate);
                    res = this.updateQuesDisplay(res);
                    this.pdResponceList = JSON.parse(JSON.stringify(res));
                    console.log("pdResponceList resp  ", res, this.pdResponceList,);
                    console.log("pdResponceList resp  ", JSON.stringify(this.pdResponceList));
                    console.log("tableDataToUpdate after   ", this.tableDataToUpdate);
                }
            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in geting getAllPd " + err.message);
                console.log(" retrievePD  error===", err);
            });

    }

    updateQuesDisplay(allQues) {
        const self = this;
        let quesList = [];
        allQues.forEach(function (q) {
            quesList = [...quesList, ...q.questions];
        })
        console.log('quesList==', quesList);
        allQues.forEach(function (q) {
            let displaySec = false;
            q.questions.forEach(function (pdq) {
                if (pdq.criteriaList) {
                    var criteriaJsn = self.evaluateQuestions(pdq.criteriaList, quesList);
                    pdq.displayQues = criteriaJsn.value;
                    if (criteriaJsn.options && pdq.respType === 'Picklist') {
                        pdq.possibleOptions = criteriaJsn.options;
                    }
                    else if (criteriaJsn.options) {
                        pdq.quesResp = criteriaJsn.options[0];
                    }
                } else {
                    pdq.displayQues = true;
                }
                if (pdq.displayQues) {
                    displaySec = true;
                }
                if (pdq.responseObj && pdq.respId && pdq.responseObj == 'PDResp__c') {


                    if (self.tableDataToUpdate.length > 0) {

                        let index = self.tableDataToUpdate.findIndex(obj => obj.Id === pdq.respId);
                        if (index >= 0) {
                            self.tableDataToUpdate[index]['Id'] = pdq.respId;
                            self.tableDataToUpdate[index]['Resp__c'] = pdq.quesResp ? pdq.quesResp : '';
                            self.tableDataToUpdate[index]['sobjectType'] = 'PDResp__c';// new

                        } else {
                            let tData1 = {};
                            tData1['Id'] = pdq.respId;
                            tData1['Resp__c'] = pdq.quesResp ? pdq.quesResp : '';
                            tData1['sobjectType'] = 'PDResp__c';//
                            self.tableDataToUpdate.push(tData1);
                        }
                    }
                    else {
                        let tData1 = {};
                        tData1['Id'] = pdq.respId;
                        tData1['Resp__c'] = pdq.quesResp ? pdq.quesResp : '';
                        tData1['sobjectType'] = 'PDResp__c';//
                        self.tableDataToUpdate.push(tData1);
                    }


                }
            })
            q.displaySection = displaySec;
        })
        return allQues;
    }

    evaluateQuestions(questionToEvaluate, quesList) {
        let val = true;
        let opts;
        questionToEvaluate.forEach(function (q) {
            const quesToEval = quesList.find(ques => ques.quesId === q.evalQues);
            console.log('quesToEval==', quesToEval);
            if (quesToEval && q.criVal) {
                let answer = q.criVal.includes(quesToEval.quesResp)
                    ? true
                    : false;
                if (val) {
                    val = val && answer;
                } else {
                    val = answer;
                }
            }
            if (quesToEval && q.dependValCri) {
                let dependentValMap = JSON.parse(q.dependValCri);
                console.log('dependentValMap==', dependentValMap);
                opts = dependentValMap[quesToEval.quesResp];
            }
        });
        console.log('options==', opts);
        console.log("val==", val);
        return { value: val, options: opts };
    }
    @track multiSelectVal = [];
    @track multiSelectValDeleteOlder = false;
    fromChildComp(event) {
        console.log("from child  To Pd Compoennt updated val  ", JSON.stringify(event.detail));
        let val = JSON.parse(JSON.stringify(event.detail));
        // {"respType":"Table","objectName":"ApplAsset__c","tablevalue":{"fieldName":"Remarks__c","value":"3232323","Id":"a0zC40000005rH3IAI0"}}
        if (val.respType === 'Table') {
            let index = this.tableDataToUpdate.findIndex(obj => obj.Id === val.tablevalue.Id);
            if (index >= 0) {
                this.tableDataToUpdate[index]['sobjectType'] = val.objectName;
                this.tableDataToUpdate[index][val.tablevalue.fieldName] = val.tablevalue.value;
            }
            else {
                let tData1 = {};
                tData1['Id'] = val.tablevalue.Id;
                tData1['sobjectType'] = val.objectName;
                tData1[val.tablevalue.fieldName] = val.tablevalue.value;
                if (val.recordTypeId) {
                    tData1['RecordTypeId'] = val.recordTypeId;
                }
                this.tableDataToUpdate.push(tData1);
            }
        }
        else if (val.respType === "Picklist Multiselect") {
            console.log("from child  To Pd Compoennt updated val PM ", JSON.stringify(event.detail));
            let resp = JSON.parse(JSON.stringify(event.detail));
            console.log(resp, resp.val);

            this.multiSelectVal = [];
            this.multiSelectValDeleteOlder = true;
            for (let i = 0; i < resp.val.length; i++) {
                let data = { PD__c: this.pdTypeId, User__c: '', Assigned_Date__c: this.todaysDate, sobjectType: resp.objName };
                let valToAdd = resp.val[i];
                console.log("Picklist Multiselect", valToAdd, JSON.stringify(this.tableDataToUpdate));
                data.User__c = valToAdd.value
                // if (valToAdd.recordId == null) { }
                // this.tableDataToUpdate.push(data);
                this.multiSelectVal.push(data);
                // if (this.tableDataToUpdate.length > 0) {
                //     this.tableDataToUpdate.forEach(obj => {
                //         if (obj.sobjectType === resp.objName) {
                //             if (obj.User__c === valToAdd.value) {
                //             } else {
                //                 this.tableDataToUpdate.push(data);
                //             }
                //         }
                //     });
                // } else {
                //     this.tableDataToUpdate.push(data);
                // }

                // let selectedRec = this.tableDataToUpdate.find(obj => obj.sobjectType === resp.objName && obj.User__c === element.value);
                //  let index = this.tableDataToUpdate.findIndex(obj => obj.sobjectType === resp.objName && obj.User__c === element.value);
                // console.log("Picklist Multiselect index", index, JSON.stringify(this.tableDataToUpdate[index]));
                //if (index >= 0) {
                // if (selectedRec) {
                //     console.log("Picklist Multiselect not  added", element.label, element.value);
                // } else {
                //     console.log("Picklist Multiselect added", element.label, element.value);
                //     this.tableDataToUpdate.push(data);
                // }
                // if (selectedRec) {
                //     console.log("Picklist Multiselect not  added", element.label, element.value);
                // } else {
                //     console.log("Picklist Multiselect added", element.label, element.value);
                //     this.tableDataToUpdate.push(data);
                // }
                //this.tableDataToUpdate.push(data);

            }
            console.log("updated picklist multiselect", JSON.stringify(this.tableDataToUpdate));
        }
        else if (val.respType === "File" || val.respType === "Video") {
            console.log("File type ", val.pdQuestion);
            let quesList = [];
            let allQues = JSON.parse(JSON.stringify(this.pdResponceList));
            console.log('quesList==', allQues);
            let updateVal = null;
            let quesForFile = allQues.find(ques => ques.sectionTitle === 'Photographs');
            quesForFile.questions.forEach(q => {
                if (q.quesTitle === "Date and time of Visit" && q.quesResp == null) {
                    q.quesResp = new Date().toISOString();

                    console.log('new date', new Date().toISOString());
                    updateVal = q;
                }
            });
            this.pdResponceList = [];
            this.pdResponceList = allQues;
            if (updateVal != null && updateVal.respId) {
                let index = this.tableDataToUpdate.findIndex(obj => obj.Id === updateVal.respId);
                if (index >= 0) {
                    //  this.tableDataToUpdate[index]['Id'] = updateVal.respId;
                    this.tableDataToUpdate[index]['Resp__c'] = updateVal.quesResp;
                    //  this.tableDataToUpdate[index]['sobjectType'] = 'PDResp__c';
                } else {
                    let tData1 = {};
                    tData1['Id'] = updateVal.respId;
                    tData1['Resp__c'] = updateVal.quesResp;
                    tData1['sobjectType'] = 'PDResp__c';//
                    this.tableDataToUpdate.push(tData1);
                }
                // /......
                // this.pdResponceList = [];
                // this.pdResponceList = allQues;
                // let tData = {};
                // tData['Id'] = updateVal.respId;
                // tData['Resp__c'] = updateVal.quesResp;
                // tData['sobjectType'] = 'PDResp__c';// new
                // this.tableDataToUpdate.push(tData);

                // console.log('quesList updated ==', allQues);
            }
        } else {
            if (val.pdRespId.respType === 'Reference') {
                console.log("from child  To Pd Compoennt updated val Ref ", JSON.stringify(event.detail));
                let index = this.tableDataToUpdate.findIndex(obj => obj.Id === val.pdRespId.quesResp);
                if (index >= 0) {
                    this.tableDataToUpdate[index]['sobjectType'] = val.respVal.objectName;
                    this.tableDataToUpdate[index][val.respVal.field] = val.respVal.respVal;
                } else {
                    let data = {};
                    data[val.respVal.field] = val.respVal.respVal;
                    data['Id'] = val.pdRespId.quesResp;
                    data['sobjectType'] = val.respVal.objectName;
                    this.tableDataToUpdate.push(data);
                }
            } else {
                let allQues = this.pdResponceList;
                let quesToUpd;
                allQues.forEach(function (q) {
                    if (!quesToUpd) {
                        quesToUpd = q.questions.find(ques => ques.quesId === val.pdRespId.quesId);
                        //quesToUpd.quesResp = val.respVal;
                    }
                })
                quesToUpd.quesResp = val.respVal;
                this.pdResponceList = [];
                this.pdResponceList = this.updateQuesDisplay(allQues);
                console.log("from child  To Pd Compoennt updated val else ", JSON.stringify(event.detail));
                if (val.pdRespId.overrideCnfg) {
                    console.log("overrideCnfg", val.pdRespId.overrideCnfg);
                    let overrideCnfg = JSON.parse(val.pdRespId.overrideCnfg);
                    let ovIndex = this.tableDataToUpdate.findIndex(obj => obj.Id === overrideCnfg.recordId);
                    if (ovIndex >= 0) {
                        this.tableDataToUpdate[ovIndex]['sobjectType'] = overrideCnfg.objectName;
                        this.tableDataToUpdate[ovIndex][overrideCnfg.field] = val.respVal;

                    } else {
                        let ovr = { "Id": overrideCnfg.recordId, "sobjectType": overrideCnfg.objectName };
                        ovr[overrideCnfg.field] = val.respVal;
                        this.tableDataToUpdate.push(ovr);
                    }
                }

                let index = this.tableDataToUpdate.findIndex(obj => obj.Id === val.pdRespId.respId);
                if (index >= 0) {
                    this.tableDataToUpdate[index]['Id'] = val.pdRespId.respId;
                    this.tableDataToUpdate[index]['Resp__c'] = val.respVal;
                    this.tableDataToUpdate[index]['sobjectType'] = 'PDResp__c';// new

                } else {
                    let tData1 = {};
                    tData1['Id'] = val.pdRespId.respId;
                    tData1['Resp__c'] = val.respVal;
                    tData1['sobjectType'] = 'PDResp__c';//
                    this.tableDataToUpdate.push(tData1);
                }
            }
            console.log("from child  To Pd Compoennt updated tableDataToUpdate  ", JSON.stringify(this.tableDataToUpdate));
            console.log("from child  To Pd Compoennt updated overrideData  ", JSON.stringify(this.overrideData));
        }
        console.log("pd data to update  ", JSON.stringify(this.tableDataToUpdate));
    }
    handleInputChange(event) {
        let name = event.target.name;
        value = event.target.value;
        console.log("handleInputChange in Pd Compoennt updated val   ", name, '   vall ::: ', value);

    }
    handleLookupFieldChange(event) {
        console.log("handleLookupFieldChange in Pd Compoennt updated val ", JSON.stringify(event.detail));
    }

    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }
    handleSaveThroughLms(values) {
        console.log('in handleSaveThroughLms ', this.currentTabValue, '  :: ', this.pdTypeId);
        if (this.currentTabValue == this.pdTypeId) {
            console.log('values to save through Lms  ', this.loanAppId, this.disableMode, this.hasEditAccess, JSON.stringify(values));
            //  this.handleSave();


            if (values.recordId === this.loanAppId) {
                if (this.hasEditAccess === false || this.disableMode === true) {
                    this.showToastMessage('Error updating record', this.customLabel.PdComponent_Permission_ErrorMessage, 'error');

                } else {
                    this.handleSave(values.validateBeforeSave);
                }
            }
        }

    }
    checkReportValidity() {
        let isValid = true
        this.template.querySelectorAll('c-dynamic-form-filled').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-dynamic-form-filled');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        // if(!this.checkValidityLookup()){
        //     isValid = false;
        // }

        return isValid;
    }
    handleSave(validate) {
        console.log('save');

        this.tableDataToUpdate.forEach(element => {
            if (element.Id && element.Id.length != 18) {
                element.Id = null;
            }

        });
        // this.overrideData.forEach(element => {

        //     this.tableDataToUpdate.push(element);

        // });



        if (validate) {
            this.isModalOpen = true;

            console.log('asking permission to Submit', this.isModalOpen);

        } else {
            //In  save as draft
            console.log('Save As Draft clicked');
            let index = this.tableDataToUpdate.findIndex(obj => obj.Id === this.pdTypeId);
            if (index >= 0) {
                this.tableDataToUpdate[index]['sobjectType'] = "PD__c";
                this.tableDataToUpdate[index]['PDStatus__c'] = "In Progress";
            }
            else {
                let pdStatusVal = {
                    "Id": this.pdTypeId,
                    "sobjectType": "PD__c",
                    "PDStatus__c": "In Progress",
                }
                this.tableDataToUpdate.push(pdStatusVal);
            }
            this.updateRec();
        }
    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }

    handleSubmitPd() {
        console.log('respOfVAlidity started');
        let respOfVAlidity = this.checkReportValidity();
        console.log('respOfVAlidity done status is ', respOfVAlidity);

        if (respOfVAlidity) {

            let index = this.tableDataToUpdate.findIndex(obj => obj.Id === this.pdTypeId);
            if (index >= 0) {
                this.tableDataToUpdate[index]['sobjectType'] = "PD__c";
                this.tableDataToUpdate[index]['CmpltDt__c'] = new Date().toISOString();
                this.tableDataToUpdate[index]['IsCompleted__c'] = true;
                this.tableDataToUpdate[index]['PDStatus__c'] = "Completed";
            }
            else {
                let pdStatusVal = {
                    "Id": this.pdTypeId,
                    "sobjectType": "PD__c",
                    "PDStatus__c": "Completed",
                    "IsCompleted__c": true,
                    "CmpltDt__c": new Date().toISOString()
                }

                this.tableDataToUpdate.push(pdStatusVal);
            }

            this.updateRec();

            //  setTimeout(() => { this.updateRec(); }, 1000);

        } else {
            this.showToastMessage('Error', this.customLabel.PdComponent_ReqFields_ErrorMessage, 'error');

            this.isModalOpen = false;
        }
    }
    @track dataToSave = [];
    updateRec() {
        console.log('before upsert ', JSON.stringify(this.tableDataToUpdate));
        // upsertMultipleRecord({ params: this.tableDataToUpdate })
        //     .then(result => {
        //         console.log('result ', JSON.stringify(result));
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: "Success",
        //                 message: this.customLabel.PdComponent_Response_SuccessMessage,
        //                 variant: "success",
        //             })
        //         );
        //     })
        //     .catch(error => {
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: "Error",
        //                 message: this.customLabel.PdComponent_Upsert_ErrorMessage,
        //                 variant: "error",
        //             })
        //         );
        //         console.log('Error in upserting ', JSON.stringify(error));
        //     })

        let collectedData = [];
        collectedData = this.tableDataToUpdate;
        collectedData.forEach(ele => {
            if (this.dataToSave.length == 0) {
                let obj = { objectType: '', records: [] };
                obj.objectType = ele.sobjectType;
                obj.records.push(ele);
                console.log('Final Data to save first  ', obj);
                this.dataToSave.push(obj);
            } else {
                let commonSobj = this.dataToSave.find((doc) => doc.objectType == ele.sobjectType);
                if (commonSobj) {

                    commonSobj.records.push(ele);
                } else {
                    let obj = { objectType: '', records: [] };
                    obj.objectType = ele.sobjectType;
                    obj.records.push(ele);
                    console.log('Final Data to save first  ', obj);
                    this.dataToSave.push(obj);
                }
            }
        });
        console.log('Final Data to save modified ', this.pdTypeId, JSON.stringify(this.dataToSave));
        this.showSpinner = true;

        savePdMultiselect({ pdId: this.pdTypeId, deleteOlder: this.multiSelectValDeleteOlder, multiselectVal: this.multiSelectVal })
            .then(result => {
                this.multiSelectVal = []
                this.multiSelectValDeleteOlder = false;
                console.log('Success in savePdMultiselect ');
            })
            .catch(error => {
                console.log('Error in savePdMultiselect ', JSON.stringify(error));
            })
        savePdData({ pdId: this.pdTypeId, pdRecToSave: this.dataToSave })
            .then(result => {

                this.dataToSave = [];
                this.tableDataToUpdate = [];
                this.showToastMessage('Success', this.customLabel.PdComponent_Response_SuccessMessage, 'success');

                console.log('result from savePdData', JSON.stringify(result));
                this.passToParent();
                this.showSpinner = false;
                this.isModalOpen = false;
            })
            .catch(error => {

                this.dataToSave = [];
                if (error.body.message) {
                    this.showToastMessage('Error', error.body.message, 'error');

                } else {
                    this.showToastMessage('Error', this.customLabel.PdComponent_Upsert_ErrorMessage, 'error');

                }

                console.log('Error in savePdData ', JSON.stringify(error));
                this.showSpinner = false;
                this.isModalOpen = false;
            })
        // console.log('updated to save save ', this.tableDataToUpdate, JSON.stringify(this.tableDataToUpdate));
    }
    passToParent() {
        this.pdResponceList = [];
        this.getResp();
        console.log('from passToParent  in pd Component');
        const selectEvent = new CustomEvent('passtoparent', {
            detail: 'ReloadPd'
        });
        this.dispatchEvent(selectEvent);
    }
    showToastMessage(title, message, varient) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: varient,
                mode: 'sticky'
            })
        );
    }
}