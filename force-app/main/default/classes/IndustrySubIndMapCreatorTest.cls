@isTest
public class IndustrySubIndMapCreatorTest {

    @isTest
    static void testGetIndNsubInd() {
  
         Industry__c testIndustry1=TestDataFactory.createIndustry(false);
            testIndustry1.Name = 'Industry1';
            TriggerBase.bypass('Industry__c');
            insert testIndustry1;
            TriggerBase.clearBypass('Industry__c');
        
         Industry__c testIndustry2=TestDataFactory.createIndustry(false);
            testIndustry2.Name = 'Industry2';
            TriggerBase.bypass('Industry__c');
            insert testIndustry2;
            TriggerBase.clearBypass('Industry__c');

         SubIndustry__c testSubIndustry1=TestDataFactory.createSubIndustry(false,testIndustry1.Id);
           testSubIndustry1.Name = 'SubInd1';
           testSubIndustry1.Industry__c = testIndustry1.Id;
           TriggerBase.bypass('SubIndustry__c');
           insert testSubIndustry1;
           TriggerBase.clearBypass('SubIndustry__c');
        
          SubIndustry__c testSubIndustry2=TestDataFactory.createSubIndustry(false,testIndustry1.Id);
            testSubIndustry2.Name = 'SubInd2';
            testSubIndustry2.Industry__c = testIndustry1.Id;
            TriggerBase.bypass('SubIndustry__c');
            insert testSubIndustry2;
            TriggerBase.clearBypass('SubIndustry__c');
            
          SubIndustry__c testSubIndustry3=TestDataFactory.createSubIndustry(false,testIndustry2.Id);
            testSubIndustry3.Name = 'SubInd3';
            testSubIndustry3.Industry__c = testIndustry2.Id;
            TriggerBase.bypass('SubIndustry__c');
            insert testSubIndustry3;
            TriggerBase.clearBypass('SubIndustry__c');

            Test.startTest(); 
            Map<String, Set<String>> result = IndustrySubIndMapCreator.getIndNsubInd(); 
            Test.stopTest();
    
            System.assertEquals(2, result.size(), 'Expected two industries');
            System.assert(result.containsKey('Industry1'), 'Expected key for Industry1');
            System.assert(result.containsKey('Industry2'), 'Expected key for Industry2');
    
            Set<String> subIndustries1 = result.get('Industry1');
            Set<String> subIndustries2 = result.get('Industry2');
    
            System.assertEquals(2, subIndustries1.size(), 'Expected two sub-industries for Industry1');
            System.assert(subIndustries1.contains('SubInd1') && subIndustries1.contains('SubInd2'), 'Incorrect sub-industries for Industry1');
    
            System.assertEquals(1, subIndustries2.size(), 'Expected one sub-industry for Industry2');
            System.assert(subIndustries2.contains('SubInd3'), 'Incorrect sub-industry for Industry2');

    }
}