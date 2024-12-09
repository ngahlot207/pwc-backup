@isTest
public class RetriggerAPIsValueChangeOnApplAddrsTest {
	@isTest
    static void TestHandler(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);        
        Applicant__c Appl=TestDataFactory.createSingleApplicant(true,loan.id);
        
        ApplAddr__c addrs=new ApplAddr__c();
        addrs.Applicant__c = Appl.id;
		addrs.LoanAppl__c = loan.id;         
        insert addrs;
        list<ApplAddr__c> addrsList = new list<ApplAddr__c>{addrs};
            
        RetriggerAPIsValueChangeOnApplAddrs.afterInsert(addrsList) ;
        
        ApplAddr__c addrs1 = new ApplAddr__c();
        addrs1.id = addrs.id;
        addrs1.AddrLine1__c = '123';
        addrs1.AddrTyp__c = 'Residence Address';
        update addrs1;
        
        RetriggerAPIsValueChangeOnApplAddrs.afterUpdate(addrsList,addrsList);
        RetriggerAPIsValueChangeOnApplAddrs.afterDelete(addrsList);
     }
}