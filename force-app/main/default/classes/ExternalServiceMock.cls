public class ExternalServiceMock{
    
    @future(callout=true)
    public static void postMock(List<Id> Ids){
        system.debug('Inside mock class ');
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        
        List<IntgMsg__c> intMsgUpdate=New List<IntgMsg__c>();
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, ApiVersion__c, Svc__c,MStatus__c,ExecType__c,Req__c,DocApi__c,Resp__c,Status__c,ParentRefId__c from IntgMsg__c Where Id IN: Ids];
        
        try{
            if(!intgList.isEmpty()){
                for(IntgMsg__c intg: intgList){
                    system.debug('servicename ' + intg.Svc__c);
                    string serviceName ;
                    if(intg.Svc__c == 'KYC OCR'){
                        List<ApplKyc__c> appKycList = [SELECT Id,kycDoc__c FROM ApplKyc__c WHERE Id =:intg.ParentRefId__c];
                        if(appKycList != null && !appKycList.isEmpty()){
                            if(appKycList[0].kycDoc__c == 'Aadhaar'){
                                serviceName = 'AADHAR';
                            }else if(appKycList[0].kycDoc__c == 'Voter Id'){
                                serviceName = 'VOTER ID';
                            }
                            else if(appKycList[0].kycDoc__c == 'Passport'){
                                serviceName = 'PASSPORT';
                            }
                            else if(appKycList[0].kycDoc__c == 'Driving License'){
                                serviceName = 'DRIVING LICENSE';
                            }
                            else if(appKycList[0].kycDoc__c == 'Pan'){
                                serviceName = 'PAN';
                            }
                        }
                    }else{
                        serviceName = intg.Svc__c;
                    }
                    
                    system.debug('service name from mock class is ' + serviceName);
                    
                    StaticResource static_resource = [SELECT Id, Name, SystemModStamp
                                                      FROM StaticResource 
                                                      WHERE Name = 'Integration_Mock'
                                                      LIMIT 1];
                    
                    string newServiceName = serviceName.replace(' ','_');
                    
                    String url_file_ref = '/resource/'
                        + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                        + '/' 
                        + static_resource.get('Name')
                        + '/'+ newServiceName +'.json';
                    
                    PageReference file_ref = new PageReference(url_file_ref);
                    String res_json_body = Test.isRunningTest() ? 'Test Data': file_ref.getContent().toString();
                    system.debug('res_json_body ' + res_json_body);
                    
                    IntgMsg__c intmsg=new IntgMsg__c();
                    intmsg.Id=intg.Id;
                    intmsg.Status__c = 'Responded';
                    // StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: staticResName LIMIT 1];
                    // String body = sr.Body.toString();
                    intmsg.Resp__c  = res_json_body;
                    intmsg.MStatus__c='Acknowledged';
                    intmsg.ExecType__c='Async';
                    intMsgUpdate.add(intmsg);
                    system.debug('intMsgUpdate ==> '+intMsgUpdate);
                }
                
                if(!intMsgUpdate.isEmpty()){
                    
                    List<string> fieldNamesList = New List<string>{'Resp__c','Status__c','MStatus__c','ExecType__c'};
                        String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    
                    uow.registerDirty(intMsgUpdate);
                }  
            }
            uow.commitWork();
            system.debug('Updated successfully!');
        }
        catch(Exception ex){
             system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'ExternalServiceMock class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}