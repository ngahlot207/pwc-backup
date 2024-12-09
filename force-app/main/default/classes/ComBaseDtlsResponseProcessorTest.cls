@isTest
public class ComBaseDtlsResponseProcessorTest {
    
    @isTest
    static void testProcessSuccess1() {
        
        LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 
        applicant1.PAN__c='AAAFQ4251B';
        applicant1.FName__c='ANIL RAI GUPTA';
        applicant1.ApplType__c ='D';
        update applicant1;
        
        List<Applicant__c> liAppls=new List<Applicant__c>();
        Applicant__c appl1=new Applicant__c();
        appl1.PAN__c='ADTPG8791J';
        appl1.LoanAppln__c=loanApplication.Id;
        appl1.FName__c='Example One';
        appl1.Gender__c='M';
        appl1.ApplType__c='D';
        appl1.DOB__c=Date.newInstance(2001, 8, 13);
        appl1.Age__c=27;
        liAppls.add(appl1);
        
        
        Applicant__c appl2=new Applicant__c();
        appl2.PAN__c='AFZCG3995M';
        appl2.LoanAppln__c=loanApplication.Id;
        appl2.FName__c='Abcd Efgh';
        appl2.Gender__c='M';
        appl2.ApplType__c='D';
        appl2.DOB__c=Date.newInstance(2000, 8, 13);
        appl2.Age__c=26;
        liAppls.add(appl2);
        
        insert liAppls;
        System.debug('Applicant 1 PAN: ' + appl1.PAN__c);
        System.debug('Applicant 2 PAN: ' + appl2.PAN__c);
        List<IntgMsg__c> listIntgMsg= new List<IntgMsg__c>();
        
        List<APIVer__c> apiVersions = new List<APIVer__c>();
        APIVer__c apiVer = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        APIVer__c apiVer1 = new APIVer__c(Appl__c = appl1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        APIVer__c apiVer2 = new APIVer__c(Appl__c = appl2.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        apiVersions.add(apiVer1);
        apiVersions.add(apiVer);
        apiVersions.add(apiVer2);
        
        insert apiVersions;
        List<Applicant__c> existingAppWIthPans = [SELECT Id,name,PAN__c,LoanAppln__c, FName__c, Gender__c, ApplType__c,DOB__c,Age__c,Nationality__c from Applicant__c where PAN__c =: appl2.PAN__c AND ApplType__c ='D' AND LoanAppln__c =: loanApplication.Id];
        System.debug('existingAppWIthPans test=='+existingAppWIthPans);       
        TriggerBase.bypass('IntgMsg__c');
        IntgMsg__c intgMsg4 =new IntgMsg__c();
        intgMsg4.Svc__c='Company Base Details';
        intgMsg4.BU__c = 'HL / STL';
        intgMsg4.MStatus__c='Blank';
        intgMsg4.Status__c = 'New';
        intgMsg4.Resp__c = '';
        intgMsg4.RefId__c = appl1.Id;
        intgMsg4.RefObj__c='Applicant__c';
        intgMsg4.Name='Company Base Details';
        intgMsg4.ParentRefObj__c ='LoanAppl__c';
        intgMsg4.ParentRefId__c =loanApplication.Id; 
        listIntgMsg.add(intgMsg4);
        
        IntgMsg__c intgMsg5 =new IntgMsg__c();
        intgMsg5.Svc__c='Company Base Details';
        intgMsg5.BU__c = 'HL / STL';
        intgMsg5.MStatus__c='Blank';
        intgMsg5.Status__c = 'New';
        intgMsg5.Resp__c = '';
        intgMsg5.RefId__c = appl2.Id;
        intgMsg5.RefObj__c='Applicant__c';
        intgMsg5.Name='Company Base Details';
        intgMsg5.ParentRefObj__c ='LoanAppl__c';
        intgMsg5.ParentRefId__c =loanApplication.Id; 
        listIntgMsg.add(intgMsg5);
        
        
        
        
        insert listIntgMsg;
        TriggerBase.clearBypass('IntgMsg__c');
        
        
        List<ContentVersion> listContVer= new List<ContentVersion>();
        
        ContentVersion contentVersion3 = new ContentVersion();
        contentVersion3.VersionData =blob.valueof('{"metadata":{"api_version":"1.3","last_updated":"2024-06-20"},"data":{"company":{"cin":"L74120MH1985PLC035308","legal_name":"GODREJ PROPERTIES LIMITED","efiling_status":"Active","incorporation_date":"1985-02-08","paid_up_capital":1390207370,"sum_of_charges":43456500000,"authorized_capital":6690000000,"active_compliance":"ACTIVE compliant","cirp_status":null,"lei":{"number":"335800KM3Y5NZWXOE183","status":"ISSUED"},"registered_address":{"full_address":"Godrej One, 5th Floor, Pirojshanagar   Eastern Express Highway, Vikhroli (East), ,Mumbai, Maharashtra - 400079","address_line1":"Godrej One, 5th Floor, Pirojshanagar   Eastern Express Highway, Vikhroli (East)","address_line2":",","city":"Mumbai","pincode":"400079","state":"Maharashtra"},"classification":"Public Limited Indian Non-Government Company","status":"Listed","next_cin":null,"last_agm_date":"2023-08-02","last_filing_date":"2023-03-31","email":"secretarial@godrejproperties.com"},"authorized_signatories":[{"pan":"ADTPG8791J","din":"00432983","name":"PIROJSHA ADI GODREJ","designation":"Whole-time director","din_status":"Approved","gender":"Male","date_of_birth":"1980-10-27","age":44,"date_of_appointment":"2008-10-25","date_of_appointment_for_current_designation":"2018-04-01","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"APDPP0659J","din":"07229661","name":"GAURAV PANDEY","designation":"Managing Director","din_status":"Approved","gender":"Male","date_of_birth":"1983-05-18","age":41,"date_of_appointment":"2023-01-01","date_of_appointment_for_current_designation":"2023-01-01","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"ALCPB9271H","din":"09302960","name":"INDU BHUSHAN","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1961-01-06","age":63,"date_of_appointment":"2022-05-03","date_of_appointment_for_current_designation":"2022-07-04","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AGBPB6003B","din":"02844650","name":"SUTAPA BANERJEE","designation":"Director","din_status":"Approved","gender":"Female","date_of_birth":"1965-03-24","age":59,"date_of_appointment":"2019-11-05","date_of_appointment_for_current_designation":"2020-08-05","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AADPG7643Q","din":"00066195","name":"NADIR BURJOR GODREJ","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1951-08-26","age":73,"date_of_appointment":"1990-04-25","date_of_appointment_for_current_designation":"1990-04-25","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAIPN7631G","din":"01874599","name":"SUMEET SUBHASH NARANG","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1976-01-11","age":48,"date_of_appointment":"2023-08-18","date_of_appointment_for_current_designation":"2023-09-28","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"ADGPV2661R","din":"07140297","name":"JAYASHREE VAIDHYANTHAN","designation":"Director","din_status":"Approved","gender":"Female","date_of_birth":"1970-02-01","age":54,"date_of_appointment":"2023-08-02","date_of_appointment_for_current_designation":"2023-09-28","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AACPC1513C","din":"00074230","name":"SMITA GODREJ CRISHNA","designation":"Director","din_status":"Approved","gender":"Female","date_of_birth":"1950-12-30","age":74,"date_of_appointment":"1989-11-30","date_of_appointment_for_current_designation":"1989-11-30","date_of_cessation":"2008-01-16","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AACPN9750C","din":"00065906","name":"RISHAD KAIKHUSHRU NAOROJI","designation":"Director","din_status":"Deactivated due to non-filing of DIR-3 KYC","gender":"Male","date_of_birth":"1951-08-30","age":73,"date_of_appointment":"1989-11-30","date_of_appointment_for_current_designation":"1989-11-30","date_of_cessation":"2008-01-16","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAMPG4506D","din":"00432819","name":"PHEROZA JAMSHYD GODREJ","designation":"Director","din_status":"Approved","gender":"Female","date_of_birth":"1948-10-03","age":76,"date_of_appointment":"1989-11-30","date_of_appointment_for_current_designation":"1989-11-30","date_of_cessation":"2008-01-16","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAEPD8257E","din":"00052165","name":"KEKI BOMI DADISETH","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1945-12-20","age":79,"date_of_appointment":"2008-01-16","date_of_appointment_for_current_designation":"2008-06-18","date_of_cessation":"2021-08-03","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAEPG5696C","din":"00043559","name":"LALITA DILEEP GUPTE","designation":"Director","din_status":"Approved","gender":"Female","date_of_birth":"1948-10-04","age":76,"date_of_appointment":"2008-01-16","date_of_appointment_for_current_designation":"2008-06-18","date_of_cessation":"2023-08-02","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AABPV4181A","din":"00433379","name":"PRANAY DHANSUKHLAL VAKIL","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1947-01-13","age":77,"date_of_appointment":"2008-01-16","date_of_appointment_for_current_designation":"2008-06-18","date_of_cessation":"2022-08-02","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AGOPS0576K","din":"00057377","name":"PRITAM SINGH","designation":"Director","din_status":"Deactivated due to non-filing of DIR-3 KYC","gender":"Male","date_of_birth":"1941-06-14","age":83,"date_of_appointment":"2008-01-16","date_of_appointment_for_current_designation":"2008-06-18","date_of_cessation":"2019-04-01","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AGHPK7750J","din":"00434791","name":"MILIND KORDE SURENDRA","designation":"Managing Director","din_status":"Approved","gender":"Male","date_of_birth":"1963-08-14","age":61,"date_of_appointment":"2003-05-01","date_of_appointment_for_current_designation":"2009-04-01","date_of_cessation":"2012-04-01","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"ABUPN5095R","din":"00094081","name":"SUBBARAMAN NARAYAN","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1943-06-20","age":81,"date_of_appointment":"2008-10-25","date_of_appointment_for_current_designation":"2009-07-27","date_of_cessation":"2017-08-03","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"ABSPJ9748D","din":"01181998","name":"KARAT TAZHTETIL JITHENDRAN","designation":"Whole-time director","din_status":"Approved","gender":"Male","date_of_birth":"1967-04-01","age":57,"date_of_appointment":"2010-05-17","date_of_appointment_for_current_designation":"2011-05-07","date_of_cessation":"2015-12-16","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAEPM4024G","din":"00003285","name":"AMITAVA MUKHERJEE","designation":"Director","din_status":"Deactivated due to non-filing of DIR-3 KYC","gender":"Male","date_of_birth":"1953-05-17","age":71,"date_of_appointment":"2010-05-17","date_of_appointment_for_current_designation":"2010-07-17","date_of_cessation":"2023-07-03","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AABPV8491M","din":"00208978","name":"SRINIVASAN VISHWANATHAN","designation":"Whole-time director","din_status":"Approved","gender":"Male","date_of_birth":"1965-09-08","age":59,"date_of_appointment":"2012-04-01","date_of_appointment_for_current_designation":"2012-04-01","date_of_cessation":"2015-04-01","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AKBPM5127D","din":"07074531","name":"MOHIT MALHOTRA","designation":"Managing Director","din_status":"Approved","gender":"Male","date_of_birth":"1977-12-31","age":47,"date_of_appointment":"2015-04-01","date_of_appointment_for_current_designation":"2017-04-01","date_of_cessation":"2022-12-31","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAMPG3260A","din":"00432572","name":"PARMESHWAR ADI GODREJ","designation":"Director","din_status":"Deactivated due to non-filing of DIR-3 KYC","gender":"Female","date_of_birth":"1944-07-16","age":80,"date_of_appointment":"1989-11-30","date_of_appointment_for_current_designation":"1989-11-30","date_of_cessation":"2016-10-10","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAEPG5459R","din":"00065964","name":"ADI BARJORJI GODREJ","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1942-04-03","age":82,"date_of_appointment":"1990-04-25","date_of_appointment_for_current_designation":"1990-04-25","date_of_cessation":"2017-04-01","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAGPC4516K","din":"00557547","name":"AMIT BIREN CHOUDHURY","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1942-12-26","age":82,"date_of_appointment":"2003-05-01","date_of_appointment_for_current_designation":"2003-05-01","date_of_cessation":"2019-04-01","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AACPG0840L","din":"00076250","name":"JAMSHYD NAOROJI GODREJ","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1949-01-24","age":75,"date_of_appointment":"1990-04-25","date_of_appointment_for_current_designation":"1990-04-25","date_of_cessation":"2024-01-24","nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AAPPK3627E","din":null,"name":"ASHISH SUDHAKAR KARYEKAR","designation":"Company Secretary","din_status":null,"gender":"Male","date_of_birth":"1972-05-22","age":52,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2022-04-15","date_of_cessation":null,"nationality":null,"dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AGMPK7259D","din":null,"name":"RAJENDRA SAWARMAL KHETAWAT","designation":"CFO","din_status":null,"gender":"Male","date_of_birth":"1972-01-17","age":52,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2014-05-02","date_of_cessation":null,"nationality":null,"dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AADPV4598D","din":null,"name":"SURENDER VARMA","designation":"Company Secretary","din_status":null,"gender":"Male","date_of_birth":"1970-06-23","age":54,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2014-11-06","date_of_cessation":"2022-04-15","nationality":null,"dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AGNPK7148N","din":null,"name":"SHODHAN ARVIND KEMBHAVI","designation":"Company Secretary","din_status":null,"gender":null,"date_of_birth":null,"age":0,"date_of_appointment":null,"date_of_appointment_for_current_designation":null,"date_of_cessation":"2014-08-03","nationality":null,"dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}}],"open_charges":[{"id":100603359,"date":"2024-01-02","holder_name":"CATALYST TRUSTEESHIP LIMITED","amount":33505000000,"type":"Modification"},{"id":100496822,"date":"2023-11-05","holder_name":"KOTAK MAHINDRA BANK LIMITED","amount":9500000000,"type":"Modification"},{"id":90238122,"date":"2006-02-01","holder_name":"UTI BANK","amount":160000000,"type":"Modification"},{"id":90238043,"date":"2004-09-03","holder_name":"UTI BANK","amount":160000000,"type":"Modification"},{"id":90232719,"date":"1998-02-02","holder_name":"PUNJAB NATIONAL BANK","amount":100000000,"type":"Creation"},{"id":90232717,"date":"1998-01-15","holder_name":"CANARA BANK","amount":31500000,"type":"Creation"}]}}');
                                                  contentVersion3.Title = 'response.json';
                                                  contentVersion3.PathOnClient = 'response.json';
                                                  listContVer.add(contentVersion3);
                                                  
                                                  
                                                  ContentVersion contentVersion4 = new ContentVersion();
                                                  contentVersion4.VersionData =blob.valueof('{"message":"This is a Company PAN"}');
                                                  contentVersion4.Title = 'response.json';
                                                  contentVersion4.PathOnClient = 'response.json';
                                                  
                                                  
                                                  listContVer.add(contentVersion4);
                                                  
                                                  insert listContVer;
                                                  
                                                  
                                                  List<ContentVersion> listConLinks= [SELECT ContentDocumentId FROM ContentVersion LIMIT 2];
                                                  
                                                  Id contentDocumentId3 = listConLinks[0].ContentDocumentId;
                                                  Id contentDocumentId4 = listConLinks[1].ContentDocumentId;
                                                  List<ContentDocumentLink> listConVerLn= new List<ContentDocumentLink>();
                                                  ContentDocumentLink contentLink3 = new ContentDocumentLink();
                                                  contentLink3.ContentDocumentId = contentDocumentId3;
                                                  contentLink3.LinkedEntityId=intgMsg4.id;
                                                  contentLink3.ShareType = 'V';
                                                  // insert contentLink3;
                                                  listConVerLn.add(contentLink3);
                                                  
                                                  
                                                  ContentDocumentLink contentLink4 = new ContentDocumentLink();
                                                  contentLink4.ContentDocumentId = contentDocumentId4;
                                                  contentLink4.LinkedEntityId=intgMsg5.id;
                                                  contentLink4.ShareType = 'V';
                                                  listConVerLn.add(contentLink4);
                                                  
                                                  
                                                  insert listConVerLn;
                                                  
                                                  List<IntgMsg__c> responses3 =new List<IntgMsg__c>{intgMsg4};
                                                  List<IntgMsg__c> responses4 =new List<IntgMsg__c>{intgMsg5};
                                                  
                                                  
                                                  
                                                  
                                                  //
                                                  
                                                  
                                                  Test.startTest();
                                                  
                                                  ComBaseDtlsResponseProcessor.process(responses3);
                                                  ComBaseDtlsResponseProcessor.process(responses4);
                                                  Test.StopTest();
                                                  }
                                                  
                                                  
                                                  }