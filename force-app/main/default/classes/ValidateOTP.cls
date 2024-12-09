@RestResource(urlMapping='/validateOTP/*')
global class ValidateOTP {
    
    @HttpGet
    global static Boolean valOTP() {
        String taskId = '';
        String otp = '';
        Boolean result ;
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        taskId = restReq.params.get('taskId');
        otp = restReq.params.get('otp');
        system.debug('taskId: '+taskId+':::otp: '+otp);
        if(!String.isBlank(taskId)){
        result = validateOtp(taskId, otp);
        }
        return result;      
    }
   
     @AuraEnabled
    public static Boolean validateOtp(String taskId,String otp) {
        Boolean returnMsg;
        List<Task> taskRecrds  = new List<Task>(); 
        List<Lead> leadRecords = new List<Lead>();
        if(taskId != null ){
             taskRecrds = [SELECT Id,OTP__c,WhoId,MobNum__c FROM Task WHERE Id=:taskId LIMIT 1];
            
        }
        if(!taskRecrds.isEmpty()){
            
            if(taskRecrds[0].OTP__c == otp){
                returnMsg = true;
                if(taskRecrds[0].WhoId != NULL){
                    Lead leadRec = new Lead();
                    leadRec.Id = taskRecrds[0].WhoId;
                    leadRec.MobilePhone = taskRecrds[0].MobNum__c;
                    leadRec.ConsentType__c = 'OTP Consent';
                    leadRec.OTP_Verified__c = true;

                    update leadRec;
                }
            }else{
                returnMsg = false;
            }
        }
        return returnMsg;
    }
}