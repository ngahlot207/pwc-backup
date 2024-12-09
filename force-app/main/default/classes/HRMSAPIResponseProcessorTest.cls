@istest
public class HRMSAPIResponseProcessorTest {
    
    
    @testSetup
    static void dataSetUp() {
        Profile pr =[SELECT ID,Name from Profile WHERE Name IN ('LOS Base User')];
        
        List<User> UserList =new List<User>();
        
        User newUser1 = new User();
        newUser1.FirstName = 'John';
        newUser1.MiddleName='test';
        newUser1.LastName = 'Doe';
        newUser1.Email = 'john.doe@example.invalid';
        newUser1.Username = 'john.doe4567@example.invalid';
        newUser1.Alias = 'jdoein';
        newUser1.ProfileId = pr.Id;
        newUser1.TimeZoneSidKey = 'Asia/Kolkata';
        newUser1.LocaleSidKey = 'en_US';
        newUser1.EmailEncodingKey = 'UTF-8';
        newUser1.LanguageLocaleKey = 'en_US';
        newUser1.IsActive = true;
        newUser1.MobilePhone='123445678';
        newUser1.HRMSDepartment__c='SALES';
        newUser1.Department='SALES';
        newUser1.Division='SM';
        newUser1.EmployeeNumber='65432';
        newUser1.BrnchCode__c='PUN';
        newUser1.L1ManagerCode__c='';
        UserList.add(newUser1);
        
        User newUser2 = new User();
        newUser2.FirstName = 'John';
        newUser2.MiddleName='test';
        newUser2.LastName = 'Doe';
        newUser2.Email = 'john.doe@example.com';
        newUser2.Username = 'john.doe12345@example.com';
        newUser2.Alias = 'jdoe';
        newUser2.ProfileId = pr.Id;
        newUser2.TimeZoneSidKey = 'Asia/Kolkata';
        newUser2.LocaleSidKey = 'en_US';
        newUser2.EmailEncodingKey = 'UTF-8';
        newUser2.LanguageLocaleKey = 'en_US';
        newUser2.IsActive = true;
        newUser2.MobilePhone='1234456789';
        newUser2.HRMSDepartment__c='SALES';
        newUser2.Department='SALES';
        newUser2.Division='CPA';//CPA
        newUser2.EmployeeNumber='265';
        newUser2.BrnchCode__c='PUN';
        newUser2.L1ManagerCode__c='65431';//65432
        
       UserList.add(newUser2);
        
        Insert UserList;
        
        
        List<BankBrchMstr__c> BankBrchMstrList =new List<BankBrchMstr__c>();
        
        BankBrchMstr__c bbm2 =new BankBrchMstr__c();
        bbm2.Name='PUNE';
        bbm2.City__c='Pune';
        bbm2.BrchCode__c='PUN';
        bbm2.OffcCode__c='12';
        bbm2.OffcType__c='BO';
        bbm2.SunInforBrchCode__c='MH50004PUN';
        bbm2.SourcingBranchCode__c='PUN';
        BankBrchMstrList.add(bbm2);
        
        BankBrchMstr__c bbm1 =new BankBrchMstr__c();
        bbm1.Name='MUMBAI';
        bbm1.City__c='Mumbai';
        bbm1.BrchCode__c='MUM';
        bbm1.OffcCode__c='5';
        bbm1.OffcType__c='BO';
        bbm1.SunInforBrchCode__c='MH50005MUM';
        bbm1.SourcingBranchCode__c='MUM';
        BankBrchMstrList.add(bbm1);
        
        
        
        Insert BankBrchMstrList;
        
        
        List<TeamHierarchy__c> TeamHierarchyList=new List<TeamHierarchy__c>();
        
        TeamHierarchy__c th1 = new TeamHierarchy__c();
        th1.EmpBrch__c=BankBrchMstrList[0].id;
        th1.EmpLevel__c= '1';
        th1.EmpRole__c=UserList[0].Division;
        //th.EmpStartDt__c='';
        th1.Employee__c=UserList[0].id;
        th1.IsActive__c=true;
        th1.Product_Type__c='Home Loan';
        TeamHierarchyList.add(th1);
        
        TeamHierarchy__c th2 = new TeamHierarchy__c();
        th2.EmpBrch__c=BankBrchMstrList[0].id;
        th2.EmpLevel__c= '1';
        th2.EmpRole__c=UserList[1].Division;
        //th.EmpStartDt__c='';
        th2.Employee__c=UserList[1].id;
        th2.IsActive__c=true;
        th2.Product_Type__c='Home Loan';
        TeamHierarchyList.add(th2);
        
        Insert TeamHierarchyList;
        
        List<HRMSDepartment__c> HRMSDepartmentList =new List<HRMSDepartment__c>();
        
        HRMSDepartment__c HRMSDept1 =new HRMSDepartment__c();
        HRMSDept1.Name='HP-0001';
        HRMSDept1.HRMSDepartment__c='MSE LAP';
        HRMSDept1.SFDCProduct__c='Home Loan;Small Ticket LAP';
        HRMSDepartmentList.add(HRMSDept1);
        
        HRMSDepartment__c HRMSDept2 =new HRMSDepartment__c();
        HRMSDept2.Name='HP-0002';
        HRMSDept2.HRMSDepartment__c='Loan Against Property';
        HRMSDept2.SFDCProduct__c='Small Ticket LAP';
        HRMSDepartmentList.add(HRMSDept2);
        
        insert HRMSDepartmentList;        
        
        List<HRMSDesignation__c> HRMSDesignationList =new List<HRMSDesignation__c> ();
        
        HRMSDesignation__c HRMSDesi1 =new HRMSDesignation__c();
        HRMSDesi1.Name='HD-0001';
        HRMSDesi1.HRMSDesignation__c='Sales Manager';
        HRMSDesi1.SFDCRole__c='RM';
        HRMSDesi1.SFDCDepartment__c='SALES';
        HRMSDesignationList.add(HRMSDesi1);
        
        insert HRMSDesignationList;
        
        List<HRMSConfig__c> HRMSConfigList =new List<HRMSConfig__c>();
        
        HRMSConfig__c HRMSConfig1 =new HRMSConfig__c();
        HRMSConfig1.Name='SALES-RM';
        HRMSConfig1.Department__c='SALES';
        HRMSConfig1.PermissionSetsAPI__c='LOS_PS_RM;LOS_PS_RM_HL;LOS_PS_RM_STLAP;Microsoft_MFA';
        HRMSConfig1.Profile__c='LOS Base User';
        HRMSConfig1.PublicGrps__c='LV_RM_Group';
        HRMSConfig1.Role__c='RM';
        HRMSConfigList.add(HRMSConfig1);
        
        HRMSConfig__c HRMSConfig2 =new HRMSConfig__c();
        HRMSConfig2.Name='SALES-SM';
        HRMSConfig2.Department__c='SALES';
        HRMSConfig2.PermissionSetsAPI__c='LOS_PS_SM;LOS_PS_SM_HL;LOS_PS_SM_STLAP;Microsoft_MFA';
        HRMSConfig2.Profile__c='LOS Base User';
        HRMSConfig2.PublicGrps__c='LV_RM_Group';
        HRMSConfig2.Role__c='SM';
        HRMSConfigList.add(HRMSConfig2);
        
        insert HRMSConfigList;
        
        LoanAppl__c loanapp =new LoanAppl__c();
        loanapp.OwnerId=UserList[1].id;
        insert loanapp;
    }
    @istest
    public static void testmethod1(){
        
        IntgMsg__c intmsg =new IntgMsg__c();
        intmsg.Name='Get HRMS Details';
        intmsg.Status__c='New';
        intmsg.MStatus__c='Blank';
        intmsg.BU__c='HL / STL';
        intmsg.Svc__c='Get HRMS Details';
        intmsg.ApiVendor__c='HRMS';
        intmsg.IsActive__c=true; 
        
        TriggerBase.bypass('IntgMsg__c');
        Insert intmsg;
        TriggerBase.clearBypass('IntgMsg__c');
        
       
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('{"Data":[{"emp_code":"265","mobile_no":"7501312563","department":"MSE LAP","designation":"Sales Manager","emp_status":"Exited","emp_type":"Permanent","emp_name":"HRMS","first_name":"Satyendra","middle_name":null,"last_name":"HR8","gender":"M","business_sub_func":null,"function":"Support","grade":"Senior Manager","country":"India","zone":"West","state":"Maharashtra","district":"Mumbai","branch_name":"Kanakia Wall Street, Mumbai","office":"Corporate Office","l1_manager_code":"65432","l1_manager":"Test","l2_manager_code":"65432","l2_manager":"Sanjay Mishra","off_email_add":"test4563@gmtest.com","final_app_lwd":null,"branch_code":"MUM","joining_date":"22-10-2022","suninfo_branch_code":"MH50005MUM"},{"emp_code":"285","mobile_no":"7501312563","department":"MSE LAP","designation":"Sales Manager","emp_status":"Active","emp_type":"Permanent","emp_name":"HRMS","first_name":"Satyendra","middle_name":null,"last_name":"H8","gender":"M","business_sub_func":null,"function":"Support","grade":"Senior Manager","country":"India","zone":"West","state":"Maharashtra","district":"Mumbai","branch_name":"Kanakia Wall Street, Mumbai","office":"Corporate Office","l1_manager_code":"65432","l1_manager":"Test","l2_manager_code":"65432","l2_manager":"Sanjay Mishra","off_email_add":"test9988@ggtest.com","final_app_lwd":null,"branch_code":"MUM","joining_date":"22-10-2022","suninfo_branch_code":"MH50005MUM"}],"message":"Success"}');
        //contentVersion.VersionData =blob.valueof('{"Data":[{"emp_code":"265","mobile_no":"7501312563","department":"MSE LAP","designation":"Sales Manager","emp_status":"Exited","emp_type":"Permanent","emp_name":"HRMS","first_name":"Satyendra","middle_name":null,"last_name":"HR8","gender":"M","business_sub_func":null,"function":"Support","grade":"Senior Manager","country":"India","zone":"West","state":"Maharashtra","district":"Mumbai","branch_name":"Kanakia Wall Street, Mumbai","office":"Corporate Office","l1_manager_code":"65432","l1_manager":"Test","l2_manager_code":"65432","l2_manager":"Sanjay Mishra","off_email_add":"test4563@gmtest.com","final_app_lwd":null,"branch_code":"MUM","joining_date":"22-10-2022","suninfo_branch_code":"MH50005MUM"}],"message":"Success"}');
        contentVersion.Title = 'response.json';
        contentVersion.PathOnClient = 'response.json';
        contentVersion.FirstPublishLocationId=intmsg.Id;
        insert contentVersion;
        
        List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>{intmsg};
            Set<String> PublicGroup =new Set<String>{'265'};
        
                //HRMSTeamHierarchyQueueable
        Map<id,TeamHierarchy__c> existingTeamHierarchyMap =new Map<id,TeamHierarchy__c>([Select id from TeamHierarchy__c limit 100]); 
        Map<String, HRMSAPIResponseWrapper.Data> empDataMap = new Map<String, HRMSAPIResponseWrapper.Data>();
        HRMSAPIResponseWrapper.Data empData = new HRMSAPIResponseWrapper.Data();
        empData.emp_code = '265';
        empData.mobile_no = '7501312563';
        empData.department = 'MSE LAP';
        empData.designation = 'Sales Manager';
        empData.emp_status = 'Active';
        empData.emp_type = 'Permanent';
        empData.emp_name = 'HRMS';
        empData.first_name = 'Satyendra';
        empData.middle_name = null;
        empData.last_name = 'HR8';
        empData.gender = 'M';
        empData.business_sub_func = null;
        empData.function = 'Support';
        empData.grade = 'Senior Manager';
        empData.country = 'India';
        empData.zone = 'West';
        empData.state = 'Maharashtra';
        empData.district = 'Mumbai';
        empData.branch_name = 'Kanakia Wall Street, Mumbai';
        empData.office = 'Corporate Office';
        empData.l1_manager_code = '65432';
        empData.l1_manager = 'Test';
        empData.l2_manager_code = '65432';
        empData.l2_manager = 'Sanjay Mishra';
        empData.off_email_add = 'test4563@gmtest.com';
        empData.final_app_lwd = null;
        empData.branch_code = 'MUM';
        empData.joining_date = '22-10-2022';
        empData.suninfo_branch_code = 'MH50005MUM';
        
        empDataMap.put(empData.emp_code, empData);
        Set<String> branchCodes = new Set<String>{'MUM'};
        Set<String> priorBranchCodes = new Set<String>{'PUN'};
            
        HRMSTeamHierarchyQueueable job = new HRMSTeamHierarchyQueueable(existingTeamHierarchyMap, empDataMap, branchCodes, priorBranchCodes);
        
        Test.startTest();
        HRMSAPIResponseProcessor.process(IntgMsgList);
        HRMSAPIResponseProcessor.addUsersToPublicGroups(PublicGroup);
        HRMSAPIResponseProcessor.deletePermissionset(PublicGroup,'Active Users');
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    
     @istest
    public static void testmethod2(){
        
        IntgMsg__c intmsg =new IntgMsg__c();
        intmsg.Name='Get HRMS Details';
        intmsg.Status__c='New';
        intmsg.MStatus__c='Blank';
        intmsg.BU__c='HL / STL';
        intmsg.Svc__c='Get HRMS Details';
        intmsg.ApiVendor__c='HRMS';
        intmsg.IsActive__c=true; 
        
        TriggerBase.bypass('IntgMsg__c');
        Insert intmsg;
        TriggerBase.clearBypass('IntgMsg__c');
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('{"Data":[{}],"message":"error"}');
        contentVersion.Title = 'response.json';
        contentVersion.PathOnClient = 'response.json';
        contentVersion.FirstPublishLocationId=intmsg.Id;
        insert contentVersion;
        
        List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>{intmsg};
        Test.startTest();
        HRMSAPIResponseProcessor.process(IntgMsgList);
        Test.stopTest();
    }

}