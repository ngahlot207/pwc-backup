public without sharing class ScanBasedDisbursementCommunication {
     transient public string DocDisPatchId{get;set;}
     transient public string recordid{get;set;}
    
    Public ScanBasedDisbursementCommunication(){
       recordId = DocDisPatchId;
        /*if (recordId==null) {
            recordId='a08C4000007CR6rIAG';
        }*/if (recordId!=null) {
        	//applicationQueryList = getApplicationQuery(recordId);
        	//getDocDetails(recordId);
        } 
    }
    
    
     public list<ScanBasedDisbursementDocDtlController.opsQueryDetail> getDocumentDispatchDtl() {
         If(String.isNotBlank(DocDisPatchId) && DocDisPatchId != null){
              List<DocDispatch__c>  documentDis = [Select id,LoanAppln__c,OperationRem__c from DocDispatch__c WHERE ID =: DocDisPatchId Limit 1];
     
     list<ScanBasedDisbursementDocDtlController.opsQueryDetail> lstOpsQueryDtl = ScanBasedDisbursementDocDtlController.allDocumentRealtedInfor(documentDis[0].LoanAppln__c, documentDis[0].OperationRem__c);
     Return lstOpsQueryDtl;   
         }
        Return null; 
    
    }
    
}