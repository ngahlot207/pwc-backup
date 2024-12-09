public class APICalloutTracker {
    
    
    /*public static void create_ApiTracker(List<IntgMsg__c> newList)
{
list<APICoutTrckr__c> ApiTrackerlist=new list<APICoutTrckr__c>();
if(!newList.isEmpty())
{
for (IntgMsg__c intg : newList) 
{
APICoutTrckr__c APIT=new APICoutTrckr__c();
APIT.Appl__c=intg.Appl__c;
APIT.CrntStatus__c='In Progress';
APIT.APIName__c=intg.Svc__c;
APIT.LAN__c=intg.LoanAppln__c;
APIT.RefId__c=intg.RefId__c;
APIT.RefObj__c=intg.RefObj__c;
APIT.ReqDtTime__c=intg.ReqGenTime__c;
ApiTrackerlist.add(APIT);
}
if(!ApiTrackerlist.isEmpty())
{
Insert ApiTrackerlist;
}
}

}*/
    
    public static void create_ApiTracker(List<IntgMsg__c> newList)
    {
        list<APICoutTrckr__c> ApiTrackerlist=new list<APICoutTrckr__c>();
        //Map<Id,String> intSvcMap = new Map<Id,String>();
        //Map<Id,String> intRefIdMap = new Map<Id,String>();
        Set<String> services = new Set<String>();
        Set<String> refIds = new Set<String>();
        Set<String> parentRefIds = new Set<String>();
        Set<String> loanAppIds = new Set<String>();
        Map<String,List<Applicant__c>> loanApplMap= new Map<String,List<Applicant__c>>();
        Map<String,APICoutTrckr__c> apiCoutTrckrMap = new Map<String,APICoutTrckr__c>();
        
        if(!newList.isEmpty())
        {
            for (IntgMsg__c intg : newList) 
            {
                //intSvcMap.put(intg.Id,intg.Svc__c);
                //intRefIdMap.put(intg.Id,intg.RefId__c);
                if(intg.Svc__c!=null){
                    services.add(intg.Svc__c);
                }
                if(intg.RefId__c!=null){
                    List<String> ids = intg.RefId__c.split(',');
                    //refIds.add(intg.RefId__c);
                    refIds.addAll(ids);
                }
                if(intg.ParentRefId__c!=null){
                    parentRefIds.add(intg.ParentRefId__c);
                }
                
                if(intg.RefId__c==null && intg.ParentRefId__c!=null && intg.ParentRefObj__c=='LoanAppl__c'){
                    loanAppIds.add(intg.ParentRefId__c);
                }
                
            }
            
            if(loanAppIds!=null && !loanAppIds.isEmpty()){
                for(Applicant__c app : [Select Id,LoanAppln__c FROM Applicant__c WHERE LoanAppln__c IN:loanAppIds]){
                    if(!loanApplMap.containsKey(app.LoanAppln__c)){
                        loanApplMap.put(app.LoanAppln__c, new List<Applicant__c>{app});
                    }
                    else{
                        loanApplMap.get(app.LoanAppln__c).add(app);
                    }
                }
            }
            
            for(APICoutTrckr__c apiCoutTrckr: [select id, APIName__c,RefId__c,ParentRefId__c,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, APITriggerCount__c from APICoutTrckr__c where APIName__c IN:services and (RefId__c IN:refIds OR ParentRefId__c IN:parentRefIds)]){
                if(apiCoutTrckr.APIName__c !=null && (apiCoutTrckr.RefId__c !=null || apiCoutTrckr.ParentRefId__c!=null)){
                    apiCoutTrckrMap.put(apiCoutTrckr.IntgMsgName__c + ':' +apiCoutTrckr.APIName__c + ':' + (apiCoutTrckr.RefId__c != null ? apiCoutTrckr.RefId__c : apiCoutTrckr.ParentRefId__c),apiCoutTrckr);
                }
                
            }
            
            
            for (IntgMsg__c intg : newList) 
            {
                if(intg.Svc__c !=null && (intg.RefId__c !=null || intg.ParentRefId__c !=null)){
                    
                    if(intg.RefId__c==null && intg.ParentRefId__c!=null && intg.ParentRefObj__c=='LoanAppl__c'){
                        if(loanApplMap.containsKey(intg.ParentRefId__c)){
                            
                            for(Applicant__c app : loanApplMap.get(intg.ParentRefId__c)){
                                APICoutTrckr__c APIT=new APICoutTrckr__c();
                                if(apiCoutTrckrMap.containsKey(intg.Name + ':' +intg.Svc__c + ':' + app.Id)){
                                    APIT.Id = apiCoutTrckrMap.get(intg.Name + ':'+intg.Svc__c + ':' + app.Id).Id;
                                    APIT.APITriggerCount__c = apiCoutTrckrMap.get(intg.Name + ':'+intg.Svc__c + ':' + app.Id).APITriggerCount__c!=null ? apiCoutTrckrMap.get(intg.Name+ ':' +intg.Svc__c + ':' + app.Id).APITriggerCount__c + 1:1;
                                }
                                else{
                                    APIT.APITriggerCount__c =1;
                                }
                                APIT.Appl__c=app.Id;
                                APIT.CrntStatus__c='In Progress';
                                APIT.APIName__c=intg.Svc__c;
                                APIT.LAN__c=intg.LoanAppln__c;
                                APIT.RefId__c=app.Id;
                                APIT.RefObj__c='Applicant__c';
                                APIT.ReqDtTime__c=intg.ReqGenTime__c;
                                APIT.ParentRefId__c=intg.ParentRefId__c;
                                APIT.ParentRefObj__c=intg.ParentRefObj__c;
                                APIT.IntgMsgName__c=intg.Name;
                                APIT.BU__c=intg.BU__c;
                                ApiTrackerlist.add(APIT);
                            }
                            
                        }
                    }
                    else{
                    	List<String> ids = intg.RefId__c.split(',');
                        if(ids!=null && !ids.isEmpty()){
                            for(String refId : ids){
                                APICoutTrckr__c APIT=new APICoutTrckr__c();
                                if(apiCoutTrckrMap.containsKey(intg.Name + ':' +intg.Svc__c + ':' + (refId != null ? refId : intg.ParentRefId__c))){
                                    APIT.Id = apiCoutTrckrMap.get(intg.Name + ':'+intg.Svc__c + ':' + (refId != null ? refId : intg.ParentRefId__c)).Id;
                                    APIT.APITriggerCount__c = apiCoutTrckrMap.get(intg.Name + ':'+intg.Svc__c + ':' + (refId != null ? refId : intg.ParentRefId__c)).APITriggerCount__c!=null ? apiCoutTrckrMap.get(intg.Name+ ':' +intg.Svc__c + ':' + (refId != null ? refId : intg.ParentRefId__c)).APITriggerCount__c + 1:1;
                                }
                                else{
                                    APIT.APITriggerCount__c =1;
                                }
                                APIT.Appl__c= intg.RefObj__c=='Applicant__c'?refId: intg.Appl__c;
                                APIT.CrntStatus__c='In Progress';
                                APIT.APIName__c=intg.Svc__c;
                                APIT.LAN__c=intg.LoanAppln__c;
                                APIT.RefId__c=refId;
                                APIT.RefObj__c=intg.RefObj__c;
                                APIT.ReqDtTime__c=intg.ReqGenTime__c;
                                APIT.ParentRefId__c=intg.ParentRefId__c;
                                APIT.ParentRefObj__c=intg.ParentRefObj__c;
                                APIT.IntgMsgName__c=intg.Name;
                                APIT.BU__c=intg.BU__c;
                                ApiTrackerlist.add(APIT);
                                
                            }
                        }
                    }
                }
            }
            if(!ApiTrackerlist.isEmpty())
            {
                upsert ApiTrackerlist;
            }
        }
        
    }
    
    Public static void update_ApiTracker(string apiname, string refid, string code)
    {
        
        list<APICoutTrckr__c> apilist=[select id, LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c 
                                       from APICoutTrckr__c where APIName__c=:apiname and RefId__c=:refid];
        
        if(!apilist.isEmpty())
        {
            apilist[0].LtstRespCode__c= code;
            if(code=='Success'){
                apilist[0].LstSucesDtTime__c= Datetime.now();
            } 
            
            apilist[0].IsInvalid__c = code=='Failure'? true : false;
            
            apilist[0].RespDtTime__c= Datetime.now();
            
            apilist[0].CrntStatus__c = 'Completed';
            
            Update apilist;
        }
        
        
    }
    
    Public static void update_ApiTrackerWithIntMsg(Id intmsgid, string apiname, string refid, string code){
        
        list<IntgMsg__c> intgMsgList= [Select Id,Name,Svc__c,RefId__c,ParentRefId__c From IntgMsg__c WHERE Id =:intmsgid];
        if(!intgMsgList.isEmpty()){
            List<APICoutTrckr__c> updateTrackerList = new List<APICoutTrckr__c>();
            list<APICoutTrckr__c> apilist=[select id,IntgMsgName__c,APIName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                           from APICoutTrckr__c where  IntgMsgName__c=:intgMsgList[0].Name and APIName__c=:apiname and RefId__c=:refid AND ParentRefId__c=:intgMsgList[0].ParentRefId__c];
            Set<String> intgMsgNames= new Set<String>{'Dedupe API Token','UCIC API Token','Hunter Token','Consumer ACK Request','Commercial ACK Request'}; 
            Set<String> apiNames = new Set<String>{'Dedupe','UCIC','Hunter API','Cusomer Issue Request','Commercial Issue Request'};
            if(!apilist.isEmpty())
            {
                apilist[0].LtstRespCode__c= code;
                if(code=='Success'){
                    apilist[0].LstSucesDtTime__c= Datetime.now();
                    //Added by Ripul
                    //if(apilist[0].Retry__c == TRUE) {
                    //LAK-8774 - Changes Start 
                    apilist[0].Retry__c = FALSE;
                    apilist[0].Retry_Mode__c = 'NA';
                    if(!intgMsgNames.contains(apilist[0].IntgMsgName__c)){
                        apilist[0].Retry_Count__c = NULL;
                        apilist[0].MaxRetryExceeded__c = FALSE;
                    }
                    
                    if(apiNames.contains(apiname)){
                        if(apiname == 'Dedupe'){
                            list<APICoutTrckr__c> apiCountTrckrlist = getApiCountTrckrRecords('Dedupe API Token','Dedupe API Token',refId);
                            if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                apiCountTrckrlist[0].Retry_Count__c = NULL;
                                apiCountTrckrlist[0].MaxRetryExceeded__c = FALSE;
                                apiCountTrckrlist[0].Retry__c = FALSE;
                                apiCountTrckrlist[0].Retry_Mode__c = 'NA';
                                updateTrackerList.add(apiCountTrckrlist[0]);
                            }
                        }
                        else if(apiname == 'UCIC'){
                            list<APICoutTrckr__c> apiCountTrckrlist = getApiCountTrckrRecords('UCIC API Token','Dedupe API Token',refId);
                            if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                apiCountTrckrlist[0].Retry_Count__c = NULL;
                                apiCountTrckrlist[0].MaxRetryExceeded__c = FALSE;
                                apiCountTrckrlist[0].Retry__c = FALSE;
                                apiCountTrckrlist[0].Retry_Mode__c = 'NA';
                                updateTrackerList.add(apiCountTrckrlist[0]);
                            }
                        }
                        else if(apiname == 'Hunter API'){
                            list<APICoutTrckr__c> apiCountTrckrlist = getApiCountTrckrRecords('Hunter Token','Hunter Token',refId);
                            if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                apiCountTrckrlist[0].Retry_Count__c = NULL;
                                apiCountTrckrlist[0].MaxRetryExceeded__c = FALSE;
                                apiCountTrckrlist[0].Retry__c = FALSE;
                                apiCountTrckrlist[0].Retry_Mode__c = 'NA';
                                updateTrackerList.add(apiCountTrckrlist[0]);
                            }
                        }
                        else if(apiname == 'Cusomer Issue Request'){
                            list<APICoutTrckr__c> apiCountTrckrlist = getApiCountTrckrRecords('Consumer ACK Request','Consumer ACK Request',refId);
                            if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                apiCountTrckrlist[0].Retry_Count__c = NULL;
                                apiCountTrckrlist[0].MaxRetryExceeded__c = FALSE;
                                apiCountTrckrlist[0].Retry__c = FALSE;
                                apiCountTrckrlist[0].Retry_Mode__c = 'NA';
                                updateTrackerList.add(apiCountTrckrlist[0]);
                            }
                        }
                        else if(apiname == 'Commercial Issue Request'){
                            list<APICoutTrckr__c> apiCountTrckrlist = getApiCountTrckrRecords('Commercial ACK Request','Commercial ACK Request',refId);
                            if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                apiCountTrckrlist[0].Retry_Count__c = NULL;
                                apiCountTrckrlist[0].MaxRetryExceeded__c = FALSE;
                                apiCountTrckrlist[0].Retry__c = FALSE;
                                apiCountTrckrlist[0].Retry_Mode__c = 'NA';
                                updateTrackerList.add(apiCountTrckrlist[0]);
                            }
                        }
                    }
                    //LAK-8774 - Changes End 
                    //} 
                }
                else if(code == 'Failure') {
                    if(apiname != NULL) {
                        List<RetryConfig__mdt> rc = [SELECT id, IsActive__c from RetryConfig__mdt WHERE Svc__c =: apiname];
                        
                        if(!rc.isEmpty() && rc[0].IsActive__c == TRUE) {
                            if(apiname !='Dedupe' && apiname !='Hunter API' && apiname !='UCIC' && apiname !='Cusomer Issue Request' && apiname !='Commercial Issue Request' ){
                                apilist[0].Retry__c = TRUE;
                                apilist[0].Retry_Mode__c = 'Auto';
                            }
                            else{
                                if(apiname =='Dedupe'){
                                    list<APICoutTrckr__c> apiCountTrckrlist=[select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                           from APICoutTrckr__c where  IntgMsgName__c='Dedupe API Token' and APIName__c='Dedupe API Token' and RefId__c=:refid];
                                    if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                        apiCountTrckrlist[0].Retry__c = TRUE;
                                        apiCountTrckrlist[0].Retry_Mode__c = 'Auto';
                                        updateTrackerList.add(apiCountTrckrlist[0]);
                                    }
                                }
                                else if(apiname =='Hunter API'){
                                    list<APICoutTrckr__c> apiCountTrckrlist=[select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                           from APICoutTrckr__c where  IntgMsgName__c='Hunter Token' and APIName__c='Hunter Token' and RefId__c=:refid];
                                    if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                        apiCountTrckrlist[0].Retry__c = TRUE;
                                        apiCountTrckrlist[0].Retry_Mode__c = 'Auto';
                                        updateTrackerList.add(apiCountTrckrlist[0]);
                                    }
                                }
                                else if(apiname =='UCIC'){
                                    list<APICoutTrckr__c> apiCountTrckrlist=[select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                                                             from APICoutTrckr__c where  IntgMsgName__c='UCIC API Token' and APIName__c='Dedupe API Token' and RefId__c=:refid];
                                    if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                        apiCountTrckrlist[0].Retry__c = TRUE;
                                        apiCountTrckrlist[0].Retry_Mode__c = 'Auto';
                                        updateTrackerList.add(apiCountTrckrlist[0]);
                                    }
                                }
                                else if(apiname =='Cusomer Issue Request'){
                                    list<APICoutTrckr__c> apiCountTrckrlist=[select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                           from APICoutTrckr__c where  IntgMsgName__c='Consumer ACK Request' and APIName__c='Consumer ACK Request' and RefId__c=:refid];
                                    if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                        apiCountTrckrlist[0].Retry__c = TRUE;
                                        apiCountTrckrlist[0].Retry_Mode__c = 'Auto';
                                        updateTrackerList.add(apiCountTrckrlist[0]);
                                    }
                                }
                                else if(apiname =='Commercial Issue Request'){
                                    list<APICoutTrckr__c> apiCountTrckrlist=[select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c 
                                           from APICoutTrckr__c where  IntgMsgName__c='Commercial ACK Request' and APIName__c='Commercial ACK Request' and RefId__c=:refid];
                                    if(apiCountTrckrlist!=null && !apiCountTrckrlist.IsEmpty()){
                                        apiCountTrckrlist[0].Retry__c = TRUE;
                                        apiCountTrckrlist[0].Retry_Mode__c = 'Auto';
                                        updateTrackerList.add(apiCountTrckrlist[0]);
                                    }
                                }
                            }
                        }
                    }
                }
                
                apilist[0].IsInvalid__c = code=='Failure'? true : false;
                apilist[0].RespDtTime__c= Datetime.now();
                apilist[0].CrntStatus__c = 'Completed';
                
                //Update apilist;
                
                updateTrackerList.add(apilist[0]);
            }
            if(!updateTrackerList.isEmpty()){
                update updateTrackerList;
            }
            //Updating Integration Message
            if(intmsgid!=null && code!=null){
                
                IntgMsg__c msg =new IntgMsg__c();
                msg.id=intmsgid;
                msg.APIStatus__c=code;
                update msg;
                
            }
            
        }
    }
    
    
    Public static void update_ApiTrackerWithIntMsg(Id intmsgid,string code,List<ApiTrackerWrapper> apiTrackerRecords){
        
        if(apiTrackerRecords!=null && !apiTrackerRecords.isEmpty()){
            Set<String> intMsgNames = new Set<String>();
            Set<String> apiNames = new Set<String>();
            Set<String> refIds = new Set<String>();
            Map<String,ApiTrackerWrapper> apiTrackerMap = new Map<String,ApiTrackerWrapper>();
            Map<String,APICoutTrckr__c> apiCoutTrckrMap = new Map<String,APICoutTrckr__c>();
            Map<String,RetryConfig__mdt> retryConfigMap = new Map<String,RetryConfig__mdt>();
            for(ApiTrackerWrapper record : apiTrackerRecords){
                intMsgNames.add(record.intMsgName);
                apiNames.add(record.apiName);
                refIds.add(record.refId);
                apiTrackerMap.put(record.intMsgName + ':' + record.apiName + ':' + record.refId,record);
            }
            if(apiNames!=null && !apiNames.isEmpty()){
                for(RetryConfig__mdt rc : [SELECT id,Svc__c, IsActive__c from RetryConfig__mdt WHERE Svc__c IN: apiNames]){
                    retryConfigMap.put(rc.Svc__c,rc);
                }
            }
            for(APICoutTrckr__c record: [select id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c,APIName__c,RefId__c 
                                         from APICoutTrckr__c where  IntgMsgName__c IN:intMsgNames and APIName__c IN:apiNames AND RefId__c IN:refIds]){
                                             apiCoutTrckrMap.put(record.IntgMsgName__c + ':' + record.APIName__c + ':' + record.RefId__c,record);  
                                         }
            if(apiTrackerMap!=null && !apiTrackerMap.isEmpty()){
                List<APICoutTrckr__c> updateRecordsList = new List<APICoutTrckr__c>();
                for(String key: apiTrackerMap.keySet()){
                    if(apiCoutTrckrMap.containsKey(key)){
                        
                        APICoutTrckr__c apiTrckr = new APICoutTrckr__c();
                        apiTrckr.Id=apiCoutTrckrMap.get(key).Id;
                        ApiTrackerWrapper apiTracker  = apiTrackerMap.get(key);
                        apiTrckr.LtstRespCode__c= apiTracker.statusCode;
                        if(apiTracker.statusCode=='Success'){
                            apiTrckr.LstSucesDtTime__c= Datetime.now();
                            apiTrckr.Retry__c = FALSE;
                            apiTrckr.Retry_Count__c = NULL;
                            apiTrckr.Retry_Mode__c = 'NA';
                            apiTrckr.MaxRetryExceeded__c = FALSE;
                            
                        }
                        else if(apiTracker.statusCode == 'Failure') {
                            if(apiTracker.apiName != NULL && retryConfigMap.containsKey(apiTracker.apiName)) {
                                if(retryConfigMap.get(apiTracker.apiName).IsActive__c == TRUE) {
                                    apiTrckr.Retry__c = TRUE;
                                    apiTrckr.Retry_Mode__c = 'Auto';
                                }
                            }
                        }
                        apiTrckr.IsInvalid__c = apiTracker.statusCode=='Failure'? true : false;
                        apiTrckr.RespDtTime__c= Datetime.now();
                        apiTrckr.CrntStatus__c = 'Completed';
                        updateRecordsList.add(apiTrckr);   
                    }
                }
                if(updateRecordsList!=null && !updateRecordsList.isEmpty()){
                    update updateRecordsList;
                }
            }
        }
        
        if(intmsgid!=null && code!=null){
            IntgMsg__c msg =new IntgMsg__c();
            msg.id=intmsgid;
            msg.APIStatus__c=code;
            update msg;
        }
    }
    public static List<APICoutTrckr__c> getApiCountTrckrRecords(String intMsgName, String apiName, String refId){
       return [SELECT Id,IntgMsgName__c,LtstRespCode__c,LstSucesDtTime__c, IsInvalid__c, Retry__c FROM APICoutTrckr__c WHERE  IntgMsgName__c=:intMsgName AND APIName__c=:apiName AND RefId__c=:refId];                                   
    }
    Public Class ApiTrackerWrapper {
        public String intMsgName;
        public String apiName;
        public String refId;
        public String parentRefId;
        public String statusCode;
    }
}