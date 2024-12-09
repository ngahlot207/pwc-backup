public with sharing class LlpCompreDtlsRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        List<Id> Ids =new List<Id>();
        
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c);
        }
        

        Map<Id,Applicant__c> mapOfAppls =new Map<Id,Applicant__c>(); 

        if(!Ids.isEmpty()){   
        for(Applicant__c eachApp:[SELECT id,PAN__c,LLPIN__c from Applicant__c where id IN: Ids]){
            mapOfAppls.put(eachApp.Id,eachApp);                                  
        }
        }

        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isempty()){
                for(IntgMsg__c intMsg : msgs){
                    
                    if(mapOfAppls.containsKey(intMsg.RefId__c)){
                        
                        Applicant__c appliData= mapOfAppls.get(intMsg.RefId__c);
                        String panToPass = appliData !=null ? appliData.PAN__c :'';

                        //New Logic

                        String valToPass;
                        String jsonbody=''; 

                        if(appliData !=null){
                            if(appliData.LLPIN__c !=null){
                                valToPass=appliData.LLPIN__c;
                                jsonbody=+'callout:APIGateway?identifier_type=LLPIN&'+'CinOrPan='+ valToPass ;    
                            }
                            else if(appliData.PAN__c !=null){
                                valToPass=appliData.PAN__c;
                                jsonbody=+'callout:APIGateway?identifier_type=PAN&'+'CinOrPan='+ valToPass ;    
                            }
                        }
                        //
                        
                        //Old Logic 
                        //String jsonbody=+'callout:APIGateway?identifier_type=PAN&'+'CinOrPan='+ panToPass ;      
                        System.debug('URL is ::'+jsonbody);

                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = jsonbody; 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                        
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
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'LlpCompreDtlsRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
}