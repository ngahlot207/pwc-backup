@isTest
public class RetriggerAPIsValueChangeOnPdTest {
	@isTest
    static void TestHandler(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);        
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        
        PD__c p=new PD__c();
        p.Appl__c=Applicant.id;
        p.LoanAppl__c=loan.id;         
        insert p;
        list<PD__c> pList = new list<PD__c>{p};
            
        RetriggerAPIsValueChangeOnPd.afterInsert(pList) ;
        
        PD__c p1=new PD__c();
        p1.id=p.id;
        p1.EmpIdConductedBy__c='123';
        update p1;
        
        RetriggerAPIsValueChangeOnPd.afterUpdate(pList,pList);
        RetriggerAPIsValueChangeOnPd.afterDelete(pList);
        
        
    }
}