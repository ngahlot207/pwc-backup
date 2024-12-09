public class HRMSAPIResponseProcessor implements IintMsgCalloutResponseProcessor{
    private static boolean isException =false;
    public static void process(List<IntgMsg__c> responses) {
        system.debug(':::');
        Set<Id> ids = new Set<Id>();
        Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
        Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
        
        if(!responses.isempty()){
            //Getting IntgMsg__c Id 
            for (IntgMsg__c integrationMessage : responses) {
                ids.add(integrationMessage.Id);
            } 
        }
        
        if(!ids.isempty()){
            //Getting ContentDocumentId 
            for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:ids AND 
                                         ContentDocument.Title = 'response.json']){//response.json,hrms testdata (1), hrms testdata (2), manager change, email,HRMScreateNew,HRMSInactiveUser,NewHRMSTestDataInActive
                                             ContentDocumentMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);   
                                         }
            //Getting VersionData 
            for(ContentVersion cv:[SELECT Id, VersionData,FileType,ContentDocumentId FROM ContentVersion
                                   WHERE ContentDocumentId IN:ContentDocumentMap.values()]){
                                       ContentVersionMap.put(cv.ContentDocumentId,cv);
                                   }
        }
        
        if(!ContentVersionMap.isempty()){
            
            for(IntgMsg__c intMsg : responses){
                
                if(ContentDocumentMap.containskey(intMsg.id) && ContentVersionMap.containskey(ContentDocumentMap.get(intMsg.id))){
                    
                    ContentVersion cvdata=ContentVersionMap.get(ContentDocumentMap.get(intMsg.id));
                    
                    if(cvdata!=null){
                        String jsonContent = cvdata.VersionData.toString();
                        
                        try{
                             HRMSQueueable queueableInstance = new HRMSQueueable(jsonContent);
                             System.enqueueJob(queueableInstance);
                        }
                        catch(Exception ex){
                            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        }
                    }
                    
                }
                
            }
        }
        
    }
    //****************************************************************************************************************
    public static void processSuccessResponse(HRMSAPIResponseWrapper res){
        
        if(res!=null && res.Data!=null){
            try{
                system.debug('1');
                Set<String> employeeNumbers=new Set<String>();
                Set<String> exitedUsers =new Set<String>();
                //Set<Id> roleChangedUserIds =new Set<Id>();
                Set<String> empnumbers =new Set<String>();
                
                //List<User> upsertUserList =new List<User>();
				Map<String,User> upsertUserMap = new Map<String,User>();				
                
                Map<String,HRMSDesignation__c> hrmsDesignationMap = new Map<String,HRMSDesignation__c>();
                Map<String,HRMSDepartment__c> hrmsDepartmentMap = new Map<String,HRMSDepartment__c>();
                
                for(HRMSDepartment__c hrmsdept :HRMSDepartment__c.getAll().values()){
                    hrmsDepartmentMap.put(hrmsdept.HRMSDepartment__c,hrmsdept);
                }
                for(HRMSDesignation__c hrms : [SELECT Id, Name,HRMSDesignation__c, SFDCRole__c, SFDCDepartment__c  FROM HRMSDesignation__c]){
                    hrmsDesignationMap.put(hrms.HRMSDesignation__c,hrms);
                }
                Map<String,HRMSConfig__c> HRMSConfigMap = HRMSConfig__c.getAll();
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Get_HRMS_Details');
                Map<String,Profile> profileMap = new Map<String,Profile>();
                for(Profile pr : [SELECT ID,Name from Profile WHERE Name IN ('LOS Base User','System Administrator')]){
                    profileMap.put(pr.Name,pr);
                }
                
                Map<String,HRMSAPIResponseWrapper.Data> empDataMap = new Map<String,HRMSAPIResponseWrapper.Data>();
                Set<String> branchCodes = new Set<String>();
                Set<String> priorBranchCodes = new Set<String>();
                //Record update
                Map<Id,Id> recordUpdateMap =new Map<Id,Id>();
                
                
                //Getting all User based on resposne
                Map<String,User> UserdetailsMap =new Map<String,User>();
                for(User us:[Select id,Name,EmployeeNumber,FirstName,MiddleName,LastName,Email,MobilePhone,IsActive,Department,Division,L1ManagerCode__c,BrnchCode__c,HRMSDepartment__c from User Where EmployeeNumber!=null]){
                    UserdetailsMap.put(us.EmployeeNumber,us);
                }
                
                //Send Email
               // Map<User,List<User>> userManagersEmailMap = new Map<User,List<User>>();
               Map<String,List<User>> userManagersEmailMap = new Map<String,List<User>>();
                
                //
                List<TeamHierarchy__c> existingTeamHierarchyList = new List<TeamHierarchy__c>();
                Map<Id,TeamHierarchy__c> existingTeamHierarchyMap = new Map<Id,TeamHierarchy__c>();
                for(HRMSAPIResponseWrapper.Data responsedata:res.Data){
                    if(String.isnotBlank(responsedata.emp_code)){
                        employeeNumbers.add(responsedata.emp_code);
                    }
                }
                Map<String,Map<String,TeamHierarchy__c>> teamHierarchyMap =new Map<String,Map<String,TeamHierarchy__c>>();
                for(TeamHierarchy__c th : [SELECT Id, Product_Type__c, IsActive__c, Employee__c,Employee__r.EmployeeNumber, EmpLevel__c, EmpRole__c,EmpBrch__r.BrchCode__c,EmpStartDt__c, EmpEndDt__c, Supervisor__c,Supervisor__r.Employee__r.EmployeeNumber, ValidFrm__c, ValidThru__c, LstAssDtTime__c from TeamHierarchy__c  WHERE  Employee__r.EmployeeNumber IN:employeeNumbers AND IsActive__c=TRUE]){
                    
                    if(teamHierarchyMap.containskey(th.Employee__r.EmployeeNumber)){
                        teamHierarchyMap.get(th.Employee__r.EmployeeNumber).put(th.EmpBrch__r.BrchCode__c,th);
                    }
                    else{
                        teamHierarchyMap.put(th.Employee__r.EmployeeNumber,new Map<String,TeamHierarchy__c>{th.EmpBrch__r.BrchCode__c=>th});
                    }
                    
                }
                //Processing Response
                for(HRMSAPIResponseWrapper.Data responsedata:res.Data){
                    
                    if(String.isnotBlank(responsedata.last_name) && String.isnotBlank(responsedata.emp_code) && String.isnotBlank(responsedata.off_email_add) && String.isnotBlank(responsedata.branch_code)){
                        //If user present In SFDC
                        if(UserdetailsMap.containskey(responsedata.emp_code) && hrmsDesignationMap.Containskey(responsedata.designation)){
                            User usr =UserdetailsMap.get(responsedata.emp_code);
                            system.debug('2' + ':::' +responsedata.emp_status +isActiveMap.containsKey(responsedata.emp_status) + '::' + usr.IsActive + ':::' +  isActiveMap.get(responsedata.emp_status));
                            //Updating User
                            if(Boolean.valueOf(System.label.HRMSProcessAllRecords) || usr.FirstName!=responsedata.first_name  || usr.MiddleName!=responsedata.middle_name ||
                               usr.LastName!=responsedata.last_name    ||usr.Email!=responsedata.off_email_add ||
                               usr.MobilePhone!=responsedata.mobile_no ||(isActiveMap.containsKey(responsedata.emp_status) && usr.IsActive != isActiveMap.get(responsedata.emp_status))||
                               usr.Department!=hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c ||usr.Division!=hrmsDesignationMap.get(responsedata.designation).SFDCRole__c ||
                               usr.EmployeeNumber!=responsedata.emp_code || usr.BrnchCode__c!=responsedata.branch_code ||
                               usr.L1ManagerCode__c!=responsedata.l1_manager_code || usr.HRMSDepartment__c!=responsedata.department){
                                   
                                   User ur =new User();
                                   ur.Id=usr.Id;
                                   ur.EmployeeNumber = string.isnotblank(responsedata.emp_code) ? responsedata.emp_code:'';
                                   ur.FirstName=string.isnotblank(responsedata.first_name)?responsedata.first_name:'';
                                   ur.MiddleName=string.isnotblank(responsedata.middle_name)?responsedata.middle_name:'';
                                   ur.LastName=string.isnotblank(responsedata.last_name)?responsedata.last_name:'';
                                   ur.Email=string.isnotblank(responsedata.off_email_add)?responsedata.off_email_add:'';
                                   ur.MobilePhone=string.isnotblank(responsedata.mobile_no)?responsedata.mobile_no:'';
                                   ur.HRMSDepartment__c=string.isnotblank(responsedata.department)?responsedata.department:'';
                                   if(responsedata.emp_status=='Exited' || (!hrmsDepartmentMap.containsKey(responsedata.department) && string.isNotBlank(hrmsDepartmentMap.get(responsedata.department).SFDCProduct__c))){
                                       ur.IsActive=false;
                                       ur.username = usr.Email+'.invalid';
                                       //User manager1;
                                       //User manager2;
                                       
                                       if(UserdetailsMap.containskey(responsedata.l1_manager_code)){
                                           User manager1 =UserdetailsMap.get(responsedata.l1_manager_code);
                                           
                                           //Checking Manager to send Email
                                           if(userManagersEmailMap.containskey(usr.EmployeeNumber)){
                                               userManagersEmailMap.get(usr.EmployeeNumber).add(manager1);
                                           }
                                           else{
                                               userManagersEmailMap.put(usr.EmployeeNumber,new list<User>{manager1});
                                           }
                                       }
                                       if(UserdetailsMap.containskey(responsedata.l2_manager_code)){
                                           User manager2 =UserdetailsMap.get(responsedata.l2_manager_code);
                                           
                                           //Checking Manager to send Email
                                           if(userManagersEmailMap.containskey(usr.EmployeeNumber)){
                                               userManagersEmailMap.get(usr.EmployeeNumber).add(manager2);
                                           }
                                           else{
                                               userManagersEmailMap.put(usr.EmployeeNumber,new list<User>{manager2});
                                           }
                                       }
                                       //Adding ExitedUserId
                                       //exitedUserIds.add(ur.Id);
                                       recordUpdateMap.put(ur.Id,UserdetailsMap.containsKey(responsedata.l1_manager_code) ?UserdetailsMap.get(responsedata.l1_manager_code).Id : null);
                                       exitedUsers.add(usr.EmployeeNumber);
                                       /* if(teamHierarchyMap.containsKey(responsedata.emp_code)){
                                        //existingTeamHierarchyList.addALL(teamHierarchyMap.get(responsedata.emp_code).values());
                                        if(!teamHierarchyMap.get(responsedata.emp_code).values().isEmpty()){
                                        for(TeamHierarchy__c th: teamHierarchyMap.get(responsedata.emp_code).values()){
                                        existingTeamHierarchyMap.put(th.Id,th);
                                        }
                                        }
                                        }*/   
                                   }
                                   ur.Department = (string.isnotblank(responsedata.designation) && hrmsDesignationMap.containsKey(responsedata.designation)) ? hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c : '';
                                   
                                   if(string.isnotblank(responsedata.designation) && usr.Division!=hrmsDesignationMap.get(responsedata.designation).SFDCRole__c){
                                       ur.Division =  (string.isnotblank(responsedata.designation) && hrmsDesignationMap.containsKey(responsedata.designation)) ? hrmsDesignationMap.get(responsedata.designation).SFDCRole__c : '';
                                       //roleChangedUserIds.add(ur.id);
                                       if(teamHierarchyMap.containsKey(responsedata.emp_code) && teamHierarchyMap.get(responsedata.emp_code).containsKey(usr.BrnchCode__c)){
                                           //existingTeamHierarchyList.add(teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c));
                                           if(usr.Division == 'RM' || usr.Division == 'SM' || usr.Division == 'BBH'){
                                               existingTeamHierarchyMap.put(teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c).Id,teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c));
                                           }
                                       }
                                       empnumbers.add(ur.EmployeeNumber);
                                       if(!Boolean.valueOf(System.label.HRMSProcessAllRecords)){
                                           branchCodes.add(responsedata.branch_code);
                                           empDataMap.put(responsedata.emp_code, responsedata);
                                       }
                                   }
                                   
                                   if(string.isnotblank(responsedata.branch_code) && usr.BrnchCode__c!=responsedata.branch_code){
                                       ur.BrnchCode__c=string.isnotBlank(responsedata.branch_code)?responsedata.branch_code:'';
                                       if(teamHierarchyMap.containsKey(responsedata.emp_code) && teamHierarchyMap.get(responsedata.emp_code).containsKey(usr.BrnchCode__c)){
                                           //existingTeamHierarchyList.add(teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c));
                                           if(usr.Division == 'RM' || usr.Division == 'SM' || usr.Division == 'BBH'){
                                               existingTeamHierarchyMap.put(teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c).Id,teamHierarchyMap.get(responsedata.emp_code).get(usr.BrnchCode__c));
                                           }
                                       }
                                       if(!Boolean.valueOf(System.label.HRMSProcessAllRecords)){
                                           branchCodes.add(responsedata.branch_code);
                                           empDataMap.put(responsedata.emp_code, responsedata);
                                       }
                                       
                                       if(usr.BrnchCode__c!=null && String.isNotBlank(usr.BrnchCode__c)){
                                           priorBranchCodes.add(usr.BrnchCode__c);
                                       }
                                   }
                                   
                                   if(string.isnotblank(responsedata.l1_manager_code) && usr.L1ManagerCode__c!=responsedata.l1_manager_code){
                                       ur.L1ManagerCode__c=string.isnotBlank(responsedata.l1_manager_code)?responsedata.l1_manager_code:'';
                                       if(!Boolean.valueOf(System.label.HRMSProcessAllRecords)){
                                           branchCodes.add(responsedata.branch_code);
                                           empDataMap.put(responsedata.emp_code, responsedata);
                                       }
                                   }
                                   
                                   if(Boolean.valueOf(System.label.HRMSProcessAllRecords)){
                                       branchCodes.add(responsedata.branch_code);
                                       empDataMap.put(responsedata.emp_code, responsedata);
                                   }
                                   //upsertUserList.add(ur);
                                   upsertUserMap.put(responsedata.emp_code,ur);
                               }
                        }
                        //If user Not present In SFDC
                        else{
                            system.debug('3');
                            //Creating User
                            if(hrmsDepartmentMap.containskey(responsedata.department) && string.isNotBlank(hrmsDepartmentMap.get(responsedata.department).SFDCProduct__c) &&  hrmsDesignationMap.Containskey(responsedata.designation) && (isActiveMap.containsKey(responsedata.emp_status) && isActiveMap.get(responsedata.emp_status))){
                                User ur =new User();
                                ur.IsActive=true;
                                ur.FirstName=string.isnotblank(responsedata.first_name)?responsedata.first_name:'';
                                ur.MiddleName=string.isnotblank(responsedata.middle_name)?responsedata.middle_name:'';
                                ur.LastName=string.isnotblank(responsedata.last_name)?responsedata.last_name:'';
                                ur.Email=string.isnotblank(responsedata.off_email_add)?responsedata.off_email_add:'';
                                ur.MobilePhone=string.isnotblank(responsedata.mobile_no)?responsedata.mobile_no:'';
                                ur.HRMSDepartment__c=string.isnotblank(responsedata.department)?responsedata.department:'';
                                ur.Department = (string.isnotblank(responsedata.designation) && hrmsDesignationMap.containsKey(responsedata.designation)) ? hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c : '';
                                ur.Division =  (string.isnotblank(responsedata.designation) && hrmsDesignationMap.containsKey(responsedata.designation)) ? hrmsDesignationMap.get(responsedata.designation).SFDCRole__c : '';
                                ur.EmployeeNumber=string.isnotblank(responsedata.emp_code)?responsedata.emp_code:'';
                                ur.FederationIdentifier = (string.isnotblank(responsedata.emp_code) && string.isnotblank(svc.Domain__c))?responsedata.emp_code + '@' + svc.Domain__c:'';
                                ur.Username=string.isnotblank(responsedata.off_email_add)?String.isNotBlank(svc.Organization__c) ? responsedata.off_email_add + +'.'+svc.Organization__c : responsedata.off_email_add:'';
                                ur.TimeZoneSidKey='Asia/Kolkata';
                                ur.ProfileId= (string.isnotblank(responsedata.designation) && hrmsDesignationMap.containsKey(responsedata.designation) && HRMSConfigMap.containsKey(hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c + '-' + hrmsDesignationMap.get(responsedata.designation).SFDCRole__c) &&  profileMap.containsKey(HRMSConfigMap.get(hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c + '-' + hrmsDesignationMap.get(responsedata.designation).SFDCRole__c).Profile__c) )? profileMap.get(HRMSConfigMap.get(hrmsDesignationMap.get(responsedata.designation).SFDCDepartment__c + '-' + hrmsDesignationMap.get(responsedata.designation).SFDCRole__c).Profile__c).Id: profileMap.get('LOS Base User').Id;
                                ur.Alias= string.isnotblank(responsedata.first_name) && string.isnotblank(responsedata.last_name)?responsedata.first_name.left(1) + responsedata.last_name.left(3): responsedata.last_name.left(4);
                                ur.LocaleSidKey='en_IN';
                                ur.EmailEncodingKey='UTF-8';
                                ur.LanguageLocaleKey='en_US';
                                ur.BrnchCode__c=string.isnotBlank(responsedata.branch_code)?responsedata.branch_code:'';
                                ur.L1ManagerCode__c=string.isnotBlank(responsedata.l1_manager_code)?responsedata.l1_manager_code:'';
                                
                                branchCodes.add(responsedata.branch_code);
                                empDataMap.put(responsedata.emp_code, responsedata);
                                empnumbers.add(ur.EmployeeNumber);
                                
                                //upsertUserList.add(ur);
                                upsertUserMap.put(responsedata.emp_code,ur);
                            }
                        }
                    }
                    
                }
                
                //Upsert the users
                if(!upsertUserMap.isempty()){
                    system.debug('upsertUserList' + upsertUserMap.size());
                    //upsertUsers(upsertUserMap);
                    
                    if(!upsertUserMap.isempty()){
                        try{
                            String errorMessage = '';
                            List<String> errorMessages = new List<String>();
                            Database.UpsertResult[] results = Database.upsert(upsertUserMap.values(), User.Id, false);
                            List<String> keys = new List<String>();
                            keys.addAll(upsertUserMap.KeySet());
                            for(Integer i=0; i<results.size(); i++){
                                if(!results[i].isSuccess()){
                                    List<Database.Error> err = results[i].getErrors();
                                    errorMessages.add('Employee Number: ' + keys.get(i) + ', Error Message: '  + err[0].getStatusCode());
                                    empnumbers.remove(keys.get(i));
                                    empDataMap.remove(keys.get(i));
                                    
                                }
                            }
                            errorMessage =  String.join(errorMessages,';');
                            if(String.isNotBlank(errorMessage)){
                                logMessage('upsertUsers',errorMessage,null);
                            }
                                
                        }
                        catch(Exception ex){
                            system.debug(ex.getMessage());
                            isException= !Test.isRunningTest() ? true : false;
                            // GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                            // 'upsertUsers', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                            logMessage('upsertUsers',ex.getMessage(),ex.getLineNumber());
                        }
                        
                    }
                    
                    
                }
                
                //if(!isException){
                if(!exitedUsers.isEmpty() || !userManagersEmailMap.isempty() || !recordUpdateMap.isEmpty()){
                    system.debug('processExitedUsers');
                    processExitedUsers(JSON.serialize(userManagersEmailMap),exitedUsers,recordUpdateMap);
                }
                
                if( !empnumbers.isempty() || !existingTeamHierarchyMap.isEmpty() || (!empDataMap.isempty() && !branchCodes.isempty()) ){
                    processActiveUsers(empnumbers,existingTeamHierarchyMap,empDataMap,branchCodes,priorBranchCodes);
                }
                
                
            }
            catch(Exception ex){
                system.debug(ex.getMessage());
                GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                                         'processSuccessResponse', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }        
        
    }
    //****************************************************************************************************************
    
   //****************************************************************************************************************
    @future
    public static void logMessage(String methodName,String errormessage,Integer errorLineNumber){
        GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                  methodName, null, null, errorLineNumber != null ?  errormessage + ' line ' + errorLineNumber : errormessage, null, null, null);
    }
    //****************************************************************************************************************
    //@future
    public Static Void processExitedUsers(string userEmailMapJSON,Set<String> exitedUsers,Map<Id,Id> recordUpdateOwnerIds){//Map<User,List<User>> userEmailMap,Set<String> exitedUsers
        
        try{
            
            //Removal of Permission Sets and Public Group
            if(!exitedUsers.isempty()){
                deletePermissionset(exitedUsers, 'Inactive Users');
            }
            
            
            if(string.isnotBlank(userEmailMapJSON) || !recordUpdateOwnerIds.isempty()){
                loanAssignmentAndEmailNotification(userEmailMapJSON,recordUpdateOwnerIds);
            }
            
            
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + ':::' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
             'processExitedUsers', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    } 
    //****************************************************************************************************************
    @future
    public static void loanAssignmentAndEmailNotification(string userEmailMapJSON,Map<Id,Id> recordUpdateOwnerIds){
        
        //Email Notification to L1 and L2 Mangers
       if(string.isnotBlank(userEmailMapJSON)){
            
            EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'HRMS'];
            Id orgWideEmailId   = [Select Id, Address, DisplayName  from OrgWideEmailAddress Where Address=:System.label.HRMSNotificationEmail].Id;
            Map<String, List<User>> userEmailMap = (Map<String, List<User>>) JSON.deserialize(userEmailMapJSON, Map<String, List<User>>.class);
            //userdetails userEmailMap = (userdetails) JSON.deserialize(userEmailMapJSON, userdetails.class);
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            system.debug(userEmailMap);
            
            list<String> empNoList =new list<String>();
            for(String userEmpNo :userEmailMap.keyset()){
                empNoList.add(userEmpNo);
            }
            
            Map<String,User> userdetails =new Map<String,User>();
            for(User usr:[Select id,EmployeeNumber,Name,BrnchCode__c from User where EmployeeNumber IN:empNoList AND EmployeeNumber!=null]){
                userdetails.put(usr.EmployeeNumber,usr);
            }
            
            for (String DeactivatedUser : userEmailMap.keySet()){
                
                user mainuser =userdetails.get(DeactivatedUser);
                system.debug('mainuser' +mainuser);
                
                List<User> managers =userEmailMap.get(DeactivatedUser);
                system.debug('managers' +managers);
                
                if(managers!=null && !managers.isempty()){
                    
                    for (User manager : managers) {
                        
                        if (manager != null && manager.Email != null) {
                            system.debug(manager.Email);
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                            mail.setTemplateId(emailTemplate.Id);
                            mail.setSubject(emailTemplate.Subject);
                            mail.setPlainTextBody(emailTemplate.Body.replace('<ManagerName>', manager.Name).replace('<DeactivatedUser>', mainuser.Name).replace('<DeactivatedEmpCode>',mainuser.EmployeeNumber).replace('<DeactivatedUserBranchCode>',mainuser.BrnchCode__c));
                            mail.setToAddresses(new List<String>{manager.Email});
                            emailList.add(mail);
                        }
                    }
                }
            }
            
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            } 
        }
        
        //Loan Application Owner Change to L1 Manger
            if(!recordUpdateOwnerIds.isEmpty()){
                updateRecordsOwner(recordUpdateOwnerIds);
            }
            
    }
    //****************************************************************************************************************
    public static void createTeamHierarchies(Map<String,HRMSAPIResponseWrapper.Data> empDataMap,Set<String> branchCodes){
        system.debug('createTeamHierarchies');
        
        if(!empDataMap.isEmpty() && !branchCodes.isEmpty()){
            try{
                system.debug('empDataMap try');
                Map<String, String> empSuperVisorMap = new Map<String,String>(); 
                Set<String> employeeNumbers = new Set<String>();
                Map<String,Map<String,TeamHierarchy__c>> teamHierarchyMap =new Map<String,Map<String,TeamHierarchy__c>>();
                Map<String,User> userDetailsMap =new Map<String,User>();
                //List<TeamHierarchy__c> teamHierarchyList = new List<TeamHierarchy__c>();
                Map<String,BankBrchMstr__c> bankBranchMap = new Map<String,BankBrchMstr__c>();
                Map<String,HRMSConfig__c> HRMSConfigMap = HRMSConfig__c.getAll();
                set<String> empRoles = new set<String>();
                Map<String,HRMSDepartment__c> hrmsDepartmentMap = new Map<String,HRMSDepartment__c>();
                MAP<Id,TeamHierarchy__c> updateTeamHierarchyMap = new Map<Id,TeamHierarchy__c>();
                Map<String,Map<String,TeamHierarchy__c>> insertteamHierarchyMap =new Map<String,Map<String,TeamHierarchy__c>>();
                
                Map<String,TeamHierarchy__c> insertteamHierarchy = new Map<String,TeamHierarchy__c>();
                
                for(HRMSConfig__c hrms : HRMSConfigMap.values()){
                    if(String.isNotBlank(hrms.Role__c)){
                        empRoles.add(hrms.Role__c);
                    }
                }
                for(HRMSDepartment__c hrmsdept :HRMSDepartment__c.getAll().values()){
                    hrmsDepartmentMap.put(hrmsdept.HRMSDepartment__c,hrmsdept);
                }
                
                for(BankBrchMstr__c brch : [SELECT Id, City__c, BrchCode__c, OffcCode__c, OffcName__c,SunInforBrchCode__c,LocationMaster__c FROM BankBrchMstr__c WHERE BrchCode__c IN:branchCodes]){
                    bankBranchMap.put(brch.BrchCode__c,brch);
                }
                
                for(User usr :[Select Id,EmployeeNumber,L1ManagerCode__c,BrnchCode__c,Division,Department,HRMSDepartment__c from User where EmployeeNumber <>'' AND ISActive=True]){
                    userDetailsMap.put(usr.EmployeeNumber,usr);
                    empSuperVisorMap.put(usr.EmployeeNumber,usr.L1ManagerCode__c);
                }
                
                for(String employeeNumber : empDataMap.keySet()){
                    
                    while(employeeNumber!=null){
                        employeeNumbers.add(employeeNumber);
                        employeeNumber = empSuperVisorMap.containskey(employeeNumber) ? empSuperVisorMap.get(employeeNumber) : null;
                    }
                }
                
                
                for(TeamHierarchy__c th : [SELECT Id, Product_Type__c, IsActive__c, Employee__c,Employee__r.EmployeeNumber, EmpLevel__c, EmpRole__c,EmpBrch__r.BrchCode__c,EmpStartDt__c, EmpEndDt__c, Supervisor__c,Supervisor__r.Employee__r.EmployeeNumber, ValidFrm__c, ValidThru__c, LstAssDtTime__c,Employee__r.Division from TeamHierarchy__c  WHERE  Employee__r.EmployeeNumber IN:employeeNumbers AND EmpBrch__r.BrchCode__c IN:branchCodes AND IsActive__c=TRUE]){
                    
                    if(teamHierarchyMap.containskey(th.Employee__r.EmployeeNumber)){
                        teamHierarchyMap.get(th.Employee__r.EmployeeNumber).put(th.EmpBrch__r.BrchCode__c,th);
                    }
                    else{
                        teamHierarchyMap.put(th.Employee__r.EmployeeNumber,new Map<String,TeamHierarchy__c>{th.EmpBrch__r.BrchCode__c=>th});
                    }
                    if(String.isNotBlank(th.Employee__r.Division) && th.Employee__r.Division !=th.EmpRole__c) {
                        if(!updateTeamHierarchyMap.containsKey(th.Id)){
                            updateTeamHierarchyMap.put(th.Id,new TeamHierarchy__c(Id=th.Id,EmpRole__c = th.Employee__r.Division));
                        }
                        else{
                            updateTeamHierarchyMap.get(th.Id).EmpRole__c = th.Employee__r.Division;
                        }
                    }
                    /*if(String.isNotBlank(th.Employee__r.L1ManagerCode__c) && th.Supervisor__r.Employee__r.EmployeeNumber !=th.Employee__r.L1ManagerCode__c) {
                        if(!updateTeamHierarchyMap.containsKey(th.Id)){
                            if(teamHierarchyMap.containsKey(th.Employee__r.L1ManagerCode__c) && teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).containsKey(th.EmpBrch__r.BrchCode__c)){
                                updateTeamHierarchyMap.put(th.Id,new TeamHierarchy__c(Id=th.Id,Supervisor__c = teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).get(th.EmpBrch__r.BrchCode__c).Id));
                            }
                        }
                        else{
                            if(teamHierarchyMap.containsKey(th.Employee__r.L1ManagerCode__c) && teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).containsKey(th.EmpBrch__r.BrchCode__c)){
                                updateTeamHierarchyMap.get(th.Id).Supervisor__c = teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).get(th.EmpBrch__r.BrchCode__c).Id;
                            }
                        }
                    }*/
                    
                }
                
                
                for(String employeeNumber : empDataMap.keySet()){
                    
                    HRMSAPIResponseWrapper.Data empData = empDataMap.get(employeeNumber);
                    
                    if(userDetailsMap.containskey(employeeNumber)){
                        
                        User usr = userDetailsMap.get(employeeNumber); 
                        while(usr !=null){
                            
                            if( ((!teamHierarchyMap.containskey(usr.EmployeeNumber)) || (teamHierarchyMap.containskey(usr.EmployeeNumber) && !teamHierarchyMap.get(usr.EmployeeNumber).containskey(empData.branch_code))) && bankBranchMap.containskey(empData.branch_code) && empRoles.contains(usr.Division)){
                                
                                //Create Team Hierarchy for Emp
                                HRMSConfig__c hrms= HRMSConfigMap.get((String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
                                TeamHierarchy__c th = new TeamHierarchy__c();
                                th.EmpBrch__c=bankBranchMap.get(empData.branch_code).id;
                                th.EmpLevel__c= (hrms!=null && String.isNotBlank(hrms.EmpLevel__c))? hrms.EmpLevel__c : '';
                                th.EmpRole__c=usr.Division;
                                //th.EmpStartDt__c='';
                                th.Employee__c=usr.id;
                                th.IsActive__c=true;
                                th.Product_Type__c=hrmsDepartmentMap.containskey(usr.HRMSDepartment__c)?hrmsDepartmentMap.get(usr.HRMSDepartment__c).SFDCProduct__c:'Home Loan;Small Ticket LAP;Loan Against Property';//'Home Loan;Small Ticket LAP';
                                //th.Supervisor__c='';
                                //th.ValidFrm__c='';
                                
                                //teamHierarchyList.add(th);
                                if(insertteamHierarchyMap.containsKey(th.Employee__c)){
                                    insertteamHierarchyMap.get(th.Employee__c).put(th.EmpBrch__c,th);
                                }
                                else{
                                    insertteamHierarchyMap.put(th.Employee__c,new Map<String,TeamHierarchy__c>{th.EmpBrch__c=>th});
                                }
                                
                                usr = usr.L1ManagerCode__c!=null && userDetailsMap.containskey(usr.L1ManagerCode__c) ? userDetailsMap.get(usr.L1ManagerCode__c):null;
                            }
                            else {
                                usr=usr.L1ManagerCode__c!=null && userDetailsMap.containskey(usr.L1ManagerCode__c) ? userDetailsMap.get(usr.L1ManagerCode__c):null;
                            }
                            
                        }
                    }
                }
                //
                if(!insertteamHierarchyMap.isEmpty()){
                    for(String key : insertteamHierarchyMap.keySet()){
						  Map<String,TeamHierarchy__c> thMap = insertteamHierarchyMap.get(key);
                        if(!thMap.isEmpty()){
                            for(TeamHierarchy__c th : thMap.values()){
                                insertteamHierarchy.put(key+':'+th.EmpBrch__c,th);
                            }
                        }
                    }
                    
                }
                if(!insertteamHierarchy.isEmpty()){
                    
                    Database.SaveResult[] results = Database.insert(insertteamHierarchy.values(),false);
                    
                    
                    String errorMessage = '';
                    List<String> errorMessages = new List<String>();
                    
                    List<String> keys = new List<String>();
                    keys.addAll(insertteamHierarchy.KeySet());
                    for(Integer i=0; i<results.size(); i++){
                        if(!results[i].isSuccess()){
                            List<Database.Error> err = results[i].getErrors();
                            errorMessages.add(keys.get(i) + ': Error Message: '  + err[0].getStatusCode());
                            
                            
                        }
                    }
                    errorMessage =  String.join(errorMessages,';');
                    if(String.isNotBlank(errorMessage)){
                        GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                                                 'createTeamHierarchies', null, null, errorMessage, null, null, null);
                    }
                    
                    
                    
                    
                    
                    //List<TeamHierarchy__c> updateTeamHierarchyList = new List<TeamHierarchy__c>();
                    //List<TeamHierarchy__c> teamHierarchy = [SELECT Id, Product_Type__c, IsActive__c, Employee__c,Employee__r.EmployeeNumber,Employee__r.L1ManagerCode__c, EmpLevel__c, EmpRole__c,EmpBrch__r.BrchCode__c,EmpStartDt__c, EmpEndDt__c, Supervisor__c,Supervisor__r.Employee__r.EmployeeNumber, ValidFrm__c, ValidThru__c, LstAssDtTime__c from TeamHierarchy__c  WHERE  ID IN:teamHierarchyList AND IsActive__c=TRUE AND Supervisor__c=null];
                    List<TeamHierarchy__c> teamHierarchy = [SELECT Id, Product_Type__c, IsActive__c, Employee__c,Employee__r.EmployeeNumber,Employee__r.L1ManagerCode__c, EmpLevel__c, EmpRole__c,EmpBrch__r.BrchCode__c,EmpStartDt__c, EmpEndDt__c, Supervisor__c,Supervisor__r.Employee__r.EmployeeNumber, ValidFrm__c, ValidThru__c, LstAssDtTime__c from TeamHierarchy__c  WHERE  ((ID IN:insertteamHierarchy.Values() AND Supervisor__c=null) OR (Employee__r.EmployeeNumber IN:employeeNumbers AND EmpBrch__r.BrchCode__c IN:branchCodes)) AND IsActive__c=TRUE];
                    system.debug('teamHierarchy::'+teamHierarchy);
                    
                    for(TeamHierarchy__c th : teamHierarchy){
                        
                        if(teamHierarchyMap.containskey(th.Employee__r.EmployeeNumber)){
                            teamHierarchyMap.get(th.Employee__r.EmployeeNumber).put(th.EmpBrch__r.BrchCode__c,th);
                        }
                        else{
                            teamHierarchyMap.put(th.Employee__r.EmployeeNumber,new Map<String,TeamHierarchy__c>{th.EmpBrch__r.BrchCode__c=>th});
                        }
                    }
                    
                    for(TeamHierarchy__c th : teamHierarchy){
                        
                        if(th.Supervisor__c ==null || th.Employee__r.L1ManagerCode__c != th.Supervisor__r.Employee__r.EmployeeNumber){
                            th.Supervisor__c = teamHierarchyMap.containsKey(th.Employee__r.L1ManagerCode__c) && teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).containskey(th.EmpBrch__r.BrchCode__c)? teamHierarchyMap.get(th.Employee__r.L1ManagerCode__c).get(th.EmpBrch__r.BrchCode__c).Id :null;
                            system.debug('th.Supervisor__c::'+th.Supervisor__c);
                            //updateTeamHierarchyList.add(th);
                            if(updateTeamHierarchyMap.containsKey(th.Id)){
                                updateTeamHierarchyMap.get(th.Id).Supervisor__c = th.Supervisor__c;
                            }
                            else{
                                updateTeamHierarchyMap.put(th.Id,th);
                            }
                        }
                    }
                    
                    /*if(!updateTeamHierarchyList.isEmpty()){
                        update updateTeamHierarchyList;
                    }*/
                    if(!updateTeamHierarchyMap.isEmpty()){
                        update updateTeamHierarchyMap.values();
                    }
                }
            }
            catch(Exception ex){
                system.debug(ex.getMessage()+'::Line number::'+ex.getLineNumber());
                GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
                  'createTeamHierarchies', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
    }
    //****************************************************************************************************************
    public Static void deleteTeamHierarchies(Map<Id,TeamHierarchy__c> oldTeamHierarchies){
        
        try{
            if(!oldTeamHierarchies.isempty()){
                delete oldTeamHierarchies.values();
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'deleteTeamHierarchies', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************  
    //@future        
    public static void assginPermissionset(Set<string> employeeNumbers){//Set<Id> 
        system.debug('assginPermissionset');
        system.debug(':::::'+ employeeNumbers);
        Map<Id,User> userMap= new Map<Id,User>([SELECT Id, Name,Department, Division,IsActive,EmployeeNumber FROM USER where EmployeeNumber IN:employeeNumbers AND EmployeeNumber!=null]);
        
        Set<String> hrmsconfigkeys = new Set<String>();
        
        
        for (User usr : userMap.values()){
            if(String.isNotBlank(usr.Department) || String.isNotBlank(usr.Division)){
                hrmsconfigkeys.add( (String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
            }
        }
        
        Map<String,HRMSConfig__c> HRMSConfigMap = HRMSConfig__c.getAll();
        Set<String> permissionSets = new Set<String>();
        
        for(String key: HRMSConfigMap.keySet()){
            
            if(hrmsconfigkeys.contains(key)){
                
                HRMSConfig__c hrms= HRMSConfigMap.get(key);
                
                if(String.isNotBlank(hrms.PermissionSetsAPI__c)){
                    permissionSets.addAll(hrms.PermissionSetsAPI__c.split(';'));
                }
                
            }
        }
        
        Map<String, Id> permissionSetMap = new Map<String, Id>();
        
        List<PermissionSetAssignment> permissionSetAssignmentlist =new List<PermissionSetAssignment>();
        for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet Where Name IN: permissionSets]) {
            permissionSetMap.put(ps.Name, ps.Id);
        }
        
        Map<Id, Set<Id>> userPermissionSetMap = new Map<Id, Set<Id>>();
        
        for (PermissionSetAssignment existingPSA : [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :userMap.keyset()]) {
            
            if (userPermissionSetMap.containsKey(existingPSA.AssigneeId)) {
                userPermissionSetMap.get(existingPSA.AssigneeId).add(existingPSA.PermissionSetId);
            }
            else{
                userPermissionSetMap.put(existingPSA.AssigneeId, new Set<Id>{existingPSA.PermissionSetId});
            }
            
        }
        system.debug('userPermissionSetMap' +userPermissionSetMap);
        for (User usr : userMap.values()){
            
            if(usr.IsActive){
                HRMSConfig__c hrms= HRMSConfigMap.get((String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
                if(hrms!=null && hrms.PermissionSetsAPI__c!=null){
                    for(string key: hrms.PermissionSetsAPI__c.split(';')){
                        if(permissionSetMap.containsKey(key) && 
                           (!userPermissionSetMap.containsKey(usr.Id) ||!userPermissionSetMap.get(usr.Id).contains(permissionSetMap.get(key)))){
                               
                               PermissionSetAssignmentlist.add(new PermissionSetAssignment(AssigneeId=usr.id,PermissionSetId=permissionSetMap.get(key)));
                           }
                        
                    } 
                }
            }
        }
        system.debug('permissionSetAssignmentlist' +permissionSetAssignmentlist);
        try {
            if(!permissionSetAssignmentlist.isempty()){
                Insert permissionSetAssignmentlist;
                
            }
            addUsersToPublicGroups(employeeNumbers);
        } 
        catch (Exception e) {
            
            System.debug('::::::Message: ' + e.getMessage() + '::::::LineNumber: ' + e.getLineNumber() +'::::::');
            //GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
            //  'assginPermissionset', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************  
    public static void addUsersToPublicGroups(Set<String> employeeNumbers){
        system.debug(':::::::::::::addUsersToPublicGroups');
        Map<Id,User> userMap= new Map<Id,User>([SELECT Id, Name,Department, Division,IsActive,EmployeeNumber FROM USER where EmployeeNumber IN:employeeNumbers AND EmployeeNumber!=null]);
        
        Set<String> hrmsconfigkeys = new Set<String>();
        
        
        for (User usr : userMap.values()){
            if(String.isNotBlank(usr.Department) || String.isNotBlank(usr.Division)){
                hrmsconfigkeys.add( (String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
            }
        }
        
        Map<String,HRMSConfig__c> HRMSConfigMap = HRMSConfig__c.getAll();
        Set<String> publicGroups = new Set<String>();
        
        for(String key: HRMSConfigMap.keySet()){
            
            if(hrmsconfigkeys.contains(key)){
                
                HRMSConfig__c hrms= HRMSConfigMap.get(key);
                
                if(String.isNotBlank(hrms.PublicGrps__c)){
                    publicGroups.addAll(hrms.PublicGrps__c.split(';'));
                }
                
            }
        }
        
        Map<String, Id> groupMap = new Map<String, Id>();
        
        List<GroupMember> publicGroupslist =new List<GroupMember>();
        for(Group grp : [SELECT Id, Name,DeveloperName FROM Group Where DeveloperName IN: publicGroups]) {
            groupMap.put(grp.DeveloperName, grp.Id);
        }
        
        Map<Id, Set<Id>> userGroupMap = new Map<Id, Set<Id>>();
        
        for (GroupMember existingGroup : [SELECT Id,UserOrGroupId,Group.DeveloperName,GroupId from GroupMember WHERE Group.DeveloperName IN: publicGroups AND UserOrGroupId IN: userMap.keyset()]) {
            
            if (userGroupMap.containsKey(existingGroup.UserOrGroupId)) {
                userGroupMap.get(existingGroup.UserOrGroupId).add(existingGroup.GroupId);
            }
            else{
                userGroupMap.put(existingGroup.UserOrGroupId, new Set<Id>{existingGroup.GroupId});
            }
            
        }
        system.debug('userGroupMap' +userGroupMap);
        for (User usr : userMap.values()){
            
            if(usr.IsActive){
                HRMSConfig__c hrms= HRMSConfigMap.get((String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
                if(hrms!=null && hrms.PublicGrps__c!=null){
                    for(string key: hrms.PublicGrps__c.split(';')){
                        if(groupMap.containsKey(key) && 
                           (!userGroupMap.containsKey(usr.Id) ||!userGroupMap.get(usr.Id).contains(groupMap.get(key)))){
                               
                               publicGroupslist.add(new GroupMember(UserOrGroupId=usr.id,GroupId=groupMap.get(key)));
                           }
                        
                    } 
                }
            }
        }
        system.debug('publicGroupslist' +publicGroupslist);
        try {
            if(!publicGroupslist.isempty()){
                insert publicGroupslist;
            }
            deletePermissionset(employeeNumbers,'Active Users');
            
        } 
        catch (Exception ex) {
            
            System.debug('::::::Message: ' + ex.getMessage() + '::::::LineNumber: ' + ex.getLineNumber() +'::::::');
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'addUsersToPublicGroups', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //**************************************************************************************************************** 
    public static void deletePermissionset(Set<String> employeeNumbers, String userType) {
        system.debug('deletePermissionset');
        
        try {
            Map<String, User> userMap = new Map<String, User>();
            for(User user : [SELECT Id, Name, Department, Division, IsActive, EmployeeNumber FROM User WHERE EmployeeNumber IN :employeeNumbers AND EmployeeNumber!=null]) {
                userMap.put(user.EmployeeNumber, user);
            }
            
            Map<String, HRMSConfig__c> hrmsConfigMap = HRMSConfig__c.getAll();
            
            Set<String> allPermissionSet =new Set<String>();
            for(HRMSConfig__c hrms:hrmsConfigMap.values()){
                
                if (String.isNotBlank(hrms.PermissionSetsAPI__c)) {
                    allPermissionSet.addAll(hrms.PermissionSetsAPI__c.split(';'));
                }
                
            }
            List<PermissionSetAssignment> permissionSetAssignmentListToDelete = new List<PermissionSetAssignment>();
            
            if(string.isNotblank(userType) && userType=='Active Users'){
                
                Set<String> hrmsConfigKeys = new Set<String>();
                for (User usr : userMap.values()) {
                    if (String.isNotBlank(usr.Department) || String.isNotBlank(usr.Division)) {
                        hrmsConfigKeys.add((String.isNotBlank(usr.Department) && String.isNotBlank(usr.Division)) ? usr.Department + '-' + usr.Division : usr.Department);
                    }
                }
                
                
                Set<String> permissionSets = new Set<String>();
                
                for (String key : hrmsConfigKeys) {
                    if (hrmsConfigMap.containsKey(key)) {
                        HRMSConfig__c hrms = hrmsConfigMap.get(key);
                        if (String.isNotBlank(hrms.PermissionSetsAPI__c)) {
                            permissionSets.addAll(hrms.PermissionSetsAPI__c.split(';'));
                        }
                    }
                }
                
                
                
                Map<String, Id> permissionSetMap = new Map<String, Id>();
                for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSets]) {
                    permissionSetMap.put(ps.Name, ps.Id);
                }
                
                
                
                Map<Id, Set<Id>> userPermissionSetMap = new Map<Id, Set<Id>>();
                
                for (User usr : userMap.values()) {
                    if (usr.IsActive) {
                        String key = (String.isNotBlank(usr.Department) && String.isNotBlank(usr.Division)) ? usr.Department + '-' + usr.Division : usr.Department;
                        HRMSConfig__c hrms = hrmsConfigMap.get(key);
                        if (hrms != null && hrms.PermissionSetsAPI__c != null) {
                            Set<Id> userPermissionSets = userPermissionSetMap.containsKey(usr.Id) ? userPermissionSetMap.get(usr.Id) : new Set<Id>();
                            for (String permissionSetName : hrms.PermissionSetsAPI__c.split(';')) {
                                
                                if(userPermissionSetMap.containskey(usr.id)){
                                    userPermissionSetMap.get(usr.id).add(permissionSetMap.get(permissionSetName));
                                }else{
                                    userPermissionSetMap.put(usr.id,new set<Id>{permissionSetMap.get(permissionSetName)});
                                }
                            }
                        }
                    }
                }
                
                for(Id userId : userPermissionSetMap.keySet()){
                    Set<Id> userPermissionSets = userPermissionSetMap.get(userId);
                    
                    for(PermissionSetAssignment existingPSA : [SELECT AssigneeId,PermissionSet.Name,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name IN: allPermissionSet]){// 
                        if(!userPermissionSets.contains(existingPSA.PermissionSetId)){
                            permissionSetAssignmentListToDelete.add(existingPSA);
                        }
                        
                    }
                }
                
            }
            
            else if(string.isNotblank(userType) && userType=='Inactive Users'){
                Set<Id> userIds = new Set<Id>();
                
                for(User u : userMap.values()) {
                    userIds.add(u.Id);
                }
                List<PermissionSetAssignment> psaToDelete = [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :userIds AND PermissionSet.Name IN: allPermissionSet];
                
                if(!psaToDelete.isempty()){
                    permissionSetAssignmentListToDelete.addall(psaToDelete);
                }
            }
            if (!permissionSetAssignmentListToDelete.isEmpty()) {
                delete permissionSetAssignmentListToDelete;
            }
            deleteUsersfromPublicGroups(employeeNumbers,userType);
        }
        
        catch (Exception ex) {
            System.debug('::::::Message: ' + ex.getMessage() + '::::::LineNumber: ' + ex.getLineNumber() + '::::::');
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'deletePermissionset', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************  
    public static void deleteUsersfromPublicGroups(Set<String> employeeNumbers, String userType){
        system.debug(':::::::::::::deleteUsersfromPublicGroups ' +userType);
        
        try{
            Map<String, User> userMap = new Map<String, User>();
            for(User user : [SELECT Id, Name, Department, Division, IsActive, EmployeeNumber FROM User WHERE EmployeeNumber IN :employeeNumbers AND EmployeeNumber!=null]) {
                userMap.put(user.EmployeeNumber, user);
            }
            
            Map<String,HRMSConfig__c> HRMSConfigMap = HRMSConfig__c.getAll();
            List<GroupMember> publicGroupslist =new List<GroupMember>();
            
            Set<String> allpublicGroups =new Set<String>();
            for(HRMSConfig__c hrms:hrmsConfigMap.values()){
                
                if (String.isNotBlank(hrms.PublicGrps__c)) {
                    allpublicGroups.addAll(hrms.PublicGrps__c.split(';'));
                }
                
            }
            system.debug('allpublicGroups '+allpublicGroups);
            
            if(string.isNotblank(userType) && userType=='Active Users'){
                
                Set<String> hrmsconfigkeys = new Set<String>();
                
                for (User usr : userMap.values()){
                    if(String.isNotBlank(usr.Department) || String.isNotBlank(usr.Division)){
                        hrmsconfigkeys.add( (String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
                    }
                }
                
                
                Set<String> publicGroups = new Set<String>();
                
                for(String key: HRMSConfigMap.keySet()){
                    
                    if(hrmsconfigkeys.contains(key)){
                        
                        HRMSConfig__c hrms= HRMSConfigMap.get(key);
                        
                        if(String.isNotBlank(hrms.PublicGrps__c)){
                            publicGroups.addAll(hrms.PublicGrps__c.split(';'));
                        }
                        
                    }
                }
                
                
                
                Map<String, Id> groupMap = new Map<String, Id>();
                
                
                for(Group grp : [SELECT Id, Name,DeveloperName FROM Group Where DeveloperName IN: publicGroups]) {
                    groupMap.put(grp.DeveloperName, grp.Id);
                }
                
                
                
                Map<Id, Set<Id>> userpublicGroupsMap = new Map<Id, Set<Id>>();
                
                for (User usr : userMap.values()){
                    
                    if(usr.IsActive){
                        HRMSConfig__c hrms= HRMSConfigMap.get((String.isNotBlank(usr.Department) && String.IsNotBlank(usr.Division))? usr.Department + '-' + usr.Division  :  usr.Department);
                        if(hrms!=null && hrms.PublicGrps__c!=null){
                            for(string key: hrms.PublicGrps__c.split(';')){
                                
                                if(userpublicGroupsMap.containskey(usr.id)){
                                    userpublicGroupsMap.get(usr.id).add(groupMap.get(key));
                                }else{
                                    userpublicGroupsMap.put(usr.id,new set<Id>{groupMap.get(key)});
                                }
                            } 
                        }
                    }
                }
                
                system.debug(userpublicGroupsMap);
                
                for(Id userId : userpublicGroupsMap.keySet()){
                    Set<Id> userpublicGroups = userpublicGroupsMap.get(userId);
                    
                    
                    for(GroupMember existinggrp : [SELECT Id, UserOrGroupId,GroupId,Group.DeveloperName FROM GroupMember Where UserOrGroupId=:userId AND Group.DeveloperName IN: allpublicGroups]){// 
                        if(!userpublicGroups.contains(existinggrp.GroupId)){
                            publicGroupslist.add(existinggrp);
                        }
                        
                    }
                }
            }
            else if(string.isNotblank(userType) && userType=='Inactive Users'){
                Set<Id> userIds = new Set<Id>();
                
                for(User u : userMap.values()) {
                    userIds.add(u.Id);
                }
                
                List<GroupMember> gmToDelete =[SELECT Id, UserOrGroupId,GroupId,Group.DeveloperName FROM GroupMember Where UserOrGroupId IN:userIds AND Group.DeveloperName IN: allpublicGroups];
                
                system.debug('gmToDelete '+gmToDelete);
                
                if(!gmToDelete.isempty()){
                    publicGroupslist.addall(gmToDelete);
                }
            }
            
            If(!publicGroupslist.isempty()){
                delete publicGroupslist;
            }
        } 
        catch (Exception ex) {
            
            System.debug('::::::Message: ' + ex.getMessage() + '::::::LineNumber: ' + ex.getLineNumber() +'::::::');
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'deleteUsersfromPublicGroups', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************
    public static void updateRecordsOwner(Map<Id, Id> recordUpdateMap) {
        try{
            system.debug('updateRecordsOwner ' +recordUpdateMap);
            
            if(!recordUpdateMap.isEmpty()) {
                List<LoanAppl__c> loanAppList = new List<LoanAppl__c>();
                
                for(LoanAppl__c loanapp : [SELECT Id, OwnerId FROM LoanAppl__c WHERE OwnerId IN :recordUpdateMap.keySet()]) {
                    Id newOwnerId = recordUpdateMap.get(loanapp.OwnerId);
                    if(newOwnerId != null) {
                        loanapp.OwnerId = newOwnerId;
                        loanAppList.add(loanapp);
                    }
                }
                system.debug('loanAppList ' +loanAppList);
                if(!loanAppList.isEmpty()) {
                    Update loanAppList;
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'updateRecordsOwner', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************  
    @future
    public static void processFailureResponse(String errormessage){
        try{
            EmailTemplate emailTemplate = [SELECT Id, Subject,Body FROM EmailTemplate WHERE DeveloperName = 'HRMSFailure'];
            Id orgWideEmailId   = [Select Id, Address, DisplayName  from OrgWideEmailAddress Where Address=:System.label.HRMSNotificationEmail].Id;
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            if(string.isnotBlank(errormessage) && String.isNotBlank(system.label.HRMSFailureEmails)){
                
                List<String> emails =system.label.HRMSFailureEmails.split(';');
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemplate.Id);
                mail.setOrgWideEmailAddressId(orgWideEmailId);
                mail.setSubject(emailTemplate.Subject.replace('<CurrentDate>',String.valueOf(DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()).format('dd-MM-yyyy'))));
                mail.setPlainTextBody(emailTemplate.Body.replace('<error>', errormessage));
                mail.setToAddresses(emails);
                emailList.add(mail);
            }
            
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            }
                
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            GlobalUtility.logMessage('Error', 'HRMSAPIResponseProcessor class', 
              'processFailureResponse', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //****************************************************************************************************************
    
    //@future
    public static void processActiveUsers(Set<String> empnumbers,Map<Id,TeamHierarchy__c> existingTeamHierarchyMap,Map<String,HRMSAPIResponseWrapper.Data> empDataMap,Set<String> branchCodes,Set<String> priorBranchCodes){
        if(!empnumbers.isempty()){
            assginPermissionset(empnumbers);
        }
        
        if(!existingTeamHierarchyMap.isEmpty() || ((!empDataMap.isEmpty() && !branchCodes.isEmpty())) || !priorBranchCodes.isEmpty()){
            HRMSTeamHierarchyQueueable queueableInstance = new HRMSTeamHierarchyQueueable(existingTeamHierarchyMap,empDataMap,branchCodes,priorBranchCodes);
            System.enqueueJob(queueableInstance);
        }
        
        
    }
    //****************************************************************************************************************
    private static Map<String,Boolean> isActiveMap =new Map<String,Boolean>{'Active'=>true,'Exited'=>false,'Serving Notice Period' =>true};
        
}