public class CreateCKYCIntegrationMessageQueueable implements Queueable {
    
    private Set<Id> loanids;
    
    public CreateCKYCIntegrationMessageQueueable(Set<Id> loanids){
        this.loanids=loanids;
    }
    
    public void execute(QueueableContext context) {
        
        List<Applicant__c> applicantList = [SELECT Id, Name FROM Applicant__c WHERE LoanAppln__c IN :loanids];
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>(); 
        if(!applicantList.isempty()){
            
            for (Applicant__c app : applicantList) {
                
                //Creating Intg Msg for CKYC API  
                IntgMsg__c intMsgCkyc =new IntgMsg__c();
                intMsgCkyc.Name='CKYC API';
                intMsgCkyc.BU__c='HL / STL';
                intMsgCkyc.RefId__c=app.Id;
                intMsgCkyc.Status__c='New';
                intMsgCkyc.MStatus__c='Blank';
                intMsgCkyc.RefObj__c='Applicant__c';
                intMsgCkyc.Svc__c='CKYC API';
                intMsgCkyc.IsActive__c=true;
                
                createRequestList.add(intMsgCkyc);
                
                
                //Creating Intg Msg for CKYC ATTACHMENT  
                IntgMsg__c intMsgCkycAtt =new IntgMsg__c();
                intMsgCkycAtt.Name='CKYC ATTACHMENT';
                intMsgCkycAtt.BU__c='HL / STL';
                intMsgCkycAtt.RefId__c=app.Id;
                intMsgCkycAtt.Status__c='New';
                intMsgCkycAtt.MStatus__c='Blank';
                intMsgCkycAtt.RefObj__c='Applicant__c';
                intMsgCkycAtt.Svc__c='CKYC ATTACHMENT';
                intMsgCkycAtt.IsActive__c=true;
                
                createRequestList.add(intMsgCkycAtt);
                
             
            }
            
            
           
            
            if(createRequestList!=null && !createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uowInt = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesListInt = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectNameInt = 'IntgMsg__c';
                Schema.SObjectType objTypeInt  = Schema.getGlobalDescribe().get(sObjectNameInt);
                fflib_SecurityUtils.checkInsert(objTypeInt,fieldNamesListInt); 
                uowInt.registerNew(createRequestList);
                uowInt.commitWork();
            }
        }
    }
    
}