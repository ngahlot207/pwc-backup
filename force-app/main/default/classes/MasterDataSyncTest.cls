@istest
public class MasterDataSyncTest {
    
     @isTest
    public static void testGenerateMethod() {
        
        Account acc=new Account();
        acc.Name='test';
        acc.DSAConnId__c='3';
        acc.VCReferralId__c='3';
        Insert acc;
        
        CityInstrument__c ci=new CityInstrument__c();
        ci.CityId__c='160';
        insert ci;
        
        BankMstr__c bm=new BankMstr__c();
        bm.BankId__c='024';
        //bm.City__c='160';
        insert bm;
        
       SchmGrp__c sg=new SchmGrp__c();
        sg.SCHID__c='270';
        insert sg;
        
        List<MasterDataSync__c> mdsList =new List<MasterDataSync__c>();
        MasterDataSync__c mds =new MasterDataSync__c();
        mds.MasterDataType__c='DSAMASTER';
        mds.Identifier__c='47012275';
        mds.Record__c='{"PRODUCT_CODE":"LAP","DSA_NAME":"","BROKERID":"","BRANCH":"DELHI","AUTHID":"FEDM","ACTIVE_STATUS":"I"}';
        mdsList.add(mds);
        
        MasterDataSync__c mds1 =new MasterDataSync__c();
        mds1.MasterDataType__c='DSAMASTER';
        mds1.Identifier__c='47012275';
        mds1.Record__c='{"PRODUCT_CODE":"LAP","DSA_NAME":"VALUE LINE FINANCIAL SERVICES","BROKERID":"4","BRANCH":"DELHI","AUTHID":"FEDM","ACTIVE_STATUS":"I"}';
        mdsList.add(mds1);
        
        MasterDataSync__c mds2 =new MasterDataSync__c();
        mds2.MasterDataType__c='CONNECTORMASTER';
        mds2.Identifier__c='47012275';
        mds2.Record__c='{"VC_REFERRAL_NAME":"ANAND THANGAMALIGAI","VC_REFERRAL_ID":"13","VC_REFERRAL_CD":"CPSS1001","STATUS":"A","LPP_PRODCAT_C":"PERSONAL","AUTHID":"IT011579"}';
        mdsList.add(mds2);
        
        MasterDataSync__c mds3 =new MasterDataSync__c();
        mds3.MasterDataType__c='PROPERTYSUBTYPEMASTER';
        mds3.Identifier__c='47012275';
        mds3.Record__c='{"VALUE":"CHGP","KEY1":"PROPDESC","DESCRIPTION":"CH - GRAMPANCHAYAT PROPERTIES","AUTHID":"APIUSER"}';
        mdsList.add(mds3);
       
        
        MasterDataSync__c mds4 =new MasterDataSync__c();
        mds4.MasterDataType__c='BRANCHMASTER';
        mds4.Identifier__c='47012275';
        mds4.Record__c='{"SUNINFO_BRANCH_CODE":"test","PHONE1":"04442178159","BRANCHID":"4","BRANCHDESC":"PUNE","BRANCHCODE":"PUN","AUTHID":"IT017531"}';
        mdsList.add(mds4);
        
        MasterDataSync__c mds5 =new MasterDataSync__c();
        mds5.MasterDataType__c='SCHEMEMASTER';
        mds5.Identifier__c='47012275';
        mds5.Record__c='{"TENURE":"180","STATUS":"A","SCHID":"270","SCHEMEID":"563","SCHEMEDESC":"STL - NRP NEW - FIXED","SCHEME_START_DATE":"2019-11-14T00:00:00","SCHEME_END_DATE":"21/12/2099","PRODUCTFLAG":"STL","MINTENURE":"24","MININTRATE":"10.0","MINAMTFIN":"300000.0","MAXTENURE":"180","MAXINTRATE":"24.0","MAXAMTFIN":"7500000.0","INTRATE":"13.0","INSTLTYPE":"E","INSTLMODE":"R","FREQUENCY":"M","AUTHID":"IT018235"}';
        mdsList.add(mds5);
        
        MasterDataSync__c mds6 =new MasterDataSync__c();
        mds6.MasterDataType__c='TECHNICALAGENCYEMASTER';
        mds6.Identifier__c='47012275';
        mds6.Record__c='{"LAWYERNAME":"PADMAVATHI ARCHITECTURE CONSTULTANC","BRANCHID":"409","BRANCH":"NARASARAOPETA MSE","AUTHID":"IT018235"}';
        mdsList.add(mds6);
        
        MasterDataSync__c mds7 =new MasterDataSync__c();
        mds7.MasterDataType__c='LEGALAGENCYEMASTER';
        mds7.Identifier__c='47012275';
        mds7.Record__c='{"LFAM_AGENCYNAME_C":"ASTUTE CORPORATE SERVICES PRIVATE L","LFAM_AGENCYCODE_C":"ASTUTE_PUNE","LFABPMM_PRODCODE_C":"BL","BRANCH":"AHMEDABAD","BRANCHID":"409"}';
        mdsList.add(mds7);
        
         MasterDataSync__c mds8 =new MasterDataSync__c();
        mds8.MasterDataType__c='BANKNAMEMASTER';
        mds8.Identifier__c='47012275';
        mds8.Record__c='{"FABANKGLID":"FBPF","BANKID":"11","BANKDESC":"FEDERAL BANK - PF A/C","BANKACNUM":"13850200015678","BANK_IFS_C":"FDRL0001385","AUTHID":"SMM1"}';
        mdsList.add(mds8);
        
        MasterDataSync__c mds9 =new MasterDataSync__c();
        mds9.MasterDataType__c='MICRMASTER';
        mds9.Identifier__c='47012275';
        mds9.Record__c='{"NAME":"SECTOR 12, PANCHKULA","MICRCODE":"160024010","LSO_OFFICE_IFS_C":"PUNB0395600","CLEARINGHOUSEID":"641","CITYID":"160","BBRANCHID":"7220","BANKID":"024","BANKBRANCHID":"010","APPROVEDBY":"70019384","APPROVALDATE":"2011-07-18T00:00:00"}';
        mdsList.add(mds9);
        
         MasterDataSync__c mds10 =new MasterDataSync__c();
        mds10.MasterDataType__c='CHARGESMASTER';
        mds10.Identifier__c='47012275';
        mds10.Record__c='{"MODULEID":"LEA","CHARGEID":"230","CHARGEDESC":"UNUTILIZED DMA SUBVENTION","CHARGECODEID":"230","CHARGEAMT":1,"AUTHID":"ADMIN"}';
        mdsList.add(mds10);
        
        MasterDataSync__c mds11 =new MasterDataSync__c();
        mds11.MasterDataType__c='INSPECTORMASTER';
        mds11.Identifier__c='47012275';
        mds11.Record__c='{"INSPECTORNAME":"SHINEY AHUJA","INSPECTORID":"8","BROKERNAME":"ESCORTS FINANCIALS","BROKERID":"3","AUTHID":"RITIKA"}';
        mdsList.add(mds11);
        
        MasterDataSync__c mds12 =new MasterDataSync__c();
        mds12.MasterDataType__c='CONSTITUTIONMASTER';
        mds12.Identifier__c='47012275';
        mds12.Record__c='{"STATUS":"A","CONSTID":"9","CONSTDESC":"SOCIETY","AUTHID":"RITIKA"}';
        mdsList.add(mds12);
        
          MasterDataSync__c mds13 =new MasterDataSync__c();
        mds13.MasterDataType__c='FIAGENCYEMASTER';
        mds13.Identifier__c='47012275';
        mds13.Record__c='{"LFAM_AGENCYNAME_C":"ASTUTE CORPORATE SERVICES PRIVATE L","LFAM_AGENCYCODE_C":"ASTUTE_PUNE","LFABPMM_PRODCODE_C":"BL","BRANCH":"AHMEDABAD","BRANCHID":"409"}';
        mdsList.add(mds13);
        
         MasterDataSync__c mds14 =new MasterDataSync__c();
        mds14.MasterDataType__c='RCUAGENCYEMASTER';
        mds14.Identifier__c='47012275';
        mds14.Record__c='{"LFAM_AGENCYNAME_C":"ASTUTE CORPORATE SERVICES PRIVATE L","LFAM_AGENCYCODE_C":"ASTUTE_PUNE","LFABPMM_PRODCODE_C":"BL","BRANCH":"AHMEDABAD","BRANCHID":"409"}';
        mdsList.add(mds14);
        
        MasterDataSync__c mds15 =new MasterDataSync__c();
        mds15.MasterDataType__c='MICRMASTER';
        mds15.Identifier__c='47012275';
        mds15.Record__c='{"NAME":"SECTOR 12, PANCHKULA","MICRCODE":"160024010","LSO_OFFICE_IFS_C":"PUNB0395600","CLEARINGHOUSEID":"641","CITYID":"160","BBRANCHID":"7220","BANKID":"024","BANKBRANCHID":"010","APPROVEDBY":"70019384","APPROVALDATE":"2011-07-18T00:00:00"}';
        mdsList.add(mds15);
        
        MasterDataSync__c mds16 =new MasterDataSync__c();
        mds16.MasterDataType__c='MICRMASTER';
        mds16.Identifier__c='47012275';
        mds16.Record__c='{"VALUE":"SECONDARY","KEY1":"PURCHASETYPE","DESCRIPTION":"SECONDARY","AUTHID":"SYSTEM"}';
        mdsList.add(mds16);
        
        MasterDataSync__c mds17 =new MasterDataSync__c();
        mds17.MasterDataType__c='PROPERTPROPUSAGEMASTER';
        mds17.Identifier__c='47012275';
        mds17.Record__c='{"VALUE":"LO","KEY1":"PROPUSAGE","DESCRIPTION":"LET OUT","AUTHID":"APIUSER"}';
        mdsList.add(mds17);
        
        MasterDataSync__c mds18 =new MasterDataSync__c();
        mds18.MasterDataType__c='MICRBANKNAME';
        mds18.Identifier__c='47012275';
        mds18.Record__c='{"NAME":"ABHINANDAN URBAN COOP BANK LTD","BANKID":"885","CITYID":"160"}';
        mdsList.add(mds18);
        
        //error handling
        MasterDataSync__c mds19 =new MasterDataSync__c();
        mds19.MasterDataType__c='CONNECTORMASTER';
        mds19.Identifier__c='47012275';
        mds19.Record__c='{"VC_REFERRAL_NAME":"ANAND THANGAMALIGAI","VC_REFERRAL_ID":"","VC_REFERRAL_CD":"CPSS1001","STATUS":"A","LPP_PRODCAT_C":"PERSONAL","AUTHID":"IT011579"}';
        mdsList.add(mds19);
        
         MasterDataSync__c mds20 =new MasterDataSync__c();
        mds20.MasterDataType__c='CONNECTORMASTER';
        mds20.Identifier__c='47012275';
        mds20.Record__c='{"VC_REFERRAL_NAME":"ANAND THANGAMALIGAI","VC_REFERRAL_ID":"13","VC_REFERRAL_CD":"","STATUS":"A","LPP_PRODCAT_C":"PERSONAL","AUTHID":"IT011579"}';
        mdsList.add(mds20);
        
        MasterDataSync__c mds21 =new MasterDataSync__c();
        mds21.MasterDataType__c='PROPERTYSUBTYPEMASTER';
        mds21.Identifier__c='47012275';
        mds21.Record__c='{"VALUE":"","KEY1":"PROPDESC","DESCRIPTION":"CH - GRAMPANCHAYAT PROPERTIES","AUTHID":"APIUSER"}';
        mdsList.add(mds21);
        
        MasterDataSync__c mds22 =new MasterDataSync__c();
        mds22.MasterDataType__c='PROPERTYSUBTYPEMASTER';
        mds22.Identifier__c='47012275';
        mds22.Record__c='{"VALUE":"CHGP","KEY1":"PROPDESC","DESCRIPTION":"","AUTHID":"APIUSER"}';
        mdsList.add(mds22);
        
        MasterDataSync__c mds23 =new MasterDataSync__c();
        mds23.MasterDataType__c='PROPERTTYPEMASTER';
        mds23.Identifier__c='47012275';
        mds23.Record__c='{"VALUE":"NEW","KEY1":"PURCHASETYPE","DESCRIPTION":"NEW","AUTHID":"SYSTEM"}';
        mdsList.add(mds23);
        
        MasterDataSync__c mds24 =new MasterDataSync__c();
        mds24.MasterDataType__c='PROPERTTYPEMASTER';
        mds24.Identifier__c='47012275';
        mds24.Record__c='{"VALUE":"Property Type","KEY1":"PURCHASETYPE","DESCRIPTION":"","AUTHID":"SYSTEM"}';
        mdsList.add(mds24);
        
        MasterDataSync__c mds25 =new MasterDataSync__c();
        mds25.MasterDataType__c='BRANCHMASTER';
        mds25.Identifier__c='47012275';
        mds25.Record__c='{"SUNINFO_BRANCH_CODE":"","PHONE1":"","BRANCHID":"","BRANCHDESC":"","BRANCHCODE":"","AUTHID":""}';
        mdsList.add(mds25);
        
        MasterDataSync__c mds26 =new MasterDataSync__c();
        mds26.MasterDataType__c='SCHEMEMASTER';
        mds26.Identifier__c='47012275';
        mds26.Record__c='{"TENURE":"","STATUS":"","SCHID":"","SCHEMEID":"","SCHEMEDESC":"","SCHEME_START_DATE":"","SCHEME_END_DATE":"","PRODUCTFLAG":"","MINTENURE":"","MININTRATE":"","MINAMTFIN":"","MAXTENURE":"","MAXINTRATE":"","MAXAMTFIN":"","INTRATE":"","INSTLTYPE":"","INSTLMODE":"","FREQUENCY":"","AUTHID":""}';
        mdsList.add(mds26);
        
        MasterDataSync__c mds27 =new MasterDataSync__c();
        mds27.MasterDataType__c='TECHNICALAGENCYEMASTER';
        mds27.Identifier__c='47012275';
        mds27.Record__c='{"LAWYERNAME":"","BRANCHID":"","BRANCH":"","AUTHID":""}';
        mdsList.add(mds27);
        
        MasterDataSync__c mds28 =new MasterDataSync__c();
        mds28.MasterDataType__c='LEGALAGENCYEMASTER';
        mds28.Identifier__c='47012275';
        mds28.Record__c='{"LFAM_AGENCYNAME_C":"","LFAM_AGENCYCODE_C":"","LFABPMM_PRODCODE_C":"","BRANCH":"","BRANCHID":""}';
        mdsList.add(mds28);
        
        MasterDataSync__c mds29 =new MasterDataSync__c();
        mds29.MasterDataType__c='BANKNAMEMASTER';
        mds29.Identifier__c='47012275';
        mds29.Record__c='{"FABANKGLID":"","BANKID":"","BANKDESC":"","BANKACNUM":"","BANK_IFS_C":"","AUTHID":""}';
        mdsList.add(mds29);
        
        MasterDataSync__c mds30 =new MasterDataSync__c();
        mds30.MasterDataType__c='MICRBANKNAME';
        mds30.Identifier__c='47012275';
        mds30.Record__c='{"NAME":"","BANKID":"","CITYID":""}';
        mdsList.add(mds30);
        
        
       MasterDataSync__c mds31 =new MasterDataSync__c();
        mds31.MasterDataType__c='INSPECTORMASTER';
        mds31.Identifier__c='47012275';
        mds31.Record__c='{"INSPECTORNAME":"","INSPECTORID":"","BROKERNAME":"","BROKERID":"","AUTHID":""}';
        mdsList.add(mds31);
        
        MasterDataSync__c mds32 =new MasterDataSync__c();
        mds32.MasterDataType__c='CONSTITUTIONMASTER';
        mds32.Identifier__c='47012275';
        mds32.Record__c='{"STATUS":"","CONSTID":"","CONSTDESC":"","AUTHID":""}';
        mdsList.add(mds32);
        
        MasterDataSync__c mds33 =new MasterDataSync__c();
        mds33.MasterDataType__c='FIAGENCYEMASTER';
        mds33.Identifier__c='47012275';
        mds33.Record__c='{"LFAM_AGENCYNAME_C":"","LFAM_AGENCYCODE_C":"","LFABPMM_PRODCODE_C":"","BRANCH":"","BRANCHID":""}';
        mdsList.add(mds33);
        
        MasterDataSync__c mds34 =new MasterDataSync__c();
        mds34.MasterDataType__c='RCUAGENCYEMASTER';
        mds34.Identifier__c='47012275';
        mds34.Record__c='{"LFAM_AGENCYNAME_C":"","LFAM_AGENCYCODE_C":"","LFABPMM_PRODCODE_C":"","BRANCH":"","BRANCHID":""}';
        mdsList.add(mds34);
        
        MasterDataSync__c mds35 =new MasterDataSync__c();
        mds35.MasterDataType__c='CITYMASTER';
        mds35.Identifier__c='47012275';
        mds35.Record__c='{"LMC_CITYID_C":"1735","LMC_CITYNAME_C":"GUNA","STATEID":"29","GSTSTATECODE":"24","STATEDESC":"GUJARAT","AUTHID":"IT011579","AUTHDATE":"2024-08-18T06:41:10"}';
        mdsList.add(mds35);
        
        MasterDataSync__c mds36 =new MasterDataSync__c();
        mds36.MasterDataType__c='CITYPINCODEMAPPING';
        mds36.Identifier__c='47012275';
        mds36.Record__c='{"ZIPID":"14584","PINCODE":"605118","CITYID":"1308","AUTHID":"IT011579","AUTHDATE":"2024-08-18T06:41:10"}';
        mdsList.add(mds36);
        
        insert mdsList;
        
       Test.StartTest();
       MasterDataSync.processMasterData(mdsList);
        Test.StopTest();
    
    }
     
   
}