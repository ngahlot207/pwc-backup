public class EmploymentDetailsController {
    
    @AuraEnabled
    public static List<Employer__c> getEmployers() {
        return [Select Id, Name from Employer__c];
    }
    
    @AuraEnabled
    public static List<Industry__c> getIndustries() {
        return [Select Id, Name from Industry__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SubIndustry__c> getSubIndustries(String industryId){
        return [Select Id,Name from SubIndustry__c where Industry__c=:industryId];
    }
    
    @AuraEnabled
    public static Applicant__c getApplicant(String applicantId) {
        return [Select Id,CustProfile__c,Constitution__c,LoanAppln__c from Applicant__c Where Id=:applicantId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<RBI_ReportingIndustry__c> getRBIReportingIndustry(String industryId, String subIndustryId) {
        return [Select Id, Name from RBI_ReportingIndustry__c Where Industry__c=:industryId And SubIndustry__c=:subIndustryId];
    }
}