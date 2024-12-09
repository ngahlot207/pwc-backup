public without sharing class DummyFormController {
    
    
    @AuraEnabled
    public static DummyWrapper getRecordData(Id imdId){
        
        DummyWrapper wrap = new DummyWrapper();
        
        if(imdId!=null){
            
            List<ApplIMD__c> imd = [SELECT Id, PaytmOrderId__c,PaytmLinkURL__c, RData__c FROM ApplIMD__c WHERE Id = :imdId];
            
            wrap.bdorderid = imd[0].PaytmOrderId__c;
            wrap.rdata = imd[0].RData__c;
            wrap.href = imd[0].PaytmLinkURL__c;
        }else{
            wrap.bdorderid = 'NA';
            wrap.rdata = 'NA';
            wrap.href = 'Na';
        }
            
            
        
        return wrap;
    }
    
    
    
    
    
    
    public class DummyWrapper {
        @AuraEnabled public String bdorderid;
        @AuraEnabled public String rdata;
        @AuraEnabled public String href;
    } 
    
}