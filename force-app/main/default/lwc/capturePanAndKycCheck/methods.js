import { SCHEMA } from './schema';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import updateApplicantAddress from '@salesforce/apex/GSPGSTResponseProcessor.updateApplicantAddress';

export function createIntegrationMsg(appKycId, ddId, serviceName) {
    const fields = {};
    fields[SCHEMA.NAME.fieldApiName] = serviceName; //serviceName;//'KYC OCR'
    fields[SCHEMA.BU.fieldApiName] = 'HL / STL';
    fields[SCHEMA.IS_ACTIVE.fieldApiName] = true;
    fields[SCHEMA.SVC.fieldApiName] = serviceName; //serviceName;
    fields[SCHEMA.EXUC_TYPE.fieldApiName] = 'Async';
    fields[SCHEMA.STATUS.fieldApiName] = 'New';
    fields[SCHEMA.DOC_API.fieldApiName] = true;
    fields[SCHEMA.OUTBOUND.fieldApiName] = true;
    fields[SCHEMA.TRIGGER_PLATFORM_EVENT.fieldApiName] = true;
    fields[SCHEMA.REF_OBJ.fieldApiName] = 'DocDtl__c';
    fields[SCHEMA.REF_ID.fieldApiName] = ddId;
    fields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = "ApplKyc__c";
    fields[SCHEMA.PARENT_REF_ID.fieldApiName] = appKycId;
    console.log('from helper methods ', fields);
    return fields;
}

// import INTG_MSG from "@salesforce/schema/IntgMsg__c";
// import NAME from "@salesforce/schema/IntgMsg__c.Name";
// import REF_ID from "@salesforce/schema/IntgMsg__c.RefId__c";
// import BU from "@salesforce/schema/IntgMsg__c.BU__c";
// import IS_ACTIVE from "@salesforce/schema/IntgMsg__c.IsActive__c";
// import SVC from "@salesforce/schema/IntgMsg__c.Svc__c";
// import EXUC_TYPE from "@salesforce/schema/IntgMsg__c.ExecType__c";
// import STATUS from "@salesforce/schema/IntgMsg__c.Status__c";
// import REF_OBJ from "@salesforce/schema/IntgMsg__c.RefObj__c";
// import DOC_API from "@salesforce/schema/IntgMsg__c.DocApi__c";
// import OUTBOUND from "@salesforce/schema/IntgMsg__c.Outbound__c";
// import PARENT_REF_ID from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
// import PARENT_REF_OBJ from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";
// import TRIGGER_PLATFORM_EVENT from "@salesforce/schema/IntgMsg__c.Trigger_Platform_Event__c";



export function integratinMsz(appKycId, applicantId) {
    let fieldsOfIntMess = {};
    fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
    fieldsOfIntMess['Name'] = 'Udyam Registration Check';
    fieldsOfIntMess['IsActive__c'] = true;
    fieldsOfIntMess['Svc__c'] = 'Udyam Registration Check'; //serviceName;//'KYC OCR'
    fieldsOfIntMess['BU__c'] = 'HL / STL';
    fieldsOfIntMess['Status__c'] = 'New';
    fieldsOfIntMess['MStatus__c'] = 'Blank';
    fieldsOfIntMess['RefObj__c'] = 'ApplKyc__c';
    fieldsOfIntMess['RefId__c'] = appKycId;
    fieldsOfIntMess['ParentRefObj__c'] = 'Applicant__c';
    fieldsOfIntMess['ParentRefId__c'] = applicantId;
    fieldsOfIntMess['Trigger_Platform_Event__c'] = true;
    return fieldsOfIntMess;
}
export function retServideName(docName) {
    let serviceName = '';
    if (docName === 'PAN') {
        serviceName = 'Pan Validation';
    }
    else if (docName === 'Aadhaar') {
        serviceName = 'SFDC Aadhar XML Verification API';
    }
    else if (docName === 'Passport') {
        serviceName = 'Passport Verification';
    }
    else if (docName === 'Driving license') {
        serviceName = 'DL Authentication';
    }
    else if (docName === 'Voter ID') {
        serviceName = 'Voterid Verification';
    }
    return serviceName;
}
export function createPANIngMsgFields(appKycId, ddId) {
    let serviceName = 'Pan Validation';
    const ingMsgFields = {};
    ingMsgFields[SCHEMA.REF_OBJ.fieldApiName] = 'DocDtl__c';
    ingMsgFields[SCHEMA.REF_ID.fieldApiName] = ddId;
    ingMsgFields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = "ApplKyc__c";
    ingMsgFields[SCHEMA.PARENT_REF_ID.fieldApiName] = appKycId;
    ingMsgFields[SCHEMA.BU.fieldApiName] = 'HL / STL';
    ingMsgFields[SCHEMA.IS_ACTIVE.fieldApiName] = true;
    ingMsgFields[SCHEMA.EXUC_TYPE.fieldApiName] = 'Async';
    ingMsgFields[SCHEMA.STATUS.fieldApiName] = 'New';
    ingMsgFields[SCHEMA.DOC_API.fieldApiName] = false;
    ingMsgFields[SCHEMA.OUTBOUND.fieldApiName] = true;
    ingMsgFields[SCHEMA.TRIGGER_PLATFORM_EVENT.fieldApiName] = true;
    ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
    ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
    return ingMsgFields;
}
export function checkPanValidity(panNo, constitutionIs) {
    let panStatus = panNo.substring(3, 4).toUpperCase();
    if ((panStatus == 'P' && (constitutionIs == 'INDIVIDUAL' || constitutionIs == 'PROPERITORSHIP')) ||
        (panStatus == 'C' && (constitutionIs == 'PRIVATE LIMITED COMPANY' || constitutionIs == 'PUBLIC LIMITED COMPANY')) ||
        (panStatus == 'H' && constitutionIs == 'HUF') ||
        (panStatus == 'A' && (constitutionIs == 'ASSOCIATION OF PERSONS' || constitutionIs == 'SOCIETY')) ||
        (panStatus == 'F' && (constitutionIs == 'LIMITED LIABILITY PARTNERSHIP' || constitutionIs == 'PARTNERSHIP')) ||
        (panStatus == 'T' && constitutionIs == 'TRUST')
    ) {
        return true;
    } else {
        return false;
    }

}

export async function getGstDetails(applicantId) {
    let params = {
        ParentObjectName: 'ApplGST__c',
        parentObjFields: ['Id', 'Applicant__c', 'GSTIN__c', 'GSTIN_Status__c', 'LegalNameOfBusiness_GST_Certificate__c', 'Main_GSTIN__c', 'TradeName_GST_Certificate__c', 'AddrLine1__c', 'AddrLine2__c', 'CityId__c', 'City__c', 'Index__c', 'PinId__c', 'Pincode__c', 'StateId__c', 'State__c', 'HouseNo__c', 'Locality__c', 'Landmark__c', 'Invalid__c', 'NameMatchAPIStatus__c', 'GSTAuthenticationStatus__c', 'GSTAuthenticationErrorMessage__c', 'FetchFromSource__c'],
        queryCriteria: ' where Applicant__c = \'' + applicantId + '\''
    };
    try {
        
        const result = await getSobjectDataNonCacheable({ params: params });
        console.log("ApplGST__c present  ", result);

        if (result.parentRecords && result.parentRecords.length > 0) {
            console.log("ApplGST__c is there   ", result.parentRecords);
            let gstDataList = [];
            result.parentRecords.forEach(element => {
                if (element.GSTIN__c) {
                    let gstdata = { label: element.GSTIN__c, value: element.Id };
                    gstDataList.push(gstdata);
                }
            });

            return { gstOpt: gstDataList, gstRecords: result.parentRecords };
            //  return result.parentRecords; // Return the relevant data
        } else {
            return []; // Return an empty array or appropriate value if no records are found
        }
    } catch (error) {
        console.log("get applicantKyc error ", error);
        throw error; // Rethrow the error to be handled by the caller
    }
}
export function integratinMszForGST(gstSelected, applicantId, gstId, appkyc) {
    if (gstId) {
        let fieldsOfIntMess = {};
        fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
        fieldsOfIntMess['Name'] = 'GSP GST Authentication';
        fieldsOfIntMess['IsActive__c'] = true;
        fieldsOfIntMess['Svc__c'] = 'GSP GST Authentication';
        fieldsOfIntMess['BU__c'] = 'HL / STL';
        fieldsOfIntMess['Status__c'] = 'New';
        fieldsOfIntMess['MStatus__c'] = 'Blank';
        fieldsOfIntMess['RefObj__c'] = 'ApplGST__c';
        fieldsOfIntMess['RefId__c'] = gstId;//  applGST.Id;
        fieldsOfIntMess['ParentRefObj__c'] = 'Applicant__c';
        fieldsOfIntMess['ParentRefId__c'] = applicantId;
        fieldsOfIntMess['Trigger_Platform_Event__c'] = true;
        return fieldsOfIntMess;
    } else {
        let applGst = {};
        applGst['sobjectType'] = 'ApplGST__c';
        applGst['GSTIN__c'] = gstSelected;
        applGst['Applicant__c'] = applicantId;
        let newArray = [];
        if (applGst) {
            newArray.push(applGst);
        }
        if (newArray) {

            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('upsertMultipleRecord for ApplicantGST ', result);
                    let fieldsOfIntMess = {};
                    fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                    fieldsOfIntMess['Name'] = 'GSP GST Authentication';
                    fieldsOfIntMess['IsActive__c'] = true;
                    fieldsOfIntMess['Svc__c'] = 'GSP GST Authentication';
                    fieldsOfIntMess['BU__c'] = 'HL / STL';
                    fieldsOfIntMess['Status__c'] = 'New';
                    fieldsOfIntMess['MStatus__c'] = 'Blank';
                    fieldsOfIntMess['RefObj__c'] = 'ApplGST__c';
                    fieldsOfIntMess['RefId__c'] = result.Id;//  applGST.Id;
                    fieldsOfIntMess['ParentRefObj__c'] = 'Applicant__c';
                    fieldsOfIntMess['ParentRefId__c'] = applicantId;
                    fieldsOfIntMess['Trigger_Platform_Event__c'] = true;
                    let newArray1 = [];
                    if (fieldsOfIntMess) {
                        newArray1.push(fieldsOfIntMess);
                    }
                    if (newArray1) {

                        upsertMultipleRecord({ params: newArray1 })
                            .then((result) => {
                                console.log('upsertMultipleRecord for integration msz created ', result);
                            })
                            .catch((error) => {
                                console.log('Error In upserting  ntegration msz created Details is ', error);
                            });
                    }
                })
                .catch((error) => {

                    console.log('Error In upserting  Applicantgst Details is ', error);
                });
        }

    }



}

export function updateApplicantKYC(applicantId, gstRecord, appKycId, docDtlId) {//his.applicantId, this.selectedGstRec, this.appKycId
    //AddrLine1__c	AddrLine2__c	CityId__c	City__c	Index__c	PinId__c	Pincode__c	StateId__c	State__c	HouseNo__c	Locality__c	Landmark__c	
    if (applicantId && gstRecord && appKycId) {
        console.log('updateApplicantKYC :: ', applicantId, gstRecord, appKycId, docDtlId);

        let appKyc = {};
        appKyc['Id'] = appKycId;
        appKyc['sobjectType'] = "ApplKyc__c";
        appKyc['GSTIN__c'] = gstRecord && gstRecord.GSTIN__c ? gstRecord.GSTIN__c : '';
        appKyc['Name__c'] = gstRecord && gstRecord.LegalNameOfBusiness_GST_Certificate__c ? gstRecord.LegalNameOfBusiness_GST_Certificate__c : ''; //
        appKyc['Validation_Error_Message__c'] = gstRecord && gstRecord.GSTAuthenticationErrorMessage__c ? gstRecord.GSTAuthenticationErrorMessage__c : '';
        appKyc['ValidationStatus__c'] = gstRecord && gstRecord.GSTAuthenticationStatus__c ? gstRecord.GSTAuthenticationStatus__c : '';
        appKyc['AddrLine1__c'] = gstRecord && gstRecord.AddrLine1__c ? gstRecord.AddrLine1__c : '';
        appKyc['AddrLine2__c'] = gstRecord && gstRecord.AddrLine2__c ? gstRecord.AddrLine2__c : '';
        appKyc['Landmark__c'] = gstRecord && gstRecord.Landmark__c ? gstRecord.Landmark__c : '';
        appKyc['Locality__c'] = gstRecord && gstRecord.Locality__c ? gstRecord.Locality__c : '';
        appKyc['HouseNo__c'] = gstRecord && gstRecord.HouseNo__c ? gstRecord.HouseNo__c : '';
        appKyc['Country__c'] = gstRecord && gstRecord.Country__c ? gstRecord.Country__c : '';
        appKyc['Pincode__c'] = gstRecord && gstRecord.Pincode__c ? gstRecord.Pincode__c : '';
        appKyc['City__c'] = gstRecord && gstRecord.City__c ? gstRecord.City__c : '';
        // appKyc['CityId__c'] = gstRecord && gstRecord.CityId__c ? gstRecord.CityId__c : '';
        appKyc['State__c'] = gstRecord && gstRecord.State__c ? gstRecord.State__c : '';
        // appKyc['StateId__c'] = gstRecord && gstRecord.StateId__c ? gstRecord.StateId__c : '';

        let newArray = [];
        if (appKyc) {
            newArray.push(appKyc);
        }
        if (newArray) {

            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('upsertMultipleRecord for updateApplicantKYC', result);
                    updateApplicantAddress({ docDtlId: docDtlId })
                        .then((result) => {
                            console.log('upsertMultipleRecord for updateApplicantAddress', result);
                        })
                        .catch((error) => {

                            console.log('Error In upserting  updateApplicantAddress  ', error);
                        });

                })
                .catch((error) => {

                    console.log('Error In upserting  updateApplicantKYC Details is ', error);
                });
        }
    } else {
        console.log('record missing in call of updateApplicantKYC');
    }



}
export async function updateAppKycCrtIntMsz(applicantId, gstNo, appKycId, docDetId) {//his.applicantId, this.selectedGstRec, this.appKycId
    try {
        if (applicantId && gstNo && appKycId) {
            let appKyc = {};
            appKyc['Id'] = appKycId;
            appKyc['sobjectType'] = "ApplKyc__c";
            appKyc['GSTIN__c'] = gstNo;

            let newArray = [];
            if (appKyc) {
                newArray.push(appKyc);
            }
            if (newArray) {

                upsertMultipleRecord({ params: newArray })
                    .then((result) => {
                        console.log('upsertMultipleRecord for ApplicantAddress', result);

                        if (result) {
                            let fieldsOfIntMess = {};
                            fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                            fieldsOfIntMess['Name'] = 'GSP GST Authentication';
                            fieldsOfIntMess['IsActive__c'] = true;
                            fieldsOfIntMess['Svc__c'] = 'GSP GST Authentication';
                            fieldsOfIntMess['BU__c'] = 'HL / STL';
                            fieldsOfIntMess['Status__c'] = 'New';
                            fieldsOfIntMess['RefObj__c'] = 'DocDtl__c';
                            fieldsOfIntMess['RefId__c'] = docDetId;
                            fieldsOfIntMess['ParentRefObj__c'] = 'ApplKyc__c';
                            fieldsOfIntMess['ParentRefId__c'] = appKycId;
                            fieldsOfIntMess['Trigger_Platform_Event__c'] = true;

                            fieldsOfIntMess['Outbound__c'] = true;
                            fieldsOfIntMess['DocApi__c'] = false;

                            let newArray1 = [];
                            if (fieldsOfIntMess) {
                                newArray1.push(fieldsOfIntMess);
                            }
                            if (newArray1) {

                                upsertMultipleRecord({ params: newArray1 })
                                    .then((result) => {

                                        console.log('upsertMultipleRecord for integration msz created ', result);
                                        //showToast("Success ", "success", 'GST Validation Initiated ');
                                    })
                                    .catch((error) => {
                                        console.log('Error In upserting  ntegration msz created Details is ', error);
                                    });
                            }
                        }



                    })
                    .catch((error) => {

                        console.log('Error In upserting  ApplicantAddress Details is ', error);
                    });
            }
        }


    } catch (error) {
        console.log("get applicantKyc error ", error);
        throw error; // Rethrow the error to be handled by the caller
    }
}