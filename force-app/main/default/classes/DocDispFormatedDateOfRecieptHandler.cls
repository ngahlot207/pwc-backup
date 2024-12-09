public class DocDispFormatedDateOfRecieptHandler implements TriggerAction.beforeUpdate{
    
     public static void beforeUpdate(List<DocDispatch__c> newList, List<DocDispatch__c> oldList){
          Map<Id,DocDispatch__c> MapOfOldDocDispatch  = new Map<Id,DocDispatch__c>(oldList);
         for(DocDispatch__c docDis : newList){
             If( MapOfOldDocDispatch.containskey(docDis.Id) && docDis.DateofReceiptbyOps__c != MapOfOldDocDispatch.get(docDis.Id).DateofReceiptbyOps__c  && docDis.DateofReceiptbyOps__c != null){
                  String formatedDate = docDis.DateofReceiptbyOps__c.format('dd/MM/yyyy, hh:mm a');
                  System.debug('formatedDate:::::::::' + formatedDate);
                  docDis.FormatedDateofReceipt__c = formatedDate;
             }  
         }   
     }
}