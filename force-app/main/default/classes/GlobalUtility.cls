public without sharing class GlobalUtility 
{
    
    public static List<String> getOTP() {
        Integer len = 6;
        String str = String.valueOf(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        System.debug('Random Number: ' + randomNumber);
        List<String> otpList = new List<String>();
        otpList.add(randomNumber);
        System.debug('List: ' + otpList);
        return otpList;
    }
    
    
    
    
    //This method is use to create application log in exception handling scenario
    public static void logMessage(String logLevel, 
                                  String sourceClass,
                                  String sourceFunction, 
                                  String referenceId,
                                  String referenceInfo,
                                  String logMessage, 
                                  String payLoad,
                                  Exception ex,
                                  long timeTaken)
    {                                                  
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;
        logMessage( msg );                                                 
    }
    
    //we are calling this method in above logMessage method   
    public static void logMessage(ApplicationLogWrapper appLog)
    {
        List<ApplicationLogWrapper> appLogs = new List<ApplicationLogWrapper>();
        appLogs.add ( appLog );
        logMessage ( appLogs );
    }
    
    //we are calling this method in above logMessage method and we are inserting the - application log records
    public static void logMessage(List<ApplicationLogWrapper> appLogs)
    {        
        
        
        List<Application_Log__c> insertAppLogs = new List<Application_Log__c>();       
        for(ApplicationLogWrapper appLog : appLogs)
        {         
            
            
            Application_Log__c log = new Application_Log__c();  
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;
            log.Reference_Info__c = appLog.referenceInfo;  
            
            if(appLog.ex != null)
            {
                
                
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage() + '::::: ' + appLog.logMessage;
                //log.Exception_Type__c = applog.ex.getTypeName();
                
                
            }
            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            
            insertAppLogs.add(log);
            
        }
        
        if ( insertAppLogs.size() != 0 )
        { fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { Application_Log__c.SObjectType }
        );
         List<string> fieldNamesList = New List<string>{'Source__c','Source_Function__c','Reference_Id__c','Message__c','Integration_Payload__c','Reference_Info__c','Stack_Trace__c','Debug_Level__c','Log_Code__c','Timer__c'};
             
             String sObjectName = 'Application_Log__c';
         Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
         fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
         uow.registerNew(insertAppLogs);
         uow.commitWork();
         //insert insertAppLogs;
         
         
        }
    }
    
    //This Method is Used For Generating UniqueNumber For Integration RefID
    public static String getUniqueNumber(){
        integer leng=9;
        string  character='0123456789';
        string uniqueid;
        
        for(integer i=0;i<leng;i++){
            integer randomIndex=(integer)Math.floor(math.random()*character.length());
            uniqueid +=character.substring(randomIndex,randomIndex+1);
        }
        return uniqueid.replaceAll('null','');
        
    }
    
}