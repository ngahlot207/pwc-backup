@isTest
public class ReusableLookupControllerTest {
    @isTest
    static void testFetchRecords(){
            try{
                LoanAppl__c loanApln = new LoanAppl__c();
                insert loanApln;
                Account ac = new Account();
                ac.Name = 'Test';
                insert ac;
                
                ReusableLookupController.SearchWrapper wrp = new ReusableLookupController.SearchWrapper();
                wrp.objectApiName = 'Account';
                wrp.fieldApiName = 'Name';
                wrp.parentFieldApiName = 'Id';
                wrp.searchString ='Test';
                wrp.filterConditions = 'Id != null';
                wrp.parentRecordId = loanApln.Id;
                wrp.keyId = 'Id';
                //wrp.selectFields = 'Name';
                wrp.selecetdFieldName = 'Phone';
                wrp.selectedRecordId = ''+ac.id+'';
                // wrpList.add(wrp);
                List<ReusableLookupController.ResultWrapper> returnWrpList = new List<ReusableLookupController.ResultWrapper>();
                ReusableLookupController.ResultWrapper wrp1 = new ReusableLookupController.ResultWrapper();
                wrp1.mainField = wrp.fieldApiName;
                returnWrpList.add(wrp1);
                ReusableLookupController.fetchRecords(wrp);
                
                
                ReusableLookupController.SearchWrapper wrp2 = new ReusableLookupController.SearchWrapper();
                wrp2.objectApiName = 'Account';
                wrp2.fieldApiName = 'Name';
                wrp2.parentFieldApiName = 'Name';
                wrp2.searchString ='Test';
                wrp2.filterConditions = 'Id != null';
                wrp2.parentRecordId = loanApln.Id;
                wrp2.keyId = 'Id';
                wrp2.selectFields = 'Phone';
                wrp2.selecetdFieldName = 'Fax';
                wrp2.selectedRecordId = ''+ac.id+'';
             
                ReusableLookupController.fetchRecords(wrp2);
                
                ReusableLookupController.SearchWrapper wrp3 = new ReusableLookupController.SearchWrapper();
                wrp3.objectApiName = 'Account';
                wrp3.fieldApiName = 'Name';
                wrp3.parentFieldApiName = 'Name';
                wrp3.searchString ='Test';
                wrp3.filterConditions = 'Id != null';
                wrp3.parentRecordId = loanApln.Id;
                wrp3.keyId = 'Id';
                wrp3.selectFields = 'Phone';
                //wrp3.selecetdFieldName = 'Name';
                wrp3.selectedRecordId = ''+ac.id+'';
             
                ReusableLookupController.fetchRecords(wrp3);
                
                ReusableLookupController.SearchWrapper wrp4 = new ReusableLookupController.SearchWrapper();
                wrp4.objectApiName = 'Account';
                wrp4.fieldApiName = 'Name';
                wrp4.parentFieldApiName = 'Name';
                wrp4.searchString ='Test';
                wrp4.filterConditions = 'Id != null';
                wrp4.parentRecordId = 'Name';
                wrp4.keyId = 'Id';
                wrp4.selectFields = 'Phone';
                //wrp4.selecetdFieldName = 'Name';
                //wrp4.selectedRecordId = 'Test';
             
                ReusableLookupController.fetchRecords(wrp4);
                
                DocMstr__c docTyp = new DocMstr__c();
                insert docTyp;
                
                ReusableLookupController.SearchWrapper wrp5 = new ReusableLookupController.SearchWrapper();
                wrp5.objectApiName = 'DocMstr__c';
                wrp5.fieldApiName = 'DocTyp__c';
                wrp5.parentFieldApiName = 'Id';
                wrp5.searchString ='Test';
                wrp5.filterConditions = 'Id != null';
                wrp5.parentRecordId = ''+docTyp.id+'';
                wrp5.keyId = 'Id';
                ReusableLookupController.fetchRecords(wrp5);
            }catch(exception e){
                system.assertEquals('Script-thrown exception', e.getMessage());
                system.debug('exception:::::'+e.getMessage());
            }
      //  }
    }
    @isTest
    static void testFetchRecords3(){
            try{
                LoanAppl__c loanApln = new LoanAppl__c();
                insert loanApln;
                Account ac = new Account();
                ac.Name = 'Test';
                insert ac;
                
                DocMstr__c docTyp = new DocMstr__c();
                docTyp.DocTyp__c = 'Pan';
                insert docTyp;
                
                ReusableLookupController.SearchWrapper wrp5 = new ReusableLookupController.SearchWrapper();
                ReusableLookupController.SearchWrapper wrp6 = new ReusableLookupController.SearchWrapper();
                wrp5.objectApiName = 'DocMstr__c';
                wrp5.fieldApiName = 'DocTyp__c';
                wrp5.parentFieldApiName = 'Id';
                wrp5.searchString ='Test';
                wrp5.filterConditions = 'Id != null';
                wrp5.parentRecordId = 'Name';
                wrp5.keyId = 'Id';
                //wrp5.selectFields = 'Id';
                //wrp4.selecetdFieldName = 'Name';
                //wrp5.selectedRecordId = 'Test';
                //
                ReusableLookupController.fetchRecords(NULL);
                ReusableLookupController.fetchRecords(wrp5);
            }catch(exception e){
                system.assertEquals('Script-thrown exception', e.getMessage());
                system.debug('exception:::::'+e.getMessage());
            }
    }
}