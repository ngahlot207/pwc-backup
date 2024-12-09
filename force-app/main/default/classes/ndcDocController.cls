public with sharing class ndcDocController {
    
    @AuraEnabled
    public static Map<String,Map<String,List<String>>> getNdcRequiredDoc(String docCategory){
        
        Map<String,Map<String,Set<String>>> cateWithTypeAndSubType = new Map<String,Map<String,Set<String>>>();
        
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        if(docCategory != '' && docCategory != null){
            docMstrList = [SELECT id,Catgry__c,DocTyp__c,DocSubTyp__c FROM DocMstr__c WHERE Catgry__c =: docCategory];
        }
        if(docMstrList.size() > 0 ){
            for(DocMstr__c dcMstr : docMstrList){
                
                Map<String,Set<String>> existringRecord = cateWithTypeAndSubType.get(dcMstr.Catgry__c);
                if(existringRecord == null){         
                    existringRecord = new Map<String,Set<String>>();           
                    Set<String> subTypes = new Set<String> ();          
                    subTypes.add(dcMstr.DocSubTyp__c);    
                    system.debug('subTypes ' + subTypes);    
                    existringRecord.put(dcMstr.DocTyp__c,subTypes);
                }else{  
                    Set<String> subTypes = existringRecord.get(dcMstr.DocTyp__c);     
                    if(subTypes == null){subTypes = new Set<String> ();
                    }subTypes.add(dcMstr.DocSubTyp__c);  
                    existringRecord.put(dcMstr.DocTyp__c,subTypes);
                } cateWithTypeAndSubType.put(dcMstr.Catgry__c,existringRecord);
            }
        }
        
        if(cateWithTypeAndSubType.size() > 0){
            Map<String,Map<String,List<String>>> fetchAllDocs = new Map<String,Map<String,List<String>>>();
            system.debug('cateWithTypeAndSubType final is' + cateWithTypeAndSubType);
            for(String key : cateWithTypeAndSubType.keySet()) {
                Map<String, List<String>> docTypes = new Map<String, List<String>>();
                for(String docTypeKey : cateWithTypeAndSubType.get(key).keySet()) {
                    docTypes.put(docTypeKey, new List<String>(cateWithTypeAndSubType.get(key).get(docTypeKey)));
                }
                fetchAllDocs.put(key, docTypes);
            }
            return fetchAllDocs;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static string  createDocDetailwithApplicantAsset(String applicantId, String loanAppId, string docCategory, string docType,string docSubType,String applicantAssetId){
        List<DocMstr__c> docMstrList = new List<DocMstr__c> ();  
        
        docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c FROM DocMstr__c 
                       WHERE Catgry__c =: docCategory AND DocTyp__c =: docType AND DocSubTyp__c =:docSubType WITH SECURITY_ENFORCED];
        if(applicantAssetId != null && applicantAssetId != ''){
            ApplAsset__c appAssetRecord = [SELECT Id,State__c FROM ApplAsset__c WHERE Id=:applicantAssetId];     
        }
        
        DocDtl__c   dd  = new DocDtl__c ();   
        dd.Appl__c = applicantId != null ? applicantId : null;   
        dd.DocMstr__c = docMstrList != null && !docMstrList.isEmpty() ? docMstrList[0].id : null;   
        dd.DocCatgry__c = docCategory != null ? docCategory : null ;   
        dd.DocSubTyp__c = docSubType != null ? docSubType : null ;   
        dd.DocTyp__c = docType != null ? docType : null ;   
        dd.LAN__c = loanAppId != null ? loanAppId : null ;   
        if(applicantAssetId != null && applicantAssetId != ''){   
            dd.ApplAsset__c = applicantAssetId;  
        } 
        try{
            insert dd;
            return dd.id;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }  
    }
}