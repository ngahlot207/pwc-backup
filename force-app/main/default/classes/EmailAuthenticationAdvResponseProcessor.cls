public class EmailAuthenticationAdvResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,EmailAuthenticationAdvResponseWrapper> successResponseMap = new Map<IntgMsg__c,EmailAuthenticationAdvResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            for(IntgMsg__c intmsg:responses){
                
                if(string.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        EmailAuthenticationAdvResponseWrapper  res =(EmailAuthenticationAdvResponseWrapper) JSON.deserialize(intmsg.Resp__c.replace('status-code','statuscode'),EmailAuthenticationAdvResponseWrapper.class);
                        
                        
                        //Success
                        if(Integer.valueof(res.statuscode) ==GlobalConstants.karza_Status_101){//101
                            successResponseMap.put(intmsg,res);
                        }
                        
                        //Failure
                        else if(Integer.valueof(res.statuscode) !=GlobalConstants.karza_Status_101){
                            failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(Integer.valueof(res.statuscode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueof(res.statuscode)):'');
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
    }
    //***************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,EmailAuthenticationAdvResponseWrapper> successResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Applicant__c> applicantMap;
            List<Applicant__c> applicantList = new List<Applicant__c>();
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            Map<Id,List<APIVerDtl__c>> apiVerificationDetailMap	 =new Map<Id,List<APIVerDtl__c>>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('EmailAuthAdvance').getRecordTypeId();
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            if(!applicantIds.isEmpty()){
                
                applicantMap=new Map<Id,Applicant__c>([Select Id,LoanAppln__c from Applicant__c Where Id IN:applicantIds]);
                
                
                //Making Islatest False
                Set<String> recordTypeDeveloperName =New Set<String>{'OfficialEmail','EmailAuthAdvance'};
                List<APIVer__c>  apiver =[Select Id,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName IN:recordTypeDeveloperName
                                          AND Appl__c IN:applicantIds AND IsLatest__c=True];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver,'IsLatest__c',false);
                }
            }
            
            IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Email_Verification');
            
            //Processing the Response
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c)){
                    
                    EmailAuthenticationAdvResponseWrapper resp =successResp.get(intmsg);
                    
                    if(resp!=null && resp.result!=null){
                        
                        APIVer__c veri =new APIVer__c();
                        veri.Appl__c=intmsg.RefId__c;
                        veri.LoanAplcn__c=string.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__c:'';
                        veri.RecordTypeId=recordTypeId;
                        veri.IsLatest__c=true;
                        veri.IntegrationStatus__c='Success';
                        
                         //Updating Applicant
                        Applicant__c app =new Applicant__c();
                        app.Id=intmsg.RefId__c;
                        
                        if(resp.result.data!=null && String.isNotblank(resp.result.data.result) && 
                           containsValidStatus(resp.result.data.result.tolowercase(),svc.ProcessCode__c.tolowercase())){
                               app.EmailVerified__c=true;
                               app.EmailIDverificationStatus__c = 'Verified';
                           }
                        
                        else{
                            app.EmailVerified__c=false;
                            app.EmailIDverificationStatus__c = 'Failed';
                        }
                        applicantList.add(app);
                        
                        //additional_info
                        if(resp.result.additional_info!=null){
                            
                            //company_info
                            if(resp.result.additional_info.company_info!=null){
                                
                                //org_domain_match
                                if(resp.result.additional_info.company_info.org_domain_match!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> orgMatchResult=orgMatch(resp.result.additional_info.company_info.org_domain_match,intmsg.RefId__c,'org_domain_match');
                                    
                                    if(orgMatchResult!=null){
                                        
                                        for(Id keyvalue : orgMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(orgMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, orgMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                                
                                //org_email_match
                                if(resp.result.additional_info.company_info.org_email_match!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> orgMatchResult=orgMatch(resp.result.additional_info.company_info.org_email_match,intmsg.RefId__c,'org_email_match');
                                    
                                    if(orgMatchResult!=null){
                                        
                                        for(Id keyvalue : orgMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(orgMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, orgMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                                
                                //usr_director_match
                                if(resp.result.additional_info.company_info.usr_director_match!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> usrMatchResult=usrAndIndividualMatch(resp.result.additional_info.company_info.usr_director_match,intmsg.RefId__c,'usr_director_match');
                                    
                                    if(usrMatchResult!=null){
                                        
                                        for(Id keyvalue : usrMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(usrMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, usrMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                            }
                            
                            //individual_match
                            if(resp.result.additional_info.individual_match!=null){
                                
                                Map<Id, List<APIVerDtl__c>> individualMatchResult=usrAndIndividualMatch(resp.result.additional_info.individual_match,intmsg.RefId__c,'individual_match');
                                    
                                    if(individualMatchResult!=null){
                                        
                                        for(Id keyvalue : individualMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(individualMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, individualMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                            }
                            
                            //spam_record
                            if(resp.result.additional_info.spam_record!=null){
                                
                                EmailAuthenticationAdvResponseWrapper.SpamRecord SpmRec=resp.result.additional_info.spam_record;
                                
                                if(SpmRec.spam_email!=null && SpmRec.spam_email){
                                    veri.SpamEmail__c=SpmRec.spam_email;
                                }
                                
                                if(SpmRec.report_count!=null){
                                    veri.RptCount__c=SpmRec.report_count;
                                }
                                
                                if(SpmRec.ip_blacklist!=null && SpmRec.ip_blacklist){
                                    veri.IPBlacklist__c=SpmRec.ip_blacklist;
                                }
                            }
                            
                            //whois_info
                            if(resp.result.additional_info.whois_info!=null){
                                
                                EmailAuthenticationAdvResponseWrapper.WhoIsInfo whoInfo=resp.result.additional_info.whois_info;
                                
                                if(whoInfo.age_year!=null){
                                   veri.Age__c= whoInfo.age_year;
                                }
                                
                                if(String.isNotblank(whoInfo.creation_date)){
                                   veri.CrtDateTime__c= Datetime.valueOf(whoInfo.creation_date);
                                }
                                
                                if(String.isNotblank(whoInfo.expiration_date)){
                                   veri.ExpDateTime__c= Datetime.valueOf(whoInfo.expiration_date);
                                }
                                
                                if(String.isNotblank(whoInfo.update_date)){
                                   veri.UpdateDateTime__c= Datetime.valueOf(whoInfo.update_date);
                                }
                                
                                if(whoInfo.expired!=null && whoInfo.expired){
                                    veri.Expired__c= whoInfo.expired;
                                }
                                
                                //whois_email_domain_match
                                if(whoInfo.whois_email_domain_match!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> emailDomainMatchResult=whoEmailMatch(whoInfo.whois_email_domain_match,intmsg.RefId__c,'whois_email_domain_match');
                                    
                                    if(emailDomainMatchResult!=null){
                                        
                                        for(Id keyvalue : emailDomainMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(emailDomainMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, emailDomainMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                                
                                //whois_email_match
                                if(whoInfo.whois_email_domain_match!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> emailMatchResult=whoEmailMatch(whoInfo.whois_email_match,intmsg.RefId__c,'whois_email_match');
                                    
                                    if(emailMatchResult!=null){
                                        
                                        for(Id keyvalue : emailMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(emailMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, emailMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                                
                                //whois_indv_name
                                if(whoInfo.whois_indv_name!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> nameMatchResult=whoNameMatch(whoInfo.whois_indv_name,intmsg.RefId__c,'whois_indv_name');
                                    
                                    if(nameMatchResult!=null){
                                        
                                        for(Id keyvalue : nameMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(nameMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, nameMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                                
                                //whois_org_name
                                if(whoInfo.whois_org_name!=null){
                                    
                                    Map<Id, List<APIVerDtl__c>> orgNameMatchResult=whoNameMatch(whoInfo.whois_org_name,intmsg.RefId__c,'whois_org_name');
                                    
                                    if(orgNameMatchResult!=null){
                                        
                                        for(Id keyvalue : orgNameMatchResult.keySet()) {
                                            
                                            if(apiVerificationDetailMap.containsKey(keyvalue)) {
                                                apiVerificationDetailMap.get(keyvalue).addAll(orgNameMatchResult.get(keyvalue));
                                            }
                                            else{
                                                apiVerificationDetailMap.put(keyvalue, orgNameMatchResult.get(keyvalue));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        //data
                        if(resp.result.data!=null){
                            
                            EmailAuthenticationAdvResponseWrapper.Data data=resp.result.data;
                            
                            if(data.disposable!=null && data.disposable){
                              veri.disposable__c= data.disposable; 
                            }
                            
                            if(data.webmail!=null && data.webmail){
                                veri.webmail__c= data.webmail;
                            }
                            
                            if(String.isNotblank(data.result)){
                                veri.Result__c= data.result;
                            }
                            
                            if(data.accept_all!=null && data.accept_all){
                                veri.acceptAll__c= data.accept_all;
                            }
                            
                            if(data.smtp_check!=null && data.smtp_check){
                                veri.smtpCheck__c= data.smtp_check;
                            }
                            
                            if(data.regexp!=null && data.regexp){
                                veri.regexp__c= data.regexp;
                            }
                            
                            if(data.mx_records!=null && data.mx_records){
                                veri.mxRecords__c= data.mx_records;
                            }
                            
                            if(String.isNotblank(data.email)){
                                veri.Email__c= data.email;
                            }
                            
                            if(data.smtp_server!=null && data.smtp_server){
                                veri.SmtpServer__c= data.smtp_server;
                            }
                            
                            if(data.is_blocked!=null && data.is_blocked){
                                veri.IsBlocked__c= data.is_blocked;
                            }
                            
                            if(String.isNotblank(data.reason)){
                                veri.Reason__c= data.reason;
                            }
                            
                            if(data.generic_email!=null && data.generic_email){
                                veri.GenericEmail__c=data.generic_email;
                            }
                        }
                        
                        //result_summary
                        if(resp.result.result_summary!=null){
                            
                            EmailAuthenticationAdvResponseWrapper.ResultSummary resSummary=resp.result.result_summary;
                            
                            if(resSummary.email_valid!=null && resSummary.email_valid ){
                                veri.ValidEmail__c=resSummary.email_valid;
                            }
                            else if(resp.result.data!=null && String.isNotblank(resp.result.data.result) && 
                                    containsValidStatus(resp.result.data.result.tolowercase(),svc.ProcessCode__c.tolowercase())){
                                veri.ValidEmail__c=true;
                            }
                            
                            if(resSummary.org_domain_match!=null && resSummary.org_domain_match ){
                                veri.OrgDomainMatch__c=resSummary.org_domain_match;
                            }
                            
                            if(resSummary.indv_flag!=null && resSummary.indv_flag ){
                                veri.Invalid__c=resSummary.indv_flag;
                            }
                            
                            if(String.isNotblank(resSummary.overall_result)){
                                veri.OverallResult__c=resSummary.overall_result;
                            }
                        }
                        
                        apiVerList.add(veri);
                    }
                }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }
            
            if(!applicantList.isEmpty()){
                Update applicantList;
            }
            
            if(!apiVerList.isEmpty()){
                
                Insert apiVerList;
                
                if(!apiVerificationDetailMap.isEmpty()){
                    creatAPIVerDtl(apiVerificationDetailMap);
                }
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    
    //***************************************************************************************************************************************
    public static Map<Id, List<APIVerDtl__c>> orgMatch(List<EmailAuthenticationAdvResponseWrapper.OrgMatch> orgMatchresponse, Id applicantId, String responseTag) {
    
        Map<Id, List<APIVerDtl__c>> verificationDetailMap = new Map<Id, List<APIVerDtl__c>>();
    
    try {
        List<APIVerDtl__c> verDtlList = new List<APIVerDtl__c>();
        
        if (String.isNotBlank(responseTag)) {
            
            for (EmailAuthenticationAdvResponseWrapper.OrgMatch orgmtch : orgMatchresponse) {
                
                APIVerDtl__c verDtl = new APIVerDtl__c();
                verDtl.Type__c = responseTag.equalsIgnoreCase('org_domain_match') ? 'Email Org Domain Match' : 'Email Org Email Match';
                
                if (String.isNotBlank(orgmtch.domain)) {
                    verDtl.Domain__c = orgmtch.domain;
                }
                
                if (orgmtch.match != null && orgmtch.match) {
                    verDtl.Match__c = orgmtch.match;
                }
                
                if (String.isNotBlank(orgmtch.org_name)) {
                    verDtl.OrgName__c = orgmtch.org_name;
                }
                
                if (String.isNotBlank(orgmtch.company_email)) {
                    verDtl.CmpyEmail__c = orgmtch.company_email;
                }
                
                if (orgmtch.source != null) {
                    verDtl.Source__c = String.join(orgmtch.source, ',');
                }
                
                verDtlList.add(verDtl);
            }
            
            verificationDetailMap.put(applicantId, verDtlList);
        }
        
    } catch (Exception ex) {
       GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor class', 
                                  'orgMatch', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
    }
    
    return verificationDetailMap;
}
    
    //***************************************************************************************************************************************
    public static Map<Id, List<APIVerDtl__c>> usrAndIndividualMatch(List<EmailAuthenticationAdvResponseWrapper.UsrAndIndividualMatch> usrMatchresponse, Id applicantId,String responseTag){
        
        Map<Id, List<APIVerDtl__c>> verificationDetailMap = new Map<Id, List<APIVerDtl__c>>();
        
        try{
            
            List<APIVerDtl__c> verDtlList = new List<APIVerDtl__c>();
            
            for (EmailAuthenticationAdvResponseWrapper.UsrAndIndividualMatch usrindmtch : usrMatchresponse) {
                
                APIVerDtl__c verDtl = new APIVerDtl__c();
                verDtl.Type__c =responseTag.equalsIgnoreCase('usr_director_match')?'Email User Director Match':'Email Individual Match';
                
                if (usrindmtch.match != null && usrindmtch.match) {
                    verDtl.Match__c = usrindmtch.match;
                }
                
                if (String.isNotBlank(usrindmtch.name)) {
                    verDtl.Name__c = usrindmtch.name;
                }
                
                 if (String.isNotBlank(usrindmtch.org_name)) {
                    verDtl.OrgName__c = usrindmtch.org_name;
                }
                
                if (usrindmtch.score!=null) {
                    verDtl.Score__c = String.valueOf(usrindmtch.score);
                }
                
                verDtlList.add(verDtl);
            }
            verificationDetailMap.put(applicantId, verDtlList);
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'usrAndIndividualMatch', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        return verificationDetailMap;
    }
    //***************************************************************************************************************************************
    public static Map<Id, List<APIVerDtl__c>> whoEmailMatch(List<EmailAuthenticationAdvResponseWrapper.WhoIsEmailMatch> emailMatchResponse,Id applicantId, String responseTag){
        
        Map<Id, List<APIVerDtl__c>> verificationDetailMap = new Map<Id, List<APIVerDtl__c>>();
        
        try{
            
            List<APIVerDtl__c> verDtlList = new List<APIVerDtl__c>();
            
            for(EmailAuthenticationAdvResponseWrapper.WhoIsEmailMatch emailMtch:emailMatchResponse){
                
                APIVerDtl__c verDtl = new APIVerDtl__c();
                verDtl.Type__c =responseTag.equalsIgnoreCase('whois_email_domain_match')?'Email Whois Email Domain Match':'Email Whois Email Match';
            
                if(String.isNotblank(emailMtch.domain)){
                    verDtl.Domain__c=emailMtch.domain;
                }
                
                if(String.isNotblank(emailMtch.company_email)){
                    verDtl.CmpyEmail__c=emailMtch.company_email;
                }
                
                if(emailMtch.match!=null && emailMtch.match){
                    verDtl.Match__c=emailMtch.match;
                }
               verDtlList.add(verDtl);
            }
             verificationDetailMap.put(applicantId, verDtlList);
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'whoEmailMatch', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
        return verificationDetailMap;
    }
    //***************************************************************************************************************************************
    public static Map<Id, List<APIVerDtl__c>> whoNameMatch(List<EmailAuthenticationAdvResponseWrapper.WhoIsIndvAndOrgName> nameMatchResponse,Id applicantId, String responseTag){
        
        Map<Id, List<APIVerDtl__c>> verificationDetailMap = new Map<Id, List<APIVerDtl__c>>();
        
        try{
            List<APIVerDtl__c> verDtlList = new List<APIVerDtl__c>();
            
            for(EmailAuthenticationAdvResponseWrapper.WhoIsIndvAndOrgName nameMtch:nameMatchResponse){
            
                APIVerDtl__c verDtl = new APIVerDtl__c();
                verDtl.Type__c =responseTag.equalsIgnoreCase('whois_indv_name')?'Email Whois Indv Name':'Email Whois Org Name';
            
                if(String.isNotblank(nameMtch.name)){
                    verDtl.Name__c=nameMtch.name;
                }
                
                if(String.isNotblank(nameMtch.org_name)){
                    verDtl.OrgName__c=nameMtch.org_name;
                }
                
                if(nameMtch.match!=null && nameMtch.match){
                    verDtl.Match__c=nameMtch.match;
                }
                
                if(nameMtch.score!=null){
                    verDtl.Score__c=String.valueOf(nameMtch.score);
                }
                
                verDtlList.add(verDtl);
            }
            
             verificationDetailMap.put(applicantId, verDtlList);
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'whoNameMatch', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        return verificationDetailMap;
    }
    //***************************************************************************************************************************************
    public static void creatAPIVerDtl(Map<Id,List<APIVerDtl__c>> apiVeriDetailMap){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVerDtl__c> VerificationDtl =new List<APIVerDtl__c>();
            
            for(Id appId:apiVeriDetailMap.keyset()){
                applicantIds.add(appId);
            }
            
            Map<Id,Id> apiVerificationMap =new Map<Id,Id>();//[Select Id,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName='EmailAuthAdvance'
                                                                         //AND Appl__c IN:applicantIds AND IsLatest__c=True]);
           
            for(APIVer__c apiver:[Select Id,Appl__c,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName='EmailAuthAdvance'
                                 AND Appl__c IN:applicantIds AND IsLatest__c=True]){
                
                                     apiVerificationMap.put(apiver.Appl__c,apiver.id);
            }
            
             for(Id appId:apiVeriDetailMap.keyset()){
                 
                 if(!apiVerificationMap.isEmpty() && apiVerificationMap.containsKey(appId)){
                     
                     list<APIVerDtl__c>  verificationDetail=apiVeriDetailMap.get(appId);
                     
                     
                     if(!verificationDetail.isEmpty()){
                         
                         for(APIVerDtl__c dtl:verificationDetail){
                             
                             dtl.APIVerification__c=apiVerificationMap.get(appId);
                             
                             VerificationDtl.add(dtl);
                         }
                     }
                 }
                
                 
            }
            
            if(!VerificationDtl.isEmpty()){
                Insert VerificationDtl;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'creatAPIVerDtl', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    
    //***************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Applicant__c> applicantMap;
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            List<Applicant__c> applicantList = new List<Applicant__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('EmailAuthAdvance').getRecordTypeId();
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            
            if(!applicantIds.isEmpty()){
                
                applicantMap=new Map<Id,Applicant__c>([Select Id,LoanAppln__c from Applicant__c Where Id IN:applicantIds]);
                
                
                //Making Islatest False
                Set<String> recordTypeDeveloperName =New Set<String>{'OfficialEmail','EmailAuthAdvance'};
                List<APIVer__c>  apiver =[Select Id,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName IN:recordTypeDeveloperName
                                          AND Appl__c IN:applicantIds AND IsLatest__c=True];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver,'IsLatest__c',false);
                }
            }
            
            //Processing the Response
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(applicantMap.ContainsKey(intmsg.RefId__c)){
                    
                    
                    Applicant__c app =new Applicant__c();
                    app.Id=intmsg.RefId__c;
                    app.EmailVerified__c=false;
                    app.EmailIDverificationStatus__c = 'Failed';
                    applicantList.add(app); 
                    
                    
                    APIVer__c apiver =new APIVer__c();
                    apiver.Appl__c=applicantMap.get(intmsg.RefId__c).Id;
                    apiver.LoanAplcn__c=String.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__c:'';
                    apiver.IsLatest__c=true;
                    apiver.RecordTypeId=recordTypeId;
                    apiver.IntegrationStatus__c='Failure';
                    apiver.IntegrationErrorMessage__c=failureResp.get(intmsg);
                    apiVerList.add(apiver);
                    
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                }
                
                
            }
            
            if(!applicantList.isEmpty()){
                Update applicantList;
            }
            
            if(!apiVerList.isEmpty()){
                Insert apiVerList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //***************************************************************************************************************************************
    public Static Boolean containsValidStatus(String responseResult, String validKey){
        
        List<String> statusList = validKey.split(',');
        
        for (String metadataValues : statusList) {
            if (responseResult.contains(metadataValues)) {
                return true;
            }
        }
        return false;
    }
}