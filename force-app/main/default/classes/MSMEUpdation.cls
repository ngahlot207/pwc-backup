/** 
* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 06-Oct-2023
* ********************************************************
*/


public without sharing class MSMEUpdation implements TriggerAction.AfterUpdate {
    
    
    public static void afterUpdate(List<Applicant__c> newList,List<Applicant__c> oldList) {
        updateMSMEValue(newList,oldList);
    }
    public static void updateMSMEValue(list<Applicant__c> newList,List<Applicant__c> oldList){
        set<id> AppIds = new set<id>();
        list<id> LoanAppIdList = new list<id>();
        map<id,Applicant__c> NonIndividual = new map<id,Applicant__c>();   
        map<id,Applicant__c> Individual = new map<id,Applicant__c>();
        map<id,Applicant__c> listMicro = new map<id,Applicant__c>();
        map<id,Applicant__c> listMedium = new map<id,Applicant__c>();
        map<id,Applicant__c> listSmall = new map<id,Applicant__c>();
        list<LoanAppl__c> LoanFinalMSME =new list<LoanAppl__c>();
        Map<Id, Applicant__c> oldListMap = new Map<Id, Applicant__c>(oldList);
        string result;
        
        //fetching Applicant Id 
        for(Applicant__c a :newList){
            if(a.Investment_in_Plant_and_Machinery__c<>oldListMap.get(a.id).Investment_in_Plant_and_Machinery__c
               || a.Annual_Turnover__c<>oldListMap.get(a.id).Annual_Turnover__c || a.MSME_Type__c<>oldListMap.get(a.id).MSME_Type__c
              || a.MSME__c<>oldListMap.get(a.id).MSME__c){
            LoanAppIdList.add(a.LoanAppln__c);
            }
            
            //for updated PAT and income-RBI calculation
            set<id> RBIApplnId= new set<id>();
            for(Applicant__c app :newList){
            if(app.TotalIncome__c<>oldListMap.get(app.id).TotalIncome__c
               || app.PAT__c <>oldListMap.get(app.id).PAT__c|| app.Constitution__c <>oldListMap.get(app.id).Constitution__c ||
              app.CustProfile__c <>oldListMap.get(app.id).CustProfile__c){
            RBIApplnId.add(app.id);
               }}
            if(!RBIApplnId.isEmpty()){
                updateRBICheck.updateMainRBiIndustry(RBIApplnId);
            }
            /*  if(a.Investment_in_Plant_and_Machinery__c<>null || a.Annual_Turnover__c<>null){
if(a.ApplType__c=='P' || a.ApplType__c=='C'){
if(a.Constitution__c<> 'INDIVIDUAL'){
NonIndividual.put(a.id,a);
}else if(a.Constitution__c == 'INDIVIDUAL' && (a.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' || a.CustProfile__c=='SELF EMPLOYED PROFESSIONAL')){
Individual.put(a.id,a);
}
}              
}  */         
        }
        system.debug('NonIndividual'+NonIndividual);
        system.debug('Individual'+Individual);   
        
        //calculating priorities 
        Boolean nonIndividualFlag = false;
        Map<Id,String> loanMSMEMap = new Map<Id,String>();
        
        //  if(!NonIndividual.isEmpty()){
        
        for(Applicant__c pr : [select id,CustProfile__c,Constitution__c,LoanAppln__c,MSME_Type__c,LoanAppln__r.Final_MSME__c from Applicant__c  where LoanAppln__c IN: LoanAppIdList ]){
            //SMALL,MICRO,MEDIUM
            if(pr.Constitution__c != 'INDIVIDUAL' || (pr.Constitution__c =='INDIVIDUAL' && (pr.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' ||pr.CustProfile__c=='SELF EMPLOYED PROFESSIONAL'))){
                if(!loanMSMEMap.containskey(pr.LoanAppln__c)){
                    loanMSMEMap.put(pr.LoanAppln__c,'Micro');
                }         
                if(pr.Constitution__c != 'INDIVIDUAL'){
                    nonIndividualFlag = true;
                    if(loanMSMEMap.get(pr.LoanAppln__c) == 'Micro' ){
                        loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                    }else if(loanMSMEMap.get(pr.LoanAppln__c) == 'Small'){
                        if(pr.MSME_Type__c != 'Micro'){
                            loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                        }
                    }else if(loanMSMEMap.get(pr.LoanAppln__c) == 'Medium'){
                        if(pr.MSME_Type__c != 'Micro' && pr.MSME_Type__c !='Small'){
                            loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                        }
                    }
                }else{
                    if(nonIndividualFlag== false){
                        if(loanMSMEMap.get(pr.LoanAppln__c) == 'Micro' ){
                            loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                        }else if(loanMSMEMap.get(pr.LoanAppln__c) == 'Small'){
                            if(pr.MSME_Type__c != 'Micro'){
                                loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                            }
                        }else if(loanMSMEMap.get(pr.LoanAppln__c) == 'Medium'){
                            if(pr.MSME_Type__c != 'Micro' && pr.MSME_Type__c !='Small'){
                                loanMSMEMap.put(pr.LoanAppln__c, pr.MSME_Type__c);
                            }
                        }
                        
                    }
                    
                }
                system.debug('Pr'+pr);
                system.debug('Pr'+pr.MSME_Type__c);
                
            }
            
            
            
        }  
       // if(!loanMSMEMap.isEmpty()){
       if(loanMSMEMap.size()>0){
            for(Id loanId : loanMSMEMap.keySet()){
                LoanAppl__c l = new LoanAppl__c();
                l.id=loanId;
                l.Final_MSME__c= loanMSMEMap.get(loanId);
                LoanFinalMSME.add(l);    
            }
        	
        }
        
       // if(!LoanFinalMSME.isEmpty()){ 
        if(LoanFinalMSME.size()>0){
            update LoanFinalMSME;
        }
        
        
    }
    
    /*   if(NonIndividual.isEmpty() && !Individual.isEmpty()){
List<Applicant__c> p = new List<Applicant__c>([select id,LoanAppln__c,MSME_Type__c,LoanAppln__r.Final_MSME__c from Applicant__c  where id in: Individual.keyset()  ]);

if(p.size()>0 && p.size()<2)
{
result = p[0].MSME_Type__c;


}
if(p.size()>2){
for(Applicant__c pr :  p){
if(pr.MSME_Type__c.contains('Medium')){
result = pr.MSME_Type__c;
listMedium.put(pr.id,pr);

}else if(pr.MSME_Type__c.contains('Small')){
//result = pr.MSME_Type__c;
listSmall.put(pr.id,pr);
}else{
// result = pr.MSME_Type__c;
listMicro.put(pr.id,pr);
}
}    

}
if(!listMedium.isEmpty())
{
result = 'Medium';
}
else if(listMedium.isEmpty() && !listSmall.isEmpty())
{
result = 'Small';
}
else{
result = 'Micro';
}


}*/
    
    
}