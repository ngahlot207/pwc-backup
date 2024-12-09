import { LightningElement, api, track,wire } from 'lwc';

import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataWire from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import getValidationReport from "@salesforce/apex/ValidateRequiredFieldsAndDoc.getValidationReport";
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";

import { CPARoles, CPAClaimRoles } from 'c/globalConstant';

export default class LoginAcceptanceButton extends LightningElement {


    @api recordId;

    @track loginAcceptanceMessage = "Are you sure, You want to complete the Login Acceptance?";
    @track showSpinner = false;
    @track isLoginAcceptance = false;
    connectedCallback() {
        this.isLoginAcceptance = true;
        this.getProduct();
        // this.getValidationReport();
    }

    closeModalCPA() {
        this.isLoginAcceptance = false;
        this.fireCustomEvent(null, null, null);
    }

@track userRole;
    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c=\''+Id+'\''
        }
        @wire(getSobjectDataWire,{params : '$teamHierParam'})
        teamHierHandler({data,error}){
            if(data){
                console.log('DATA IN LOGIN ACCEPT DETAILS :::: #412>>>>',data);
                if(data.parentRecords !== undefined ){
                    this.userRole = data.parentRecords[0].EmpRole__c
                    console.log('DATA IN LOGIN ACCPET DETAILS :::: #415>>>>',this.userRole);
                }
                          
            }
            if(error){
                console.error('ERROR CASE DETAILS:::::::#420',error)
            }
        }
    // getValidationReport() {
    //     this.spinnerEvent(true);
    //     getValidationReport({ loanAppId: this.recordId })
    //         .then((result) => {
    //             console.log('resp of validation  ', JSON.stringify(result));
    //             let positiveResp = true;
    //             result.forEach(res => {
    //                 console.log('res.validated false  ', JSON.stringify(res));
    //                 if (res.validated === false) {
    //                     positiveResp = false;
    //                     let resp = res.applicantName + ' : ' + res.errorMessage;
    //                     // this.showToastMessage("Error", "error", resp);
    //                     this.fireCustomEvent("Error", "error", resp);
    //                 }
    //             })

    //             if (positiveResp) {
    //                 this.changeLoanAppSubstage();
    //                 //this.showToastMessage("Success", "Login Accepted", "success");
    //                 //this.showSpinner = false;
    //                 console.log('resp of validation  Positive ');
    //             } else {
    //                 this.fireCustomEvent("", "", "");
    //             }

    //             // this.showSpinner = false;
    //             console.log('resp of validation   last line ');

    //         })
    //         .catch((err) => {
    //             this.fireCustomEvent("Error", "error", "Error occured in : " + err.body.message);
    //             // this.showToastMessage("Error", "Error occured in getValidationReport   ", "error");
    //             // this.showToastMessage("Error", "error", "Error occured in : " + err.body.message);
    //             console.log(" Error occured in getValidationReport   ", err, err.body.message);
    //             // this.showSpinner = false;
    //             this.spinnerEvent(false);
    //         });
    // }
    getValidationReportMethod() {
        this.showSpinner = true;
        this.spinnerEvent(true);
        // only check  values in fields not document .
        getValidationReport({ loanAppId: this.recordId })
            .then((result) => {
                console.log('resp of validation  ', JSON.stringify(result));
                let positiveResp = true;
                this.showSpinner = false;
                result.forEach(res => {

                    ////

                    if (res.validated === true) {
                        positiveResp = true;
                        if (res.missingSubDocValue) {
                            const subDocList = Object.entries(res.missingSubDocValue).map(([subDocName, subDocValues]) => {
                                return { subDocName, subDocValues };
                            });
                            console.log(subDocList);
                        }



                        // this.showToast("Success", "success", "Validated");
                        //  this.changeSubStage();
                        // this.showSpinner = false;                          
                    } else {
                        let resp = '';
                        if (res.missingDoc === true && res.missingSubDocValue) {
                            const subDocList = Object.entries(res.missingSubDocValue).map(([subDocName, subDocValues]) => {
                                return { subDocName, subDocValues };
                            });

                            let respVal = '';
                            if (subDocList) {
                                subDocList.forEach(element => {
                                    let res = '';
                                    if (element.subDocValues.length > 0) {
                                        res = element.subDocName + ' : ( ' + element.subDocValues.join(' ,') + ') ,';
                                    } else {
                                        res = element.subDocName + ' , ';
                                    }
                                    respVal = respVal + res;
                                });
                            }

                            if (respVal.length >= 2) {
                                // Remove the last two characters using Substring
                                respVal = respVal.substring(0, respVal.length - 2);
                            }


                            console.log('subDocList ', subDocList, JSON.stringify(subDocList));
                            // resp = res.applicantName + ' : ' + res.errorMessage + ' : [ ' + res.missingValue + ' ]';
                            resp = res.applicantName + ' : ' + res.errorMessage + ' : [ ' + respVal + ' ]';
                        } else {
                            resp = res.applicantName + ' : ' + res.errorMessage;
                        }
                        positiveResp = false;
                        //resp = res.applicantName + ' : ' + res.errorMessage;
                        this.fireCustomEvent("Error", "error", resp);
                    }
                    ///




                    // console.log('res.validated false  ', JSON.stringify(res));
                    // if (res.validated === false) {
                    //     positiveResp = false;
                    //     let resp = res.applicantName + ' : ' + res.errorMessage;
                    //     // this.showToastMessage("Error", "error", resp);
                    //     this.fireCustomEvent("Error", "error", resp);
                    // }

                })
                if (positiveResp) {
                    //this.fireCustomEvent("Success", "success", "Integration Initiated Successfully!", false);//LAK-3368
                   if(this.loanStatus !== 'BRE Soft Reject'){
                    this.changeLoanAppSubstage();
                    console.log('resp of validation  Positive ');
                   }else{
                    this.fireCustomEvent("Error", "error", "Loan Application Status is  " + this.loanStatus)
                   }
                   
                    //this.showSpinner = false;
                    
                } else {
                    //// this.fireCustomEvent("", "", "");
                }

                // this.showSpinner = false;
                //console.log('resp of validation   last line ');

            })
            .catch((err) => {
                this.fireCustomEvent("Error", "error", "Error occured in : " + err.body.message);
                // this.showToastMessage("Error", "Error occured in getValidationReport   ", "error");
                // this.showToastMessage("Error", "error", "Error occured in : " + err.body.message);
                console.log(" Error occured in getValidationReport   ", err, err.body.message);
                this.showSpinner = false;
                this.spinnerEvent(false);
            });
    }
    changeLoanAppSubstage() {
        let loanAppFields = {};
        loanAppFields['Id'] = this.recordId;
        //LAK-3393 
        loanAppFields['Stage__c'] = 'DDE';
        if(CPAClaimRoles && CPAClaimRoles.includes(this.userRole)){
            loanAppFields['SubStage__c'] = 'CPA Data Entry';
        }else if(this.userRole === 'VCPA'){
            loanAppFields['SubStage__c'] = 'CPA Vendor Data Entry';
        }       
        loanAppFields['LoginAcceptance__c'] = true;
        let dt = new Date().toISOString().substring(0, 10);
        console.log('current date ISO is===>>>>>>>', dt);
        loanAppFields['LoginAcceptDate__c'] = dt;

        let upsertDataFile = {
            parentRecord: loanAppFields,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertDataFile));

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
            .then(result => {
                this.showSpinner = false;
                //this.spinnerEvent(false);
                this.getProduct();
                this.getApplicantIds();
                //this.fireCustomEvent("Success", "success", "Login Acceptance done Successfully!"); // commnted for LAK-3368
                /* setTimeout(() => { this.fireCustomEvent("Success", "success", "Login Acceptance done Successfully!"); }, 3000);//LAK-3368
                this.showToastMessage('Success', 'Watchout Integration Initiated Successfully!', 'success', 'dismissible');//LAK-3368 */
                //this.showToastMessage("Success", "Trackwizz Integration Initiated Successfully!", "success", 'dismissible');//LAK-3368
                //this.showToastMessage("Success", "Hunter Integration Initiated Successfully!", "success", 'dismissible');//LAK-3368
                // this.showToastMessage("Success", "Files Accepted Successfully!", "success");
            }).catch(error => {
                this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message)

                console.log(error);
                // this.showSpinner = false;
                // this.spinnerEvent(false);
            })

    }

    @track loanProductType;
    @track loanStatus;  
    getProduct(){
        let parameterLoanApplication = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Product__c','Status__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: parameterLoanApplication })
            .then((result) => {
                
                console.log('result in login acceptance button::::254', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanProductType = result.parentRecords[0].Product__c ? result.parentRecords[0].Product__c : null;
                    this.loanStatus = result.parentRecords[0].Status__c;

                    console.log('this.productType ', this.loanProductType,'status:::',this.loanStatus);
                    
                }              
            })
            .catch((error) => {

                console.log("error occured in product type", error);

            });

    }

    @track intRecords = [];
    @track appIds = [];
    @track appData;
    @track appIDsforUCID = [];
    getApplicantIds() {
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'IntegrationStatus__c', 'UCID__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\''
        }
        console.log('test####');
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                this.appData = result;
                console.log('result is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    // this.appRecordsData = result.parentRecords;
                    result.parentRecords.forEach(item => {
                        this.appIds.push(item.Id);
                        if (!item.UCID__c) {
                            this.appIDsforUCID.push(item.Id);
                        }
                    })

                    this.createIntegrationMsgWatchOut(this.appIds);
                    console.log('this.appRecordsData after', JSON.stringify(this.appIds));
                }
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
    }

    createIntegrationMsgWatchOut(appIds) {
        appIds.forEach(item => {
            let fieldsWo = {};
            fieldsWo['sobjectType'] = 'IntgMsg__c';
            fieldsWo['Name'] = 'ScreeningWachout'; //serviceName;//'KYC OCR'
            fieldsWo['BU__c'] = 'HL / STL';
            fieldsWo['IsActive__c'] = true;
            fieldsWo['Svc__c'] = 'ScreeningWachout'; //serviceName;
            fieldsWo['ExecType__c'] = 'Async';
            fieldsWo['Status__c'] = 'New';
            fieldsWo['Mresp__c'] = 'Blank';
            fieldsWo['Outbound__c'] = true;
            fieldsWo['Trigger_Platform_Event__c'] = false;
            fieldsWo['RefObj__c'] = 'Applicant__c';
            fieldsWo['RefId__c'] = item;
            fieldsWo['ParentRefObj__c'] = "LoanAppl__c";
            fieldsWo['ParentRefId__c'] = this.recordId;
            this.intRecords.push(fieldsWo);
        })
        this.createIntMsgForTra();
        // this.upsertIntRecord(this.intRecords);
    }

    createIntMsgForTra() {
        let arra = ['Risk API', 'Screening API'];
        for (let i = 0; i < 2; i++) {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = arra[i]; //serviceName;//'KYC OCR'
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = arra[i]; //serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.recordId;
            fields['RefObj__c'] = '';
            fields['RefId__c'] = '';
            this.intRecords.push(fields);
        }
        this.createIntMsgForHun();
        //  this.upsertIntRecord(this.intRecords);
    }

    createIntMsgForHun() {
        let fields = {};
        if(this.loanProductType != 'Business Loan' && this.loanProductType != 'Personal Loan'){
        fields['sobjectType'] = 'IntgMsg__c';
        fields['Name'] = 'Hunter Token';
        fields['BU__c'] = 'HL / STL';
        fields['IsActive__c'] = true;
        fields['Svc__c'] = 'Hunter Token';
        fields['ExecType__c'] = 'Async';
        fields['Status__c'] = 'New';
        fields['Mresp__c'] = 'Blank';
        fields['Outbound__c'] = true;
        fields['Trigger_Platform_Event__c'] = false;
        fields['ParentRefObj__c'] = "LoanAppl__c";
        fields['ParentRefId__c'] = this.recordId;
        fields['RefObj__c'] = 'LoanAppl__c';
        fields['RefId__c'] = this.recordId;
        this.intRecords.push(fields);
        console.log('this.intRecords ', JSON.stringify(this.intRecords));
        }

        this.createIntForUCID();
        //this.upsertIntRecord(this.intRecords);
    }
    createIntForUCID() {
        if (this.appIDsforUCID.length > 0) {
            this.appIDsforUCID.forEach(item => {
                let fieldsWo = {};
                fieldsWo['sobjectType'] = 'IntgMsg__c';
                fieldsWo['Name'] = 'UCIC API Token'; //serviceName;//'KYC OCR'
                fieldsWo['BU__c'] = 'HL / STL';
                fieldsWo['IsActive__c'] = true;
                fieldsWo['Svc__c'] = 'Dedupe API Token'; //serviceName;
                fieldsWo['ExecType__c'] = 'Async';
                fieldsWo['Status__c'] = 'New';
                fieldsWo['Mresp__c'] = 'Blank';
                fieldsWo['Outbound__c'] = true;
                fieldsWo['Trigger_Platform_Event__c'] = false;
                fieldsWo['RefObj__c'] = 'Applicant__c';
                fieldsWo['RefId__c'] = item;
                fieldsWo['ParentRefObj__c'] = "LoanAppl__c";
                fieldsWo['ParentRefId__c'] = this.recordId;
                this.intRecords.push(fieldsWo);
            })
        }
        this.upsertIntRecord(this.intRecords);
    }
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('###upsertMultipleRecord###');
                setTimeout(() => { this.fireCustomEvent("Success", "success", "Login Acceptance done Successfully!"); }, 3000);//LAK-3368
                this.fireCustomEvent("Watchout:", "success", "Watchout Integration Initiated Successfully!");//LAK-3368
                this.fireCustomEvent("Trackwizz:", "success", "Trackwizz Integration Initiated Successfully!");//LAK-3368
                
                if(this.loanProductType != 'Business Loan' && this.loanProductType != 'Personal Loan'){
                this.fireCustomEvent("Hunter:", "success", "Hunter Integration Initiated Successfully!");//LAK-3368
                }

                if (this.appIDsforUCID.length > 0) {
                    this.fireCustomEvent("Hunter:", "success", "UCID Creation Initiated Successfully");
                }

                this.intRecords = []
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message, false);
            });
    }


    showToastMessage(title1, message1, variant1, mode1) {
        const evt = new ShowToastEvent({
            title: title1,
            message: message1,
            variant: variant1,
            mode: mode1
        });
        this.dispatchEvent(evt);
    }

    spinnerEvent(val) {
        const selectEvent = new CustomEvent('spinner', {
            detail: val
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
    fireCustomEvent(title, vart, msg) {
        const selectEvent = new CustomEvent('click', {
            detail: { title: title, variant: vart, message: msg, from: "LoginAcceptance" }

        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}