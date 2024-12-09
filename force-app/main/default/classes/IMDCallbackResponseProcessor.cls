public class IMDCallbackResponseProcessor {
    
    public Static void process(List<IntgMsg__c> responses){
        try{
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            Set<String> responsestring=new Set<String>();
            Map<String,IMDResponseWrapper> jsonresponsemap=new  Map<String,IMDResponseWrapper> ();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            
            for(IntgMsg__c integrationMessage:responses){
                if(integrationMessage.Req__c!=null ){
                    IMDResponseWrapper res=(IMDResponseWrapper) JSON.deserialize(integrationMessage.Req__c,IMDResponseWrapper.class);
                    if(!string.isblank(res.requestID)){
                        jsonresponsemap.put(res.requestID,res);
                        intgMsgRefIdsMap.put(integrationMessage.Id,res.requestID);
                    }
                    /*IntgMsg__c intg=New IntgMsg__c();
                    intg.id=integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
            if(!jsonresponsemap.isempty()){
                IMDCallbackSucess(intgMsgRefIdsMap,jsonresponsemap); 
            }
            /*if(!updateIntRecords.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntRecords);
            }
            uow.commitWork();*/
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }
    
    Public Static void IMDCallbackSucess(Map<String,String> intgMsgRefIdsMap,Map<String,IMDResponseWrapper> responsemap){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplIMD__c.SObjectType,IntgMsg__c.SObjectType });
        if(!responsemap.isempty()){
            
            List<ApplIMD__c> applimdList =new List<ApplIMD__c>();
            List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
            Map<String,ApplIMD__c> applIMDMap = new Map<String,ApplIMD__c>();
            for(ApplIMD__c applimd:[select id,FinnoneRequestId__c,FinnoneChequeId__c,LoanAppln__c,LoanAppln__r.Applicant__c from ApplIMD__c where FinnoneRequestId__c IN:responsemap.keyset()]){
                
                applIMDMap.put(applimd.FinnoneRequestId__c,applimd);
                
                if(responsemap.containskey(applimd.FinnoneRequestId__c)){
                    
                    ApplIMD__c imd=new ApplIMD__c();
                    imd.id=applimd.Id;
                    
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).chequeStatus)){ 
                        imd.BRECheqClrStatus__c = responsemap.get(applimd.FinnoneRequestId__c).chequeStatus;
                        imd.IMDReceived__c = responsemap.get(applimd.FinnoneRequestId__c).chequeStatus.containsIgnoreCase('CLEARED') ? 'Yes' : 'No';
                        if(responsemap.get(applimd.FinnoneRequestId__c).chequeStatus.containsIgnoreCase('CLEARED')){
                            imd.IMDStatus__c = 'Cleared';
                        }
                        else if(responsemap.get(applimd.FinnoneRequestId__c).chequeStatus.containsIgnoreCase('BOUNCE')){
                            imd.IMDStatus__c = 'Bounced';
                            
                            if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).bounceReasonID)){
                                imd.BounceReasonID__c = responsemap.get(applimd.FinnoneRequestId__c).bounceReasonID;
                            }
                        }
                        else if(responsemap.get(applimd.FinnoneRequestId__c).chequeStatus.containsIgnoreCase('CANCEL')){
                            imd.IMDStatus__c = 'Cancelled';
                        }
                        else {
                            imd.IMDStatus__c = 'Failed';
                        }
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).realizationDate)){
                        List<String> realizationDateList = responsemap.get(applimd.FinnoneRequestId__c).realizationDate.split('-');
                        if(realizationDateList.size()>=3){
                            String month = realizationDateList[1].toUpperCase();
                            if(monthMap.containsKey(month)){
                                imd.CheqClrDate__c=Date.newInstance(Integer.valueof(realizationDateList[2]),monthMap.get(month),Integer.valueof(realizationDateList[0]));
                            }
                        }
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).bounceReasonDesc)){
                        imd.CheqBounceReason__c = responsemap.get(applimd.FinnoneRequestId__c).bounceReasonDesc;                      
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).utrNo)){
                        imd.PaymentRefNo__c = responsemap.get(applimd.FinnoneRequestId__c).utrNo;
                    }
                    
                    /*if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).agreementID)){

                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).remarks)){
                    
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).bounceReasonID)){
                    
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).requestID)){
                    
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).failureDate)){
                    
                    }
                    if(!string.isblank(responsemap.get(applimd.FinnoneRequestId__c).sourceID)){
                    
                    }*/
                    
                    applimdList.add(imd);
                }
                
            }
            
            if(!intgMsgRefIdsMap.isEmpty()){
                for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.id =  intgMsgId;
                    intg.Status__c = 'Processed';
                    if(applIMDMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                        if(applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c!=null){
                            intg.LoanAppln__c = applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c;
                            if(applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__r.Applicant__c!=null){
                            intg.Appl__c = applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__r.Applicant__c;
							}
                        }
                    }
                    updateIntgMsgRecords.add(intg);
                }
            }
            
            if(applimdList!=null && !applimdList.isEmpty()){
                List<string> fieldNamesList = New List<string>{'IMDReceived__c','BRECheqClrStatus__c','CheqClrDate__c','CheqBounceReason__c','PaymentRefNo__c','BounceReasonID__c'};
                    String sObjectName = 'ApplIMD__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(applimdList);
            }
            if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Status__c','LoanAppln__c','Appl__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntgMsgRecords);
            }
            uow.commitWork();
        }
        
    }        
    
    public class IMDResponseWrapper{
        public String chequeStatus;	//CLEARED
        public String agreementID;	//3167089
        public String remarks;	//
        public String chequeID;	//47628546
        public String realizationDate;	//20-FEB-2020
        public String bounceReasonDesc;	//null
        public String bounceReasonID;	//null
        public String requestID ;	//168944
        public String failureDate;	//
        public String sourceID;	//3167089
        public String utrNo;	//ABD4567768ASD567
        
    }
    
    private static Map<String,Integer> monthMap = new Map<String,Integer>{'JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12};
        
}