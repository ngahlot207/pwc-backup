public without sharing class PDController {
    @AuraEnabled
    public static PD__c initiatePD(PDReqestWrapper req) {
        try {
            Map<String, Sobject> dataMap = new Map<String, Sobject>();
            LoanAppl__c loanApp = [
                SELECT
                Id,
                Product__c,
                ReqLoanAmt__c,
                AssessedIncAppln__c,
                AssesIncomeAppl__c
                FROM LoanAppl__c
                WHERE Id = :req.loanAppId
            ];
            list<user> userList = new list<user>();
            if(req.vendorAccId != null){
                userList = [SELECT Id,  Name,  ContactId, AccountId FROM User  WHERE AccountId =: req.vendorAccId];
            }
            string productType = loanApp.Product__c;
            dataMap.put('LoanAppl__c', loanApp);
            Applicant__c applicant = [
                SELECT
                Id,
                CustProfile__c,
                Constitution__c,
                TabName__c,
                MobNumber__c,
                ApplType__c,
                Relationship__c,
                LatestyearforwhichITRisavailable__c,
                (SELECT Id, AddrTyp__c FROM Applicant_Addresses__r)
                FROM Applicant__c
                WHERE Id = :req.applicantId
            ];
            dataMap.put('Applicant__c', applicant);
            List<ApplicantEmployment__c> employmentList = [
                SELECT
                Id,
                EmployerName__c,
                LoanApplicant__r.LatestyearforwhichITRisavailable__c,
                EmployerName__r.Name,
                Others__c,
                EntityName__c,
                DesignationText__c,
                DesignationValues__c,
                toLabel(NatureOfBusinessCorporate__c),
                toLabel(NatureOfBusinessIndividual__c),
                WorkingWithCurrentEmployer_Months__c,
                WorkingWithCurrentEmployer_Years__c
                FROM ApplicantEmployment__c
                WHERE LoanApplicant__c = :req.applicantId
                LIMIT 1
            ];
            if (employmentList.size() > 0) {
                dataMap.put('ApplicantEmployment__c', employmentList[0]);
            }
            // List<UWriter__c> uwList = [
            //     SELECT Id
            //     FROM UWriter__c
            //     WHERE LoanAplcn__c = :req.loanAppId
            // ];
            
            List<PDQues__c> pdQuesList = [
                SELECT
                CustProf__c,
                DefValCri__c,
                DispSeq__c,
                FileConfig__c,
                FiltrCri__c,
                Id,
                IsReqMob__c,
                IsReqWeb__c,
                Is_Active__c,
                Name,
                PDTyp__c,
                PossResp__c,
                ProdTyp__c,
                QuesApiName__c,
                QuesTtl__c,
                RespTyp__c,
                SecSeq__c,
                SecTtl__c,
                VldFrm__c,
                VldTill__c
                FROM PDQues__c
                WHERE
                Is_Active__c = TRUE
                AND CustProf__c INCLUDES (:applicant.CustProfile__c)
                AND PDTyp__c INCLUDES (:req.pdMode)
                AND ProdTyp__c INCLUDES (:loanApp.Product__c)
            ];
            DocMstr__c docMstr = new DocMstr__c();
            docMstr = [
                SELECT Id, Prod__c, Catgry__c, DocTyp__c, DocSubTyp__c
                FROM DocMstr__c
                WHERE
                Prod__c = :loanApp.Product__c
                AND Catgry__c = 'Personal Discussion'
                AND DocTyp__c = 'PD Photographs'
                AND Active__c = TRUE
                LIMIT 1
            ];
            system.debug('pdQuesList '+pdQuesList);
            PD__c intiatePd = new PD__c();
            intiatePd.LoanAppl__c = req.loanAppId;
            intiatePd.Appl__c = req.applicantId;
            // if (uwList.size() > 0) {
                //     intiatePd.Underwriter__c = uwList[0].Id;
            // }
            boolean createCaseForAgency = false;
            if((productType == 'Business Loan' || productType == 'Personal Loan') && req.isDoneByVendor == true){
                intiatePd.PD_Vendor_Acc__c = req.assigndTo;
                if(userList.size()>0){
                    intiatePd.OwnerId = userList[0].Id;
                    intiatePd.AsgnTo__c = userList[0].Id;
                    intiatePd.PD_Vendor_Contact__c = userList[0].ContactId;
                    intiatePd.PD_Done_By_Agency__c = req.isDoneByVendor;
                    createCaseForAgency = true;
                }
                
            }else{
                intiatePd.AsgnTo__c = req.assigndTo;
                intiatePd.OwnerId = req.assigndTo;
            }
            
            intiatePd.PdTyp__c = req.pdMode;
            intiatePd.ProdTyp__c = loanApp.Product__c;
            intiatePd.SchDate__c = req.schdDate;
            intiatePd.CreatedBy__c = UserInfo.getUserId();
            intiatePd.PDStatus__c = 'Initiated';
            insert intiatePd;
            if(req.pdMode == 'Video PD'){
                IntgMsg__c intMsz = new IntgMsg__c();
                
                intMsz.Name='Guest Call';
                intMsz.BU__c='HL / STL';
                intMsz.RefId__c=intiatePd.Id;
                intMsz.Status__c='New';
                intMsz.MStatus__c='Blank';
                intMsz.RefObj__c='PD__c';
                intMsz.Svc__c='Guest Call';
                intMsz.ParentRefId__c = intiatePd.Appl__c;
                intMsz.ParentRefObj__c ='Applicant__c';
                intMsz.IsActive__c=true;
                insert intMsz;
            }
            
            if(createCaseForAgency == true){
                try {
                    
                    
                    Case newCase = new Case();
                    newCase.Loan_Application__c = intiatePd.LoanAppl__c;
                    newCase.Assigned_To__c =intiatePd.OwnerId;
                    newCase.ownerId = intiatePd.OwnerId;
                    newCase.Personal_Discussion__c =  intiatePd.Id;
                    newCase.ContactId =  intiatePd.PD_Vendor_Contact__c;
                    newCase.AccountId =  intiatePd.PD_Vendor_Acc__c;
                    newCase.RecordTypeId =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('PD').getRecordTypeId();
                    
                    system.debug('newCase' + newCase);
                    insert newCase;
                    
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            
            Map<String, DocDtl__c> docDtlList = new Map<String, DocDtl__c>();
            for (PDQues__c pdQ : pdQuesList) {
                if (
                    pdQ.RespTyp__c != null &&
                    pdQ.QuesTtl__c != null &&
                    (pdQ.RespTyp__c == 'File' ||
                    pdQ.RespTyp__c == 'Video')
                ) {
                    Boolean createDD = true;
                    if (pdQ.FileConfig__c != null) {
                        Map<String, Object> fileConfig = (Map<String, Object>) JSON.deserializeUntyped(
                            pdQ.FileConfig__c
                            );
                        if (
                            fileConfig.get('AllowUpload') != null &&
                            (Boolean) fileConfig.get('AllowUpload') == false
                        ) {
                            createDD = false;
                        }
                    }
                    if (createDD) {
                        system.debug('In  pdQ.RespTyp__c == File ' + pdQ);
                        DocDtl__c dd = new DocDtl__c();
                        dd.Appl__c = req.applicantId;
                        dd.DocMstr__c = docMstr.Id;
                        dd.DocCatgry__c = 'Personal Discussion';
                        dd.DocSubTyp__c = pdQ.QuesTtl__c;
                        dd.DocTyp__c = 'PD Photographs';
                        dd.LAN__c = req.loanAppId;
                        dd.PrsnlDis__c = intiatePd.Id;
                        docDtlList.put(pdQ.QuesTtl__c, dd);
                    }
                }
            }
            system.debug('docList ' + docDtlList.Values());
            if (docDtlList.size() > 0) {
                insert docDtlList.Values();
            }
            
            Operations opObj = Operations.getInstance();
            opObj.registerOperation(OperationFactory.getInstance('&&'));
            opObj.registerOperation(OperationFactory.getInstance('=='));
            opObj.registerOperation(OperationFactory.getInstance('!='));
            opObj.registerOperation(OperationFactory.getInstance('||'));
            opObj.registerOperation(OperationFactory.getInstance('('));
            opObj.registerOperation(OperationFactory.getInstance(')'));
            opObj.registerOperation(OperationFactory.getInstance('<'));
            opObj.registerOperation(OperationFactory.getInstance('<='));
            opObj.registerOperation(OperationFactory.getInstance('>'));
            opObj.registerOperation(OperationFactory.getInstance('>='));
            List<PDResp__c> pdResponseList = new List<PDResp__c>();
            for (PDQues__c pdQues : pdQuesList) {
                FilterCriteria filtrCri = pdQues.FiltrCri__c != null
                    ? (FilterCriteria) JSON.deserialize(
                    pdQues.FiltrCri__c,
                FilterCriteria.class
                    )
                    : null;
                Boolean isApplicable = true;
                if (filtrCri != null) {
                    system.debug('filtrCri.criteria '+ filtrCri.criteria);
                    Rule r = new Rule().setExpression(filtrCri.criteria);
                    SObject record = dataMap.get(filtrCri.objectName);
                    Map<string, string> bindings = new Map<string, string>();
                    if (record != null) {
                        for (string fl : filtrCri.fields) {
                            List<String> splitVal = fl.trim().split('\\.');
                            System.debug('splitVal==' + splitVal);
                            System.debug('size==' + splitVal.size());
                            String value = '';
                            if (splitVal.size() == 1) {
                                value = record.get(splitVal[0]) != null
                                    ? (String) record.get(splitVal[0])
                                    : 'blank';
                            } else if (splitVal.size() == 2) {
                                value = record.getSobject(splitVal[0])
                                    .get(splitVal[1]) != null
                                    ? (String) record.getSobject(splitVal[0])
                                    .get(splitVal[1])
                                    : 'blank';
                            }
                            value = value.replaceAll('\\s+', '');
                            value = value.replaceAll('\\(', '');
                            value = value.replaceAll('\\)', '');
                            value = value.replaceAll('\\-', '');
                            bindings.put(fl.trim().toLowerCase(), value);
                        }
                        isApplicable = r.eval(bindings);
                    } else {
                        isApplicable = false;
                    }
                }
                if (isApplicable) {
                    PDResp__c pdResp = new PDResp__c();
                    pdResp.PDQues__c = pdQues.Id;
                    pdResp.PrsnlDisc__c = intiatePd.Id;
                    pdResp.Ques__c = pdQues.QuesTtl__c;
                    
                    if (pdQues.RespTyp__c == 'Reference') {
                        Ref__c ref = new Ref__c();
                        ref.PrsnlDis__c = intiatePd.Id;
                        ref.Applicant__c = req.applicantId;
                        ref.Loan_Application__c = req.loanAppId;
                        insert ref;
                        pdResp.Resp__c = ref.Id;
                    }
                    if (
                        pdQues.RespTyp__c != null &&
                        pdQues.QuesTtl__c != null &&
                        (pdQues.RespTyp__c == 'File' ||
                        pdQues.RespTyp__c == 'Video')
                    ) {
                        pdResp.DocDtl__c = docDtlList.get(pdQues.QuesTtl__c) !=
                            null
                            ? docDtlList.get(pdQues.QuesTtl__c).Id
                            : null;
                    }
                    pdResponseList.add(pdResp);
                }
            }
            insert pdResponseList;
            return intiatePd;
        } catch (exception e) {
            system.debug(
                'error occured ' +
                e.getMessage() +
                'get line number ' +
                e.getLineNumber() +
                ' get stack trace ' +
                e.getStackTraceString()
                );
            throw new AuraHandledException(
                e.getMessage() +
                'get line number ' +
                e.getLineNumber() +
                ' get stack trace ' +
                e.getStackTraceString()
                );
        }
    }
    
    @AuraEnabled
    public static List<PDResponseWrapper> retrievePD(Id pdId) {
        try {
            system.debug('pdId   ' + pdId);
            PD__c pd = [
                SELECT
                Id,
                PdTyp__c,
                SchDate__c,
                ProdTyp__c,
                AsgnTo__c,
                Appl__c,
                CreatedBy__c,
                CmpltBy__c,
                format(CmpltDt__c),
                EmpIdConductedBy__c,
                LoanAppl__c,
                LoanAppl__r.Status__c,
                Result__c,
                PDRmrks__c,
                IsCompleted__c,
                WorkAppRedirectionUrl__c
                FROM PD__c
                WHERE Id = :pdId AND PDStatus__c != 'Withdrawn'
            ];
            
            Boolean pdNonEditabel =
                pd.IsCompleted__c ||
                pd.LoanAppl__r.Status__c == 'Hold' ||
                pd.LoanAppl__r.Status__c == 'Cancelled' ||
                pd.LoanAppl__r.Status__c == 'Rejected';
            
            List<PDResp__c> pdRespList = [
                SELECT
                Id,
                PrsnlDisc__c,
                PrsnlDisc__r.CmpltDt__c,
                PrsnlDisc__r.CmpltBy__c,
                Resp__c,
                DocDtl__c,
                PDQues__r.DispSeq__c,
                PDQues__r.FiltrCri__c,
                PDQues__r.Id,
                PDQues__r.IsReqMob__c,
                PDQues__r.IsReqWeb__c,
                PDQues__r.VisibleWeb__c,
                PDQues__r.VisibleMob__c,
                PDQues__r.Is_Active__c,
                PDQues__r.PossResp__c,
                PDQues__r.QuesApiName__c,
                PDQues__r.QuesTtl__c,
                PDQues__r.RespTyp__c,
                PDQues__r.IsEditable__c,
                PDQues__r.SecSeq__c,
                PDQues__r.SecTtl__c,
                PDQues__r.QuesConf__c,
                PDQues__r.FileConfig__c,
                PDQues__r.DefValCri__c,
                PDQues__r.OverrideConfig__c,
                PDQues__r.EnableOverride__c,
                PDQues__r.ValConfig__c,
                PDQues__r.MobValCnfg__c
                FROM PDResp__c
                WHERE PrsnlDisc__c = :pdId AND PDQues__r.Is_Active__c = TRUE
                ORDER BY PDQues__r.SecSeq__c, PDQues__r.DispSeq__c
            ];
            
            Set<Id> pdQuesIds = new Set<Id>();
            for (PDResp__c resp : pdRespList) {
                pdQuesIds.add(resp.PDQues__r.Id);
            }
            List<TeamHierarchy__c> thList = new List<TeamHierarchy__c>();
            thList = [
                SELECT
                Id,
                IsActive__c,
                Employee__c,
                Employee__r.name,
                Employee__r.EmployeeNumber,
                EmpLevel__c,
                EmpRole__c,
                EmpLoc__c,
                EmpBrch__c
                FROM TeamHierarchy__c
                WHERE Employee__c = :pd.AsgnTo__c
               
            ];
            List<Applicant_Income__c> caseflowIncomes = [
                SELECT
                Id,
                Normal_Days_sales_Receipts_Daily__c,
                Normal_Days_sales_Days_Working__c,
                Peak_Days_sales_Receipts_Daily__c,
                Peak_Days_sales_Receipts_Days_Working__c,
                OtherRevenueMonthly__c,
                ServicesRevenueMonthly__c,
                Monthly_Purchases_Cost_Of_Materials__c,
                Total_Expense_of_operations_Or_Business__c,
                ReceiptsPerDayDaily__c
                FROM Applicant_Income__c
                WHERE
                RecordType.DeveloperName = 'Cashflow_Map'
                AND Applicant__c = :pd.Appl__c
            ];
            
            List<DocDtl__c> bureauReports = [
                SELECT Id, DocTyp__c
                FROM DocDtl__c
                WHERE
                DocCatgry__c = 'Bureau Report'
                AND LAN__c = :pd.LoanAppl__c
                AND Appl__c = :pd.Appl__c
                ORDER BY CreatedDate DESC
            ];
            
            Map<String, Sobject> dataMap = new Map<String, Sobject>();
            
            dataMap.put('PD__c', pd);
            if (thList.size() > 0 ) {
                dataMap.put('TeamHierarchy__c', thList[0]);
            }
            //  dataMap.put('TeamHierarchy__c', th);
            if (bureauReports.size() > 0) {
                dataMap.put('DocDtl__c', bureauReports[0]);
            }
            if (caseflowIncomes.size() > 0) {
                dataMap.put('Applicant_Income__c', caseflowIncomes[0]);
            }
            LoanAppl__c loanApp = [
                SELECT Id, Product__c, ReqLoanAmt__c
                FROM LoanAppl__c
                WHERE Id = :pd.LoanAppl__c
            ];
            dataMap.put('LoanAppl__c', loanApp);
            Applicant__c applicant = [
                SELECT
                Id,
                CustProfile__c,
                Constitution__c,
                TabName__c,
                MobNumber__c,
                ApplType__c,
                CompanyName__c,
                Relationship__c,
                EmailId__c,
                CIN__c,
                LLPIN__c,
                DOI__c,
                Politically_Exposed_Person__c,
                (
                    SELECT Id, AddrTyp__c, toLabel(OwnType__c)
                    FROM Applicant_Addresses__r
                )
                FROM Applicant__c
                WHERE Id = :pd.Appl__c
            ];
            dataMap.put('Applicant__c', applicant);
            List<ApplicantEmployment__c> employmentList = [
                SELECT
                Id,
                EntityName__c,
                EmployerName__c,
                Others__c,
                EmployerName__r.Name,
                DesignationText__c,
                DesignationValues__c,
                WorkingWithCurrentEmployer_Months__c,
                WorkingWithCurrentEmployer_Years__c,
                CurrentBusinessVintage_Years__c,
                CurrentBusinessVintage_Months__c,
                TotalWorkExperience_Years__c,
                TotalWorkExperience_Months__c,
                MSME_Industry_selection__c,
                Is_URC_UAC_available__c,
                GST_Registered__c,
                GSTIN__c,
                RetirementAge__c,
                OfficialEmail__c,
                IndustryType__r.Name,
                SubIndustry__r.Name,
                toLabel(TypeOfOrganisation__c),
                toLabel(NatureOfBusinessCorporate__c),
                toLabel(NatureOfBusinessIndividual__c)
                FROM ApplicantEmployment__c
                WHERE LoanApplicant__c = :pd.Appl__c
                LIMIT 1
            ];
            if (employmentList.size() > 0) {
                dataMap.put('ApplicantEmployment__c', employmentList[0]);
            }
            //
            List<ApplGST__c> applGstList = [
                SELECT Id,
                Applicant__c,
                ApplAsset__c, 
                GSTIN__c
                FROM ApplGST__c WHERE Applicant__c  = :pd.Appl__c  order by Main_GSTIN__c desc 
                
                
            ];
            if (applGstList.size() > 0) {
                system.debug('In applGstList');
                dataMap.put('ApplGST__c', applGstList[0]);
            }
            //
            
            Map<String, List<SObject>> optionMap = new Map<String, List<SObject>>();
            List<Industry__c> industory = [SELECT Id, Name FROM Industry__c];
            optionMap.put('Industry__c', industory);
            List<SubIndustry__c> subIndustory = [
                SELECT Id, Name, Industry__r.Name
                FROM SubIndustry__c
            ];
            optionMap.put('SubIndustry__c', subIndustory);
            List<LoanPurpose__c> loanPurposeList = [
                SELECT Id, Name
                FROM LoanPurpose__c
                WHERE ProdType__c INCLUDES (:pd.ProdTyp__c)
            ];
            optionMap.put('LoanPurpose__c', loanPurposeList);
            
            List<ApplAddr__c> addressList = [
                SELECT Id, AddrTyp__c, FullAdrs__c, toLabel(OwnType__c)
                FROM ApplAddr__c
                WHERE Applicant__c = :pd.Appl__c
            ];
            optionMap.put('ApplAddr__c', addressList);
            System.debug('optionMap==' + optionMap.keySet());
            
            Map<String, List<SObject>> tableDataMap = new Map<String, List<SObject>>();
            List<BureauRespDtl__c> extBureau = new List<BureauRespDtl__c>();
            List<BureauRespDtl__c> pdBureau = new List<BureauRespDtl__c>();
            List<String> consumerProduct = new List<String>{
                'Auto Loan',
                'Housing Loan',
                'Property Loan',
                'Loan Against Shares/Securities',
                'Personal Loan',
                'Consumer Loan',
                'Education Loan',
                'Loan to Professional',
                'Leasing',
                'Overdraft',
                'Two-wheeler Loan',
                'Loan Against Bank Deposits',
                'Commercial Vehicle Loan',
                'GECL Loan Secured',
                'GECL Loan Unsecured',
                'Used Car Loan',
                'Construction Equipment Loan',
                'Tractor Loan',
                'Loan on Credit Card',
                'Mudra Loans – Shishu / Kishor / Tarun',
                'Microfinance – Business Loan',
                'Microfinance – Personal Loan',
                'Microfinance – Housing Loan',
                'Microfinance – Other',
                'P2P Personal Loan',
                'P2P Auto Loan',
                'P2P Education Loan',
                'Business Loan – Secured',
                'Business Loan – General',
                'Business Loan – Priority Sector – Small Business',
                'Business Loan – Priority Sector – Agriculture',
                'Business Loan – Priority Sector – Others',
                'Business Loan - Unsecured',
                'Other'
            };
            List<String> commercialProduct = new List<String>{
                'Cash credit',
                'Overdraft',
                'Demand loan',
                'Medium term loan (period above 1 year and up to 3 years)',
                'Long term loan (period above 3 years)',
                'Lease finance',
                'Hire purchase',
                'Commercial vehicle loan',
                'Equipment financing (construction office medical)',
                'Unsecured business loan',
                'Short term loan (less than 1 year)',
                'Auto Loan',
                'Property Loan',
                'Gold Loan',
                'HealthCare Finance',
                'Infrastructure Finance',
                'GECL Loan',
                'Others'
            };
            
            Date minCloseDate = Date.today().addYears(-1);
            for (BureauRespDtl__c brd : [
                SELECT
                Id,
                NatureOfLoan__c,
                LoanAmount__c,
                EMI__c,
                Treatment__c,
                Applicant__c,
                Bureau__c,
                Source__c,
                PrsnlDis__c,
                IsLatest__c,
                CrdFacType__c,
                CloseDate__c,
                Remarks__c,
                RecordType.name
                FROM BureauRespDtl__c
                WHERE
                Applicant__c = :pd.Appl__c
                AND (CloseDate__c = NULL
                     OR CloseDate__c >= :minCloseDate) // Bureau__c
            ]) {
                if (
                    brd.Source__c != 'Manual' &&
                    ((brd.RecordType.name == 'Consumer Obligation' &&
                    consumerProduct.contains(brd.NatureOfLoan__c)) ||
                    (brd.RecordType.name == 'Commercial Obligation' &&
                    commercialProduct.contains(brd.NatureOfLoan__c) &&
                    brd.CrdFacType__c == 'Current'))
                ) {
                    extBureau.add(brd);
                } else if (
                brd.PrsnlDis__c == pdId ||
                    brd.Source__c == 'Manual'
                ) {
                    pdBureau.add(brd);
                }
            }
            
            List<LoanApplRelationship__c> applRelation =[
                SELECT   
                 Id,
                  Loan_Applicant__c,
                    Relationship_Type__c,  
                       Related_To_applicant__c, 
                       Personal_Discussion__c,
                        Mobile_No__c, Occupation__c,
                         Name_of_family_member__c   
                           FROM LoanApplRelationship__c
                             WHERE Relationship_Type__c ='Relationship in PD' 
                             AND  Personal_Discussion__c = :pdId                   
            ];
            List<Applicant_Income__c> pdIncome = [
                SELECT
                Id,
                IncomeType__c,
                OtherRevenueMonthly__c,
                Remark__c,
                RecordTypeId,
                Name_of_Company__c,
                Name_of_Owners__c,
                Relationship_with_applicant__c,
                Annual_Turnover_Inc_det__c,
                Firm_Consumption__c
                FROM Applicant_Income__c
                WHERE PrsnlDis__c = :pdId
            ];
            List<ApplAsset__c> pdAssets = [
                SELECT Id, PropType__c, PDPropAdd__c, ApproxValue__c, Remarks__c
                FROM ApplAsset__c
                WHERE PrsnlDis__c = :pdId
            ];
            Map<Id, Ref__c> referencesMap = new Map<Id, Ref__c>(
                [
                    SELECT
                    Id,
                    Title__c,
                    Add__c,
                    Comments__c,
                    ContactNo__c,
                    // RelationWthApp__c,
                    toLabel(RelationshipWthApp__c),
                    FName__c
                    FROM Ref__c
                    WHERE PrsnlDis__c = :pdId
                ]
                );
            List<ApplExpense__c> pdExpenses = [
                SELECT Id, ExpType__c, ExpAmt__c, RecordTypeId
                FROM ApplExpense__c
                WHERE PrsnlDis__c = :pdId
            ];
            tableDataMap.put('LoanApplRelationship__c', applRelation);
            tableDataMap.put('Applicant_Income__c', pdIncome);
            tableDataMap.put('ApplExpense__c', pdExpenses);
            tableDataMap.put('ApplAsset__c', pdAssets);
            tableDataMap.put('Ref__c', referencesMap.values());
            
            system.debug(
                'pdRespList  ' + pdRespList.size() + pdRespList + dataMap
                );
            system.debug('pdRespList' + dataMap.keySet());
            List<PDQuesResponse> respList = new List<PDQuesResponse>();
            Map<String, PDResponseWrapper> pdResponseMap = new Map<String, PDResponseWrapper>();
            // List<PDAccompnyingUsers> pdUsers = new List<PDAccompnyingUsers>();// chaged to list of id of user formobile
            
            List<string> pdUsers = new List<string>();
            for (PDPrtcpnts__c pdp : [
                SELECT Id, User__c, User__r.Name
                FROM PDPrtcpnts__c
                WHERE PD__c = :pdId
            ]) {
                pdUsers.add(pdp.User__c);
                // PDAccompnyingUsers pdaUser = new PDAccompnyingUsers();
                // pdaUser.userId = pdp.User__c;
                // pdaUser.userName = pdp.User__r.Name;
                // pdaUser.recordId = pdp.Id;
                // pdUsers.add(pdaUser);
            }
            
            List<DocDtl__c> docIds = [
                SELECT Id, DocCatgry__c, DocSubTyp__c
                FROM DocDtl__c
                WHERE PrsnlDis__c = :pd.Id
            ];
            
            //Map<Id, List<ContentDocumentLink>> cdlByDocdtlId = new Map<Id, List<ContentDocumentLink>>();
            Map<Id, List<ContentVersion>> cvByDocdtlId = new Map<Id, List<ContentVersion>>();
            Map<Id, Id> docIdToDocDtlIdMap = new Map<Id, Id>();
            
            if (docIds != null && docIds.size() > 0) {
                Map<Id, DocDtl__c> docDtlMap = new Map<Id, DocDtl__c>(docIds);
                List<ContentDocumentLink> dduploaded = [
                    SELECT
                    Id,
                    LinkedEntityId,
                    ContentDocumentId,
                    ContentDocument.CreatedDate,
                    ContentDocument.Title,
                    ContentDocument.ContentSize,
                    ContentDocument.FileType,
                    ContentDocument.FileExtension
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :docDtlMap.keySet()
                ];
                
                for (ContentDocumentLink cdl : dduploaded) {
                    docIdToDocDtlIdMap.put(
                        cdl.ContentDocumentId,
                    cdl.LinkedEntityId
                        );
                    // List<ContentDocumentLink> cdlList = cdlByDocdtlId.get(
                    //     cdl.LinkedEntityId
                    // );
                    // if (cdlList == null) {
                        //     cdlList = new List<ContentDocumentLink>();
                    // }
                    // cdlList.add(cdl);
                    // cdlByDocdtlId.put(cdl.LinkedEntityId, cdlList);
                }
            }
            
            for (ContentVersion cv : [
                SELECT
                Id,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.ContentSize,
                ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIdToDocDtlIdMap.keySet()
            ]) {
                Id docDtlId = docIdToDocDtlIdMap.get(cv.ContentDocumentId);
                List<ContentVersion> cvList = cvByDocdtlId.get(docDtlId);
                if (cvList == null) {
                    cvList = new List<ContentVersion>();
                }
                cvList.add(cv);
                cvByDocdtlId.put(docDtlId, cvList);
            }
            //System.debug('cdlByDocdtlId==' + cdlByDocdtlId);
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name FROM RecordType]) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
            
            Map<Id, List<QuestionCriteria>> quesCriMap = new Map<Id, List<QuestionCriteria>>();
            for (PDQuesCri__c cri : [
                SELECT Id, ApcblQues__c, EvalCrit__c, EvalQues__c, DepValCnfg__c
                FROM PDQuesCri__c
                WHERE
                IsActive__c = TRUE
                AND ApcblQues__c IN :pdQuesIds
                AND EvalQues__c IN :pdQuesIds
            ]) {
                List<QuestionCriteria> critList = quesCriMap.get(
                    cri.ApcblQues__c
                    );
                if (critList == null) {
                    critList = new List<QuestionCriteria>();
                }
                QuestionCriteria newCri = new QuestionCriteria();
                newCri.applicableQues = cri.ApcblQues__c;
                newCri.evalQues = cri.EvalQues__c;
                newCri.criVal = cri.EvalCrit__c != null
                    ? (List<String>) JSON.deserialize(
                    cri.EvalCrit__c,
                List<String>.class
                    )
                    : null;
                if (cri.DepValCnfg__c != null) {
                    DependentValues depVal = (DependentValues) JSON.deserialize(
                        cri.DepValCnfg__c,
                    DependentValues.class
                        );
                    List<Sobject> objects = optionMap.get(depVal.sourceObject);
                    if (objects != null && objects.size() > 0) {
                        Map<String, List<String>> depValMap = new Map<String, List<String>>();
                        if (objects != null && objects.size() > 0) {
                            for (Sobject obj : objects) {
                                String key;
                                if (depVal.dependentParent != null) {
                                    if (
                                        obj.getSObject(
                                        depVal.dependentParent
                                        ) != null
                                    ) {
                                        key = (String) obj.getSObject(
                                            depVal.dependentParent
                                            )
                                            .get(depVal.dependentField);
                                    }
                                } else {
                                    key = (String) obj.get(
                                        depVal.dependentField
                                        );
                                }
                                if (key != null) {
                                    List<String> options = depValMap.get(key);
                                    if (options == null) {
                                        options = new List<String>();
                                    }
                                    options.add(
                                        (String) obj.get(depVal.sourceField)
                                        );
                                    depValMap.put(key, options);
                                }
                            }
                            newCri.dependValCri = JSON.serialize(depValMap);
                        }
                    }
                }
                //newCri.dependValCri = cri.DepValCnfg__c;
                critList.add(newCri);
                quesCriMap.put(cri.ApcblQues__c, critList);
            }
            
            for (PDResp__c resp : pdRespList) {
                PDResponseWrapper respWpr = pdResponseMap.get(
                    resp.PDQues__r.SecTtl__c
                    );
                if (respWpr == null) {
                    respWpr = new PDResponseWrapper();
                    respWpr.recordId = resp.PrsnlDisc__c;
                    respWpr.sectionTitle = resp.PDQues__r.SecTtl__c;
                    respWpr.sectionSeq = resp.PDQues__r.SecSeq__c != null
                        ? resp.PDQues__r.SecSeq__c.intValue()
                        : 0;
                    //respWpr.accompanyingBy = pdUsers;
                    respWpr.completedBy = resp.PrsnlDisc__r.CmpltBy__c;
                    // respWpr.pdComplDate = resp.PrsnlDisc__r.CmpltDt__c.date();
                    // system.debug( 'date error '+resp.PrsnlDisc__r.CmpltDt__c   + +resp.PrsnlDisc__r.CmpltDt__c.date() );
                    // respWpr.pdComplDate = resp.PrsnlDisc__r.CmpltDt__c.date();
                    respWpr.questions = new List<PDQuesResponse>();
                }
                PDQuesResponse pdResp = new PDQuesResponse();
                pdResp.respId = resp.Id;
                pdResp.quesId = resp.PDQues__r.Id;
                pdResp.quesTitle = resp.PDQues__r.QuesTtl__c;
                pdResp.quesResp = resp.Resp__c;
                pdResp.docDetailId = resp.DocDtl__c;
                pdResp.validationConfig = resp.PDQues__r.ValConfig__c;
                pdResp.mobileValidationConfig = resp.PDQues__r.MobValCnfg__c;
                pdResp.criteriaList = quesCriMap.get(resp.PDQues__r.Id);
                pdResp.displaySeq = resp.PDQues__r.DispSeq__c != null
                    ? resp.PDQues__r.DispSeq__c.intValue()
                    : 0;
                pdResp.respType = resp.PDQues__r.RespTyp__c;
                if (pdResp.respType == 'Picklist Multiselect') {
                    List<Options> opts = new List<Options>();
                    map<Id, Options> optsMap = new Map<Id, Options>();
                    for (TeamHierarchy__c thr : [
                        SELECT
                        Id,
                        Employee__c,
                        Employee__r.FirstName,
                        Employee__r.LastName
                        FROM TeamHierarchy__c
                        WHERE
                        EmpRole__c = 'UW'
                        OR EmpRole__c = 'ACM'
                        OR EmpRole__c = 'RCM'
                        OR EmpRole__c = 'CM'
                        OR EmpRole__c = 'NCM'
                        OR EmpRole__c = 'CH'
                        OR EmpRole__c = 'CPA'
                        OR EmpRole__c = 'ZCM'
                    ]) {
                        Options opt = new Options();
                        opt.label = thr.Employee__r.FirstName != null
                            ? thr.Employee__r.FirstName +
                            ' ' +
                            thr.Employee__r.LastName
                            : thr.Employee__r.LastName;
                        opt.value = thr.Employee__c;
                        optsMap.put(thr.Employee__c, opt);
                        //  opts.add(opt);
                    }
                    
                    pdResp.multiSelectOptions = optsMap.values();
                    pdResp.quesResp = JSON.serialize(pdUsers);
                }
                // if(pdResp.respType == 'Table' || pdResp.respType == 'Reference') {
                    //     pdResp.quesConfig = resp.PDQues__r.QuesConf__c;
                // }
                pdResp.quesConfig = resp.PDQues__r.QuesConf__c;
                if (pdResp.respType == 'Reference') {
                    RecordForm recForm = (RecordForm) JSON.deserialize(
                        resp.PDQues__r.QuesConf__c,
                    RecordForm.class
                        );
                    if (pdNonEditabel) {
                        for (TableColumn col : recForm.columns) {
                            col.editable = false;
                        }
                    }
                    recForm.record = referencesMap.get(pdResp.quesResp);
                    recForm.data = new List<Sobject>{ recForm.record };
                    pdResp.quesConfig = JSON.serialize(recForm);
                }
                if (pdResp.respType == 'Table') {
                    TableConfig tblCnfg = (TableConfig) JSON.deserialize(
                        resp.PDQues__r.QuesConf__c,
                    TableConfig.class
                        );
                    if (tblCnfg.recordType != null) {
                        pdResp.recordTypeId = recordTypeMap.get(
                            tblCnfg.recordType
                            );
                    }
                    if (tblCnfg.objectName == 'BureauRespDtl__c') {
                        tblCnfg.data = tblCnfg.enableAddMore != null
                            ? pdBureau
                            : extBureau;
                    } else {
                        if (pdResp.recordTypeId != null) {
                            System.debug(
                                'pdResp.recordTypeId==' + pdResp.recordTypeId
                                );
                            List<Sobject> filterData = new List<Sobject>();
                            for (
                                Sobject obj : tableDataMap.get(
                                tblCnfg.objectName
                                )
                            ) {
                                if (
                                    obj.get('RecordTypeId') ==
                                    pdResp.recordTypeId
                                ) {
                                    System.debug(
                                        'RecordTypeId==' +
                                        obj.get('RecordTypeId')
                                        );
                                    filterData.add(obj);
                                }
                            }
                            tblCnfg.data = filterData;
                        } else {
                            tblCnfg.data = tableDataMap.get(tblCnfg.objectName);
                        }
                        System.debug('tblCnfg.data==' + tblCnfg.data);
                    }
                    if (pdNonEditabel) {
                        tblCnfg.enableAddMore = false;
                        for (TableColumn col : tblCnfg.columns) {
                            col.editable = false;
                        }
                    }
                    pdResp.quesConfig = JSON.serialize(tblCnfg);
                }
                if (pdResp.respType == 'File' || pdResp.respType == 'Video') {
                    FileConfig fileConfig = (FileConfig) JSON.deserialize(
                        resp.PDQues__r.FileConfig__c,
                    FileConfig.class
                        );
                    if (pdNonEditabel) {
                        fileConfig.AllowUpload = false;
                        fileConfig.AllowMultipleFile = false;
                        fileConfig.AllowDelete = false;
                    }
                    if (fileConfig.MinFileCount == null) {
                        fileConfig.MinFileCount = 1;
                    }
                    pdResp.fileConfig = JSON.serialize(fileConfig);
                    List<ContentVersion> cvList = cvByDocdtlId.get(
                        resp.DocDtl__c
                        );
                    List<FileRespWpr> fileRespList = new List<FileRespWpr>();
                    //System.debug('cdlList==' + cdlList);
                    if (cvList != null && cvList.size() > 0) {
                        for (ContentVersion cv : cvList) {
                            FileRespWpr fileResp = new FileRespWpr();
                            fileResp.fileExtension = cv.ContentDocument.FileExtension;
                            fileResp.fileName = cv.ContentDocument.Title;
                            fileResp.fileSize = cv.ContentDocument.ContentSize;
                            fileResp.res = new FileRespnse();
                            fileResp.res.id = cv.Id;
                            fileRespList.add(fileResp);
                        }
                        pdResp.quesResp = JSON.serialize(fileRespList);
                    }
                }
                if (resp.PDQues__r.PossResp__c != null) {
                    PossibleValues valuesWpr = (PossibleValues) JSON.deserialize(
                        resp.PDQues__r.PossResp__c,
                    PossibleValues.class
                        );
                    if (valuesWpr.isFixed) {
                        pdResp.possibleOptions = valuesWpr.options;
                    } else {
                        System.debug(
                            'objects=1=' +
                            valuesWpr.sourceObject +
                            optionMap.keySet()
                            );
                        List<Sobject> objects = optionMap.get(
                            valuesWpr.sourceObject
                            );
                        System.debug(
                            'objects==' + optionMap.keySet() + objects
                            );
                        if (objects != null && objects.size() > 0) {
                            List<String> options = new List<String>();
                            for (Sobject obj : objects) {
                                options.add(
                                    (String) obj.get(valuesWpr.sourceField)
                                    );
                            }
                            pdResp.possibleOptions = options;
                        }
                    }
                }
                if (
                    resp.PDQues__r.DefValCri__c != null &&
                    pdResp.quesResp == null
                ) {
                    DefaultDataCri defDataCtri = (DefaultDataCri) JSON.deserialize(
                        resp.PDQues__r.DefValCri__c,
                    DefaultDataCri.class
                        );
                    
                    // if (
                    //     defDataCtri.objectName == 'Applicant_Income__c' &&
                    //     dataMap.get(defDataCtri.objectName) == null
                    // ) {
                        //     Applicant_Income__c income = new Applicant_Income__c();
                        //     income.RecordTypeId = recordTypeMap.get('Cashflow Map');
                        //     income.Applicant__c = pd.Appl__c;
                        //     income.PrsnlDis__c = pdId;
                        //     insert income;
                        //     dataMap.put('Applicant_Income__c', income);
                    // }
                    Sobject defaulObj = dataMap.get(defDataCtri.objectName);
                    if (defaulObj != null) {
                        if (defDataCtri.parentRelationObj != null) {
                            SObject parentObj = defaulObj.getSobject(
                                defDataCtri.parentRelationObj
                                );
                            if (parentObj != null) {
                                pdResp.quesResp = String.valueOf(
                                    parentObj.get(defDataCtri.field)
                                    );
                            }
                        } else if (
                        defDataCtri.childRelationObj != null &&
                            defDataCtri.filterConditions != null &&
                            defDataCtri.filterConditions.size() > 0
                        ) {
                            List<Sobject> childRecords = defaulObj.getSObjects(
                                defDataCtri.childRelationObj.trim()
                                );
                            if (
                                childRecords != null &&
                                childRecords.size() > 0
                            ) {
                                for (Sobject sobj : childRecords) {
                                    Boolean valid = true;
                                    for (
                                        FilterCondition filter : defDataCtri.filterConditions
                                    ) {
                                        valid =
                                            valid &&
                                            (sobj.get(filter.field) ==
                                            filter.value);
                                    }
                                    if (valid) {
                                        pdResp.quesResp = String.valueOf(
                                            sobj.get(defDataCtri.field)
                                            );
                                        break;
                                    }
                                }
                            }
                        } else {
                            pdResp.quesResp = String.valueOf(
                                defaulObj.get(defDataCtri.field)
                                );
                        }
                        if (defDataCtri.objectName == 'DocDtl__c') {
                            pdResp.docDetailId = pdResp.quesResp;
                            pdResp.quesResp = null;
                        }
                        
                        if (
                            pdResp.respType == 'Date' &&
                            !String.isEmpty(pdResp.quesResp)
                        ) {
                            List<String> dateList = pdResp.quesResp.split(' ');
                            if (dateList != null && dateList.size() > 0) {
                                pdResp.quesResp = dateList[0];
                            }
                        }
                        if (pdResp.respType == 'DateTime') {
                            System.debug('DateTime settig value ' + pdResp.quesResp);
                            if(pdResp.quesResp != null ){
                                DateTime currentDateTimeGMT = Datetime.valueOf(pdResp.quesResp) ;
                                TimeZone indiaTimeZone = TimeZone.getTimeZone('Asia/Kolkata');
                                DateTime currentDateTimeIndia = currentDateTimeGMT.addSeconds(indiaTimeZone.getOffset(currentDateTimeGMT) / 1000);
                                pdResp.quesResp = currentDateTimeIndia.format('yyyy-MM-dd HH:mm:ss');
                                // pdResp.quesResp = currentDateTimeIndia.format('yyyy-MM-dd HH:mm');
                                System.debug('DateTime settig value Final ' + pdResp.quesResp);
                            }else{
                                pdResp.quesResp ='';
                                System.debug('DateTime settig value Final ' + pdResp.quesResp);
                            }
                            
                        }
                    }
                }
                if (resp.PDQues__r.OverrideConfig__c != null) {
                    OverrideConfig overrideCnfg = (OverrideConfig) JSON.deserialize(
                        resp.PDQues__r.OverrideConfig__c,
                    OverrideConfig.class
                        );
                    if (
                        overrideCnfg.objectName == 'Applicant_Income__c' &&
                        dataMap.get(overrideCnfg.objectName) == null
                    ) {
                        Applicant_Income__c income = new Applicant_Income__c();
                        income.RecordTypeId = recordTypeMap.get('Cashflow Map');
                        income.Applicant__c = pd.Appl__c;
                        income.PrsnlDis__c = pdId;
                        insert income;
                        dataMap.put('Applicant_Income__c', income);
                    }
                    Sobject ordObj = dataMap.get(overrideCnfg.objectName);
                    if (ordObj != null) {
                        overrideCnfg.recordId = ordObj.Id;
                    }
                    if(resp.PDQues__r.EnableOverride__c == false){
                        pdResp.overrideCnfg = JSON.serialize(overrideCnfg);// latest commented by shek on 10/10/24
                    }
                    
                }
                pdResp.isReqPortal = resp.PDQues__r.IsReqWeb__c;
                pdResp.isReqMobile = resp.PDQues__r.IsReqMob__c;
                pdResp.isEditable = pdNonEditabel
                    ? false
                    : resp.PDQues__r.IsEditable__c;
                pdResp.visibleOnMobile = resp.PDQues__r.VisibleMob__c;
                pdResp.visibleOnPortal = resp.PDQues__r.VisibleWeb__c;
                pdResp.responseObj = 'PDResp__c';
                respWpr.questions.add(pdResp);
                pdResponseMap.put(resp.PDQues__r.SecTtl__c, respWpr);
            }
            return pdResponseMap.Values();
        } catch (exception e) {
            system.debug(
                'error occured ' +
                e.getMessage() +
                'get line number ' +
                e.getLineNumber() +
                ' get stack trace ' +
                e.getStackTraceString()
                );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string savePdData(
        string pdId,
    List<QuestionsSaveWrapper> pdRecToSave
    ) {
        try {
            Boolean isFinalSubmit = false;
            for (QuestionsSaveWrapper pdSave : pdRecToSave) {
                for (Sobject rec : pdsave.records) {
                    if (pdsave.objectType == 'PD__c') {
                        System.debug('CmpltDt__c  before stamp '+ rec.get('PDStatus__c'));
                        if (
                            rec.get('IsCompleted__c') != null &&
                             rec.get('IsCompleted__c') == true
                        ) {
                            
                            isFinalSubmit = true;
                        }
                    }
                }
                
                
            }
            return savePd(pdId, pdRecToSave, isFinalSubmit);
        } catch (Exception e) {
            if(e.getMessage().contains('Normal_Days_sales_Days_Working__c') ){
                throw new AuraHandledException('Sum of normal working days in a month as per applicant and peak days in month should not exceed 30 days.');
            }
            else if(e.getMessage().contains('OfficialEmail__c') ){
                throw new AuraHandledException('Invalid email address');
            }
            else{
                throw new AuraHandledException(e.getMessage());
            }
            
        }
    }
    
    public static string savePd(
        string pdId,
    List<QuestionsSaveWrapper> pdRecToSave,
    boolean isFinalSubmit
    ) {
        List<ApplicantEmployment__c> applicantEmploymentList = new List<ApplicantEmployment__c>();
        string IndustryId;
        
        // try {
            boolean deleteAllPdPart = false;
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name FROM RecordType]) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
            
            
            
            PD__c pdDet = new PD__c();
            pdDet = [
            SELECT Id, AsgnTo__c, Appl__c, LoanAppl__c
            FROM PD__c
            WHERE Id = :pdId
            LIMIT 1
        ];
            
            if(pdDet.Appl__c != null){
                applicantEmploymentList = [SELECT Id, LoanApplicant__c,IndustryType__c from ApplicantEmployment__c WHERE LoanApplicant__c =: pdDet.Appl__c LIMIT 1];
            }
            list<PDPrtcpnts__c> pdPartOld = new List<PDPrtcpnts__c>();
            pdPartOld = [
            SELECT Id, PD__c, User__c, Assigned_Date__c
            FROM PDPrtcpnts__c
            WHERE PD__c = :pdId
        ];
            
            Map<string, PDPrtcpnts__c> pdPartOldMap = new Map<string, PDPrtcpnts__c>();
            if (pdPartOld.size() > 0) {
                for (PDPrtcpnts__c pdp : pdPartOld) {
                    pdPartOldMap.put(pdp.User__c, pdp);
                }
            }
            
            list<PDPrtcpnts__c> pdPartNew = new List<PDPrtcpnts__c>();
            
            Map<String, String> industoryIdNameMap = new Map<String, String>();
            Map<String, String> subIndustoryIdNameMap = new Map<String, String>();
            for (Industry__c ind : [SELECT Id, Name FROM Industry__c]) {
                industoryIdNameMap.put(ind.Name, ind.Id);
            }
            Map<String,Id> MapOfSub = new Map<String,Id>();
            for (SubIndustry__c subInd : [SELECT Id,Name,Industry__c FROM SubIndustry__c]) {
                subIndustoryIdNameMap.put(subInd.Name, subInd.Id);
                MapOfSub.put(subInd.Industry__c+'-'+subInd.Name, subInd.Id);
            }
            
            Map<string, string> natureOfBusinessIndividual = new Map<string, string>();
            natureOfBusinessIndividual = getPickListValuesIntoMap(
                'ApplicantEmployment__c',
            'NatureOfBusinessIndividual__c'
                );
            Map<string, string> NatureOfBusinessCorporate = new Map<string, string>();
            NatureOfBusinessCorporate = getPickListValuesIntoMap(
                'ApplicantEmployment__c',
            'NatureOfBusinessCorporate__c'
                );
            Map<string, string> typeOfOrganisation = new Map<string, string>();
            typeOfOrganisation = getPickListValuesIntoMap(
                'ApplicantEmployment__c',
            'TypeOfOrganisation__c'
                );
            Map<string, string> relationshipWthAppMap = new Map<string, string>();
            relationshipWthAppMap = getPickListValuesIntoMap(
                'Ref__c',
            'RelationshipWthApp__c'
                );
            //LAK-8312 Added Required Fields for Calculation
            List<Applicant_Income__c> caseflowIncomes = [
            SELECT Id,Nature_Of_Business_of_Applicant__c,ServicesRevenueMonthly__c,OtherDayDaily__c,OthersDaysWorking__c,OtherRevenueMonthly__c,Monthly_Purchases_Cost_Of_Materials__c,Total_Expense_of_operations_Or_Business__c,
            ReceiptsPerDayDaily__c,ReceiptsPerDayDaysWorking__c,Peak_Days_sales_Receipts_Days_Working__c,Peak_Days_sales_Receipts_Daily__c,Normal_Days_sales_Receipts_Daily__c,Normal_Days_sales_Days_Working__c,PrsnlDis__c,Applicant__c
            FROM Applicant_Income__c
            WHERE
            RecordType.DeveloperName = 'Cashflow_Map'
            AND Applicant__c = :pdDet.Appl__c
        ];
            // LAK- 8558
            List<ApplExpense__c> pdExpenses = [
            SELECT Id, ExpType__c, ExpAmt__c, RecordTypeId
            FROM ApplExpense__c
            WHERE PrsnlDis__c = :pdId
        ];
            Boolean expNotPresent = false;
            if(pdExpenses.size() == 0){
                expNotPresent = true;
            }
            // LAK- 8558
            list<Sobject> upsertRecList = new List<Sobject>();
            list<Sobject> deleteRecList = new List<Sobject>();
            System.debug('pdRecToSave' + pdRecToSave.size() + pdId + pdRecToSave);
            if (pdRecToSave.size() > 0) {
                for (QuestionsSaveWrapper pdsave : pdRecToSave) {
                    System.debug('pdsave' + pdsave);
                    for (Sobject rec : pdsave.records) {
                        System.debug('rec' + rec);
                        if (pdsave.objectType == 'ApplAsset__c' && rec.Id == null) {
                            rec.put('Appl__c', pdDet.Appl__c);
                            rec.put('PrsnlDis__c', pdDet.Id); // added new
                            upsertRecList.add(rec);
                        } else if (
                        pdsave.objectType == 'ApplAsset__c' &&
                            rec.Id != null
                        ) {
                            if (
                                rec.get('IsDeleted') != null &&
                                (boolean) rec.get('IsDeleted') == true
                            ) {
                                if (rec.Id != null && (string) rec.Id != '') {
                                    deleteRecList.add(rec);
                                }
                            } else {
                                upsertRecList.add(rec);
                            }
                            //rec.put('Applicant__c', pdDet.Appl__c);
                        } else if (pdsave.objectType == 'PDPrtcpnts__c') {
                            if (rec.get('User__c') != null) {
                                PDPrtcpnts__c pdPart = new PDPrtcpnts__c();
                                pdPart.User__c = (String) rec.get('User__c');
                                pdPart.PD__c = pdId;
                                pdPart.Assigned_Date__c = System.today();
                                pdPartNew.add(pdPart);
                            } else {
                                deleteAllPdPart = true;
                            }
                            
                            // for multiselectPd
                            //rec.put('Applicant__c',pdDet.Appl__c) ;
                        } else if (pdsave.objectType == 'PDResp__c') {
                            upsertRecList.add(rec);
                        } else if (pdsave.objectType == 'Ref__c') {
                            if (rec.get('RelationshipWthApp__c') != null) {
                                rec.put(
                                    'RelationshipWthApp__c',
                                relationshipWthAppMap.get(
                                    (String) rec.get('RelationshipWthApp__c')
                                    )
                                    );
                            }
                            upsertRecList.add(rec);
                        }
                        else if (pdsave.objectType == 'Applicant_Income__c') {
                            
                            //LAK-8312 Start - Calculating values on PD Update
                            Integer ServicesRevenueMonthly =0;
                            Integer OtherRevenueMonthly =0;
                            Integer totalExpense =0;
                            if(rec.get('ServicesRevenueMonthly__c') != null){
                                ServicesRevenueMonthly = Integer.valueOf(rec.get('ServicesRevenueMonthly__c'));
                            }
                            //LAK-8454 check caseflowIncomes array size
                            else if (caseflowIncomes.size() > 0) {
                                ServicesRevenueMonthly = Integer.valueOf(caseflowIncomes[0].ServicesRevenueMonthly__c != null ?caseflowIncomes[0].ServicesRevenueMonthly__c:0);
                            }
                            
                            if(rec.get('OtherRevenueMonthly__c') != null){
                                OtherRevenueMonthly = Integer.valueOf(rec.get('OtherRevenueMonthly__c'));
                            }
                            //LAK-8454 check caseflowIncomes array size
                            else if (caseflowIncomes.size() > 0) {
                                OtherRevenueMonthly = Integer.valueOf(caseflowIncomes[0].OtherRevenueMonthly__c != null?caseflowIncomes[0].OtherRevenueMonthly__c:0);
                            }
                            //LAK-8454 check caseflowIncomes array size
                            else if (caseflowIncomes.size() > 0) {
                                totalExpense = Integer.valueOf(caseflowIncomes[0].Total_Expense_of_operations_Or_Business__c != null?caseflowIncomes[0].Total_Expense_of_operations_Or_Business__c:0);
                            }
                            //LAK-8454 check caseflowIncomes array size
                            if(caseflowIncomes.size() > 0){
                                if(caseflowIncomes[0].Nature_Of_Business_of_Applicant__c == 'Manufacturing' || caseflowIncomes[0].Nature_Of_Business_of_Applicant__c == 'Trading'){
                                    Integer monthlyPurchase = 0;
                                    Integer normalDaysSales =0;
                                    Integer normalDaysSalesDaysWorking =0;
                                    Integer peakDaysSales =0;
                                    Integer peakDaysSalesDaysWorking = 0;
                                    if(rec.get('Monthly_Purchases_Cost_Of_Materials__c') != null){
                                        monthlyPurchase = Integer.valueOf(rec.get('Monthly_Purchases_Cost_Of_Materials__c'));
                                    }
                                    else{
                                        monthlyPurchase = Integer.valueOf(caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c != null?caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c:0);
                                    }
                                    
                                    if(rec.get('Normal_Days_sales_Receipts_Daily__c') != null){
                                        normalDaysSales = Integer.valueOf(rec.get('Normal_Days_sales_Receipts_Daily__c'));
                                    }
                                    else{
                                        normalDaysSales = Integer.valueOf(caseflowIncomes[0].Normal_Days_sales_Receipts_Daily__c != null?caseflowIncomes[0].Normal_Days_sales_Receipts_Daily__c:0);
                                    }
                                    
                                    if(rec.get('Normal_Days_sales_Days_Working__c') != null){
                                        normalDaysSalesDaysWorking = Integer.valueOf(rec.get('Normal_Days_sales_Days_Working__c'));
                                    }
                                    else{
                                        normalDaysSalesDaysWorking = Integer.valueOf(caseflowIncomes[0].Normal_Days_sales_Days_Working__c != null? caseflowIncomes[0].Normal_Days_sales_Days_Working__c:0);
                                    }
                                    rec.put('Normal_Days_sales_Receipts_Monthly__c',( normalDaysSales * normalDaysSalesDaysWorking));
                                    
                                    if(rec.get('Peak_Days_sales_Receipts_Daily__c') != null){
                                        peakDaysSales = Integer.valueOf(rec.get('Peak_Days_sales_Receipts_Daily__c'));
                                    }
                                    else{
                                        peakDaysSales = Integer.valueOf(caseflowIncomes[0].Peak_Days_sales_Receipts_Daily__c != null?caseflowIncomes[0].Peak_Days_sales_Receipts_Daily__c:0);
                                    }
                                    
                                    if(rec.get('Peak_Days_sales_Receipts_Days_Working__c') != null){
                                        peakDaysSalesDaysWorking = Integer.valueOf(rec.get('Peak_Days_sales_Receipts_Days_Working__c'));
                                    }
                                    else{
                                        peakDaysSalesDaysWorking = Integer.valueOf(caseflowIncomes[0].Peak_Days_sales_Receipts_Days_Working__c != null?caseflowIncomes[0].Peak_Days_sales_Receipts_Days_Working__c:0);
                                    }
                                    rec.put('Peak_Days_sales_Receipts_Receipts_Monthl__c',( peakDaysSales * peakDaysSalesDaysWorking));
                                    
                                    Decimal totalInflowAmount1 = ((normalDaysSales * normalDaysSalesDaysWorking) + (peakDaysSales * peakDaysSalesDaysWorking) + ServicesRevenueMonthly + OtherRevenueMonthly) ;
                                    rec.put('Operating_Activity_Receipts__c',totalInflowAmount1);
                                    rec.put('Total_Inflow_From_Operations__c',totalInflowAmount1);
                                    Decimal netCashPL1 = totalInflowAmount1 - monthlyPurchase - totalExpense ;
                                    rec.put('NET_CASH_PROFIT_LOSS__c',netCashPL1);
                                    Decimal appoxMargin = 0;
                                    if((netCashPL1 != 0 || netCashPL1 != null  )&& (totalInflowAmount1 != 0 || totalInflowAmount1 != null)){
                                        appoxMargin = ((netCashPL1 / totalInflowAmount1) * 100).setScale(2);
                                    }
                                    //     Decimal appoxMargin = ((netCashPL1 / totalInflowAmount1) * 100).setScale(2);
                                    rec.put('APPROXIMATE_MARGIN_IN_THE_BUSINESS__c',appoxMargin);
                                }
                                
                                if(caseflowIncomes[0].Nature_Of_Business_of_Applicant__c == 'Services'){
                                    Integer monthlyPurchase = 0;
                                    Integer otherDayWorking = 0;
                                    Integer receiptperDay =0;
                                    Integer preceiptperDayWorking =0;
                                    Integer otherperDay =0;
                                    Integer reciptMontly = 0;
                                    Integer otherMontly = 0;
                                    monthlyPurchase = Integer.valueOf(caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c != null ?caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c:0);
                                    
                                    otherperDay = Integer.valueOf(caseflowIncomes[0].OtherDayDaily__c != null ?caseflowIncomes[0].OtherDayDaily__c:0);
                                    otherDayWorking = Integer.valueOf(caseflowIncomes[0].OthersDaysWorking__c != null ?caseflowIncomes[0].OthersDaysWorking__c:0);
                                    
                                    receiptperDay = Integer.valueOf(caseflowIncomes[0].ReceiptsPerDayDaily__c != null ?caseflowIncomes[0].ReceiptsPerDayDaily__c:0);
                                    preceiptperDayWorking = Integer.valueOf(caseflowIncomes[0].ReceiptsPerDayDaysWorking__c != null ?caseflowIncomes[0].ReceiptsPerDayDaysWorking__c:0);
                                    
                                    reciptMontly =  receiptperDay * preceiptperDayWorking;
                                    otherMontly = otherperDay * otherDayWorking;
                                    Decimal totalInflowAmount = (reciptMontly + otherMontly + ServicesRevenueMonthly + OtherRevenueMonthly) ;
                                    rec.put('Operating_Activity_Receipts__c',totalInflowAmount);
                                    rec.put('Total_Inflow_From_Operations__c',totalInflowAmount);
                                    Decimal netCashPL = totalInflowAmount - monthlyPurchase - totalExpense ;
                                    rec.put('NET_CASH_PROFIT_LOSS__c',netCashPL);
                                    //Decimal appoxMargin = ((netCashPL / totalInflowAmount) * 100).setScale(2);
                                    Decimal appoxMargin = 0;
                                    if((netCashPL != 0 && netCashPL != null  )&& (totalInflowAmount != 0 && totalInflowAmount != null)){
                                        appoxMargin = ((netCashPL / totalInflowAmount) * 100).setScale(2);
                                    }
                                    rec.put('APPROXIMATE_MARGIN_IN_THE_BUSINESS__c',appoxMargin);
                                }
                            }
                            //LAK-8312 End
                            // LAK- 8558
                            if(expNotPresent == true){
                                rec.put('Total_Expense_of_operations_Or_Business__c',0);
                            }
                            // LAK- 8558
                            if (rec.Id == null || (string) rec.Id == '') {
                                rec.put('Id', null);
                                rec.put('Applicant__c', pdDet.Appl__c);
                                rec.put('PrsnlDis__c', pdId);
                                if (rec.get('RecordTypeId') == null) {
                                    rec.put(
                                        'RecordTypeId',
                                    recordTypeMap.get('Cashflow Map')
                                        );
                                }
                            }
                            if (
                                rec.get('IsDeleted') != null &&
                                (boolean) rec.get('IsDeleted') == true
                            ) {
                                if (rec.Id != null && (string) rec.Id != '') {
                                    deleteRecList.add(rec);
                                }
                            } else {
                                upsertRecList.add(rec);
                            }
                        }
                        else if (pdsave.objectType == 'ApplExpense__c') {
                            if (rec.Id == null || (string) rec.Id == '') {
                                rec.put('Id', null);
                                rec.put('PrsnlDis__c', pdId);
                                if (caseflowIncomes.size() > 0) {
                                    rec.put('ApplInc__c', caseflowIncomes[0].Id);
                                }
                            }
                            if (
                                rec.get('IsDeleted') != null &&
                                (boolean) rec.get('IsDeleted') == true
                            ) {
                                if (rec.Id != null && (string) rec.Id != '') {
                                    deleteRecList.add(rec);
                                }
                            } else {
                                upsertRecList.add(rec);
                            }
                        } else if (pdsave.objectType == 'BureauRespDtl__c') {
                            if (rec.Id == null || (string) rec.Id == '') {
                                //|| rec.Id ==''
                                rec.put('Id', null);
                                rec.put('LoanApplication__c', pdDet.LoanAppl__c);
                                rec.put('Applicant__c', pdDet.Appl__c);
                                rec.put('PrsnlDis__c', pdId);
                                rec.put('Source__c', 'Manual');
                            }
                            if (
                                rec.get('IsDeleted') != null &&
                                (boolean) rec.get('IsDeleted') == true
                            ) {
                                if (rec.Id != null && (string) rec.Id != '') {
                                    deleteRecList.add(rec);
                                }
                            } else {
                                upsertRecList.add(rec);
                            }
                        }
                        
                        else if (pdsave.objectType == 'LoanApplRelationship__c') {
                            if (rec.Id == null || (string) rec.Id == '') {
                                //|| rec.Id ==''
                                rec.put('Id', null);
                                //  rec.put('Loan_Applicant__c', pdDet.LoanAppl__c);
                                rec.put('Loan_Applicant__c', pdDet.Appl__c);
                                rec.put('Personal_Discussion__c', pdId);
                                rec.put('Relationship_Type__c', 'Relationship in PD');
                                //  Relationship_Type__c ='Relationship in PD'
                            }
                            if (
                                rec.get('IsDeleted') != null &&
                                (boolean) rec.get('IsDeleted') == true
                            ) {
                                if (rec.Id != null && (string) rec.Id != '') {
                                    deleteRecList.add(rec);
                                }
                            } else {
                                upsertRecList.add(rec);
                            }
                        }
                        
                        else if (pdsave.objectType == 'ApplicantEmployment__c') {
                            if (rec.get('IndustryType__c') != null) {
                                
                                rec.put(
                                    'IndustryType__c',
                                industoryIdNameMap.get(
                                    (String) rec.get('IndustryType__c')
                                    )
                                    
                                
                                );
                            }
                            if (rec.get('SubIndustry__c') != null) {
                                if(rec.get('IndustryType__c') != null){
                                    IndustryId = (String) rec.get('IndustryType__c');
                                    
                                }else if(applicantEmploymentList != null && !applicantEmploymentList.isEmpty()){
                                    IndustryId = applicantEmploymentList[0].IndustryType__c;
                                }
                                String SubIndName =  (String) rec.get('SubIndustry__c');
                                rec.put('SubIndustry__c',MapOfSub.get(IndustryId+'-'+SubIndName));
                                
                                
                                //                             rec.put(
                                // 'SubIndustry__c',
                                // subIndustoryIdNameMap.get(
                                // (String) rec.get('SubIndustry__c')
                                // )
                                // );
                            }
                            string natOfBusinessVal = (string) rec.get(
                                'NatureOfBusinessIndividual__c'
                                );
                            
                            if (natOfBusinessVal != null) {
                                rec.put(
                                    'NatureOfBusinessIndividual__c',
                                natureOfBusinessIndividual.get(natOfBusinessVal)
                                    );
                            }
                            string NatureOfBusinessCorporateVal = (string) rec.get(
                                'NatureOfBusinessCorporate__c'
                                );
                            if (NatureOfBusinessCorporateVal != null) {
                                rec.put(
                                    'NatureOfBusinessCorporate__c',
                                NatureOfBusinessCorporate.get(
                                    NatureOfBusinessCorporateVal
                                    )
                                    );
                            }
                            string typeOfOrganisationVal = (string) rec.get(
                                'TypeOfOrganisation__c'
                                );
                            if (typeOfOrganisationVal != null) {
                                rec.put(
                                    'TypeOfOrganisation__c',
                                typeOfOrganisation.get(typeOfOrganisationVal)
                                    );
                            }
                            
                            upsertRecList.add(rec);
                        } else if (pdsave.objectType == 'PDC__c') {
                            rec.put('Loan_Application__c', pdDet.loanAppl__c);
                        } else if (pdsave.objectType == 'PD__c') {
                            System.debug('CmpltDt__c  before stamp '+ rec.get('PDStatus__c'));
                            if (
                                rec.get('IsCompleted__c') != null &&
                                rec.get('IsCompleted__c') == true
                            ) {
                                System.debug('CmpltDt__c stamped'+ rec.get('PDStatus__c'));
                                rec.put('CmpltDt__c', DateTime.now());
                                rec.put('PDStatus__c', 'Completed');
                            }else{
                                rec.put('CmpltDt__c', null);
                                System.debug('CmpltDt__c stamped null'+ rec.get('CmpltDt__c'));
                            }
                            upsertRecList.add(rec);
                        } else if (pdsave.objectType == 'Applicant__c' ) {
                            upsertRecList.add(rec);
                        }
                    }
                }
            }
            
            list<PDPrtcpnts__c> pdPartToDel = new List<PDPrtcpnts__c>();
            
            if (pdPartNew.size() > 0) {
                if (pdPartOld.size() > 0) {
                    delete pdPartOld;
                }
                upsert pdPartNew;
            }
            if (deleteAllPdPart) {
                delete pdPartOld;
            }
            if (deleteRecList.size() > 0) {
                delete deleteRecList;
            }
            if (upsertRecList.size() > 0) {
                upsert upsertRecList;
            }
            if(isFinalSubmit ){
                //  updateOverrideConfig(Id pdId)
                string industryId1 = '';
                string natureOfBusiness ='';
                List<PDResp__c> pdRespList = new List<PDResp__c>();
                pdRespList =[ SELECT Id, PDQues__r.EnableOverride__c,PDQues__r.OverrideConfig__c, PDQues__r.RespTyp__c,  PrsnlDisc__c,  PDQues__c, Ques__c, Resp__c, Cmnt__c, DocDtl__c
                         FROM PDResp__c where PrsnlDisc__c =:pdId AND PrsnlDisc__r.PDStatus__c   ='Completed'  AND 
                         PDQues__r.EnableOverride__c = true];
                list<Sobject> upsertRecList1 = new List<Sobject>();
                if(pdRespList.size() >0 ){
                    
                    
                    //data gathering
                    //        if(pdDet.Appl__c != null){
                        //Id, AsgnTo__c, Appl__c, LoanAppl__c
                        //pdDet
                        Map<String, Sobject> dataMap = new Map<String, Sobject>();
                        dataMap.put('PD__c',pdDet);
                        if(pdDet.LoanAppl__c != null){
                            LoanAppl__c loanApp = [
                        SELECT
                        Id,
                        Product__c,
                        ReqLoanAmt__c,
                        AssessedIncAppln__c,
                        AssesIncomeAppl__c
                        FROM LoanAppl__c
                        WHERE Id = :pdDet.LoanAppl__c
                    ];
                            dataMap.put('LoanAppl__c', loanApp);
                        }
                        if(pdDet.Appl__c != null){
                            Applicant__c applicant = [
                        SELECT
                        Id,
                        CustProfile__c,
                        Constitution__c,
                        TabName__c,
                        MobNumber__c,
                        ApplType__c,
                        Relationship__c,
                        LatestyearforwhichITRisavailable__c,
                        (SELECT Id, AddrTyp__c FROM Applicant_Addresses__r)
                        FROM Applicant__c
                        WHERE Id = :pdDet.Appl__c
                    ];
                            dataMap.put('Applicant__c', applicant);
                            
                            List<ApplicantEmployment__c> employmentList = [
                        SELECT
                        Id,
                        EmployerName__c,
                        LoanApplicant__r.LatestyearforwhichITRisavailable__c,
                        EmployerName__r.Name,
                        Others__c,
                        EntityName__c,
                        DesignationText__c,
                        DesignationValues__c,
                        toLabel(NatureOfBusinessCorporate__c),
                        toLabel(NatureOfBusinessIndividual__c),
                        WorkingWithCurrentEmployer_Months__c,
                        WorkingWithCurrentEmployer_Years__c
                        FROM ApplicantEmployment__c
                        WHERE LoanApplicant__c = :pdDet.Appl__c
                        LIMIT 1
                    ];
                            if (employmentList.size() > 0) {
                                dataMap.put('ApplicantEmployment__c', employmentList[0]);
                            }
                            // List<Applicant_Income__c> caseflowIncomes = [
                            //     SELECT
                            //     Id,
                            //     Normal_Days_sales_Receipts_Daily__c,
                            //     Normal_Days_sales_Days_Working__c,
                            //     Peak_Days_sales_Receipts_Daily__c,
                            //     Peak_Days_sales_Receipts_Days_Working__c,
                            //     OtherRevenueMonthly__c,
                            //     ServicesRevenueMonthly__c,
                            //     Monthly_Purchases_Cost_Of_Materials__c,
                            //     Total_Expense_of_operations_Or_Business__c,
                            //     ReceiptsPerDayDaily__c
                            //     FROM Applicant_Income__c
                            //     WHERE
                            //     RecordType.DeveloperName = 'Cashflow_Map'
                            //     AND Applicant__c = :pdDet.Appl__c
                            // ];
                        }
                        Applicant_Income__c appInc = new Applicant_Income__c();
                        if (caseflowIncomes.size() > 0) {
                            dataMap.put('Applicant_Income__c', caseflowIncomes[0]);
                            appInc = caseflowIncomes[0];
                        }
                        
                        
                        System.debug('  dataMap value == '+ dataMap);
                        
                        //
                        Applicant__c appl =  new Applicant__c();
                        appl =(Applicant__c) dataMap.get('Applicant__c');
                        PD__c pd =  new PD__c();
                        pd = pdDet;
                        ApplicantEmployment__c appEmp =  new ApplicantEmployment__c();
                        if(dataMap.get('ApplicantEmployment__c') != null){
                            appEmp =(ApplicantEmployment__c) dataMap.get('ApplicantEmployment__c');
                        }
                        
                        
                        for (PDResp__c pdresp : pdRespList) {
                            if (pdresp.PDQues__r.OverrideConfig__c != null &&  pdresp.Resp__c != null && pdresp.PDQues__r.EnableOverride__c == true ) {
                                OverrideConfig overrideCnfg = (OverrideConfig) JSON.deserialize(
                                    pdresp.PDQues__r.OverrideConfig__c,
                                OverrideConfig.class
                                    );
                                //  map<string,string> updateOnjects = new  map<string,string> (0;)
                                // sObject  updateOnjects  = new sObject();
                                System.debug('override configs = '+ overrideCnfg );
                                if (
                                    overrideCnfg.objectName == 'ApplicantEmployment__c' &&
                                    dataMap.get(overrideCnfg.objectName) != null
                                ) {
                                    if( overrideCnfg.field == 'IndustryType__c' &&  industoryIdNameMap.get(pdresp.Resp__c) != null ){
                                        appEmp.IndustryType__c = industoryIdNameMap.get(pdresp.Resp__c);
                                        industryId1 = (string) industoryIdNameMap.get(pdresp.Resp__c);
                                    }
                                    else if( overrideCnfg.field == 'SubIndustry__c' && MapOfSub.get(industryId1+'-'+pdresp.Resp__c) != null){
                                        appEmp.SubIndustry__c = MapOfSub.get(industryId1+'-'+pdresp.Resp__c);
                                    }
                                    else if( overrideCnfg.field == 'NatureOfBusinessIndividual__c' && natureOfBusinessIndividual.get(pdresp.Resp__c) != null ){
                                        natureOfBusiness = pdresp.Resp__c;
                                        appEmp.NatureOfBusinessIndividual__c = natureOfBusinessIndividual.get(pdresp.Resp__c);
                                    }
                                    else if( overrideCnfg.field == 'NatureOfBusinessCorporate__c' && NatureOfBusinessCorporate.get(pdresp.Resp__c) != null){
                                        natureOfBusiness = pdresp.Resp__c;
                                        appEmp.NatureOfBusinessCorporate__c = NatureOfBusinessCorporate.get(pdresp.Resp__c);
                                    }
                                    else if( overrideCnfg.field == 'TypeOfOrganisation__c' &&  typeOfOrganisation.get(pdresp.Resp__c) != null){
                                        appEmp.TypeOfOrganisation__c = typeOfOrganisation.get(pdresp.Resp__c);
                                    }
                                    else if( overrideCnfg.field == 'CurrentBusinessVintage_Years__c' ||  overrideCnfg.field == 'TotalWorkExperience_Years__c' || overrideCnfg.field == 'TotalWorkExperience_Months__c'){
                                        appEmp.put(overrideCnfg.field, Integer.valueOf(pdresp.Resp__c));
                                    }else{
                                        if( pdresp.PDQues__r.RespTyp__c == 'Number'){
                                            appEmp.put(overrideCnfg.field, Integer.valueOf(pdresp.Resp__c));
                                        }
                                        // if( pdresp.PDQues__r.RespTyp__c == 'Date'){
                                            //     appEmp.put(overrideCnfg.field, Integer.valueOf(pdresp.Resp__c));
                                        // }
                                        else{
                                            appEmp.put(overrideCnfg.field, pdresp.Resp__c);
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    System.debug('appEmp  == '+ appEmp);
                                    //  upsertRecList1.add(updateOnjects);
                                }
                                
                                if (
                                    overrideCnfg.objectName == 'Applicant_Income__c' &&
                                    dataMap.get(overrideCnfg.objectName) != null
                                ) {
                                    // call sapereat emethod for cashflow computations
                                    //;;;;;;;;;;;;;;;;;;;;;;;;;;
                                    //LAK-8312 Start - Calculating values on PD Update
                                    
                                    if( pdresp.PDQues__r.RespTyp__c == 'Number'){
                                        appInc.put(overrideCnfg.field, Integer.valueOf(pdresp.Resp__c));
                                    }
                                    else{
                                        appInc.put(overrideCnfg.field, pdresp.Resp__c);
                                    }
                                    Integer ServicesRevenueMonthly =0;
                                    Integer OtherRevenueMonthly =0;
                                    Integer totalExpense =0;
                                    System.debug('overrideCnfg 1747== '+ overrideCnfg.objectName  + overrideCnfg.field + pdresp.Resp__c );
                                    if(overrideCnfg.field == 'ServicesRevenueMonthly__c' && pdresp.Resp__c != null){
                                        ServicesRevenueMonthly = Integer.valueOf( pdresp.Resp__c);
                                    }
                                    //LAK-8454 check caseflowIncomes array size
                                    else if (caseflowIncomes.size() > 0) {
                                        ServicesRevenueMonthly = Integer.valueOf(caseflowIncomes[0].ServicesRevenueMonthly__c  != null ?caseflowIncomes[0].ServicesRevenueMonthly__c:0);
                                    }
                                    
                                    if(overrideCnfg.field == 'OtherRevenueMonthly__c' && pdresp.Resp__c != null){
                                        OtherRevenueMonthly = Integer.valueOf(pdresp.Resp__c);
                                    }
                                    //LAK-8454 check caseflowIncomes array size
                                    else if (caseflowIncomes.size() > 0) {
                                        OtherRevenueMonthly = Integer.valueOf(caseflowIncomes[0].OtherRevenueMonthly__c   != null?caseflowIncomes[0].OtherRevenueMonthly__c:0);
                                    }
                                    //LAK-8454 check caseflowIncomes array size
                                    else if (caseflowIncomes.size() > 0) {
                                        totalExpense = Integer.valueOf(caseflowIncomes[0].Total_Expense_of_operations_Or_Business__c  != null?caseflowIncomes[0].Total_Expense_of_operations_Or_Business__c:0);
                                    }
                                    //LAK-8454 check caseflowIncomes array size
                                    if(caseflowIncomes.size() > 0){
                                        if(natureOfBusiness == 'MANUFACTURING' || natureOfBusiness == 'TRADING'){
                                            Integer monthlyPurchase = 0;
                                            Integer normalDaysSales =0;
                                            Integer normalDaysSalesDaysWorking =0;
                                            Integer peakDaysSales =0;
                                            Integer peakDaysSalesDaysWorking = 0;
                                            if(overrideCnfg.field == 'Monthly_Purchases_Cost_Of_Materials__c' && pdresp.Resp__c != null){
                                                monthlyPurchase = Integer.valueOf(pdresp.Resp__c);
                                            }
                                            else{
                                                monthlyPurchase = Integer.valueOf(caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c  != null?caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c:0);
                                            }
                                            
                                            if(overrideCnfg.field == 'Normal_Days_sales_Receipts_Daily__c' && pdresp.Resp__c != null){
                                                normalDaysSales = Integer.valueOf(pdresp.Resp__c);
                                            }
                                            else{
                                                normalDaysSales = Integer.valueOf(caseflowIncomes[0].Normal_Days_sales_Receipts_Daily__c != null?caseflowIncomes[0].Normal_Days_sales_Receipts_Daily__c:0);
                                            }
                                            
                                            if(overrideCnfg.field == 'Normal_Days_sales_Days_Working__c' && pdresp.Resp__c != null){
                                                normalDaysSalesDaysWorking = Integer.valueOf(pdresp.Resp__c);
                                            }
                                            else{
                                                normalDaysSalesDaysWorking = Integer.valueOf(caseflowIncomes[0].Normal_Days_sales_Days_Working__c != null? caseflowIncomes[0].Normal_Days_sales_Days_Working__c:0);
                                            }
                                            appInc.Normal_Days_sales_Receipts_Monthly__c = normalDaysSales * normalDaysSalesDaysWorking ;
                                            // rec.put('Normal_Days_sales_Receipts_Monthly__c',( normalDaysSales * normalDaysSalesDaysWorking));
                                            
                                            if(overrideCnfg.field == 'Peak_Days_sales_Receipts_Daily__c' && pdresp.Resp__c != null){
                                                peakDaysSales = Integer.valueOf( pdresp.Resp__c);
                                            }
                                            else{
                                                peakDaysSales = Integer.valueOf(caseflowIncomes[0].Peak_Days_sales_Receipts_Daily__c  != null?caseflowIncomes[0].Peak_Days_sales_Receipts_Daily__c:0);
                                            }
                                            
                                            if(overrideCnfg.field == 'Peak_Days_sales_Receipts_Days_Working__c' && pdresp.Resp__c != null){
                                                peakDaysSalesDaysWorking  = Integer.valueOf( pdresp.Resp__c);
                                            }
                                            else{
                                                peakDaysSalesDaysWorking = Integer.valueOf(caseflowIncomes[0].Peak_Days_sales_Receipts_Days_Working__c != null?caseflowIncomes[0].Peak_Days_sales_Receipts_Days_Working__c:0);
                                            }
                                            appInc.Peak_Days_sales_Receipts_Receipts_Monthl__c = ( peakDaysSales * peakDaysSalesDaysWorking);
                                            //rec.put('Peak_Days_sales_Receipts_Receipts_Monthl__c',( peakDaysSales * peakDaysSalesDaysWorking));
                                            
                                            Decimal totalInflowAmount1 = ((normalDaysSales * normalDaysSalesDaysWorking) + (peakDaysSales * peakDaysSalesDaysWorking) + ServicesRevenueMonthly + OtherRevenueMonthly) ;
                                            appInc.Operating_Activity_Receipts__c =totalInflowAmount1;
                                            // rec.put('Operating_Activity_Receipts__c',totalInflowAmount1);
                                            appInc.Total_Inflow_From_Operations__c =totalInflowAmount1;
                                            //   rec.put('Total_Inflow_From_Operations__c',totalInflowAmount1);
                                            Decimal netCashPL1 = totalInflowAmount1 - monthlyPurchase - totalExpense ;
                                            appInc.NET_CASH_PROFIT_LOSS__c = netCashPL1;
                                            //rec.put('NET_CASH_PROFIT_LOSS__c',netCashPL1);
                                            Decimal appoxMargin = 0;
                                            System.debug('divide by error check '+netCashPL1+totalInflowAmount1 );
                                            if((netCashPL1 != 0 && netCashPL1  != null  )&& (totalInflowAmount1 != 0 && totalInflowAmount1 != null)){
                                                appoxMargin = ((netCashPL1 / totalInflowAmount1) * 100).setScale(2);
                                            }
                                            //     Decimal appoxMargin = ((netCashPL1 / totalInflowAmount1) * 100).setScale(2);
                                            appInc.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = appoxMargin;
                                            appInc.Nature_Of_Business_of_Applicant__c =  natureOfBusiness == 'MANUFACTURING'? 'Manufacturing' :'Trading';
                                            // rec.put('APPROXIMATE_MARGIN_IN_THE_BUSINESS__c',appoxMargin);
                                        }
                                        
                                        if(natureOfBusiness == 'SERVICES'){
                                            Integer monthlyPurchase = 0;
                                            Integer otherDayWorking = 0;
                                            Integer receiptperDay =0;
                                            Integer preceiptperDayWorking =0;
                                            Integer otherperDay =0;
                                            Integer reciptMontly = 0;
                                            Integer otherMontly = 0;
                                            monthlyPurchase = Integer.valueOf(caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c  != null ?caseflowIncomes[0].Monthly_Purchases_Cost_Of_Materials__c:0);
                                            
                                            otherperDay = Integer.valueOf(caseflowIncomes[0].OtherDayDaily__c  != null ?caseflowIncomes[0].OtherDayDaily__c:0);
                                            otherDayWorking = Integer.valueOf(caseflowIncomes[0].OthersDaysWorking__c != null ?caseflowIncomes[0].OthersDaysWorking__c:0);
                                            
                                            receiptperDay = Integer.valueOf(caseflowIncomes[0].ReceiptsPerDayDaily__c  != null ?caseflowIncomes[0].ReceiptsPerDayDaily__c:0);
                                            preceiptperDayWorking = Integer.valueOf(caseflowIncomes[0].ReceiptsPerDayDaysWorking__c  != null ?caseflowIncomes[0].ReceiptsPerDayDaysWorking__c:0);
                                            
                                            reciptMontly =  receiptperDay * preceiptperDayWorking;
                                            otherMontly = otherperDay * otherDayWorking;
                                            Decimal totalInflowAmount = (reciptMontly + otherMontly + ServicesRevenueMonthly + OtherRevenueMonthly) ;
                                            appInc.Operating_Activity_Receipts__c = totalInflowAmount;
                                            //rec.put('Operating_Activity_Receipts__c',totalInflowAmount);
                                            appInc.Total_Inflow_From_Operations__c = totalInflowAmount;
                                            // rec.put('Total_Inflow_From_Operations__c',totalInflowAmount);
                                            Decimal netCashPL = totalInflowAmount - monthlyPurchase - totalExpense ;
                                            appInc.NET_CASH_PROFIT_LOSS__c = netCashPL;
                                            // rec.put('NET_CASH_PROFIT_LOSS__c',netCashPL);
                                            //Decimal appoxMargin = ((netCashPL / totalInflowAmount) * 100).setScale(2);
                                            Decimal appoxMargin = 0;
                                            if((netCashPL != 0 && netCashPL  != null  )&& (totalInflowAmount != 0 && totalInflowAmount  != null)){
                                                appoxMargin = ((netCashPL / totalInflowAmount) * 100).setScale(2);
                                            }
                                            appInc.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = appoxMargin;
                                            appInc.Nature_Of_Business_of_Applicant__c =   'Services';
                                            //rec.put('APPROXIMATE_MARGIN_IN_THE_BUSINESS__c',appoxMargin);
                                        }
                                    }
                                    // LAK-8312 End
                                    //  LAK- 8558
                                    if(expNotPresent == true){
                                        appInc.put('Total_Expense_of_operations_Or_Business__c',0);
                                    }
                                    // LAK- 8558
                                    system.System.debug('Applicant__c  inc before save ' +appInc+  pdDet.Appl__c);
                                    if (appInc.Id == null || (string) appInc.Id == '') {
                                        appInc.put('Id', null);
                                        appInc.put('Applicant__c', pdDet.Appl__c);
                                        appInc.put('PrsnlDis__c', pdId);
                                        //  if (overrideCnfg.objectName == 'RecordTypeId' == null) {}
                                        appInc.put(
                                            'RecordTypeId',
                                        recordTypeMap.get('Cashflow Map')
                                            );
                                        
                                    }
                                    // if (
                                    //     overrideCnfg.field == 'IsDeleted' &&
                                    //     (boolean) overrideCnfg.objectName == 'IsDeleted' == true
                                    // ) {
                                        //     if (rec.Id && pdresp.Resp__c != null && (string) rec.Id != '') {
                                            //         deleteRecList.add(rec);
                                        //     }
                                    // } else {
                                        //     upsertRecList.add(rec);
                                    // }
                                    
                                    
                                    //;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                }
                                if (
                                    overrideCnfg.objectName == 'Applicant__c' &&
                                    dataMap.get(overrideCnfg.objectName) != null
                                ) {
                                    if( overrideCnfg.field == 'Relationship__c' ){
                                        appl.put(overrideCnfg.field, (pdresp.Resp__c));
                                    }else{
                                        if( pdresp.PDQues__r.RespTyp__c == 'Number'){
                                            appl.put(overrideCnfg.field, Integer.valueOf(pdresp.Resp__c));
                                        }
                                        else{
                                            appl.put(overrideCnfg.field, pdresp.Resp__c);
                                        }
                                    }
                                    
                                }
                                if (
                                    overrideCnfg.objectName == 'PD__c' &&
                                    dataMap.get(overrideCnfg.objectName) != null
                                ) {
                                    
                                    // if (
                                    //     overrideCnfg.field == 'Relationship__c'
                                    // ) {
                                        //     System.debug('CmpltDt__c stamped'+ rec.get('PDStatus__c'));
                                        //     rec.put('CmpltDt__c', DateTime.now());
                                        
                                    // }else{
                                        //     rec.put('CmpltDt__c', null);
                                        //     System.debug('CmpltDt__c stamped null'+ rec.get('CmpltDt__c'));
                                    // }
                                    // upsertRecList.add(rec);
                                }
                                
                                if (
                                    overrideCnfg.objectName == 'PDPrtcpnts__c' &&
                                    dataMap.get(overrideCnfg.objectName) != null
                                ) {
                                    
                                }
                                //   Sobject ordObj = dataMap.get(overrideCnfg.objectName);
                                //   if (ordObj != null) {
                                    //       overrideCnfg.recordId = ordObj.Id;
                                //   }
                                //pdResp.overrideCnfg = JSON.serialize(overrideCnfg);
                            }
                        }
                        System.debug('appEmp == '+ appEmp);
                        System.debug('appInc == '+ appInc);
                        if( appEmp !=  null){
                            if(appEmp.NatureOfBusinessCorporate__c != null ){
                                appEmp.NatureOfBusinessCorporate__c =  NatureOfBusinessCorporate.get(appEmp.NatureOfBusinessCorporate__c) != null ?  NatureOfBusinessCorporate.get(appEmp.NatureOfBusinessCorporate__c) : appEmp.NatureOfBusinessCorporate__c;
                            }
                            if(appEmp.NatureOfBusinessIndividual__c != null ){
                                appEmp.NatureOfBusinessIndividual__c =  natureOfBusinessIndividual.get(appEmp.NatureOfBusinessIndividual__c) != null ?  natureOfBusinessIndividual.get(appEmp.NatureOfBusinessIndividual__c) : appEmp.NatureOfBusinessIndividual__c;
                            }
                            upsert appEmp;
                        }
                        if( appInc !=  null   && appInc.Applicant__c  != null){// &&  appInc.PrsnlDis__c != null
                            System.debug('appInc 123== '+ appInc);
                            upsert appInc;
                        }
                        
                    }
                    System.debug('upsertRecList1 == '+ upsertRecList1);
                    System.debug('upsertRecList == '+ upsertRecList);
                }
                
                return JSON.serialize(upsertRecList);
                
            }
            //     public static void updateOverrideConfig(Id pdId){
                // //         select Id, PDQues__r.EnableOverride__c,PDQues__r.OverrideConfig__c,   PrsnlDisc__c,  PDQues__c, Ques__c, Resp__c, Cmnt__c, DocDtl__c, CustVidRec__c  from PDResp__c where PrsnlDisc__c ='a0wC4000000NIx7IAG' AND PrsnlDisc__r.PDStatus__c   ='Completed'  AND
                // // PDQues__r.EnableOverride__c = true
                //         List<PDResp__c> pdRespList = new List<PDResp__c>();
                //         pdRespList =[ SELECT Id, PDQues__r.EnableOverride__c,PDQues__r.OverrideConfig__c,   PrsnlDisc__c,  PDQues__c, Ques__c, Resp__c, Cmnt__c, DocDtl__c, CustVidRec__c
    //                       FROM PDResp__c where PrsnlDisc__c =:pdId AND PrsnlDisc__r.PDStatus__c   ='Completed'  AND 
    //                          PDQues__r.EnableOverride__c = true];
                //             if(pdRespList.size() >0 ){
                    //                     if (resp.PDQues__r.OverrideConfig__c != null) {
                        //                     OverrideConfig overrideCnfg = (OverrideConfig) JSON.deserialize(
                        //                         resp.PDQues__r.OverrideConfig__c,
                        //                         OverrideConfig.class
                        //                     );
                        //                     if (
                        //                         overrideCnfg.objectName == 'Applicant_Income__c' &&
                        //                         dataMap.get(overrideCnfg.objectName) == null
                        //                     ) {
                            //                         Applicant_Income__c income = new Applicant_Income__c();
                            //                         income.RecordTypeId = recordTypeMap.get('Cashflow Map');
                            //                         income.Applicant__c = pd.Appl__c;
                            //                         income.PrsnlDis__c = pdId;
                            //                         insert income;
                            //                         dataMap.put('Applicant_Income__c', income);
                        //                     }
                        //                     Sobject ordObj = dataMap.get(overrideCnfg.objectName);
                        //                     if (ordObj != null) {
                            //                         overrideCnfg.recordId = ordObj.Id;
                        //                     }
                        //                    // pdResp.overrideCnfg = JSON.serialize(overrideCnfg);
                    //                 }
                //             }
            //     }
            @AuraEnabled
            public static void savePdMultiselect(
                string pdId,
            boolean deleteOlder,
            List<sObject> multiselectVal
            ) {
                try {
                    if (pdId != null) {
                        list<PDPrtcpnts__c> pdPartOld = new List<PDPrtcpnts__c>();
                        pdPartOld = [
                    SELECT Id, PD__c, User__c, Assigned_Date__c
                    FROM PDPrtcpnts__c
                    WHERE PD__c = :pdId
                ];
                        if (deleteOlder) {
                            delete (pdPartOld);
                        }
                    }
                    if (multiselectVal.size() > 0) {
                        insert (multiselectVal);
                    }
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            
            public static Map<string, string> getPickListValuesIntoMap(
                string objectApiName,
            string fieldApiName
            ) {
                // List<String> pickListValuesList= new List<String>();
                
                List<Schema.PicklistEntry> picklistValues;
                Map<string, string> pickListValuesMap = new Map<string, string>();
                try {
                    Schema.DescribeFieldResult fieldDescription = Schema.getGlobalDescribe()
                        .get(objectApiName)
                        .getDescribe()
                        .fields.getMap()
                        .get(fieldApiName)
                        .getDescribe();
                    
                    if (fieldDescription.getType() == Schema.DisplayType.PICKLIST) {
                        picklistValues = fieldDescription.getPicklistValues();
                        
                        for (Schema.PicklistEntry entry : picklistValues) {
                            // System.debug('Picklist Label: ' + entry.getLabel());
                            // System.debug('Picklist Value: ' + entry.getValue());
                            pickListValuesMap.put(entry.getLabel(), entry.getValue());
                        }
                        //  return pickListValuesMap;
                    } else {
                        System.debug('The specified field is not a picklist field.');
                        return pickListValuesMap;
                    }
                    //return pickListValuesMap;
                } catch (Exception e) {
                    System.debug('An error occurred: ' + e.getMessage());
                }
                return pickListValuesMap;
            }
            // public class QuestionsSaveWrapper{
                //     @AuraEnabled
                //     public string objectType { get; set; }
                //     @AuraEnabled
                //     public  List<Sobject>  records { get; set; }
            // }
            
            
            
            public class DefaultDataCri {
                public String objectName;
                public String field;
                public String parentRelationObj;
                public String childRelationObj;
                public List<FilterCondition> filterConditions;
            }
            
            public class FilterCondition {
                public String field;
                public String value;
            }
            
            public class PDReqestWrapper {
                @AuraEnabled
                public Id loanAppId { get; set; }
                @AuraEnabled
                public string applicantId { get; set; }
                @AuraEnabled
                public String pdMode { get; set; }
                @AuraEnabled
                public Date schdDate { get; set; }
                @AuraEnabled
                public Id assigndTo { get; set; }
                @AuraEnabled
                public Id vendorAccId { get; set; }
                @AuraEnabled
                public Id vendorContactcId { get; set; }
                @AuraEnabled
                public Boolean isDoneByVendor { get; set; }
            }
            
            public class PDResponseWrapper {
                @AuraEnabled
                public Id recordId { get; set; }
                @AuraEnabled
                public String sectionTitle { get; set; }
                @AuraEnabled
                public Integer sectionSeq { get; set; }
                @AuraEnabled
                public Date pdComplDate { get; set; }
                @AuraEnabled
                public Id completedBy { get; set; }
                @AuraEnabled
                public List<PDQuesResponse> questions { get; set; }
            }
            
            public class PDAccompnyingUsers {
                @AuraEnabled
                public Id userId { get; set; }
                @AuraEnabled
                public String userName { get; set; }
                @AuraEnabled
                public Id recordId { get; set; }
            }
            
            public class PDQuesResponse {
                @AuraEnabled
                public Id respId { get; set; }
                @AuraEnabled
                public Id recordTypeId { get; set; }
                @AuraEnabled
                public Id quesId { get; set; }
                @AuraEnabled
                public String quesTitle { get; set; }
                @AuraEnabled
                public String quesResp { get; set; }
                @AuraEnabled
                public Id docDetailId { get; set; }
                @AuraEnabled
                public Integer displaySeq { get; set; }
                @AuraEnabled
                public String respType { get; set; }
                @AuraEnabled
                public String quesConfig { get; set; }
                @AuraEnabled
                public String fileConfig { get; set; }
                @AuraEnabled
                public List<String> possibleOptions { get; set; }
                @AuraEnabled
                public List<Options> multiSelectOptions { get; set; }
                @AuraEnabled
                public Boolean isReqMobile { get; set; }
                @AuraEnabled
                public Boolean isReqPortal { get; set; }
                @AuraEnabled
                public Boolean visibleOnMobile { get; set; }
                @AuraEnabled
                public Boolean visibleOnPortal { get; set; }
                @AuraEnabled
                public Boolean isEditable { get; set; }
                @AuraEnabled
                public String responseObj { get; set; }
                @AuraEnabled
                public String validationConfig { get; set; }
                @AuraEnabled
                public String mobileValidationConfig { get; set; }
                @AuraEnabled
                public String overrideCnfg { get; set; }
                @AuraEnabled
                public List<QuestionCriteria> criteriaList { get; set; }
            }
            
            public class Options {
                @AuraEnabled
                public String label { get; set; }
                @AuraEnabled
                public String value { get; set; }
            }
            
            public class PossibleValues {
                public Boolean isFixed { get; set; }
                public String sourceObject { get; set; }
                public String sourceField { get; set; }
                public List<String> options { get; set; }
            }
            
            public class DependentValues {
                public String sourceObject { get; set; }
                public String sourceField { get; set; }
                public String dependentField { get; set; }
                public String dependentParent { get; set; }
                public List<String> options { get; set; }
            }
            
            public class TableConfig {
                public Boolean enableAddMore { get; set; }
                public String recordType { get; set; }
                public String objectName { get; set; }
                public List<TableColumn> columns { get; set; }
                public List<Sobject> data { get; set; }
            }
            
            public class TableColumn {
                public String label { get; set; }
                public String fieldName { get; set; }
                public String type { get; set; }
                public String min { get; set; }
                public String max { get; set; }
                public Boolean editable { get; set; }
                public Boolean required { get; set; }
                public Boolean isReqMobile { get; set; }
                public Boolean visibleOnMobile { get; set; }
                public List<String> options { get; set; }
                public String validationConfig { get; set; }
                public String mobileValidationConfig { get; set; }
                string pattern { get; set; }
            }
            
            public class OverrideConfig {
                public String objectName;
                public String field;
                public String recordId;
            }
            
            public class FileConfig {
                public List<String> FileType;
                public Integer MazSize;
                public Boolean AllowMultipleFile;
                public Boolean AllowUpload;
                public Boolean AllowDelete;
                public Boolean AllowDownload;
                public String FileExtention;
                public Integer MinFileCount;
            }
            
            public class RecordForm {
                public String objectName;
                public List<TableColumn> columns;
                public SObject record;
                public List<Sobject> data { get; set; }
            }
            
            public class FilterCriteria {
                public String objectName;
                public List<String> fields;
                public String criteria;
            }
            
            public class FileRespWpr {
                public String fileExtension;
                public String fileName;
                public Integer fileSize;
                public String fileUri;
                public FileRespnse res;
            }
            
            public class FileRespnse {
                String id;
                Boolean success;
            }
            
            public class QuestionCriteria {
                @AuraEnabled
                public Id applicableQues { get; set; }
                @AuraEnabled
                public Id evalQues { get; set; }
                @AuraEnabled
                public List<String> criVal { get; set; }
                @AuraEnabled
                public String dependValCri { get; set; }
            }
        }