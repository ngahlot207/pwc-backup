@isTest
public class TestQuestionCriteria {
    
    @isTest
    static void testQuestionCriteria() {
        // Create test data
        PDQuesCri__c PD = new PDQuesCri__c();
        PD.EvalCrit__c='Test';
        insert PD;
        QuestionCriteria qc = new QuestionCriteria();
        qc.applicableQues = PD.id; // Replace with a valid Id
        qc.evalQues = PD.id; // Replace with a valid Id
        qc.criVal = new List<String>{'Value1', 'Value2'};
        qc.dependValCri = 'Dependency Value';

   

        // Retrieve the inserted record
        //QuestionCriteria insertedQc = [SELECT Id, applicableQues, evalQues, criVal, dependValCri FROM QuestionCriteria WHERE Id = :qc.Id LIMIT 1];

        // Perform assertions to verify data integrity
        /*System.assertEquals('a1K1v00000ABCDEF123', insertedQc.applicableQues, 'Applicable Question ID should match');
        System.assertEquals('a1K1v00000GHIJKL456', insertedQc.evalQues, 'Evaluation Question ID should match');
        System.assertEquals(new List<String>{'Value1', 'Value2'}, insertedQc.criVal, 'Criteria values should match');
        System.assertEquals('Dependency Value', insertedQc.dependValCri, 'Dependency value should match');*/
    }
}