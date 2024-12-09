export function getLoanAppealParam(loanAppId) {
    let params = {
        ParentObjectName: 'LoanAppeal__c',
        parentObjFields: ['Id', 'Name', 'CreatedDate', 'RecordType.name', 'Recommender__r.Name', 'Approver__r.Name', 'ApproverLevel__c', 'Status__c', 'LoanAppl__c', 'Comments__c', 'OwnerName__c', 'LAN__c', 'Recommender__c', 'Approver__c', 'Decision__c'],
        queryCriteria: ' where LoanAppl__c = \'' + loanAppId + '\' AND RecordType.name = \'' + 'Roi Pf Correction' + '\''
    }
    return params;
}