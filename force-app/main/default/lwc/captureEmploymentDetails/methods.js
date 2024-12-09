export function createIntMesgEpfo(applicantid){
    let fieldsOfIntMess = {};
    fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
    fieldsOfIntMess['Name'] = 'EPF UAN Lookup';
    fieldsOfIntMess['IsActive__c'] = true;
    fieldsOfIntMess['Svc__c'] = 'EPF UAN Lookup'; 
    fieldsOfIntMess['BU__c'] = 'HL / STL';
    fieldsOfIntMess['Status__c'] = 'New';
    fieldsOfIntMess['MStatus__c'] = 'Blank';
    fieldsOfIntMess['RefObj__c'] = 'Applicant__c';
    fieldsOfIntMess['RefId__c'] = applicantId;
    return fieldsOfIntMess;
}