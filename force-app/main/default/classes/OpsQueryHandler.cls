public class OpsQueryHandler {
  public static List<OpsQueryWrapper> getOpsqueryRema(String loanId) {
    List<OpsQueryWrapper> opsQuryWrprResults = new List<OpsQueryWrapper>();
    List<NDC__c> ndcResilts = [
      SELECT
        Id,
        OpsQryCnt__c,
        NDC_Section__c,
        DocDtl__c,
        DocDtl__r.DocSubTyp__c,
        ScreenNames__c,
        (SELECT Id, QryTyp__c, Remarks__c FROM Application_Queries__r)
      FROM NDC__c
      WHERE OpsQryCnt__c > 0 AND LoanAppl__c = :loanId
    ];
    if (ndcResilts != null && ndcResilts.size() > 0) {
      for (NDC__c ndc : ndcResilts) {
        String cpaRemarks = '';
        String opsRemarks = '';
        for (Application_Query__c appQuery : ndc.Application_Queries__r) {
            if(appQuery.QryTyp__c == 'Response'){
                cpaRemarks += appQuery.Remarks__c + '<br/>';
            }else {
                opsRemarks += appQuery.Remarks__c + '<br/>';
            }
        }
        OpsQueryWrapper opsQryErpr = new OpsQueryWrapper();
        opsQryErpr.querySecName = ndc.NDC_Section__c != null
          ? ndc.NDC_Section__c
          : ndc.ScreenNames__c;

        opsQryErpr.documentName = ndc.DocDtl__c != null
          ? ndc.DocDtl__r.DocSubTyp__c
          : '';
        opsQryErpr.cpaRemarks = cpaRemarks;
        opsQryErpr.opsRemarks = opsRemarks;
        opsQuryWrprResults.add(opsQryErpr);
      }
    }
    if (opsQuryWrprResults != null && opsQuryWrprResults.size() > 0) {
      return opsQuryWrprResults;
    }
    return null;
  }
  public class OpsQueryWrapper {
    public String querySecName { get; set; }
    public String documentName { get; set; }
    public String opsRemarks { get; set; }
    public String cpaRemarks { get; set; }
  }
}