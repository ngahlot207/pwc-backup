public class MultiTrancheRequestGenerator implements ICalloutRequestGenerator {

    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        Map<Id, LoanAppl__c> loanAppRecordsMap = new Map<Id, LoanAppl__c>();
        
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
        try{
        if(msgs !=null && !msgs.isEmpty()){
                
        for(IntgMsg__c intMsg : msgs){

                Id loanAppId = intMsg.RefId__c !=null ? intMsg.RefId__c :'';

                for(LoanAppl__c loanApp : [SELECT ID, Finnone_Loan_Number__c FROM LoanAppl__c WHERE Id =: loanAppId]){
                    loanAppRecordsMap.put(loanApp.Id,loanApp);  
                }
                LoanAppl__c loanAppObj = loanAppRecordsMap.get(loanAppId);

                MultiTrancheRequestWrapper multiTrObj =new MultiTrancheRequestWrapper();
                multiTrObj.LANNo = loanAppObj.Finnone_Loan_Number__c;

                IntgMsg__c intg=New IntgMsg__c();
                intg.id=intMsg.id;
                intg.Req__c = JSON.serialize(multiTrObj,true); 
                intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                updateIntRecords.add(intg);
                }
        }

                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }    
                uow.commitWork();


    }
    catch(Exception ex){
        System.debug('error'+ex.getMessage());
        GlobalUtility.logMessage('Error', 'MultiTrancheRequestGenerator' + ex.getLineNumber(), 
                                 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
    }   
}

}