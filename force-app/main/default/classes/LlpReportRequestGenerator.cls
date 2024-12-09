public class LlpReportRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        List<Id> Ids =new List<Id>();
        
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c); //Applicant Obj
        }
        Map<Id,Applicant__c> mapOfAppls =new Map<Id,Applicant__c>(); 

        if(!Ids.isEmpty()){   
        for(Applicant__c eachApp:[SELECT id,PAN__c,LLPIN__c,DOI__c from Applicant__c where id IN: Ids]){
            mapOfAppls.put(eachApp.Id,eachApp);                                  
        }
        }

        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isempty()){
                for(IntgMsg__c intMsg : msgs){
                    //LLPIN or PAN of the LLP to fetch
                    if(mapOfAppls.containsKey(intMsg.RefId__c)){
                        
                        Applicant__c appliData= mapOfAppls.get(intMsg.RefId__c);
             
                        String valToPass;
                        string jsonbody=''; 
                        if(appliData !=null){
                            if(appliData.LLPIN__c !=null){
                                valToPass=appliData.LLPIN__c;
                                //https://uat-api.fedfina.com/uat/probe
                                //https://uat-api.fedfina.com/uat/probe/lips/AAC-4506?type=pdf&client_name=probe&unit=INR&identifier_type=LLPIN
                                jsonbody=+'callout:ProbeAPIGateway/lips/'+ valToPass +'?type=pdf&identifier_type=LLPIN&client_name=probe';
                                
                            }
                            else if(appliData.PAN__c !=null){
                                valToPass=appliData.PAN__c;
                                jsonbody=+'callout:ProbeAPIGateway/lips/'+ valToPass +'?type=pdf&identifier_type=PAN&client_name=probe';
                            }
                        }
                        
                        System.debug('URL get is ::'+jsonbody);

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
            GlobalUtility.logMessage('Error', 'LlpReportRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }





}