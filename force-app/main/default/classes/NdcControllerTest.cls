@isTest
public class NdcControllerTest {
    
    @testSetup
    static void setupTestData() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        //loan.Product__c ='    Home Loan';
        Applicant__c Applicant = TestDataFactory.createSingleApplicant(true,loan.id);
        
        //  Applicant.FullName__c = 'Test Test';
        // TriggerBase.bypass('Applicant__c');
        //update reparAcc;
        //TriggerBase.clearBypass('Applicant__c');
        List<ApplicantEmployment__c> appEmpList = new List<ApplicantEmployment__c>();
        appEmpList.add(new ApplicantEmployment__c(
            UdyamAssistCertificate__c = '4567895678',
            UdyamRegistrationNumber__c = 'UDYAM-JH-00-9876543',
            LoanApplicant__c = Applicant.Id
        ));
        TriggerBase.bypass('ApplicantEmployment__c');
        insert appEmpList;
        TriggerBase.clearBypass('ApplicantEmployment__c');
        
        List<ApplAddr__c> appAddrList = new List<ApplAddr__c>();
        appAddrList.add(new ApplAddr__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            OwnType__c = 'B',
            HouseNo__c = '1-15',
            AddrLine1__c = 'test',
            AddrLine2__c = 'test',
            AddrTyp__c = 'Permanent Address'
        ));
        appAddrList.add(new ApplAddr__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            OwnType__c = 'B',
            HouseNo__c = '1-15',
            AddrLine1__c = 'test',
            AddrLine2__c = 'test',
            AddrTyp__c = '	Office Address'
        ));
        appAddrList.add(new ApplAddr__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            OwnType__c = 'B',
            HouseNo__c = '1-15',
            AddrLine1__c = 'test',
            AddrLine2__c = 'test',
            AddrTyp__c = 'Residence Address'
        ));
        TriggerBase.bypass('ApplAddr__c');
        insert appAddrList;
        TriggerBase.clearBypass('ApplAddr__c');
        
        Repayment_Account__c reparAcc = new Repayment_Account__c();
        reparAcc.Loan_Application__c = loan.Id;
        reparAcc.Is_Active__c = true;
        reparAcc.Repayment_Mode__c = 'PDC';
        TriggerBase.bypass('Repayment_Account__c');
        insert reparAcc;
        TriggerBase.clearBypass('Repayment_Account__c');
        
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'Repayment Documents SPDCs',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Repayment Documents',
            DocSubTyp__c = 'Repayment Documents PDCs',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Property Documents',
            DocTyp__c = 'Property Documents - Common',
            DocSubTyp__c = 'Prop Non-Critical OTC 2',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Additional Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'OTC declaration',
            Active__c = TRUE
        ));
        TriggerBase.bypass('DocMstr__c');
        insert docMstrList;
        TriggerBase.clearBypass('DocMstr__c');
        
        BankBrchMstr__c bankBraMstr = new BankBrchMstr__c();
        bankBraMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBraMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');
        
        LocMstr__c locMstr = new LocMstr__c();
        locMstr.State__c = 'MADHYA PRADESH';
        TriggerBase.bypass('LocMstr__c');
        insert locMstr;
        TriggerBase.clearBypass('LocMstr__c');
        
        LocBrchJn__c locsBrJun = new LocBrchJn__c();
        locsBrJun.Branch__c = bankBraMstr.Id;
        locsBrJun.Location__c = locMstr.Id; 
        TriggerBase.bypass('LocBrchJn__c');
        insert locsBrJun;
        TriggerBase.clearBypass('LocBrchJn__c');
        
        DocMstrCrtr__c docMstrCr = new DocMstrCrtr__c();
        docMstrCr.Criticality__c = 'Critical';
        docMstrCr.State__c = 'MADHYA PRADESH';
        docMstrCr.OTC__c = 1;
        docMstrCr.PDD__c = 2;
        docMstrCr.AllBT__c = true;
        docMstrCr.DocMstr__c = docMstrList[0].Id;
        TriggerBase.bypass('DocMstrCrtr__c');
        insert docMstrCr;
        TriggerBase.clearBypass('DocMstrCrtr__c');
        
        
        ApplAsset__c Asset = TestDataFactory.ApplAsset(true,loan.Id,Applicant.Id);
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'Property Documents',
            DocTyp__c = 'Property Documents - Common',
            DocSubTyp__c = 'Prop Non-Critical OTC 2'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'PAN Documents',
            DocTyp__c = 'PAN',
            DocSubTyp__c = 'PAN'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Aadhaar Consent',
            DocSubTyp__c = 'Aadhaar Consent'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Identity Proof',
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'DOB Proof',
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            DocSubTyp__c = 'Aadhar'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - Deemed OVD',
            DocSubTyp__c = 'Electricity Bill'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Signature Verification Proof',
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Registered office - Address Proof',
            DocSubTyp__c = 'Test'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Principal Place of Business - Address Proof',
            DocSubTyp__c = 'GST certificate'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Principal Place of Business - Address Proof',
            DocSubTyp__c = 'Udyam Registration Certificate'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Constitution wise Mandatory KYC documents',
            DocSubTyp__c = 'Udyam Registration Certificate'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Constitution wise Mandatory KYC documents',
            DocSubTyp__c = 'LLP Registration certificate'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Constitution wise Mandatory KYC documents',
            DocSubTyp__c = 'Trust / Society Registration Certificate'
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loan.Id,
            ApplAsset__c = Asset.Id,
            Appl__c = Applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Constitution wise Mandatory KYC documents',
            DocSubTyp__c = 'Certificate of incorporation'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        NDC__c NDC =TestDataFactory.NDCData(true,loan.Id,Applicant.Id);
        
        list<NDC__c> NDCList= new list<NDC__c>();
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Borrower Details'
        ));
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Additional Post Sanction Documents'
        ));
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Property Documents'
        ));
        TriggerBase.bypass('NDC__c');
        insert NDCList;
        TriggerBase.clearBypass('NDC__c');
        
        list<NDCConfig__c> ndcConfigList = new list<NDCConfig__c>();
        ndcConfigList.add(new NDCConfig__c(
            ProdTyp__c = 'Home Loan',
            IsActive__c = TRUE,
            SecOrdr__c = 1,
            NDCSection__c = 'Borrower Details',
            QryCnfg__c = '{\"sobjectType\": \"Applicant__c\", \"query\": \"SELECT Id, OpsVer__c, TabName__c,toLabel(ApplType__c),CustProfile__c,Constitution__c,toLabel(Gender__c),Age__c FROM Applicant__c WHERE LoanAppln__c =: loanId AND ApplType__c IN (\'G\',\'P\',\'C\') ORDER BY ApplType__c\",'+
            '  \"mappings\": ['+
            '    {'+
            '      \"targetField\": \"Applicant__c\",'+
            '      \"sourceField\": \"Id\"'+
            '    }'+
            '  ]}',
            DsplyCnfg__c = '{\"title\" : \"Borrower Details\",'+
            '\"columns\" : ['+
            '        {'+
            '            \"label\": \"Borrower Name\",'+
            '            \"fieldName\": \"TabName__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        },'+
            '   {'+
            '            \"label\": \"Borrower Type\",'+
            '            \"fieldName\": \"ApplType__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        },'+
            '   {'+
            '            \"label\": \"Customer Segment\",'+
            '            \"fieldName\": \"CustProfile__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        },'+
            '   {'+
            '            \"label\": \"Constitution\",'+
            '            \"fieldName\": \"Constitution__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        },'+
            '  {'+
            '            \"label\": \"Gender\",'+
            '            \"fieldName\": \"Gender__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        },'+
            '   {'+
            '            \"label\": \"Age\",'+
            '            \"fieldName\": \"Age__c\",'+
            '            \"type\": \"Number\",'+
            '            \"Editable\": false'+
            '        },'+
            '   {'+
            '            \"label\": \"UCID\",'+
            '            \"fieldName\": \"UCID__c\",'+
            '            \"type\": \"text\",'+
            '            \"Editable\": false'+
            '        }'+
            '       ,'+
            '       {'+
            '            \"label\": \"Ops Verification\",'+
            '            \"fieldName\": \"OpsVer__c\",'+
            '            \"type\": \"Checkbox\",'+
            '            \"Editable\": false,'+
            '            \"selectAll\" : true'+
            '        },{'+
            '\"label\": \"Query Remarks\",'+
            '\"fieldName\": \"\",'+
            '\"type\": \"Query\",'+
            '\"Editable\": false'+
            '}'+
            '    ]}'
        ));
        
        ndcConfigList.add(new NDCConfig__c(
            ProdTyp__c = 'Home Loan',
            IsActive__c = TRUE,
            SecOrdr__c = 4,
            NDCSection__c = 'IMD Details',
            QryCnfg__c = '{\"sobjectType\" : \"ApplIMD__c\",'+
            '\"query\": \"SELECT Id, OpsVer__c, IMDAmt__c,ActualAmt__c, PaymentMode__c, InstrumentNo__c, InstrumentAmt__c, Amount__c,InstrumentDt__c, CheqBounceReason__c, CheqClrDate__c, BankName__c, PaymentRefNo__c, BRECheqClrStatus__c FROM ApplIMD__c WHERE LoanAppln__c =: loanId\",'+
            '\"mappings\": ['+
            '{'+
            '\"targetField\": \"AppIMD__c\",'+
            '\"sourceField\": \"Id\"'+
            '}'+
            ']'+
            '}',
            DsplyCnfg__c = '{\"title\" : \"IMD Details\",'+
            '\"columns\" : ['+
            '{'+
            '\"label\": \"Payment Mode\",'+
            '\"fieldName\": \"PaymentMode__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Instrument Amount\",'+
            '\"fieldName\": \"Amount__c\",'+
            '\"type\": \"currency\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Instrument Number\",'+
            '\"fieldName\": \"InstrumentNo__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Instrument Date\",'+
            '\"fieldName\": \"InstrumentDt__c\",'+
            '\"type\": \"Date\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Bank Name\",'+
            '\"fieldName\": \"BankName__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Clearance Status\",'+
            '\"fieldName\": \"BRECheqClrStatus__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Bounce Reason\",'+
            '\"fieldName\": \"CheqBounceReason__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Payment ref no\",'+
            '\"fieldName\": \"PaymentRefNo__c\",'+
            '\"type\": \"text\",'+
            '\"Editable\": false'+
            '},'+
            '{'+
            '\"label\": \"Ops Verification\",'+
            '\"fieldName\": \"OpsVer__c\",'+
            '\"type\": \"Checkbox\",'+
            '\"Editable\": false,'+
            '\"selectAll\" : true'+
            '},'+
            '{'+
            '\"label\": \"Query Remarks\",'+
            '\"fieldName\": \"\",'+
            '\"type\": \"Query\",'+
            '\"Editable\": false'+
            '}'+
            ']}'
        ));
        
        
        ndcConfigList.add(new NDCConfig__c(
            ProdTyp__c = 'Home Loan',
            IsActive__c = TRUE,
            SecOrdr__c = 2,
            NDCSection__c = 'Property Documents',
            QryCnfg__c = '{\"sobjectType\": \"DocDtl__c\", \"query\": \"SELECT Id, OpsVer__c, ApplAsset__c, ApplAsset__r.Id, ApplAsset__r.PropAddrs__c, DocTyp__c, DocSubTyp__c,OriDoc__c, Rmrk__c, Criticality__c, DocStatus__c, ReceivedDt__c, TargetDt__c, DevLvl__c, AppvdRmrks__c FROM DocDtl__c WHERE DocCatgry__c  = \'Property Documents\' AND LAN__c =:loanId\",'+
            ' \"mappings\": ['+
            '    {'+
            '      \"targetField\": \"ApplAsset__c\",'+
            '      \"sourceField\": \"ApplAsset__c\"'+
            '    },'+
            '   {'+
            '      \"targetField\": \"DocDtl__c\",'+
            '      \"sourceField\": \"Id\"'+
            '    }'+
            '  ]}',
            DsplyCnfg__c = '{'+
            '  \"title\": \"Property\",'+
            '  \"groupBy\": \"ApplAsset__c\",'+
            '  \"allowUpload\": true,'+
            '  \"allowDelete\" : true,'+
            '  \"docCategory\": \"Property Documents\",'+
            '  \"columns\": ['+
            '    {'+
            '      \"label\": \"Document Type\",'+
            '      \"fieldName\": \"DocTyp__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Name\",'+
            '      \"fieldName\": \"DocSubTyp__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Description\",'+
            '      \"fieldName\": \"Rmrk__c\",'+
            '      \"type\": \"textarea\",'+
            '      \"Editable\": true'+
            '    },'+
            '    {'+
            '      \"label\": \"View Document\",'+
            '      \"fieldName\": \"Id\",'+
            '      \"type\": \"preview\",'+
            '      \"Editable\": false,'+
            '      \"allowUpload\" : true'+
            '    },'+
            '    {'+
            '      \"label\": \"Criticality\",'+
            '      \"fieldName\": \"Criticality__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false,'+
            '      \"options\": ['+
            '        \"Critical\",'+
            '        \"Non-critical\"'+
            '      ]'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Status\",'+
            '      \"fieldName\": \"DocStatus__c\",'+
            '      \"type\": \"Picklist\",'+
            '      \"Editable\": true,'+
            ' \"options\": ['+
            '        \"Completed\",'+
            '        \"OTC\",'+
            '        \"PDD\",'+
            '		\"Received\",'+
            '        \"Waiver\" '+
            '      ],'+
            '\"Required\" : true'+
            '    },'+
            '{'+
            '      \"label\": \"Original Document?\",'+
            '      \"fieldName\": \"OriDoc__c\",'+
            '      \"type\": \"Picklist\",'+
            '      \"Editable\": true,'+
            '      \"options\": ['+
            '        \"Certified  \",'+
            '        \"Copy \",'+
            '        \"Original\"'+
            '      ]'+
            '    },'+
            '    {'+
            '      \"label\": \"Received Date\",'+
            '      \"fieldName\": \"ReceivedDt__c\",'+
            '      \"type\": \"Date\",'+
            '      \"Editable\": true,'+
            '    \"width\" :  \"100px\"'+
            '    },'+
            '    {'+
            '      \"label\": \"Target Date\",'+
            '      \"fieldName\": \"TargetDt__c\",'+
            '      \"type\": \"Date\",'+
            '      \"Editable\": true,'+
            '    \"width\" :  \"100px\"'+
            '    },'+
            '    {'+
            '      \"label\": \"Deviation Level\",'+
            '      \"fieldName\": \"DevLvl__c\",'+
            '      \"type\": \"text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Approval Remarks\",'+
            '      \"fieldName\": \"AppvdRmrks__c\",'+
            '      \"type\": \"text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Ops Verification\",'+
            '      \"fieldName\": \"OpsVer__c\",'+
            '      \"type\": \"Checkbox\",'+
            '      \"Editable\": false,'+
            '\"selectAll\" : true'+
            '    },'+
            '    {'+
            '      \"label\": \"Query Remarks\",'+
            '      \"fieldName\": \"\",'+
            '      \"type\": \"Query\",'+
            '      \"Editable\": false'+
            '    }'+
            '  ]'+
            '}'
        ));
        
        ndcConfigList.add(new NDCConfig__c(
            ProdTyp__c = 'Home Loan',
            IsActive__c = TRUE,
            SecOrdr__c = 3,
            NDCSection__c = 'Additional Post Sanction Documents',
            QryCnfg__c = '{\"sobjectType\": \"DocDtl__c\", \"query\": \"SELECT Id, OpsVer__c, ApplAsset__c, ApplAsset__r.Id, ApplAsset__r.PropAddrs__c, DocTyp__c, DocSubTyp__c, Rmrk__c, Criticality__c, DocStatus__c, ReceivedDt__c, TargetDt__c, DevLvl__c, AppvdRmrks__c FROM DocDtl__c WHERE LAN__c =: loanId AND DocCatgry__c =\'Additional Post Sanction Documents\'\",'+
            '\"mappings\": ['+
            '   {'+
            '      \"targetField\": \"DocDtl__c\",'+
            '      \"sourceField\": \"Id\"'+
            '    }'+
            '  ]'+
            '}',
            DsplyCnfg__c = '{'+
            '  \"title\": \"Additional Post Sanction Documents\",'+
            '  \"allowUpload\": true,'+
            '\"allowDelete\" : true,'+
            '  \"docCategory\": \"Additional Post Sanction Documents\",'+
            '  \"columns\": ['+
            '    {'+
            '      \"label\": \"Document Type\",'+
            '      \"fieldName\": \"DocTyp__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Name\",'+
            '      \"fieldName\": \"DocSubTyp__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Description\",'+
            '      \"fieldName\": \"Rmrk__c\",'+
            '      \"type\": \"textarea\",'+
            '      \"Editable\": true'+
            '    },'+
            '    {'+
            '      \"label\": \"View Document\",'+
            '      \"fieldName\": \"Id\",'+
            '      \"type\": \"preview\",'+
            '      \"Editable\": false,'+
            '    \"allowUpload\" : true'+
            '    },'+
            '    {'+
            '      \"label\": \"Criticality\",'+
            '      \"fieldName\": \"Criticality__c\",'+
            '      \"type\": \"Text\",'+
            '      \"Editable\": false,'+
            '      \"options\": ['+
            '        \"Critical\",'+
            '        \"Non-critical\"'+
            '      ]'+
            '    },'+
            '    {'+
            '      \"label\": \"Document Status\",'+
            '      \"fieldName\": \"DocStatus__c\",'+
            '      \"type\": \"Picklist\",'+
            '      \"Editable\": true,'+
            '     \"options\": ['+
            '        \"Completed\",'+
            '        \"OTC\",'+
            '        \"PDD\",'+
            '        \"Received\",'+
            '        \"Waiver\" '+
            '      ],'+
            '     \"Required\" : true'+
            '    },'+
            '    {'+
            '      \"label\": \"Received Date\",'+
            '      \"fieldName\": \"ReceivedDt__c\",'+
            '      \"type\": \"Date\",'+
            '      \"Editable\": true,'+
            '     \"width\" :  \"100px\"'+
            '    },'+
            '    {'+
            '      \"label\": \"Target Date\",'+
            '      \"fieldName\": \"TargetDt__c\",'+
            '      \"type\": \"Date\",'+
            '      \"Editable\": true,'+
            '      \"width\" :  \"100px\"'+
            '    },'+
            '    {'+
            '      \"label\": \"Deviation Level\",'+
            '      \"fieldName\": \"DevLvl__c\",'+
            '      \"type\": \"text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Approval Remarks\",'+
            '      \"fieldName\": \"AppvdRmrks__c\",'+
            '      \"type\": \"text\",'+
            '      \"Editable\": false'+
            '    },'+
            '    {'+
            '      \"label\": \"Ops Verification\",'+
            '      \"fieldName\": \"OpsVer__c\",'+
            '      \"type\": \"Checkbox\",'+
            '      \"Editable\": false,'+
            '\"selectAll\" : true'+
            '    },'+
            '    {'+
            '      \"label\": \"Query Remarks\",'+
            '      \"fieldName\": \"\",'+
            '      \"type\": \"Query\",'+
            '      \"Editable\": false'+
            '    }'+
            '  ]'+
            '}'
        ));
        TriggerBase.bypass('NDCConfig__c');
        insert ndcConfigList;
        TriggerBase.clearBypass('NDCConfig__c');
    }
    
    @isTest
    static void ndcControllerTestMethod() { 
        LoanAppl__c loan = [SELECT Id, Stage__c, Product__c, BrchCode__c
                            FROM LoanAppl__c
                            LIMIT 1];
        Applicant__c Applicant = [SELECT Id
                                  FROM Applicant__c
                                  LIMIT 1];
        ApplAsset__c Asset = [SELECT Id,Appl__c,LoanAppln__c
                              FROM ApplAsset__c
                              LIMIT 1];
        List<NDC__c> NDCList = [SELECT Id,NDC_Section__c,OpsQuery__c,IsInvalid__c,LoanAppl__c,Applicant__c,ApplAsset__c
                                FROM NDC__c
                               ];
        
        List<DocDtl__c> docDtlList = [SELECT Id, OpsVer__c, ApplAsset__c, ApplAsset__r.Id, 
                                      DocTyp__c, DocSubTyp__c,OriDoc__c, Rmrk__c, Criticality__c, DocStatus__c, 
                                      ReceivedDt__c, TargetDt__c, DevLvl__c, AppvdRmrks__c FROM DocDtl__c ];
        
        Test.startTest();
        //NdcController.generateNdcRecord(loan.Id,'');
        NdcController.getNdcRequiredDoc('Mandatory Post Sanction Documents');
        NdcController.createNDCRecord(Asset,'ApplAsset__c','Borrower Details',NDCList);
        
        Test.stopTest();
        
        try{
            DocDtl__c docDtl = NdcController.createDocDetailwithApplicantAsset(Applicant.Id,loan.Id,'Additional Post Sanction Documents','Disbursal Documents','OTC declaration',Asset.Id,false);
            system.debug('docDtl is '+ docDtl);
            system.assertEquals(null, docDtl.OTC__c);
            NdcController.createDocDetailwithApplicantAsset(null,null,null,null,null,null,null);
        }catch(QueryException ex){
            system.assertEquals('List has no rows for assignment to SObject', ex.getMessage());
        }  
        
        try{
            List<NdcController.NdcDataWrapr> returnVal = NdcController.retrieveNdcData(loan.Id,'Scan Based Disbursement');
            system.debug('returnVal ' + returnVal.size());
            system.assertEquals(4, returnVal.size());
            NdcController.retrieveNdcData(null,null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        List<NdcController.NdcDataWraprForSave> ndcDatForSaveList = new List<NdcController.NdcDataWraprForSave>(); 
        NdcController.NdcDataWraprForSave ndcDataForSave = new NdcController.NdcDataWraprForSave();
        ndcDataForSave.ndcId = 'a1TC40000006BQcMAM';
        // Assuming YourSObjectType is the name of your SObject type
        DocDtl__c sObjectRecord = (DocDtl__c)DocDtl__c.SObjectType.newSObject();
        
        NdcController.getDataEntry(loan.Id);
        // Set field values
        sObjectRecord.Id = docDtlList[0].Id;
        sObjectRecord.DocStatus__c = 'Completed';
        ndcDataForSave.record = sObjectRecord;
        ndcDatForSaveList.add(ndcDataForSave);
        
        
        DocDispatch__c dispatchData = new  DocDispatch__c();
        dispatchData.CPARemarks__c = 'Added';
        dispatchData.LoanAppln__c = loan.Id;
        List<DocDispatch__c> docDisList = new List<DocDispatch__c>();
        docDisList.add(dispatchData);
        List<String> ndcIdsToDelete = new List<String> ();
        ndcIdsToDelete.add(NDCList[0].Id);
        List<SObject> recordsToDelete = new List<SObject> ();
        recordsToDelete.add(docDtlList[0]);
        try{
            NdcController.saveNdcData(loan.Id,'Scan Based Disbursement',ndcDatForSaveList,recordsToDelete,ndcIdsToDelete,docDisList);
            NdcController.saveNdcData(null,null,null,null,null,null);          
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
    }
    @isTest
    static void ndcControllerTestMethodd() { 
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        //loan.Product__c ='    Home Loan';
        Applicant__c Applicant = TestDataFactory.createSingleApplicant(true,loan.id);
        
        Repayment_Account__c reparAcc = new Repayment_Account__c();
        reparAcc.Loan_Application__c = loan.Id;
        reparAcc.Is_Active__c = true;
        reparAcc.Repayment_Mode__c = 'PDC';
        TriggerBase.bypass('Repayment_Account__c');
        insert reparAcc;
        TriggerBase.clearBypass('Repayment_Account__c');
        
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'Repayment Documents SPDCs',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Repayment Documents',
            DocSubTyp__c = 'Repayment Documents PDCs',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Repayment Documents',
            DocSubTyp__c = 'Repayment Documents NACH',
            Active__c = TRUE
        ));
        TriggerBase.bypass('DocMstr__c');
        insert docMstrList;
        TriggerBase.clearBypass('DocMstr__c');
        
        BankBrchMstr__c bankBraMstr = new BankBrchMstr__c();
        bankBraMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBraMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');
        
        LocMstr__c locMstr = new LocMstr__c();
        locMstr.State__c = 'MADHYA PRADESH';
        TriggerBase.bypass('LocMstr__c');
        insert locMstr;
        TriggerBase.clearBypass('LocMstr__c');
        
        LocBrchJn__c locsBrJun = new LocBrchJn__c();
        locsBrJun.Branch__c = bankBraMstr.Id;
        locsBrJun.Location__c = locMstr.Id; 
        TriggerBase.bypass('LocBrchJn__c');
        insert locsBrJun;
        TriggerBase.clearBypass('LocBrchJn__c');
        
        DocMstrCrtr__c docMstrCr = new DocMstrCrtr__c();
        docMstrCr.Criticality__c = 'Critical';
        docMstrCr.State__c = 'MADHYA PRADESH';
        docMstrCr.OTC__c = 1;
        docMstrCr.PDD__c = 2;
        docMstrCr.AllBT__c = true;
        docMstrCr.DocMstr__c = docMstrList[0].Id;
        TriggerBase.bypass('DocMstrCrtr__c');
        insert docMstrCr;
        TriggerBase.clearBypass('DocMstrCrtr__c');
        
        
        ApplAsset__c Asset = TestDataFactory.ApplAsset(true,loan.Id,Applicant.Id);
        
        NDC__c NDC =TestDataFactory.NDCData(true,loan.Id,Applicant.Id);
        
        list<NDC__c> NDCList= new list<NDC__c>();
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Borrower Details'
        ));
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Additional Post Sanction Documents'
        ));
        NDCList.add(new NDC__c(
            Applicant__c = Applicant.Id,
            LoanAppl__c = loan.Id,
            IsInvalid__c = false,
            OpsQuery__c = false,
            NDC_Section__c = 'Property Documents'
        ));
        TriggerBase.bypass('NDC__c');
        insert NDCList;
        TriggerBase.clearBypass('NDC__c');  
        //NdcController.retrieveNdcData(loan.Id); 
        Boolean isAssert = true;
        try{
            NdcController.createMandatoryDocs(loan);         
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    @isTest
    static void generateNdcRecForScrnsTest(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
       	Test.startTest();
        NdcController.generateNdcRecForScrns(loan.Id);
        Test.stopTest();
    }
}