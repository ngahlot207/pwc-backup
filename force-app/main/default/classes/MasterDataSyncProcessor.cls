public class MasterDataSyncProcessor {
    public static void process(List<IntgMsg__c> responses){ 
        try{
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
        List<MasterDataSync__c> masterDataSyncRecords = new List<MasterDataSync__c>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Req__c!=null){
                MasterDataSyncResponseWrapper response= (MasterDataSyncResponseWrapper) JSON.deserialize(integrationMessage.Req__c,MasterDataSyncResponseWrapper.class);
                if(String.isNotBlank(response.identifier) && !response.masterbody.isEmpty()){
                    for(Masterbody data : response.masterbody){
                        if(String.isNotBlank(data.masterDataType) && data.masterData!=null && !data.masterData.isEmpty()){
                            for(MasterData masterData : data.masterData){
                                if(!masterData.record.isEmpty()){
                                    Integer seqNo=0;
                                    for(Record obj : masterData.record){
                                        system.debug(obj);
                                        MasterDataSync__c mds = new MasterDataSync__c();
                                        mds.Identifier__c=response.identifier;
                                        mds.MasterDataType__c = data.masterDataType;
                                        mds.Async__c = String.isNotBlank(data.asyncProcessing) ? data.asyncProcessing.equalsIgnoreCase('true')? true : false : true;
                                        mds.Record__c = JSON.serialize(obj,true);
                                        mds.SequenceNumber__c=++seqNo;
                                        masterDataSyncRecords.add(mds);
                                    }
                                }
                            }    
                            
                            
                            
                            MasterDataSync__c mds = new MasterDataSync__c();
                            mds.Identifier__c=response.identifier;
                        }
                    }
                }
                
                IntgMsg__c intg=New IntgMsg__c();
                intg.id=integrationMessage.Id;
                intg.Status__c = 'Processed';
                updateIntRecords.add(intg);    
            }
        }
        
        if(!updateIntRecords.isEmpty()) {
            String sObjectName = 'IntgMsg__c';
            List<String> fieldNamesList = new List<String>{'Status__c'};
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(updateIntRecords);
        }
        uow.commitWork();
        if(!masterDataSyncRecords.isEmpty()){
            insert masterDataSyncRecords;
        }
        }
        catch(Exception ex){
            System.debug(ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public class MasterDataSyncResponseWrapper{
        
        public String identifier;	//47012275
        public List<Masterbody> masterbody;
        
    }
    public class Masterbody {
        public String masterDataType;	//DSAMASTER
        public String asyncProcessing;	//true
        public List<MasterData> masterData;
    }
    public class MasterData {
        public List<Record> record;
    }
    public class Record{
        public String BROKERID;	//4
        public String DSA_NAME;	//VALUE LINE FINANCIAL SERVICES
        public String BRANCH;	//DELHI
        public String PRODUCT_CODE;	//LAP
        public String ACTIVE_STATUS;	//I
        public String AUTHID;	//FEDM
        public String AUTHDAT;
        public String VC_REFERRAL_ID;	//13
        public String VC_REFERRAL_CD;	//CPSS1001
        public String VC_REFERRAL_NAME;	//ANAND THANGAMALIGAI
        public String LPP_PRODCAT_C;	//PERSONAL
        public String STATUS;	//A
        public String KEY1;	//PROPDESC
        public String VALUE;	//HRH
        public String DESCRIPTION;	//HR - HSIIDC
        public String BRANCHID;	//88
        public String BRANCHDESC;	//REPALLE
        public String PHONE1;	//08648320022
        public String BRANCHCODE;	//REP
        public String SUNINFO_BRANCH_CODE;	//Closed
        public String PRODUCTFLAG;	//LAP
        public String SCHEME_END_DATE;	//16/07/2018
        public String SCHEMEID;	//325
        public String SCHEMEDESC;	//TOP-UP - OTHERS
        public String FREQUENCY;	//M
        public String INSTLMODE;	//R
        public String INSTLTYPE;	//E
        public String INTRATE;	//13.0
        public String MAXAMTFIN;	//50000000.0
        public String MAXINTRATE;	//24.0
        public String MAXTENURE;	//180
        public String MINAMTFIN;	//100000.0
        public String MININTRATE;	//10.0
        public String MINTENURE;	//
        public String SCHID;	//239
        public String SCHEME_START_DATE;	//2012-06-25T00:00:00
        public String TENURE;	//180
        public String LAWYERNAME;	//K P SATISH BABU
        public String LFAM_AGENCYCODE_C;	//G A MEMON
        public String LFAM_AGENCYNAME_C;	//G A MEMON
        public String LFABPMM_PRODCODE_C;	//LAP
        public String BANKID;	//11
        public String BANKDESC;	//FEDERAL BANK - PF A/C
        public String FABANKGLID;	//FBPF
        public String BANKACNUM;	//13850200015678
        public String BANK_IFS_C;	//FDRL0001385
        public String BANK_RTGS_C;	//
        public String BANK_NEFT_C;	//
        public String BANK_IMPS_C; 
        public String CHARGEID;	//230
        public String MODULEID;	//LEA
        public String CHARGECODEID;	//230
        public String CHARGEDESC;	//UNUTILIZED DMA SUBVENTION
        public Decimal CHARGEAMT;	//1
        public String TAX_APPL_FLG;	//
        public String GST_FLAG;	//
        public String INSPECTORID;	//8
        public String INSPECTORNAME;	//SHINEY AHUJA
        public String BROKERNAME;	//ESCORTS FINANCIALS
        public String CONSTID;	//7
        public String CONSTDESC;	//HUF
        public String BBRANCHID;	//7220
        public String CITYID;	//160
        public String BANKBRANCHID;	//010
        public String NAME;	//SECTOR 12, PANCHKULA
        public String CLEARINGHOUSEID;	//641
        public String MICRCODE;	//160024010
        public String LSO_OFFICE_IFS_C;	//PUNB0395600
        public String APPROVEDBY;	//70019384
        public String APPROVALDATE;	//2011-07-18T00:00:00
        
        public String LMC_CITYID_C;	//1735
        public String LMC_CITYNAME_C;	//GUNA
        public String STATEID;	//29
        public String GSTSTATECODE;	//24
        public String STATEDESC;	//GUJARAT
        public String AUTHDATE;	//2024-08-18T06:41:10
        
        public String ZIPID;	//14584
        public String PINCODE;	//605118
        
    }
}