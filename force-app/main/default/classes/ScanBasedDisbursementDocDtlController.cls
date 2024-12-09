public class ScanBasedDisbursementDocDtlController {
 Public static List<opsQueryDetail> allDocumentRealtedInfor(String LoanAppId, String OpsRemark){
    List<opsQueryDetail> lstOpsQueryDetal = new List<opsQueryDetail>();
    Map<String,DocDispatch__c>  mapOfDocDispatch = new Map<String,DocDispatch__c>();
   /* for(DocDispatch__c doc : [Select id,LoanAppln__c, OperationRem__c from DocDispatch__c WHERE LoanAppln__c =:LoanAppId AND LoanAppln__c != NULL] ){
    mapOfDocDispatch.put(doc.LoanAppln__c, doc);
    } */
        
        
        for(DocDtl__c docDtl : [SELECT ID,LAN__c,LAN__r.Name,LAN__r.FinnoneAppid__c,LAN__r.Finnone_Loan_Number__c, LAN__r.CustomerName__c, DocSubTyp__c   from DocDtl__c  where LAN__c =:LoanAppId AND LAN__c != NULL AND PhyFileRec__c = 'Query'] ){
           opsQueryDetail objOpsdtl = new  opsQueryDetail();
           objOpsdtl.loanAppNo = docDtl.LAN__r.Name;
           objOpsdtl.FinnoneAppID = docDtl.LAN__r.FinnoneAppid__c;
           objOpsdtl.FinnoneLANNo = docDtl.LAN__r.Finnone_Loan_Number__c;
           objOpsdtl.CustomerName = docDtl.LAN__r.CustomerName__c;
           objOpsdtl.DocumentDtl = docDtl.DocSubTyp__c;
           objOpsdtl.OpsQueryremarks = OpsRemark;
           lstOpsQueryDetal.add(objOpsdtl);
        }     
        if(lstOpsQueryDetal != null && lstOpsQueryDetal.size() > 0){
            return lstOpsQueryDetal;
        }
        return null;
    
    }
    
    
    
Public class opsQueryDetail{
Public String loanAppNo{ get; set; }
Public String FinnoneAppID{ get; set; }
Public String FinnoneLANNo{ get; set; }
Public String CustomerName{ get; set; }
Public String DocumentDtl{ get; set; }
Public String OpsQueryremarks{ get; set; }
}
}