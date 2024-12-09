@RestResource(urlMapping='/queryObjects/*')
global class ObjectQueryAPI {
    
    @HttpPost
    global static MobileResponseData queryObjects(String objectName, String condition,List<String> fields) {       
        MobileResponseData response = new MobileResponseData();    
        System.debug('objectName==' + objectName);
        System.debug('condition==' + condition);       
        try {
            if (String.isNotBlank(objectName)  && fields != null && !fields.isEmpty()) {
                String query='';
                String fieldNames = String.join(fields, ',');
                if(String.isNotBlank(condition)){
                    query = 'SELECT ' + fieldNames + ' FROM ' + objectName + ' WHERE ' + condition ;   
                }else{
                    query = 'SELECT ' + fieldNames + ' FROM ' + objectName ;      
                }               
                List<SObject> queriedRecords = Database.query(query);               
                response.isSuccess = true;
                response.responseData = JSON.serialize(queriedRecords);
            } else {
                response.isSuccess = false;
                response.errorMessage = 'Object name,  or fields list is empty.';
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessage = ex.getMessage();
        }
        return response;
    } 
}