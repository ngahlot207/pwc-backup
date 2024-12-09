/* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 06-Oct-2023
* ********************************************************
*/

public without sharing class MSMEInsertion implements TriggerAction.BeforeUpdate {
    
  
    public static void beforeUpdate(List<Applicant__c> newList,List<Applicant__c> oldList) {
        Map<Id, Applicant__c> oldListMap = new Map<Id, Applicant__c>(oldList);
        set<id> AppIds = new set<id>();
         for(Applicant__c app :newList){
           if(app.Investment_in_Plant_and_Machinery__c<>oldListMap.get(app.id).Investment_in_Plant_and_Machinery__c
               || app.Annual_Turnover__c<>oldListMap.get(app.id).Annual_Turnover__c || app.MSME_Type__c<>oldListMap.get(app.id).MSME_Type__c){
                   AppIds.add(app.Id);
               } 
        }
        System.debug('--AppIds msmeinsertion->'+AppIds);      
               
        if(AppIds.size()>0){
        	createMSME(AppIds,newList);
        }
    }
	public static void createMSME(set<id> AppIds,List<Applicant__c> newList){
        set<id> AppEmpforOtherIndustry = new set<id>();
        
       
        List<Investment_in_Plant_and_Machinery__mdt> listInvestment = [SELECT Id,Min__c,Max__c,MSME_Type__c from Investment_in_Plant_and_Machinery__mdt];
		System.debug('--listEmailDomain->'+listInvestment);
        
        List<Annual_Turnover__mdt> listAnnualTurnover = [SELECT Id,Min__c,Max__c,MSME_Type__c from Annual_Turnover__mdt];
		System.debug('--listEmailDomain->'+listAnnualTurnover);      
               
        String msmeTypeBasedOnInvestment = 'Not Applicable';
        String msmeTypeBasedOnAnnualTurnOver = 'Not Applicable';
        Decimal Investamount;
        Decimal AnnualTurnOver;
        
        for(ApplicantEmployment__c appEmp : [select id, MSME_Industry_selection__c,LoanApplicant__c from ApplicantEmployment__c where MSME_Industry_selection__c='OTHERS' and LoanApplicant__c in: AppIds ]){
            AppEmpforOtherIndustry.add(appEmp.LoanApplicant__c);
        }
        for(Applicant__c a :newList){
          // for (Applicant__c a : [select id,Investment_in_Plant_and_Machinery__c,Annual_Turnover__c,MSME_Type__c,MSME__c,TotalIncome__c, (select id, MSME_Industry_selection__c from Applicant_Employments__r where MSME_Industry_selection__c='OTHERS')from Applicant__c  where id in: AppIds  ] ){
            if(AppEmpforOtherIndustry.contains(a.id)){
            Investamount = a.Investment_in_Plant_and_Machinery__c != NULL?a.Investment_in_Plant_and_Machinery__c:0;
            AnnualTurnOver = a.Annual_Turnover__c != NULL?a.Annual_Turnover__c:0;
            
            
            for(Investment_in_Plant_and_Machinery__mdt i :listInvestment){
                if( Investamount>i.Min__c && Investamount<i.Max__c ){
                    
                    msmeTypeBasedOnInvestment=i.MSME_Type__c;
                    break;
                }else{
                    
                }
            }
            for (Annual_Turnover__mdt at :listAnnualTurnover){
                if( AnnualTurnOver>at.Min__c && AnnualTurnOver<at.Max__c ){
                    
                    msmeTypeBasedOnAnnualTurnOver=at.MSME_Type__c;   
                }
            }
            if(AnnualTurnOver> Investamount){
                a.MSME_Type__c=msmeTypeBasedOnAnnualTurnOver;
              
            }else if(AnnualTurnOver < Investamount){
                a.MSME_Type__c=msmeTypeBasedOnInvestment;
                
            }
           // if(a.MSME_Type__c == 'Not Applicable'){
           //          a.MSME__c = 'No';
           // }
            /*else{
                a.MSME__c = 'Yes';
             }*/
            if(a.MSME_Type__c !=Null && a.MSME_Type__c != 'Not Applicable' ){
                a.MSME__c = 'Yes';
            }
            
            //for non-other industry
            //if(a.MSME_Type__c !=Null && a.MSME_Type__c != 'Not Applicable' ){
            //    a.MSME__c = 'Yes';
            //}
            
                /*if(){
                    if((a.Investment_in_Plant_and_Machinery__c<>null && a.Investment_in_Plant_and_Machinery__c>i.Min__c &&
                   		a.Investment_in_Plant_and_Machinery__c<i.Max__c) )
                        {
                        a.MSME__c='Yes';
                        a.MSME_Type__c=i.MSME_Type__c;   
                        system.debug('MSME_Type__c'+a.MSME_Type__c);
           		 		}
            		
                }
                
                if(a.Investment_in_Plant_and_Machinery__c < a.Annual_Turnover__c){
                    if(a.Annual_Turnover__c<>null &&
                       a.Annual_Turnover__c>at.Min__c && a.Annual_Turnover__c<at.Max__c){
                          a.MSME__c='Yes';
                         a.MSME_Type__c=at.MSME_Type__c;   
                        system.debug('MSME_Type__c'+a.MSME_Type__c); 
                       }
                }*/
            	
            
       		 
        	 System.debug('--a applicant msmeinsertion->'+a);
            
                
        }
        
        }}


}