public class CaseWrapper implements Comparable {
    public Case caseRecord;
    
    public CaseWrapper(Case caseRecord) {
        this.caseRecord = caseRecord;
    }

    public Integer compareTo(Object other) {
        CaseWrapper otherWrapper = (CaseWrapper) other;
        // Compare dates in descending order
        if (this.caseRecord.Date_of_Report__c > otherWrapper.caseRecord.Date_of_Report__c) {
            return -1;
        } else if (this.caseRecord.Date_of_Report__c < otherWrapper.caseRecord.Date_of_Report__c) {
            return 1;
        } else {
            return 0;
        }
    }
}