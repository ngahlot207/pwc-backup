public class HRMSIntegrationMessage implements Schedulable{
    
    public void execute(SchedulableContext ctx) {
        
        
        IntgMsg__c intmsg =new IntgMsg__c();
        intmsg.Name='Get HRMS Details';
        intmsg.Status__c='New';
        intmsg.MStatus__c='Blank';
        intmsg.BU__c='HL / STL';
        intmsg.Svc__c='Get HRMS Details';
        intmsg.ApiVendor__c='HRMS';
        intmsg.IsActive__c=true; 
        
        Insert intmsg;
        
        //String Cor='0 00 20 * * ?';
        //HRMSIntegrationMessage hrms=new HRMSIntegrationMessage();
        //System.schedule('HRMSIntegrationMessage', Cor, hrms);
    }

}