/** 
* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 04-Oct-2023
* ********************************************************
*/


public without sharing class RBICheck implements TriggerAction.AfterInsert {
    
  
    public static void afterInsert(List<ApplicantEmployment__c> newList) {
        createIndustry(newList);
    }
    
    public static void createIndustry(list<ApplicantEmployment__c> newList){
        set<id> AppEmpIds = new set<id>();
        set<id> LoanAppId = new set<id>();
        map<id,Applicant__c> NonIndividualCal = new map<id,Applicant__c>(); 
        map<id,decimal> NonIndividualCalIncome = new map<id,decimal>();
        map<id,Applicant__c> IndividualCal = new map<id,Applicant__c>();
        map<id,decimal> IndividualCalIncome = new map<id,decimal>();
        map<id,Applicant__c> OtherCal = new map<id,Applicant__c>();
        map<id,decimal> OtherCalIncome = new map<id,decimal>();
        list<Applicant__c> FinalRBI =new list<Applicant__c>();
        list<LoanAppl__c> LoanFinalRBI =new list<LoanAppl__c>();
        list<Applicant__c> MSMEUpdateforOthers = new list<Applicant__c>();
         set<Id> ApplicantId = new set<Id>();
        set<Id> AppIdsOther = new set<Id>();
        list<Applicant__c> MSMEUpdate =new list<Applicant__c>();
        
        
        system.debug('newlist of appemp'+newList );
        //fetching Applicant Id from applicant employment record
        for(ApplicantEmployment__c a :newList){
            if(a.MainRBIIndustry__c<>null){
                AppEmpIds.add(a.LoanApplicant__c);                
            }  
            
            // msme and msme type
            if(a.MSME_Industry_selection__c!='OTHERS'){              
                ApplicantId.add(a.LoanApplicant__c);               
               
            }
            if(a.MSME_Industry_selection__c=='OTHERS'){              
                AppIdsOther.add(a.LoanApplicant__c);        
               
            }
            
        }
        
        //fetching Loan application id from applicant records
        for (Applicant__c appId : [select LoanAppln__c from Applicant__c where id in: AppEmpIds] ){
            LoanAppId.add(appId.LoanAppln__c);
        }
        system.debug('LoanAppId '+LoanAppId );
        //fetching all related applicant records using Loan application id
        for (Applicant__c app : [select id,LatestyearforwhichITRisavailable__c,ApplType__c, CustProfile__c, Constitution__c, FName__c,CompanyName__c,TotalIncome__c ,(select id,DesignationText__c, IndustryType__r.Name, SubIndustry__r.Name, MainRBIIndustry__c, IndustryForRBIReporting__r.Name from Applicant_Employments__r)from Applicant__c  where LoanAppln__c in: LoanAppId  and Type_of_Borrower__c='Financial' ] ){
            if(app!=null){
            if(app.Constitution__c<> 'INDIVIDUAL'){
                if(app.LatestyearforwhichITRisavailable__c!=null && app.LatestyearforwhichITRisavailable__c!='ITR Not Available'){
                    decimal PatValue =getApplicantPAT(app.id,app.LatestyearforwhichITRisavailable__c);
                    
                    decimal TotalValue=PatValue+(app.TotalIncome__c!=null?app.TotalIncome__c:0);
                    NonIndividualCalIncome.put(app.id,TotalValue);
                    
                }else{
                    NonIndividualCalIncome.put(app.id,app.TotalIncome__c);
                }
                NonIndividualCal.put(app.id,app); 
               
               
                
            }
            if(app.Constitution__c== 'INDIVIDUAL'){
                    if(app.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' ||app.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' ){
                        if(app.LatestyearforwhichITRisavailable__c!=null && app.LatestyearforwhichITRisavailable__c!='ITR Not Available'){
                        decimal PatValue =getApplicantPAT(app.id,app.LatestyearforwhichITRisavailable__c);
                        decimal TotalValue=PatValue+(app.TotalIncome__c!=null?app.TotalIncome__c:0);
                        IndividualCalIncome.put(app.id,TotalValue);
                        
                        }else{
                            IndividualCalIncome.put(app.id,app.TotalIncome__c);
                        }
                    IndividualCal.put(app.id,app);
                    
                }
                else{
                    //OtherCalIncome
                    OtherCal.put(app.id,app);
                    if(app.LatestyearforwhichITRisavailable__c!=null && app.LatestyearforwhichITRisavailable__c!='ITR Not Available'){
                        decimal PatValue =getApplicantPAT(app.id,app.LatestyearforwhichITRisavailable__c);
                        decimal TotalValue=PatValue+(app.TotalIncome__c!=null?app.TotalIncome__c:0);
                        OtherCalIncome.put(app.id,TotalValue);
                        
                        }else{
                            OtherCalIncome.put(app.id,app.TotalIncome__c);
                        }
                    
                }
                    
            }  
              system.debug('app' +app);      
            
        }
        }
      
        
        if(!NonIndividualCalIncome.isEmpty()){
            
            //calculating highest income value
            Id highestId;
			Decimal maxValue = 0;
			for (Id recordId : NonIndividualCalIncome.keySet()) {
                if (NonIndividualCalIncome.get(recordId) > maxValue) {
                    maxValue = NonIndividualCalIncome.get(recordId);
                    highestId = recordId;
                }
        	}
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c ,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id =:highestId ]){
               system.debug('income.Applicant_Employments__r'+income);
                if(income.Applicant_Employments__r.size()>0 ){
                    income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
                    LoanAppl__c l = new LoanAppl__c();
                    l.id=income.LoanAppln__c;
                    l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                    LoanFinalRBI.add(l);  
                }
                            
                
            }
        }
        
        if(NonIndividualCalIncome.isEmpty() && !IndividualCalIncome.isEmpty()){
            //calculating highest income value
            Id highestId;
			Decimal maxValue = 0;
			for (Id recordId : IndividualCalIncome.keySet()) {
                if (IndividualCalIncome.get(recordId) > maxValue) {
                    maxValue = IndividualCalIncome.get(recordId);
                    highestId = recordId;
                }
        	}
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c ,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id=:highestId ]){
                system.debug('income.Applicant_Employments__r'+income);
                if(income.Applicant_Employments__r.size()>0){                   
                    income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
                    LoanAppl__c l = new LoanAppl__c();
                    l.id=income.LoanAppln__c;
                    l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                    LoanFinalRBI.add(l);
                }
                
            }
        }
        
        if(NonIndividualCalIncome.isEmpty() && IndividualCalIncome.isEmpty() && !OtherCalIncome.isEmpty()){
            //calculating highest income value
            Id highestId;
			Decimal maxValue = 0;
			for (Id recordId : OtherCalIncome.keySet()) {
                if (OtherCalIncome.get(recordId) > maxValue) {
                    maxValue = OtherCalIncome.get(recordId);
                    highestId = recordId;
                }
        	}
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c ,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id =:highestId ]){
                system.debug('income.Applicant_Employments__r'+income);
                if(income.Applicant_Employments__r.size()>0){
                    income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
                    LoanAppl__c l = new LoanAppl__c();
                    l.id=income.LoanAppln__c;
                    l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                    LoanFinalRBI.add(l);
                }
               
                
            }            
                
        }
        
        //msme and msme type for !others
         for (Applicant__c AInd : [select id,MSME__c,MSME_Type__c,Investment_in_Plant_and_Machinery__c,Annual_Turnover__c,(select id,MSME_Industry_selection__c	 from Applicant_Employments__r)from Applicant__c  where Id in: ApplicantId ] ){
             Applicant__c l = new Applicant__c();
                l.id=AInd.Id;
                l.MSME__c='No';
        		l.MSME_Type__c = 'Not Applicable';
                MSMEUpdateforOthers.add(l);
         }
         for (Applicant__c AInd : [select id,MSME__c,MSME_Type__c,Investment_in_Plant_and_Machinery__c,Annual_Turnover__c,(select id,MSME_Industry_selection__c	 from Applicant_Employments__r)from Applicant__c  where Id in: AppIdsOther ] ){
             Applicant__c l = new Applicant__c();
                l.id=AInd.Id;
             
                l.MSME__c='';
        		l.MSME_Type__c = '';
                MSMEUpdate.add(l);
         }
        
        
        if(LoanFinalRBI.size()>0){
            system.debug('LoanFinalRBI'+LoanFinalRBI);
        update LoanFinalRBI;
        }
        
         if(MSMEUpdateforOthers.size()>0){
        update MSMEUpdateforOthers;
        }
        
        if(MSMEUpdate.size()>0){
             update MSMEUpdate;
                         system.debug('inside update.MSMEUpdateforOthers'+MSMEUpdateforOthers);

      
              
        }
        
        
        
        	
    }
    
    public static Decimal getApplicantPAT(Id applicantId, String latestYear) {
        Decimal patValue = 0;
        
        // Query Applicant_Financial_Summary__c based on conditions
        List<Applicant_Financial_Summary__c> financialSummaries = [SELECT Pat__c 
                                                                    FROM Applicant_Financial_Summary__c 
                                                                    WHERE Applicant_Financial__c != null 
                                                                    AND Applicant_Financial__r.Loan_Applicant__c = :applicantId 
                                                                    AND Applicant_Financial__r.RecordTypeId!=null
                                                                    AND Applicant_Financial__r.RecordType.DeveloperName = 'Profit_Loss' 
                                                                    AND Financial_Year__c = :latestYear];
        
        // Check if any records are returned
        if (!financialSummaries.isEmpty()) {
            patValue = financialSummaries[0].Pat__c;
        }
        system.debug('patValue'+patValue);
        return patValue;
    }
}