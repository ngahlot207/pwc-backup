public class DedupeAccessTokenResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        try{
            Set <Id> loanApplnIds = new Set<Id>();
            Set <Id> applIds = new Set<Id>();
            Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
            Map<Id,Id> intMsgLoanAppMap = new Map<Id,Id>();
            for(IntgMsg__c integrationMessage : responses){
                
                if(integrationMessage.RefObj__c == 'LoanAppl__c') {
                    loanApplnIds.add(integrationMessage.RefId__c);
                    intMsgLoanAppMap.put(integrationMessage.Id,integrationMessage.RefId__c);
                }
                else if(integrationMessage.RefObj__c == 'Applicant__c') {
                    List<Id> ids= integrationMessage.RefId__c.split(',');
                    applIds = new Set<Id>(ids);
                    intMsgLoanAppMap.put(integrationMessage.Id,integrationMessage.ParentRefId__c);
                    
                }
                
                
            }
            
            if(!loanApplnIds.isEmpty()){
                for(LoanAppl__c app : [SELECT ID, (SELECT Id  FROM Applicants__r) FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                    List<Applicant__c> applicantList = app.Applicants__r;
                    loanAppMap.put(app.Id,applicantList);
                }
            }
            
            if(!applIds.isEmpty()){
                for( Applicant__c app : [SELECT Id,LoanAppln__c FROM Applicant__c Where Id IN:applIds]){
                    if(loanAppMap.containsKey(app.LoanAppln__c)){
                        loanAppMap.get(app.LoanAppln__c).add(app);
                    }
                    else{
                        loanAppMap.put(app.LoanAppln__c,new List<Applicant__c>{app});
                    }
                }
            }
            
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            for(IntgMsg__c integrationMessage : responses){
                
                try{
                DedupeAccessTokenWrapper responseWrapper = (DedupeAccessTokenWrapper) JSON.deserialize(integrationMessage.Resp__c, DedupeAccessTokenWrapper.class); 
                //check if responseWrapper is empty or not                
                if(responseWrapper != null){
                    if(!String.isBlank(responseWrapper.access_token)){
                        //---------------------------------------------------------------------
                        
                        if(intMsgLoanAppMap.containsKey(integrationMessage.Id)){
                            if(loanAppMap.containsKey(intMsgLoanAppMap.get(integrationMessage.Id))){
                                List<Applicant__c> applicantList = loanAppMap.get(intMsgLoanAppMap.get(integrationMessage.Id));
                                if(!applicantList.isEmpty()){
                                    for(Applicant__c app : applicantList){
                                        IntgMsg__c intmsg =new IntgMsg__c();
                                        if(integrationMessage.Name.equalsIgnoreCase('UCIC API Token')){
                                             intmsg.Name='UCIC';
                                             intmsg.Svc__c='UCIC';
                                        }else{
                                             intmsg.Name='Dedupe';
                                             intmsg.Svc__c='Dedupe';
                                        }   
                                       
                                        intmsg.BU__c='HL / STL';
                                        intmsg.RefId__c=app.Id;
                                        intmsg.Status__c='New';
                                        intmsg.MStatus__c='Blank';
                                        intmsg.RefObj__c='Applicant__c';
                                        intmsg.IsActive__c=true;
                                        intmsg.ParentRefId__c=integrationMessage.Id;
                                        intmsg.ParentRefObj__c='IntgMsg__c';

                                        if(integrationMessage.TriggFrmScrn__c !=null && String.isNotEmpty(integrationMessage.TriggFrmScrn__c)){
                                            intmsg.TriggFrmScrn__c=integrationMessage.TriggFrmScrn__c;
                                        }
                                        
                                        createRequestList.add(intmsg);
                                    }
                                }
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        
                        //----------------------------------------------------------------------
                        /*if(loanAppMap.containsKey(integrationMessage.RefId__c)){
                            List<Applicant__c> applicantList = loanAppMap.get(integrationMessage.RefId__c);
                            if(!applicantList.isEmpty()){
                                for(Applicant__c app : applicantList){
                                    IntgMsg__c intmsg =new IntgMsg__c();
                                    intmsg.Name='Dedupe API';
                                    intmsg.BU__c='HL / STL';
                                    intmsg.RefId__c=app.Id;
                                    intmsg.Status__c='New';
                                    intmsg.MStatus__c='Blank';
                                    intmsg.RefObj__c='Applicant__c';
                                    intmsg.Svc__c='Dedupe API';
                                    intmsg.IsActive__c=true;
                                    intmsg.ParentRefId__c=integrationMessage.Id;
                                    intmsg.ParentRefObj__c='IntgMsg__c';
                                    createRequestList.add(intmsg);
                                }
                            }
                        }*/
                        /*IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Dedupe API';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=integrationMessage.RefId__c;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c=integrationMessage.RefObj__c;
                        intmsg.Svc__c='Dedupe API';
                        intmsg.IsActive__c=true;
                        intmsg.ParentRefId__c=integrationMessage.Id;
                        intmsg.ParentRefObj__c='IntgMsg__c';
                        createRequestList.add(intmsg);*/
                    }
                    else if(!String.isBlank(responseWrapper.error)){
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.ParentRefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.errorMessage = String.isNotBlank(responseWrapper.error_description)?responseWrapper.error_description:responseWrapper.error;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                    }
                }
                    }
                catch(Exception ex){
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }
            
            if(!createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                uow.commitWork();
            }
            
            
        }
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'DedupeAccessTokenResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
        
    }
    
    
    /*public static void createDedupeRequest(){
        Set <Id> loanApplnIds = new Set<Id>();
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
        
        for(IntgMsg__c integrationMessage : [Select id,RefId__c from IntgMsg__c]){
            loanApplnIds.add(integrationMessage.RefId__c);
        }
        
        //List<LoanAppl__c> loanApplnList = [SELECT ID, (SELECT Id  FROM Applicants__r) FROM LoanAppl__c WHERE Id IN:loanApplnIds];
        if(!loanApplnIds.isEmpty()){
            for(LoanAppl__c app : [SELECT ID, (SELECT Id  FROM Applicants__r) FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                List<Applicant__c> applicantList = app.Applicants__r;
                loanAppMap.put(app.Id,applicantList);
            }
        }
        
        
        for(IntgMsg__c integrationMessage : [Select id,RefId__c from IntgMsg__c]){
            if(loanAppMap.containsKey(integrationMessage.RefId__c)){
                List<Applicant__c> applicantList = loanAppMap.get(integrationMessage.RefId__c);
                if(!applicantList.isEmpty()){
                    for(Applicant__c app : applicantList){
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Dedupe API';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=app.Id;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Applicant__c';
                        intmsg.Svc__c='Dedupe API';
                        intmsg.IsActive__c=true;
                        intmsg.ParentRefId__c=integrationMessage.Id;
                        intmsg.ParentRefObj__c='IntgMsg__c';
                        createRequestList.add(intmsg);
                    }
                }
            }
        }
        
        
    }*/
}