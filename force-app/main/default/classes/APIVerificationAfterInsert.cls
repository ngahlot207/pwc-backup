public class APIVerificationAfterInsert implements TriggerAction.AfterInsert {
	
    public void afterInsert(List<APIVer__c> newList){
       
        if(newList!=null && !newList.isEmpty()){
            Set<String> recordTypeNames = new Set<String>{'GST','QualificationCheck','Probe42'};
            Set<Id> applicantIds = new Set<Id>();
            Map<Id,Boolean> applIDProofMap = new Map<Id,Boolean>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            
           Map<Id,RecordType> recordTypeMap=new Map<Id,RecordType>([SELECT Id,DeveloperName FROM RecordType where SobjectType ='APIVer__c' AND DeveloperName IN:recordTypeNames]);
            
            for(APIVer__c apiVer : newList){
                if(apiVer.Appl__c!=null && apiVer.IsLatest__c && recordTypeMap.containsKey(apiVer.RecordTypeId) && apiVer.IntegrationStatus__c == GlobalConstants.MSG_SUCCESS){
                    applicantIds.add(apiVer.Appl__c);
                }
            }
            
            if(!applicantIds.isEmpty()){
                for(DocDtl__c docDtl : [SELECT Id,Applicant_KYC__r.Name__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c FROM DocDtl__c WHERE 
                                        ((Appl__r.Constitution__c ='INDIVIDUAL' AND DocCatgry__c ='KYC Documents'  AND DocTyp__c ='Identity Proof')  OR
                                         (Appl__r.Constitution__c <> 'INDIVIDUAL' AND DocCatgry__c ='PAN Documents'  AND DocTyp__c ='PAN')) AND Appl__c IN: applicantIds]){
                                             if(!applIDProofMap.containsKey(docDtl.Appl__c)){
                                                 applIDProofMap.put(docDtl.Appl__c,TRUE);
                                             } 
                                         }
            }
            
            for(APIVer__c apiVer : newList){
                
                if(apiVer.Appl__c!=null && apiVer.IsLatest__c && recordTypeMap.containsKey(apiVer.RecordTypeId) && apiVer.IntegrationStatus__c == GlobalConstants.MSG_SUCCESS){
                    
                    if(applIDProofMap.containsKey(apiVer.Appl__c) && applIDProofMap.get(apiVer.Appl__c)){
                        
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = 'Name Similarity';
                        intMsgRec.BU__c = 'HL / STL';
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = 'Name Similarity';
                        intMsgRec.RefId__c = apiVer.Id;
                        intMsgRec.RefObj__c = 'APIVer__c';
                        intMsgRec.ParentRefId__c = apiVer.Appl__c;
                        intMsgRec.ParentRefObj__c = 'Applicant__c';
                        intMsgRec.IsActive__c = TRUE;
                        createRequestList.add(intMsgRec); 
                    }
                }
            }    
            
            if(createRequestList!=null && !createRequestList.isEmpty()){
                insert createRequestList;
            }
        }
        
    }
}