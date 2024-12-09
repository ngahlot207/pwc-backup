public class CrifAuthLoginRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
        
        try{   
            if(!msgs.isEmpty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Crif_Auth_Login');
                for(IntgMsg__c intMsg : msgs){
                    
                    if(intMsg.RefId__c!=null){
                        CrifAuthLoginRequestWrapper request = new CrifAuthLoginRequestWrapper();
                        request.userId = svc.Username__c;
                        request.password = svc.Password__c;
                        request.domain = svc.Domain__c;
                        request.mode = GlobalConstants.Mode;
                        
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        intg.Req__c = JSON.serialize(request); 
                        updateIntMsgList.add(intg);
                        
                        //brelatest(intMsg.RefId__c);
                    }
                    else{
                        throw new CrifAuthLoginRequestException('Reference Id missing');
                    }
                    
                }
                
                if(!updateIntMsgList.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifAuthLoginRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    /*
     //*********************************************************************************************************************************
    Public static void brelatest(String loanids){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {LoanAppl__c.SObjectType});
        
        if(loanids!=null){
            //Updating loan Applications
            List<LoanAppl__c> loanlist =new List<LoanAppl__c>();
            
            LoanAppl__c la =new LoanAppl__c();
            la.id=loanids;
            la.MaxBreLnEliWIns__c=0;
            la.MaxBreLnEliWoIns__c=0;
            la.EMIIcludingInsurance__c=0;
            //la.EffectiveROI__c=0;
            loanlist.add(la);
            
            if(loanlist!=null){
                List<string> fieldNamesList = New List<string>{'MaxBreLnEliWIns__c','MaxBreLnEliWoIns__c','EMIIcludingInsurance__c'};
                    String sObjectName = 'LoanAppl__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkupdate(objType,fieldNamesList); 
                uow.registerDirty(loanlist);
            }
            
            uow.commitWork();
            
            //Checking BRE record
            List<BRE__c> breIslatest =[Select id,IsLatest__c,LoanAppl__c from BRE__c Where LoanAppl__c =:loanids AND IsLatest__c=true];
            
            if(!breIslatest.Isempty()){
                IsLatestFalse(breIslatest,'IsLatest__c');
            }
        }
        
    }
    //*********************************************************************************************************************************
    public Static void IsLatestFalse(List<SObject> recordList, String fieldName){
        
        if(!recordList.isempty()){
            // SObjectType sObjectType = recordList.getSObjectType();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            
            for (SObject record : recordList) {
                if (record.get(fieldName) != null) {
                    record.put(fieldName, false);
                    recordsToUpdate.add(record);
                }
            }
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
        
        
        
    } */  
    public class CrifAuthLoginRequestException extends Exception {
        
    }
}