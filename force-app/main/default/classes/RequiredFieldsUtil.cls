public class RequiredFieldsUtil {
    public static List<String> getRequiredFields(String objectApiName) {
        List<String> requiredFieldNames = new List<String>();
        
        // Describe the object
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        
        // Get the fields for the object
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        
        // Iterate through the fields and check if they are required
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            if (fieldDescribe.isNillable() == false && fieldDescribe.isCreateable()) {
                requiredFieldNames.add(fieldName);
            }
        }
        
        return requiredFieldNames;
    }
}