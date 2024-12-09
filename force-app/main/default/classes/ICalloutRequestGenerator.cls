public interface ICalloutRequestGenerator  {
    //Here we created interface ICalloutRequestGenerator with a method called generate() 
    //and use this interface to implement the IntegrationMessageTriggerHandler class 
    void  generate(List<IntgMsg__c> msgs, String service, String processType);
    
}