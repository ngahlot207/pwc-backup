@isTest
public class IntegrationMessageTriggerHandlerTest {
    
    @isTest static void testMethod1(){ 
        Boolean isError=False;
        try{
            Map<Id,IntgMsg__c>IntMap =New Map<Id,IntgMsg__c>();
        List<String>servNames = New List<String>();
        List<String>BUNames =New List<String>();
        
         IntgMsg__c intmsg = New IntgMsg__c();
        intmsg.BU__c ='Vehicle Loan';
        intmsg.RefObj__c='intmsg__c';
        intmsg.RefId__c='a054w00002tpicBAAQ';
        intmsg.Status__c='New';
        intmsg.IsActive__c=true;
        intmsg.Outbound__c=false;
        intmsg.Svc__c='PAN-PROFILE';
        intmsg.MStatus__c = 'Blank';
        insert intmsg;
         List<IntgMsg__c> newList1 =[SELECT Id, Status__c, IsActive__c, Name, BU__c, RefId__c, ParentRefId__c,
                                   RefObj__c, ParentRefObj__c, Req__c, Resp__c, Mresp__c, 
                                   MStatus__c, Svc__c, ApiVendor__c, ApiVersion__c, DocApi__c, ExecType__c, Outbound__c FROM IntgMsg__c where id=: intmsg.Id];
           IntegrationMessageTriggerHandler.AfterInsert(newList1); 
        IntegrationMessageRequestProcesser.requestProcesser(IntMap,servNames,BUNames);  

         
        }catch(exception e){
            isError=true;
        }
         //System.AssertEquals(False,isError);
       
        
    }  
    
    
}