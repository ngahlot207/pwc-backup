global class QuestionsSaveWrapper {
  @AuraEnabled
    global string objectType { get; set; }
  //  global string multiSelectResponse { get; set; }
  @AuraEnabled
    global List<Sobject>  records { get; set; }     
}