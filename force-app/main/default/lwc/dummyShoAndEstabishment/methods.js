import { SCHEMA } from './schema';
export function saveResult(a, b) {
    return a + b;
}
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
export function integratinMsz(appKycId, applicantId) {
    let fieldsOfIntMess = {};
    fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
    fieldsOfIntMess['Name'] = 'Udyam Registration Check'; //serviceName;//'KYC OCR'
    fieldsOfIntMess['BU__c'] = 'HL / STL';
    fieldsOfIntMess['Status__c'] = 'New';
    fieldsOfIntMess['MStatus__c'] = 'Blank';
    fieldsOfIntMess['RefObj__c'] = 'ApplKyc__c';
    fieldsOfIntMess['RefId__c'] = appKycId;
    fieldsOfIntMess['ParentRefObj__c'] = 'Applicant__c';
    fieldsOfIntMess['ParentRefId__c'] = applicantId;
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