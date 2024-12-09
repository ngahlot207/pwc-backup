public class OTCPDDStatusCallbackResponseProcessor {
    
    public Static void process(List<IntgMsg__c> responses){
        try{
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            Map<String,Map<String,OTCPDDStatusWrapper>> jsonresponsemap=new  Map<String,Map<String,OTCPDDStatusWrapper>>();
            Set<String> docIds = new Set<String>();
            for(IntgMsg__c integrationMessage:responses){
                if(integrationMessage.Req__c!=null ){
                    
                    OTCPDDStatusWrapper res=(OTCPDDStatusWrapper) JSON.deserialize(integrationMessage.Req__c,OTCPDDStatusWrapper.class);
                    if(string.isNotblank(res.APPLID) && String.isNotBlank(res.DOCID)){
                        docIds.add(res.DOCID);
                        intgMsgRefIdsMap.put(integrationMessage.Id,res.APPLID);
                        if(jsonresponsemap.containsKey(res.APPLID)){
                            jsonresponsemap.get(res.APPLID).put(res.DOCID,res);  
                        }
                        else{
                            jsonresponsemap.put(res.APPLID,new Map<String,OTCPDDStatusWrapper>{res.DOCID=>res});
                        }
                        
                    }
                    
                    /*IntgMsg__c intg=New IntgMsg__c();
                    intg.id=integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
            if(!jsonresponsemap.isempty()){
                processOTCPDDStatus(intgMsgRefIdsMap,jsonresponsemap,docIds); 
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
    
    
    public static void processOTCPDDStatus(Map<String,String> intgMsgRefIdsMap,Map<String,Map<String,OTCPDDStatusWrapper>> responseMap,Set<String> docIds){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DocDtl__c.SObjectType,IntgMsg__c.SObjectType });
        if(!responsemap.isempty()){
            List<DocDtl__c> docDtlList =new List<DocDtl__c>();
            List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
            Map<String,DocDtl__c> docDtlMap = new Map<String,DocDtl__c>();
            for(DocDtl__c doc : [SELECT Id,DocMstr__c,DocMstr__r.DocId__c,LAN__r.FinnoneAppid__c,LAN__c,LAN__r.Applicant__c FROM DocDtl__c WHERE LAN__r.FinnoneAppid__c IN:responseMap.keySet() AND DocMstr__r.DocId__c IN:docIds]){
                docDtlMap.put(doc.LAN__r.FinnoneAppid__c,doc);
                if(responseMap.containsKey(doc.LAN__r.FinnoneAppid__c) && responseMap.get(doc.LAN__r.FinnoneAppid__c).containsKey(doc.DocMstr__r.DocId__c)){
                    
                    OTCPDDStatusWrapper response = responseMap.get(doc.LAN__r.FinnoneAppid__c).get(doc.DocMstr__r.DocId__c);
                    if(response!=null){
                        DocDtl__c docDtl = new DocDtl__c();
                        docDtl.Id = doc.Id;
                        System.debug('response.RECEIVED:'+response.RECEIVED);
                        if(String.isNotBlank(response.RECEIVED) && (response.RECEIVED.equalsIgnoreCase('R') || response.RECEIVED.equalsIgnoreCase('RECEIVED')) ){
                            docDtl.DocStatus__c='Received';                      
                        }
                        if(String.isNotBlank(response.RECEIVED) && (response.RECEIVED.equalsIgnoreCase('C') || response.RECEIVED.equalsIgnoreCase('COMPLETED')) ){
                            docDtl.DocStatus__c='Completed';                      
                        }
                        System.debug('Received date before if::'+response.RECEIVEDDATE);
                        if(String.isNotBlank(response.RECEIVEDDATE)){
                            List<String> receiveDate = response.RECEIVEDDATE.split('[- T :]');
                            System.debug('receiveDate List::'+receiveDate);
                            if(receiveDate!=null && receiveDate.size()>=3){
                                //docDtl.ReceivedDt__c = Date.newInstance(Integer.valueof(receiveDate[2]),Integer.valueof(receiveDate[1]),Integer.valueof(receiveDate[0]));
                                docDtl.ReceivedDt__c = Date.newInstance(Integer.valueof(receiveDate[0]),Integer.valueof(receiveDate[1]),Integer.valueof(receiveDate[2]));
                                System.debug('docDtl.ReceivedDt__c::'+docDtl.ReceivedDt__c);
                            }
                        }
                        if(String.isNotBlank(response.REMARKS)){
                            docDtl.Rmrk__c = response.REMARKS;
                        }
                        if(String.isNotBlank(response.ORIGINALS) && (response.ORIGINALS.equalsIgnoreCase('Y') || response.ORIGINALS.equalsIgnoreCase('Yes'))){
                            docDtl.Originals__c=True;
                        }
                        if(String.isNotBlank(response.TARGETDATE)){
                            List<String> targetDate = response.TARGETDATE.split('[- T :]');
                            if(targetDate!=null && targetDate.size()>=3){
                                //docDtl.TargetDt__c = Date.newInstance(Integer.valueof(targetDate[2]),Integer.valueof(targetDate[1]),Integer.valueof(targetDate[0]));
                            	docDtl.TargetDt__c = Date.newInstance(Integer.valueof(targetDate[0]),Integer.valueof(targetDate[1]),Integer.valueof(targetDate[2]));
                            	 System.debug('docDtl.TargetDt__c::'+docDtl.TargetDt__c);
                            }
                        }
                        if(String.isNotBlank(response.VALIDTILLDATE)){
                            List<String> validTillDate = response.VALIDTILLDATE.split('[- T :]');
                            if(validTillDate!=null && validTillDate.size()>=3){
                                //docDtl.ValidTillDt__c = Date.newInstance(Integer.valueof(validTillDate[2]),Integer.valueof(validTillDate[1]),Integer.valueof(validTillDate[0]));
                            	docDtl.ValidTillDt__c = Date.newInstance(Integer.valueof(validTillDate[0]),Integer.valueof(validTillDate[1]),Integer.valueof(validTillDate[2]));
                            	System.debug('docDtl.ValidTillDt__c::'+docDtl.ValidTillDt__c);
                            }
                        }
                        if(String.isNotBlank(response.DATELASTUPDT)){
                            List<String> dateLastUpDate = response.DATELASTUPDT.split('[- T :]');
                            if(dateLastUpDate!=null && dateLastUpDate.size()>=3){
                                //docDtl.DateLastUpDt__c = Date.newInstance(Integer.valueof(dateLastUpDate[2]),Integer.valueof(dateLastUpDate[1]),Integer.valueof(dateLastUpDate[0]));
                                docDtl.DateLastUpDt__c = Date.newInstance(Integer.valueof(dateLastUpDate[0]),Integer.valueof(dateLastUpDate[1]),Integer.valueof(dateLastUpDate[2]));
                           		System.debug('docDtl.DateLastUpDt__c::'+docDtl.DateLastUpDt__c);
                            }
                        }
                        if(String.isNotBlank(response.CRITICAL)){
                            docDtl.Criticality__c = response.CRITICAL;
                        }
                        docDtlList.add(docDtl);
                    }    
                }
                
            }
            
            if(!intgMsgRefIdsMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(docDtlMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            if(docDtlMap.get(intgMsgRefIdsMap.get(intgMsgId)).LAN__c!=null){
                                intg.LoanAppln__c = docDtlMap.get(intgMsgRefIdsMap.get(intgMsgId)).LAN__c;
                                if(docDtlMap.get(intgMsgRefIdsMap.get(intgMsgId)).LAN__r.Applicant__c!=null){
                                    intg.Appl__c = docDtlMap.get(intgMsgRefIdsMap.get(intgMsgId)).LAN__r.Applicant__c;
                                }
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                }
            
            if(!docDtlList.isEmpty()){
                
                List<string> fieldNamesList = New List<string>{'DocStatus__c','ReceivedDt__c','Rmrk__c','Originals__c','TargetDt__c','ValidTillDt__c','DateLastUpDt__c','Criticality__c'};
                    String sObjectName = 'DocDtl__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(docDtlList);
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
    
    public class OTCPDDStatusWrapper{
        public String DOCDESC;	//Document name
        public String DOCID;	//Finnone ID
        public String APPLID;	//Finnone loan ID
        public String RECEIVED;	//Yes
        public String RECEIVEDDATE;	//
        public String REMARKS;	//PPI
        public String ORIGINALS;	//yes
        public String TARGETDATE;	//
        public String VALIDTILLDATE;	//
        public String DATELASTUPDT;	//
        public String CRITICAL;	//
    }
}