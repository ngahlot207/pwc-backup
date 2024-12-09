public class DisbursementComparator implements Comparator<Disbursement__c> {
    public Integer compare(Disbursement__c a, Disbursement__c b) {
        if (a.Disbur_No__c == b.Disbur_No__c) {
            return 0;
        } else if (a.Disbur_No__c > b.Disbur_No__c) {
            return 1;
        } else {
            return -1;
        }
    }
}