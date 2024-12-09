import { LightningElement, api, wire, track } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import retrieveCV from '@salesforce/apex/CollateralVisitController.retrieveCV'
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';

import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
// Custom labels
import CvResponse_ReqFields_ErrorMessage from '@salesforce/label/c.CvResponse_ReqFields_ErrorMessage';
import CvResponse_Response_SuccessMessage from '@salesforce/label/c.CvResponse_Response_SuccessMessage';
import CvResponse_Upsert_ErrorMessage from '@salesforce/label/c.CvResponse_Upsert_ErrorMessage';

export default class CVResponse extends LightningElement {
    label = {
        CvResponse_ReqFields_ErrorMessage,
        CvResponse_Response_SuccessMessage,
        CvResponse_Upsert_ErrorMessage

    }
    @api hasEditAccess;
    @track submitModelMessage = ' You wont be able to edit the details after submit. Are you sure you want to Submit ? ';
    @track isModalOpen = false; @track _caseId;
    @api get caseId() {
        return this._caseId;
    }
    set caseId(value) {
        this._caseId = value;
        this.setAttribute("caseId", value);

        // this.handleRecordIdChange(value);
    }
    get isReadOnly() {
        if (this.hasEditAccess) {
            return false;
        } else {
            return true;
        }
    }
    @api cvResp;
    @api cvDetail;
    @api layoutSize;
    @api applicantId;
    currentUserName;
    @track cvResponseToUpdate = [];
    @track cvStatus = {};

    @track cvResponceList;
    // @track visitDate = this.todaysDate;
    saveSubscription = null;
    @wire(MessageContext)
    MessageContext;
    // todaysDate;
    visitDate;

    // get todaysDate() {
    //     const today = new Date();
    //     return today.toISOString();
    // }
    // @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
    // currentUserInfo({ error, data }) {
    //     if (data) {
    //         console.log('currentUserInfo ', data);
    //         console.table(data);
    //         this.currentUserName = data.fields.Name.value;
    //     } else if (error) {
    //         this.error = error;
    //     }
    // }
    getCaseData() {
        let paramsCase = {
            ParentObjectName: 'Case',
            parentObjFields: ['Id', 'Assigned_To__c', 'Assigned_To__r.Name', 'Loan_Application__c', 'Loan_Application__r.Stage__c', 'Loan_Application__r.SubStage__c', 'SchDate__c', 'IsCompleted__c'],
            queryCriteria: ' where Id = \'' + this._caseId + '\' '
        }
        getSobjectDat({ params: paramsCase })
            .then((result) => {
                console.log('Case data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.caseRecord = { ...result.parentRecords[0] };
                    if (this.caseRecord.Loan_Application__r.Stage__c !== 'UnderWriting' && this.caseRecord.Loan_Application__r.SubStage__c !== 'Credit Appraisal') {
                        this.hasEditAccess = false;
                    }
                    if (this.caseRecord.Assigned_To__c !== this.userId) {
                        this.hasEditAccess = false;
                    }
                    if (this.caseRecord.Assigned_To__c == this.userId) {
                        this.hasEditAccess = true;
                    }
                    console.log('this.caseRecord-->', JSON.stringify(this.caseRecord));
                    this.currentUserName = this.caseRecord.Assigned_To__r.Name;
                    this.visitDate = this.caseRecord.SchDate__c;

                }


            })
            .catch((error) => {
                console.log('Error In getting Case Data ', error);
            });
    }
    completed = true;
    @track showFooterButtons = true;
    getcvCloseCases() {
        let paramsCase = {
            ParentObjectName: 'Case',
            parentObjFields: ['Id'],
            queryCriteria: ' where Id = \'' + this._caseId + '\' AND IsCompleted__c = true'
        }
        getSobjectDat({ params: paramsCase })
            .then((result) => {
                console.log('Closed CV Case data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('this.showFooterButtons', this.showFooterButtons);
                    console.log('this.submitModelMessage', this.submitModelMessage);
                    this.hasEditAccess = false;
                    this.showFooterButtons = false;
                    this.submitModelMessage = 'This CV already Submitted! ';

                }
            })
            .catch((error) => {
                console.log('Error In getting CV closed Case Data ', error);
            });
    }
    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.employeeRole = result.parentRecords[0].EmpRole__c;
                    console.log('this.employeeRole is ', this.employeeRole);
                    if (this.employeeRole == 'UW' || this.employeeRole == 'ACM' || this.employeeRole == 'RCM' || this.employeeRole == 'ZCM' || this.employeeRole == 'NCM' || this.employeeRole == 'CH') {
                        this.retvalue = true;
                    }
                    else {

                        this.hasEditAccess = false;


                    }
                }
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }
    @track userId = Id;

    connectedCallback() {
        // if(this.hasEditAccess = false){
        //                 this.isReadOnly = true;
        // }
        this.getUserRole();
        this.getcvCloseCases();
        this.getCaseData();
        this.sunscribeToSaveMessageChannel();
        console.log('caseId', this._caseId, 'cvResp', this.cvResp, 'cvDetail', this.cvDetail);

        console.log('lastt', this.cvResp);

        // this.pdTypeId = updatedData;
        retrieveCV({ cvId: this._caseId })
            .then((res) => {
                let resp;
                if (res.length > 0) {
                    console.log('cv response==', JSON.stringify(res));
                    resp = res.filter(item => item.sectionTitle != null)
                    console.log("retrieveCV resp  ", resp);
                    resp = this.updateQuesDisplay(resp);
                    console.log("retrieveCV resp  ", resp);
                    this.cvResponceList = resp;
                    console.log('updatedData  ', JSON.stringify(this.cvResponceList));
                }
            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in geting getAllCases " + err.message);
                console.log(" retrieveCV  error===", err);
            });

        //this.cvResponceList = this.cvResp;
        // this.getCaseData();
    }

    updateQuesDisplay(allQues) {
        const self = this;
        let quesList = [];
        allQues.forEach(function (q) {
            quesList = [...quesList, ...q.questions];
        })
        console.log('quesList==', quesList);
        allQues.forEach(function (q) {
            q.questions.forEach(function (cvq) {
                if (cvq.criteriaList) {
                    var displayVal = self.evaluateQuestions(cvq.criteriaList, quesList);
                    cvq.displayQues = displayVal;
                } else {
                    cvq.displayQues = true;
                }
                if (cvq.quesTitle === 'Date and time of Visit' && !cvq.quesResp && cvq.quesResp == null) {
                    const quesToEval = q.questions.find(ques => ques.quesTitle === 'Photograph of Property Visited');
                    if (quesToEval && quesToEval.quesResp) {
                        let dateVal = JSON.parse(quesToEval.quesResp);
                        console.log('quesToEval is :: ', dateVal[0].createdDate);
                        cvq.quesResp = dateVal[0].createdDate;
                    }

                }
            })
        })
        return allQues;
    }

    unsubscribeMC() {
        unsubscribe(this.saveSubscription);
        this.saveSubscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeMC();
    }

    evaluateQuestions(questionToEvaluate, quesList) {
        let val = true;
        questionToEvaluate.forEach(function (q) {
            // let criteria = JSON.parse(q.Evaluation_Criteria__c);
            // if (criteria) {
            //     console.log("value ", criteria.value);
            //     console.log("logic ", criteria.logic);
            //     console.log("operator ", criteria.operator);
            // }

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
        });
        console.log("val==", val);
        return val;
    }

    // @track cvResponseToUpdate = [];//[{ objectName: '', records: [{ Id: '' }] }];
    fromChildComp(event) {
        try {
            let val = JSON.parse(JSON.stringify(event.detail));
            let allQues = this.cvResponceList;
            let quesToUpd;
            if (val.respType !== "File") {

                // if (val.pdRespId != undefined && val.pdRespId.quesTitle === 'Property Visit Final Status') {
                //     let upObj = {
                //         Id: this._caseId,
                //         Property_Visit_Final_Status__c: val.respVal,
                //         IsCompleted__c : true
                //     }
                //     this.cvStatus = upObj;
                //     console.log('this.cvStatus==>', this.cvStatus);
                // }
                if (val.pdRespId.overrideCnfg) {
                    console.log("overrideCnfg", val.pdRespId.overrideCnfg);
                    let overrideCnfg = JSON.parse(val.pdRespId.overrideCnfg);
                    let ovIndex = this.cvResponseToUpdate.findIndex(obj => obj.Id === overrideCnfg.recordId);
                    let oVal = val.respVal;
                    if (overrideCnfg.field === 'Addr_of_prop_veri_as_per_Tit__c' || overrideCnfg.field === 'Bound_are_prop_dem_n_ide__c') {
                        oVal = oVal === 'Yes' ? 'Y' : 'N';
                    }
                    if (ovIndex >= 0) {
                        this.cvResponseToUpdate[ovIndex]['sobjectType'] = overrideCnfg.objectName;
                        this.cvResponseToUpdate[ovIndex][overrideCnfg.field] = oVal;

                    } else {
                        let ovr = { "Id": overrideCnfg.recordId, "sobjectType": overrideCnfg.objectName };
                        ovr[overrideCnfg.field] = oVal;
                        this.cvResponseToUpdate.push(ovr);
                    }
                }
                allQues.forEach(function (q) {
                    if (!quesToUpd) {
                        quesToUpd = q.questions.find(ques => ques.quesId === val.pdRespId.quesId);
                        //quesToUpd.quesResp = val.respVal;
                    }
                })
                quesToUpd.quesResp = val.respVal;
                this.cvResponceList = [];
                this.cvResponceList = this.updateQuesDisplay(allQues);
                console.log("from child  To Case Compoennt updated val  ", JSON.stringify(event.detail));
                if (this.cvResponseToUpdate.length === 0) {
                    let tData = {};
                    tData['Id'] = val.pdRespId.respId;
                    tData['Resp__c'] = val.respVal;
                    this.cvResponseToUpdate.push(tData);
                }
                else {
                    let index = this.cvResponseToUpdate.findIndex(obj => obj.Id === val.pdRespId.respId);
                    if (index >= 0) {
                        this.cvResponseToUpdate[index]['Id'] = val.pdRespId.respId;
                        this.cvResponseToUpdate[index]['Resp__c'] = val.respVal;
                    } else {
                        let tData1 = {};
                        tData1['Id'] = val.pdRespId.respId;
                        tData1['Resp__c'] = val.respVal;
                        this.cvResponseToUpdate.push(tData1);
                    }

                }
            }

            // {"pdRespId":{"respId":"a1iC4000000CePvIAK","displaySeq":1,"isEditable":false,"isReqMobile":true,"isReqPortal":true,"quesId":"a17C400000Fb1pQIAR","quesTitle":"Product","respType":"Text"},"respVal":"asda"}
            // }
            console.log("from child  To Case Compoennt updated cvResponseToUpdate  ", JSON.stringify(this.cvResponseToUpdate));
            //LAK-4556  ----------------------------------------------------

            if (val.respType === "File") {
                // console.log("File type ", val.pdQuestion);
                let quesList = [];
                let allQues = JSON.parse(JSON.stringify(this.cvResponceList));
                // allQues.forEach(function (q) {
                //     quesList = [...quesList, ...q.questions];
                // })
                console.log('quesList==', allQues);
                let updateVal = null;
                let quesForFile = allQues.find(ques => ques.sectionTitle === 'PROPERTY DETAILS');
                quesForFile.questions.forEach(q => {
                    if (q.quesTitle === "Date and time of Visit") {
                        q.quesResp = new Date().toISOString();

                        console.log('new date', new Date().toISOString());
                        updateVal = q;
                    }
                });
                if (updateVal) {
                    this.cvResponceList = [];
                    this.cvResponceList = allQues;
                    let cData = {};
                    cData['Id'] = updateVal.respId;
                    cData['Resp__c'] = updateVal.quesResp;
                    cData['sobjectType'] = 'Resp__c';
                    this.cvResponseToUpdate.push(cData);

                    console.log('quesList updated ==', allQues);
                }
            }


        } catch (error) {
            console.log('error', error);
        }

        //--------------------------------------------------------
    }
    handleInputChange(event) {
        let name = event.target.name;
        value = event.target.value;
        console.log("handleInputChange in Case Compoennt updated val   ", name, '   vall ::: ', value);
        // let param = { cvvId: name, respVal: value }
        // const selectEvent = new CustomEvent('passtoparent', {
        //     detail: param
        // });
        // this.dispatchEvent(selectEvent);

    }

    sunscribeToSaveMessageChannel() {
        this.saveSubscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveLms(values)
        );

    }
    handleSaveLms(values) {
        console.log('values to save through Lms  ', JSON.stringify(values));

        if (values.validateBeforeSave) {
            this.isModalOpen = true;
        }
        else {
            this.handleSave(values.validateBeforeSave)
        }

    }
    removeDuplicatesAndInvalidIds(records) {// LAK-7861

        // Create a Map to store unique records by Id
        let idObjectMap = new Map();
        let recWithoutId = [];
        records.forEach(element => {
            if (element.Id && element.Id != null) {
                idObjectMap.set(element.Id, element);
            } else {
                recWithoutId.push(element);
            }
        });
        let newArr = [...recWithoutId, ...Array.from(idObjectMap.values())]

        // Convert the Map values back to an array
        return newArr;
    }
    handleSave(validate) {

        this.cvResponseToUpdate.forEach(element => {
            if (element.Id && element.Id.length > 18) {
                element.Id = null;
            }

        });
        let uniqueValidRecordsArray = this.removeDuplicatesAndInvalidIds(this.cvResponseToUpdate);

        console.log('before upsert ', JSON.stringify(uniqueValidRecordsArray));
        if (validate) {
            let valid = this.checkReportValidity();
            if (!valid) {
                this.isModalOpen = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.label.CvResponse_ReqFields_ErrorMessage,
                        variant: "error",
                        mode: "sticky"
                    })
                );
                return;

            } else {
                if (uniqueValidRecordsArray) {

                    upsertMultipleRecord({ params: uniqueValidRecordsArray })
                        .then(result => {
                            console.log('resultresultresultresultresult', JSON.stringify(result));
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: "CV submitted Succesfully",
                                    variant: "success",
                                    mode: "sticky"
                                })
                            );

                            this.isModalOpen = false;
                            this.showFooterButtons = false;
                            let obje = {
                                Id: this._caseId,
                                IsCompleted__c: true,
                                CVStatus__c: 'Completed',
                                NameofCredOfficer__c: this.currentUserName,
                                DateofVisit__c: this.visitDate,

                            }
                            this.upsertCase(obje);
                            const refreshCaseTabs = new CustomEvent('refreshcasetabs', {
                                detail: obje.CVStatus__c
                            });
                            this.dispatchEvent(refreshCaseTabs);
                            // location.reload();
                            if (obje.CVStatus__c == 'Completed') {
                                this.hasEditAccess = false;
                            }
                            this.dispatchEvent(new RefreshEvent());


                        }).catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Error",
                                    message: this.label.CvResponse_Upsert_ErrorMessage,
                                    variant: "error",
                                    mode: "sticky"
                                })
                            );
                            console.log('Error in upserting ', JSON.stringify(error));
                            this.isModalOpen = false;

                        })
                }
            }
        }
        else {
            if (!uniqueValidRecordsArray || uniqueValidRecordsArray.length == 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'No data to update',
                        variant: "error",
                        mode: "sticky"
                    })
                );
                return;
            }
            if (uniqueValidRecordsArray) {
                upsertMultipleRecord({ params: uniqueValidRecordsArray })
                    .then(result => {
                        console.log('resultresultresultresultresult', JSON.stringify(result));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: this.label.CvResponse_Response_SuccessMessage,
                                variant: "success",
                                mode: "sticky"
                            })
                        );

                        let obje = {
                            Id: this._caseId,
                            NameofCredOfficer__c: this.currentUserName,
                            DateofVisit__c: this.todaysDate,
                            CVStatus__c: 'In Progress',
                        }
                        this.upsertCase(obje);
                        this.dispatchEvent(new RefreshEvent());

                    }).catch(error => {
                        console.log('Error in upserting ', JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error",
                                message: this.label.CvResponse_Upsert_ErrorMessage,
                                variant: "error",
                                mode: "sticky"
                            })
                        );

                    })
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
        return valid;
    }

    upsertCase(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertMultipleRecord({ params: newArr })
                .then((result) => {
                    console.log('resultprinted ');
                })
                .catch((error) => {
                    console.log('error in upserting Case ', JSON.stringify(error));

                });
        }
    }
    handleSubmitCV(values) {

        this.handleSave(true);
    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
}