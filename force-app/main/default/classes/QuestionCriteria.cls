public class QuestionCriteria {
    @AuraEnabled
    public Id applicableQues { get; set; }
    @AuraEnabled
    public Id evalQues { get; set; }
    @AuraEnabled
    public List<String> criVal { get; set; }
    @AuraEnabled
    public String dependValCri { get; set; }
}