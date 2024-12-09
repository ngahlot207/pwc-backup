@isTest
public class RetriggerAPIsValueChangeOnApplAssetTest {
    @isTest
    static void dmlHandler(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        ApplAsset__c asset =new ApplAsset__c();
        asset.Appl__c=applicant.id;
        asset.LoanAppln__c=loan.id;         
        insert asset;
        list<ApplAsset__c> assetList = new list<ApplAsset__c>{asset};
        RetriggerAPIsValueChangeOnApplAsset.afterInsert(assetList);
        /*
        ApplAsset__c updAsset=new ApplAsset__c();
        updAsset.id=asset.id;
        updAsset.AddrLn1__c='123';
        update updAsset;
        */
        RetriggerAPIsValueChangeOnApplAsset.afterUpdate(assetList,assetList);
        RetriggerAPIsValueChangeOnApplAsset.afterDelete(assetList);
    }
}