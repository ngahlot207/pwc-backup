/** 
* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 05-OCT-2023
* ********************************************************
*/


public without sharing class updateTotalAmountConstitution implements TriggerAction.AfterUpdate {
    
    public static void afterUpdate(List<Applicant__c> newList, List<Applicant__c> oldList) {
        updateRules(newList,oldList);
        
    }
    public static Void updateRules(List<Applicant__c> newList, List<Applicant__c> oldList){
        Map<Id, Applicant__c> AppMap = new Map<Id, Applicant__c>(oldList);
        //list<Applicant__c> LoanFinalRBI =new list<Applicant__c>();
        map<id,Applicant__c> NonIndividualCal = new map<id,Applicant__c>();   
        map<id,Applicant__c> IndividualCal = new map<id,Applicant__c>();
        map<id,Applicant__c> OtherCal = new map<id,Applicant__c>();
        list<Applicant__c> FinalRBI =new list<Applicant__c>();
        list<LoanAppl__c> LoanFinalRBI =new list<LoanAppl__c>();
        set<id> LoanAppId = new set<id>();
        set<id> AppEmpIds = new set<id>();
       
        //fetching appln id
        for(Applicant__c a :newList){
            if((a.TotalIncome__c!=AppMap.get(a.Id).TotalIncome__c) || (a.Constitution__c!=AppMap.get(a.Id).Constitution__c)
               || (a.ApplType__c!=AppMap.get(a.Id).ApplType__c)  || (a.Type_of_Borrower__c!=AppMap.get(a.Id).Type_of_Borrower__c)) {
                AppEmpIds.add(a.id);                
            } 
            
            }
        system.debug('AppEmpIds'+AppEmpIds);
        //fetching Loan application id from applicant records
        for (Applicant__c appId : [select LoanAppln__c from Applicant__c where id in: AppEmpIds] ){
            LoanAppId.add(appId.LoanAppln__c);
        }
        
        
        //fetching all related applicant records using Loan application id
        for (Applicant__c app : [select id,ApplType__c, CustProfile__c, Constitution__c, FName__c,CompanyName__c,TotalIncome__c, (select id,DesignationText__c, IndustryType__r.Name, SubIndustry__r.Name, MainRBIIndustry__c, IndustryForRBIReporting__r.Name from Applicant_Employments__r)from Applicant__c  where LoanAppln__c in: LoanAppId and Type_of_Borrower__c='Financial' order by TotalIncome__c desc ] ){
            if(app.Constitution__c<> 'INDIVIDUAL'){
                NonIndividualCal.put(app.id,app); 
               // NonIndividualAmount.add(app.TotalIncome__c);
               
                
            }
            if(app.Constitution__c== 'INDIVIDUAL'){
                if(app.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' ||app.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' ){
                    IndividualCal.put(app.id,app);
                    
                }
                else{
                    OtherCal.put(app.id,app);
                    
                }
                    
            }  
                   
            
        }
        
       // system.debug('newList'+newList);
        //system.debug('LoanAppId'+LoanAppId);
        //system.debug('AppEmpIds'+AppEmpIds);
        system.debug('NonIndividualCal'+NonIndividualCal);
        system.debug('IndividualCal'+IndividualCal);
        system.debug('OtherCal'+OtherCal);
       // NonIndividualAmount.sort();
      // decimal HighestIncome = NonIndividualAmount.get(0);
        
        if(!NonIndividualCal.isEmpty()){
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id in: NonIndividualCal.keyset() order by TotalIncome__c desc limit 1 ]){
                if(!income.Applicant_Employments__r.isEmpty()){
                income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
                LoanAppl__c l = new LoanAppl__c();
                l.id=income.LoanAppln__c;
                l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                LoanFinalRBI.add(l);              
                }
            }
        }
        
        if(NonIndividualCal.isEmpty() && !IndividualCal.isEmpty()){
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id in: IndividualCal.keyset() order by TotalIncome__c desc limit 1 ]){
               // if(!income.Applicant_Employments__r.isEmpty()){
               if(income.Applicant_Employments__r.size()>0){
                income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
                LoanAppl__c l = new LoanAppl__c();
                l.id=income.LoanAppln__c;
                l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                LoanFinalRBI.add(l);
                } 
            }
        }
        
        if(NonIndividualCal.isEmpty() && IndividualCal.isEmpty() && !OtherCal.isEmpty()){
            for(Applicant__c income : [select id,LoanAppln__c,TotalIncome__c,LoanAppln__r.Final_Industry_for_RBI__c,(select id, MainRBIIndustry__c from Applicant_Employments__r)from Applicant__c  where id in: OtherCal.keyset() order by TotalIncome__c desc limit 1 ]){
              // if(!income.Applicant_Employments__r.isEmpty())
               if(income.Applicant_Employments__r.size()>0){
                income.LoanAppln__r.Final_Industry_for_RBI__c =income.Applicant_Employments__r[0].MainRBIIndustry__c;
               }else{
                 income.LoanAppln__r.Final_Industry_for_RBI__c ='';
               }
                LoanAppl__c l = new LoanAppl__c();
                l.id=income.LoanAppln__c;
                l.Final_Industry_for_RBI__c= income.LoanAppln__r.Final_Industry_for_RBI__c;
                
                LoanFinalRBI.add(l);
               
            }                
            }            
                
        
        if(LoanFinalRBI.size()>0){
            update LoanFinalRBI;
        }
        
      


    }
  
}