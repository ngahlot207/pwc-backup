public class NamasteCreditCaseCreatRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isEmpty()){
            
            try{
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Set<Id> docIds =new Set<Id>();
                
                for(IntgMsg__c msg:msgs){
                    
                    if(String.isNotblank(msg.RefId__c)){
                        docIds.add(msg.RefId__c);
                    }
                }
                
                if(!docIds.isEmpty()){
                    
                    Map<Id,DocDtl__c> docDetailMap =new Map<Id,DocDtl__c>([Select id,Appl__r.Constitution__c,Appl__r.LoanAppln__r.Name
                                                                           from DocDtl__c Where Id IN:docIds]);
                    
                    for(IntgMsg__c msg:msgs){
                        
                        if(docDetailMap.containsKey(msg.RefId__c)){
                            
                            DocDtl__c dtl =docDetailMap.get(msg.RefId__c);
                            
                            NamasteCreditCaseCreatRequestWrapper.businessDetails business =new NamasteCreditCaseCreatRequestWrapper.businessDetails();
                            business.business_name='test fedfina case';
                            business.business_type=(String.isNotblank(dtl.Appl__r.Constitution__c) && businessTypeMap.containsKey(dtl.Appl__r.Constitution__c))?businessTypeMap.get(dtl.Appl__r.Constitution__c):0;
                            
                            NamasteCreditCaseCreatRequestWrapper.loanDetails loanDtls =new NamasteCreditCaseCreatRequestWrapper.loanDetails();
                            loanDtls.application_no=msg.Integration_Message_Number__c+dtl.Appl__r.LoanAppln__r.Name;
                            loanDtls.loan_product_id='';
                            loanDtls.white_label_id='2548e38e6ee3e0126f1d18c50daaab6f';
                            
                            NamasteCreditCaseCreatRequestWrapper request =new NamasteCreditCaseCreatRequestWrapper();
                            request.Business_details=business;
                            request.loan_details=loanDtls;
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=msg.Id;
                            integrationMessage.Req__c=NamasteCreditAPIController.getEncryptedRequest(JSON.serialize(request));
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgRecords.add(integrationMessage);
                        }
                        
                    }
                }
                
                if(!updateIntMsgRecords.isEmpty()){
                    Update updateIntMsgRecords;
                }
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'NamasteCreditCaseCreatRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    }
    //******************************************************************************************************************************
    Public Static Map<String,Integer> businessTypeMap =new Map<String,Integer>{
        
        'ASSOCIATION OF PERSONS'=>11,
            'HUF'=>20,
            'INDIVIDUAL'=>7,
            'LIMITED LIABILITY PARTNERSHIP'=>14,
            'PARTNERSHIP'=>14,
            'PRIVATE LIMITED COMPANY'=>4,
            'PROPERITORSHIP'=>1,
            'PUBLIC LIMITED COMPANY'=>5,
            'SOCIETY'=>10,
            'TRUST'=>9
            
            };
                }