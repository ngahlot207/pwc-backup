public class NdcColumnConfig {
  public ColumnConfig[] columns;
  public Boolean allowUpload { get; set; }
  public Boolean allowMultiUpload { get; set; } //LAK-8428
  public Boolean allowDelete { get; set; }
  public String docCategory { get; set; }
  public String groupBy { get; set; }
  public String title { get; set; }
  public Boolean addDeviation { get; set; }
  public String deviationCategory { get; set; }

  public class ColumnConfig {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String fieldName { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public Boolean Editable { get; set; }
    @AuraEnabled
    public String[] options { get; set; }
    @AuraEnabled
    public Boolean Required { get; set; }
    @AuraEnabled
    public Boolean selectAll { get; set; }
    @AuraEnabled
    public Boolean selectAllPhyFU { get; set; }
    @AuraEnabled
    public Boolean allowUpload { get; set; }
    //LAK-8428
    @AuraEnabled
    public Boolean allowMultiUpload { get; set; }
    @AuraEnabled
    public String width { get; set; }
  }

  public static ResultJson parse(String json) {
    return (ResultJson) System.JSON.deserialize(json, ResultJson.class);
  }
}