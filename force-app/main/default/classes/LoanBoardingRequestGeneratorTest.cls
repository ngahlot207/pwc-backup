@isTest
public class LoanBoardingRequestGeneratorTest 
{
    @isTest
    public static void testGenerateMethod() {
        Test.startTest();
        
        User us = TestDataFactory.UserData(true);
        
        System.runas(us){    
            //List<LoanAppl__c> loanApps =  new List<LoanAppl__c>();
            //LoanBoardingRequestGeneratorTest.testCalculateIMD1();
            TriggerBase.bypass('LoanAppl__c');
            TriggerBase.bypass('Applicant__c');
            
            
            SchMapping__c schMap = new SchMapping__c();
            schMap.ProductType__c ='Home Loan';
            //schMap.ISBT__C =true;
            schMap.SchmId__c ='548';
            insert schMap;
            
                
                
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            //LoanAppl__c.Total_PF_Amount__c ='18526';
            loanApp.BrchName__c='MUMBAI';
            loanApp.RemPFDeductFromDisbursementAmount__c='Yes';
            loanApp.FinnoneAppid__c='587653';
            loanApp.SchemeId__c=schMap.Id;
            loanApp.FirstEMIDueMonth__c='February';
            //loanApp.RMSMEmployeeID__c='RM12345';
            loanApp.LoanPurpose__c='Balance Transfer';
            loanApp.BrchCode__c='MUM';
            loanApp.Product__c='Home Loan';
            loanApp.SchmCode__c='HL - SELLER BT';
            loanApp.LeadSource__c='Direct';
            loanApp.IncomerelateComm__c='Test';
            loanApp.BDApplicantCoapp__c='Test';
            loanApp.ReqLoanAmt__c=500005;
            loanApp.LoanPLRType__c='PLR_HL';
            loanApp.AddationalComm__c='Test';
            loanApp.Repayment_Frequency__c='M';
            loanApp.LoanPLRRate__c=20.5;
            loanApp.Rate_Type_Floating_Flag__c='Y';
            loanApp.EffectiveROI__c=5;
            loanApp.MoratGraceApplicable__c='N';
            loanApp.DisbursalType__c='Multiple';
            loanApp.DueDay__c='7';	
            //loanApp.FirstEMIDate__c='2023-02-07T01:55:43.000+0000';
            loanApp.Installment_Plan__c='E';
            loanApp.FirstEMIDueYear__c='2023';
            loanApp.Loan_Tenure_Months__c=180;
            loanApp.RMSMName__c = us.ID;
            //loanApps.add(loanApp);
            update loanApp;
            
            
            List<Applicant__c> listAppl=new List<Applicant__c>(); 
            Applicant__c appLi =new Applicant__c();
            appLi.Constitution__c= 'INDIVIDUAL';
            appLi.MobNumber__c= '8896944363';
            appLi.LName__c= 'Sample';
            appLi.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi.FName__c= 'Testing';
            appLi.Age__c= 32;
            appLi.MName__c= 'M';
            appLi.Gender__c= 'F';
            appLi.PassNo__c= 'S9265723';
            appLi.PAN__c= 'AZBPS1592F';
            appLi.KeyManName__c= 'Anu B';
            appLi.MariStatus__c= 'M';
            appLi.SpName__c= 'Abcd Sample';
            appLi.MthrMdnName__c= 'V';
            appLi.YearOfRegistration__c= null;
            appLi.DLNo__c= 'GJ0120090974832';
            appLi.VotIdEpicNo__c= null;
            appLi.EduQual__c= 'GRAD';
            appLi.CompanyName__c= null;
            appLi.Relationship__c= 'Business Associate';
            appLi.Nationality__c= 'INDIA';
            appLi.CustProfile__c= 'HOUSEWIFE';
            appLi.Title__c= 'Mr.';
            appLi.UCID__c= '12362638';
            appLi.DOI__c=   Date.newInstance(2000, 12, 9);
            appLi.ApplType__c= 'P';
            appLi.Religion__c= 'HINDU';
            appLi.Father_Name__c= 'Test FName';
            appLi.EmailId__c= 'abcd@gmail.com';
            appLi.Category__c= 'O';
            System.debug('loanApp.Id+'+loanApp.Id);
            appLi.LoanAppln__c=loanApp.Id;
            appLi.UCID__c='12345';
            appLi.MName__c='TestM';
            appLi.KeyManName__c='KeyMan';
            //insert appLi;
            listAppl.add(appLi);
            
            Applicant__c appLi1 =new Applicant__c();
            appLi1.Constitution__c= 'INDIVIDUAL';
            appLi1.MobNumber__c= '8896944363';
            appLi1.LName__c= 'Abcd';
            appLi1.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi1.FName__c= 'AppTwo';
            //appLi1.TabName__c= 'TEST USER';
            appLi1.Age__c= 24;
            appLi1.MName__c= 'M';
            appLi1.Gender__c= 'M';
            appLi1.PassNo__c= 'S9265723';
            appLi1.PAN__c= 'AZBPS1592F';
            appLi1.KeyManName__c= 'Anu B';
            appLi1.MariStatus__c= 'M';
            appLi1.SpName__c= 'Abcd Person';
            appLi1.MthrMdnName__c= 'V';
            appLi1.YearOfRegistration__c= null;
            appLi1.DLNo__c= 'GJ0120090974832';
            appLi1.VotIdEpicNo__c= null;
            appLi1.EduQual__c= 'GRAD';
            appLi1.CompanyName__c= null;
            appLi1.Relationship__c= 'Business Associate';
            appLi1.Nationality__c= 'INDIA';
            appLi1.CustProfile__c= 'HOUSEWIFE';
            appLi1.Title__c= 'Mr.';
            appLi1.UCID__c= '12362638';
            appLi1.DOI__c=   Date.newInstance(2001, 12, 9);
            appLi1.ApplType__c= 'C';
            appLi1.Religion__c= 'HINDU';
            appLi1.Father_Name__c= 'Test Data';
            appLi1.EmailId__c= 'abcd@gmail.com';
            appLi1.Category__c= 'O';
            appLi1.LoanAppln__c=loanApp.Id;
            appLi1.UCID__c='12345';
            appLi1.MName__c='TestM';
            appLi1.KeyManName__c='KeyMan';
            listAppl.add(appLi1);
            
            Applicant__c appLi2 =new Applicant__c();
            appLi2.Constitution__c= 'INDIVIDUAL';
            appLi2.MobNumber__c= '8896944363';
            appLi2.LName__c= 'Testing App';
            appLi2.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi2.FName__c= 'App test';
            appLi2.Age__c= 24;
            //appLi2.TabName__c= 'TESTOne USER';
            appLi2.MName__c= 'M';
            appLi2.Gender__c= 'M';
            appLi2.PassNo__c= 'S9265723';
            appLi2.PAN__c= 'AZBPS1592Z';
            appLi2.KeyManName__c= 'Anu B';
            appLi2.MariStatus__c= 'M';
            appLi2.SpName__c= 'Hello Person';
            appLi2.MthrMdnName__c= 'V';
            appLi2.YearOfRegistration__c= null;
            appLi2.DLNo__c= 'GJ0120090974832';
            appLi2.VotIdEpicNo__c= null;
            appLi2.EduQual__c= 'GRAD';
            appLi2.CompanyName__c= null;
            appLi2.Relationship__c= 'Business Associate';
            appLi2.Nationality__c= 'INDIA';
            appLi2.CustProfile__c= 'HOUSEWIFE';
            appLi2.Title__c= 'Mr.';
            appLi2.UCID__c= '12362638';
            appLi2.DOI__c=   Date.newInstance(2002, 12, 9);
            appLi2.ApplType__c= 'C';
            appLi2.Religion__c= 'HINDU';
            appLi2.Father_Name__c= 'Test Data';
            appLi2.EmailId__c= 'abcd@gmail.com';
            appLi2.Category__c= 'O';
            appLi2.LoanAppln__c=loanApp.Id;
            appLi2.UCID__c='87645';
            appLi2.MName__c='Test Hey';
            appLi2.KeyManName__c='KeyMan';
            listAppl.add(appLi2);
            
            Applicant__c appLi3 =new Applicant__c();
            appLi3.Constitution__c= 'INDIVIDUAL';
            appLi3.MobNumber__c= '8896333363';
            appLi3.LName__c= 'Testing App';
            appLi3.DOB__c=  Date.newInstance(1981, 12, 9);
            appLi3.FName__c= 'App testing';
            appLi3.Age__c= 24;
            appLi3.MName__c= 'M';
            appLi3.Gender__c= 'M';
            //appLi2.TabName__c= 'TESTTwo USER';
            appLi3.PassNo__c= 'S9265723';
            appLi3.PAN__c= 'AZBPS1592F';
            appLi3.KeyManName__c= 'Ankur B';
            appLi3.MariStatus__c= 'M';
            appLi3.SpName__c= 'Hello Person';
            appLi3.MthrMdnName__c= 'V';
            appLi3.YearOfRegistration__c= null;
            appLi3.DLNo__c= 'GJ0120090974832';
            appLi3.VotIdEpicNo__c= null;
            appLi3.EduQual__c= 'GRAD';
            appLi3.CompanyName__c= null;
            appLi3.Relationship__c= 'Business Associate';
            appLi3.Nationality__c= 'INDIA';
            appLi3.CustProfile__c= 'HOUSEWIFE';
            appLi3.Title__c= 'Mr.';
            appLi3.UCID__c= '12362630';
            appLi3.DOI__c=   Date.newInstance(2002, 12, 9);
            appLi3.ApplType__c= 'C';
            appLi3.Religion__c= 'HINDU';
            appLi3.Father_Name__c= 'Test Data';
            appLi3.EmailId__c= 'abcd@gmail.com';
            appLi3.Category__c= 'O';
            appLi3.LoanAppln__c=loanApp.Id;
            appLi3.UCID__c='87645';
            appLi3.MName__c='Test Hey';
            appLi3.KeyManName__c='KeyMan';
            listAppl.add(appLi3);
            
            insert listAppl;
            
            
            List<PD__c> liPerD =new List<PD__c>();
            PD__c perD =new PD__c();
            perD.CmpltDt__c=Date.newInstance(2024, 12, 9);
            //perD.AsgnTo__r.Name=us.Name;
            //perD.Appl__r.TabName__c=appLi.TabName__c;
            perD.Accompanying_By__c=us.Id;
            perD.AsgnTo__c=us.Id;
            perD.CmpltBy__c=us.Id;
            perD.SchDate__c=Date.newInstance(2023, 12, 9);
            perD.PDStatus__c='Completed';
            perD.IsCompleted__c=true;
            perD.PDRmrks__c='Test Remark';
            perD.Appl__c=appLi.Id;
            perD.LoanAppl__c=loanApp.id;
            
            liPerD.add(perD);
            
             PD__c perD1 =new PD__c();
            perD1.CmpltDt__c=Date.newInstance(2024, 12, 9);
            //perD.AsgnTo__r.Name=us.Name;
            //perD.Appl__r.TabName__c=appLi.TabName__c;
            perD1.Accompanying_By__c=us.Id;
            perD1.AsgnTo__c=us.Id;
            perD1.CmpltBy__c=us.Id;
            perD1.SchDate__c=Date.newInstance(2023, 12, 9);
            perD1.PDStatus__c='Completed';
            perD1.IsCompleted__c=true;
            perD1.Appl__c=appLi.Id;
            perD1.PDRmrks__c='Test Remark';
            perD1.LoanAppl__c=loanApp.id;
            
            liPerD.add(perD1);
            
            insert liPerD;
            
            List<PDResp__c> liPerDisRes =new List<PDResp__c>();
            PDResp__c pdres =new PDResp__c();
            //pdres.done__c =true;
            pdres.Ques__c='Name of person with whom PD was conducted';
            pdres.Resp__c='Negative';
            pdres.PrsnlDisc__c=perD.Id;
            liPerDisRes.add(pdres);
            
            PDResp__c pdres1 =new PDResp__c();
            //pdres.done__c =true;
            pdres1.Ques__c='PD Closure Date';
            pdres1.Resp__c='Negative';
            pdres1.PrsnlDisc__c=perD1.Id;
            liPerDisRes.add(pdres1);
            
            insert liPerDisRes;
            
            Disbursement__c disbObj =new Disbursement__c();
            disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
            disbObj.No_of_Disbur__c=1;
            disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
            disbObj.Princ_Rec_on__c='Amount Financed';
            disbObj.Loan_Appli__c= loanApp.id;
            disbObj.Disbur_No__c=1;            
            insert disbObj; 
            
            
            Split_Disbur__c spDisObj =new Split_Disbur__c();
            spDisObj.Disbur_To__c='Customer';
            spDisObj.DisburseRela__c=   disbObj.Id;         
            
            spDisObj.Effec_Date__c = Date.newInstance(2024, 1, 9);
            spDisObj.IFSC_Detail__c = 'ABCFDERT';
            spDisObj.Split_Cheque_Amt__c = 10000;
            spDisObj.Fedbank_Acc_No__c = '123456765433';
            spDisObj.Custo_Name__c = 'Abcd Test';
            spDisObj.Cheq_Favor_Acc_No__c = '123432456788';
            spDisObj.Remarks__c = 'test remarks';
            spDisObj.Cheq_DD_Date__c = Date.newInstance(2024, 1, 9);
            spDisObj.Cheq_Favor_Dets__c = 'DD';
            spDisObj.Payable_At__c = 'PUNE';
            spDisObj.Fund_Transf_Mode__c = 'IMPS';
            spDisObj.Pay_Mode__c = 'Cheque';
            spDisObj.Date_of_Disbur__c = Date.newInstance(2024, 1, 9);
            spDisObj.Cheq_DD_No__c = '234234432890';
            spDisObj.Fedbank_Acc_Nm__c = '234234432890';
            insert spDisObj;
            
            BRE__c breRes =new BRE__c();
            breRes.Name='SampleBreRes';
            breRes.LoanAppl__c=loanApp.Id;
            insert breRes;
            
            Insurance__c ins =new Insurance__c();
            ins.SumAmount__c=5000000;
            ins.PremiumAmount__c=54000;
            ins.LoanAppln__c=loanApp.Id;
            insert ins;
            
            MasterData__c mstrData=new MasterData__c();
            mstrData.Name= 'HDFC Life Insurance';
            mstrData.MPno__c= 'PP000280';
            insert mstrData;
            
            List<LonaApplCharges__c> listLoanAppChrg=new List<LonaApplCharges__c>();
            LonaApplCharges__c lAppChrgs = new LonaApplCharges__c();
            lAppChrgs.Amount__c= 18408;
            lAppChrgs.ChargeCodeID__c= '35';
            lAppChrgs.ChargeCodeDesc__c= 'AMT FINANCED';
            lAppChrgs.LoanApplication__c=loanApp.Id;
            listLoanAppChrg.add(lAppChrgs);
            
            LonaApplCharges__c lAppChrgs1 = new LonaApplCharges__c();
            lAppChrgs1.Amount__c= 18408;
            lAppChrgs1.ChargeCodeID__c= '68';
            lAppChrgs1.ChargeCodeDesc__c= 'AMT FINANCED';
            lAppChrgs1.LoanApplication__c=loanApp.Id;
            listLoanAppChrg.add(lAppChrgs1);
            
            insert listLoanAppChrg;
            
            ApplIMD__c appImd =new ApplIMD__c();
            appImd.City__c= 'GREATER NOIDA';
            appImd.PaymentMode__c= 'DD';
            appImd.MICRCode__c= '100002532';
            appImd.BankBrch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
            appImd.BankAccountNo__c= '7656465';
            appImd.IMDAmt__c= 2950;
            appImd.LoanAppln__c=loanApp.Id;
            insert appImd;
            
            
            List<Ref__c> listOfAllRef=new List<Ref__c>();
            
            Ref__c refObj=new Ref__c();
            refObj.RelationshipWthApp__c= 'B';
            refObj.FName__c= 'Test1';
            refObj.Add__c= 'Andheri east';
            refObj.Loan_Application__c=loanApp.Id;
            refObj.Applicant__c= appLi.Id;
            refObj.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj);

            Ref__c refObj1=new Ref__c();
            refObj1.RelationshipWthApp__c= 'M';
            refObj1.FName__c= 'Test2';
            refObj1.Add__c= 'Andheri east New';
            refObj1.Loan_Application__c=loanApp.Id;
            refObj1.Applicant__c= appLi.Id;
            refObj1.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj1);

            Ref__c refObj2=new Ref__c();
            refObj2.RelationshipWthApp__c= 'B';
            refObj2.FName__c= 'Test3';
            refObj2.Add__c= 'Andheri east';
            refObj2.Loan_Application__c=loanApp.Id;
            refObj2.Applicant__c= appLi.Id;
            refObj2.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj2);

            insert listOfAllRef;



            


            Id rtId = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
            
            BureauRespDtl__c burL =new BureauRespDtl__c();
            burL.ConsiderObligation__c= 'No';
            burL.RecordTypeId =rtId;
            burL.LoanName__c= 'SRIDEVI';
            burL.Source__c= 'Manual';
            burL.EMI__c= 12;
            burL.CloseDate__c= Date.newInstance(2023, 12, 9);
            burL.LoanAmount__c= 100000;
            burL.FinancierName__c= 'A.P. VARDHAMAN (MAHILA) CO-OP BANK LTD;HYDERABAD';
            burL.TenureLeft__c= 0;
            //burL.RecordType.name= 'Consumer Obligation';  
            burL.Treatment__c ='To continue - Obligate';
            burL.NoEMIPaid__c= 0;
            burL.CurrentOs__c= 20000;
            burL.LoanApplication__c=loanApp.Id;
            burL.Applicant__c=appLi.Id;
            insert burL;
            
            ApplAsset__c laAsset=new ApplAsset__c();
            laAsset.Resi_Age__c= 7;
            laAsset.PropSubType__c= 'DEL - COOPERATIVE SOCIETY';
            laAsset.Landmark__c= 'UJN';
            laAsset.Property_Carpet_area_Sq_Ft__c= 3000;
            laAsset.AddrLn1__c= 'TGV';
            laAsset.AddrLn2__c= 'TGB';
            laAsset.Approx_Age_of_Prop__c= 9;
            laAsset.Prop_Owners__c= 'Y';
            laAsset.Land_Area__c= 2500;
            laAsset.State__c= 'MAHARASHTRA';
            laAsset.FlatNo__c= 'YHG';
            laAsset.Is_it_an_APF__c= 'N';
            laAsset.PropType__c= 'RESIDENTIAL';
            laAsset.Builder_ID__c= 4321;
            laAsset.Pin_Code__c= '400074';
            laAsset.City__c= 'MUMBAI';
            laAsset.Property_Usage__c= 'SELF OCCUPIED';
            laAsset.PropSubTypeDesc__c= 'DELCS';
            laAsset.LoanAppln__c=loanApp.Id;
            laAsset.Prop_Owners__c= 'Y';
            //laAsset.Comments_on_Collateral__c='Test Comments';
            laAsset.Appl__c=appLi.Id;
            
            insert laAsset;
            
            /**************************APPLICANT DATA*********************************** */
            
            ApplKyc__c appKyc = new ApplKyc__c();
            appKyc.PassExpDt__c=  Date.newInstance(2029, 12, 9);
            appKyc.kycDoc__c= 'Passport';
            appKyc.Applicant__c= appLi.ID;
            insert appKyc;
            
            List<ApplAddr__c> listAdds= new List<ApplAddr__c>();
            ApplAddr__c appAddress =new ApplAddr__c();
            appAddress.Applicant__c= appLi.ID;
            appAddress.MailAddr__c= true;
            appAddress.Country__c= 'India';
            appAddress.OwnType__c= 'R';
            appAddress.AddrStability__c= null;             
            appAddress.AddrTyp__c= 'Office Address';
            appAddress.City__c= 'GANGANAGAR';
            appAddress.State__c= 'RAJASTHAN';
            appAddress.AddrLine1__c= 'UJM';
            appAddress.AddrLine2__c= 'IKM';
            appAddress.Landmark__c= 'NEAR JOTIBA MANDAIR';
            appAddress.Pincode__c= '335002';
            appAddress.Locality__c= 'GANGANAGAR';
            listAdds.add(appAddress);
            
            ApplAddr__c appAddress1 =new ApplAddr__c();
            appAddress1.Applicant__c= appLi.ID;
            appAddress1.MailAddr__c= true;
            appAddress1.Country__c= 'India';
            appAddress1.OwnType__c= 'R';
            appAddress1.AddrStability__c= null;             
            appAddress1.AddrTyp__c= 'Office Address';
            appAddress1.City__c= 'GANGANAGAR';
            appAddress1.State__c= 'RAJASTHAN';
            appAddress1.AddrLine1__c= 'UJM';
            appAddress1.AddrLine2__c= 'IKM';
            appAddress1.Landmark__c= 'NEAR JOTIBA MANDAIR';
            appAddress1.Pincode__c= '335002';
            appAddress1.Locality__c= 'GANGANAGAR';
            listAdds.add(appAddress1);
            insert listAdds;
            
            
            Employer__c empYer= new Employer__c();
            empYer.name='TATA CONSULTANCY SERVICES';
            insert empYer;
            
            Industry__c indObj = new Industry__c();
            indObj.name='HEALTHCARE';
            insert indObj;
            
            List<ApplicantEmployment__c> listEmp =new List<ApplicantEmployment__c>();
            ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
            
            appEmp.TypeOfOrganisation__c= 'MN';
            appEmp.DesignationValues__c= null;
            appEmp.WorkingWithCurrentEmployer_Years__c= 6;
            //appEmp.IndustryType__r.name=indObj.name;
            appEmp.EmployerName__c= empYer.Id;
            appEmp.TotalWorkExperience_Months__c= 0;
            appEmp.NatureOfBusinessIndividual__c= 'M';
            appEmp.NatureOfBusinessCorporate__c= 'S';
            appEmp.GST_Registered__c= 'Yes';
            appEmp.LoanApplicant__c=appLi3.ID;
            listEmp.add(appEmp);
            
            ApplicantEmployment__c appEmp1 = new ApplicantEmployment__c();
            
            appEmp1.TypeOfOrganisation__c= 'MN';
            appEmp1.DesignationValues__c= null;
            appEmp1.WorkingWithCurrentEmployer_Years__c= 6;
            appEmp1.EmployerName__c= empYer.Id;
            appEmp1.TotalWorkExperience_Months__c= 0;
            appEmp1.NatureOfBusinessIndividual__c= 'M';
            appEmp1.NatureOfBusinessCorporate__c= 'S';
            //appEmp1.GST_Registered__c= 'No';
            appEmp1.LoanApplicant__c=appLi1.ID;
            listEmp.add(appEmp1);
            
            ApplicantEmployment__c appEmp2 = new ApplicantEmployment__c();
            
            appEmp2.TypeOfOrganisation__c= 'MN';
            appEmp2.DesignationValues__c= null;
            appEmp2.WorkingWithCurrentEmployer_Years__c= 6;
            appEmp2.EmployerName__c= empYer.Id;
            appEmp2.TotalWorkExperience_Months__c= 0;
            appEmp2.NatureOfBusinessIndividual__c= 'M';
            appEmp2.NatureOfBusinessCorporate__c= 'S';
            appEmp1.GST_Registered__c= 'No';
            appEmp2.LoanApplicant__c=appLi.ID;
            listEmp.add(appEmp2);
            
            
            insert listEmp;
            
            //tbd
            Industry__c indu=new Industry__c();
            indu.IndustryID__c= '21';
            indu.Name= 'INFORMATION TECHNOLOGY';
            
            
            //EmployerName__r
            //'Name'= 'TATA CONSULTANCY SERVICES'
            
            ApplGST__c appGst =new ApplGST__c();
            appGst.GSTIN__c= '78965423';
            appGst.City__c='Pune';
            appGst.RegisteredAddress_GST__c= 'Near Durga Temple Pune';
            appGst.Main_GSTIN__c= true;
            appGst.Applicant__c= appLi.ID;
            insert appGst;
            
            ApplBanking__c appBank =new ApplBanking__c();
            appBank.AC_No__c= '6583467';
            appBank.AccountType__c= 'CC';
            appBank.Bank_Branch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
            appBank.BankName__c= 'STATE BANK OF INDIA';
            appBank.Bank_City__c= 'GREATER NOIDA';
            appBank.Bank_Code__c='007';

            appBank.Appl__c= appLi.ID;
            appBank.LoanAppl__c=loanApp.Id;
            insert appBank;
            


            Repayment_Account__c repayAcc=new Repayment_Account__c ();
            repayAcc.Is_Active__c =true;
            repayAcc.Loan_Application__c= loanApp.Id;
            repayAcc.Account_Number__c='4343201000507';
            repayAcc.MICR_Code__c='147002034';
            repayAcc.Bank_Branch__c='STATE BANK OF INDIA , PRAGATI BHAWAN, URBAN ESTAT';
            repayAcc.Bank_Name__c='SATE BANK OF PATIALA';
            repayAcc.IFSC_Code__c='NPCI0000001';
            repayAcc.Repayment_Mode__c='PDC';
            repayAcc.Applicant_Banking__c=appBank.Id;
            insert repayAcc;


            DocMstr__c  docmstr=new DocMstr__c ();

            List<DocDtl__c> listDocDtl=new List<DocDtl__c>();
            DocDtl__c appDocDtls =new DocDtl__c();
            appDocDtls.LAN__c= loanApp.Id;
            appDocDtls.OSV__c= true;
            appDocDtls.DocTyp__c= 'PAN';
            appDocDtls.Appl__c=appLi.ID;
            appDocDtls.DocStatus__c ='PDD';
			appDocDtls.DocSubTyp__c ='Photograph of Property Visited';
			appDocDtls.TargetDt__c=Date.newInstance(2024, 12, 9);
			appDocDtls.ReceivedDt__c=Date.newInstance(2025, 12, 9);
			
listDocDtl.add(appDocDtls);

DocDtl__c appDocDtls1 =new DocDtl__c();
            appDocDtls1.LAN__c= loanApp.Id;
            appDocDtls1.OSV__c= true;
            appDocDtls1.DocTyp__c= 'PAN';
            appDocDtls1.Appl__c=appLi.ID;
            appDocDtls1.DocStatus__c ='OTC';
			appDocDtls1.DocSubTyp__c ='Interest bearing Letter-Top up';
			appDocDtls1.TargetDt__c=Date.newInstance(2024, 12, 9);
			appDocDtls1.ReceivedDt__c=Date.newInstance(2025, 12, 9);
			
listDocDtl.add(appDocDtls1);

insert listDocDtl;	
            
            List<Applicant_Income__c> listAppInc=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc =new Applicant_Income__c();
            Id appIncId = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId(); 
            System.debug('Id appIncId:'+appIncId);
            appInc.Salary__c =100000;
            appInc.RecordtypeId=appIncId;   
            //appInc.RecordType.DeveloperName = 'CashSal';
            appInc.Applicant__c=appLi.ID;
            listAppInc.add(appInc);
            
            
            Applicant_Income__c appInc1 =new Applicant_Income__c ();
            //Id appIncId1 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();   
            appInc1.RecordtypeId=appIncId; 
            appInc1.Salary__c =100000;
            //appInc1.RecordType.DeveloperName = 'CashSal';
            appInc1.Applicant__c=appLi.ID;  
            listAppInc.add(appInc1);
            
            
            Applicant_Income__c appInc2 =new Applicant_Income__c ();
            //Id appIncId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();   
            appInc2.RecordtypeId=appIncId;
            //appInc2.RecordType.DeveloperName = 'CashSal';
            appinc2.Salary__c=100000 ;
            appInc2.Applicant__c=appLi.ID; 
            listAppInc.add(appInc2);
            
            //insert listAppInc;
            
            
            
            List<Applicant_Income__c> liBankCr =new List<Applicant_Income__c>();    
            Applicant_Income__c appIncCr =new Applicant_Income__c ();
            appIncCr.Net_Salary__c=5000;
            Id appIncIdCr = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Bank Credit Salary').getRecordTypeId(); 
            appIncCr.RecordtypeId=appIncIdCr;     
            
            appIncCr.Applicant__c=appLi.ID;
            liBankCr.add(appIncCr);
            listAppInc.addAll(liBankCr);   
            
            
            List<Applicant_Income__c> listAppInc1=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc3 =new Applicant_Income__c ();
            appInc3.Agricultural_Income_Year__c=2023;
            appInc3.Agricultural_Yearly_Income__c=40000;   
            Id appIncId3 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();   
            appInc3.RecordtypeId=appIncId3; 
            // appInc3.RecordType.DeveloperName = 'AgriIncome';
            appInc3.Applicant__c=appLi.ID;
            listAppInc1.add(appInc3);
            
            Applicant_Income__c appInc4 =new Applicant_Income__c ();
            appInc4.Agricultural_Income_Year__c=2023;
            appInc4.Agricultural_Yearly_Income__c=40000;
            //Id appIncId4 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();   
            appInc4.RecordtypeId=appIncId3;
            //appInc4.RecordType.DeveloperName = 'AgriIncome';
            appInc4.Applicant__c=appLi.ID;
            listAppInc1.add(appInc4);
            
            listAppInc.addAll(listAppInc1);
            //insert listAppInc1;
            
            
            List<Applicant_Income__c> listAppInc2=new List<Applicant_Income__c>();
            Applicant_Income__c appInc12 =new Applicant_Income__c ();
            appInc12.Month3_Rental_Credited_Amount__c=2023;
            appInc12.Month2_Rental_Credited_Amount__c=40000;
            appInc12.Month1_Rental_Credited_Amount__c=5000;
            //appInc12.RecordType.DeveloperName = 'Rental_woBanking';
            Id appIncId12 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental woBanking').getRecordTypeId();   
            appInc12.RecordtypeId=appIncId12;
            appInc12.Applicant__c=appLi.ID;
            listAppInc2.add(appInc12);
            
            
            
            Applicant_Income__c appInc5 =new Applicant_Income__c ();
            appInc5.Month3_Rental_Credited_Amount__c=2023;
            appInc5.Month2_Rental_Credited_Amount__c=40000;
            appInc5.Month1_Rental_Credited_Amount__c=5000;
            // appInc5.RecordType.DeveloperName = 'Rental_woBanking';
            //Id appIncId5 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental woBanking').getRecordTypeId();   
            appInc5.RecordtypeId=appIncId12;
            appInc5.Applicant__c=appLi.ID;
            listAppInc2.add(appInc5);
            
            //insert listAppInc2;
            listAppInc.addAll(listAppInc2);
            
            List<Applicant_Income__c> listAppInc3=new List<Applicant_Income__c>();
            Applicant_Income__c appInc6 =new Applicant_Income__c ();
            appInc6.Net_Salary__c=7000 ;
            appInc6.Month1_Rental_Credited_Amount__c=11000;
            appInc6.Month2_Rental_Credited_Amount__c=11000;
            appInc6.Month3_Rental_Credited_Amount__c=11000;    
            //appInc6.RecordType.DeveloperName = 'RentalwBank';
            Id appIncId6 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc6.RecordtypeId=appIncId6; 
            appInc6.Applicant__c=appLi.ID;
            listAppInc3.add(appInc6);
            
            
            
            Applicant_Income__c appInc7 =new Applicant_Income__c ();
            appInc7.Net_Salary__c=7000 ;
            appInc7.Month1_Rental_Credited_Amount__c=11000;
            appInc7.Month2_Rental_Credited_Amount__c=11000;
            appInc7.Month3_Rental_Credited_Amount__c=11000;     
            //Id appIncId7 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc7.RecordtypeId=appIncId6; 
            //appInc7.RecordType.DeveloperName = 'RentalwBank';
            appInc7.Applicant__c=appLi.ID;        
            listAppInc3.add(appInc7);
            
            Applicant_Income__c appInc8 =new Applicant_Income__c ();
            appInc8.Net_Salary__c=7000 ;
            //Id appIncId8 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc8.RecordtypeId=appIncId6;
            appInc8.Month1_Rental_Credited_Amount__c=12000;
            appInc8.Month2_Rental_Credited_Amount__c=12000;
            appInc8.Month3_Rental_Credited_Amount__c=14000;
            //appInc8.RecordType.DeveloperName = 'RentalwBank';
            appInc8.Applicant__c=appLi.ID;
            listAppInc3.add(appInc8);
            
            listAppInc.addAll(listAppInc3);
            
            List<Applicant_Income__c> listAppInc4=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc9 =new Applicant_Income__c ();
            appInc9.Monthly_Pension_Credited__c=9000 ;
            Id appIncId9 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc9.RecordtypeId=appIncId9;
            //appInc9.RecordType.DeveloperName = 'Pension';
            appInc9.Applicant__c=appLi.ID;
            listAppInc4.add(appInc9);
            
            Applicant_Income__c appInc10 =new Applicant_Income__c ();
            appInc10.Monthly_Pension_Credited__c=9000;
            // Id appIncId10 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc10.RecordtypeId=appIncId9;
            //appInc10.RecordType.DeveloperName = 'Pension';
            appInc10.Applicant__c=appLi.ID;        
            listAppInc4.add(appInc10);
            
            Applicant_Income__c appInc11 =new Applicant_Income__c ();
            appInc11.Monthly_Pension_Credited__c=9000;
            //Id appIncId11 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc11.RecordtypeId=appIncId9;
            //appInc10.RecordType.DeveloperName = 'Pension';
            appInc11.Applicant__c=appLi.ID;           
            listAppInc4.add(appInc11);
            
            
            listAppInc.addAll(listAppInc4);
            
            insert listAppInc;
            
            IntgMsg__c intgMsg1 = new IntgMsg__c();
            intgMsg1.Name='Loan Boarding';
            intgMsg1.BU__c='HL / STL';
            intgMsg1.Status__c='New';
            intgMsg1.MStatus__c='Blank';
            intgMsg1.RefObj__c='LoanAppl__c';
            intgMsg1.RefId__c = loanApp.Id;
            intgMsg1.Resp__c='';
            intgMsg1.Svc__c='Loan Boarding';
            //insert new List<IntgMsg__c>{intgMsg1};
            insert     intgMsg1;
            TriggerBase.clearBypass('LoanAppl__c');
            TriggerBase.clearBypass('Applicant__c');
            
            
            String JsonString = '{"userId":"finn1lb","unqRequestId":"L0000002879#IM0000020415","tradeInDetail":[{"yearPurchased":"","vin":"","valuation2":"","valuation1":"","tradeInInsured":"","subModel":"","registrationNo":"","natureOfOwnerShip":"","model":"","mileageKmHr":"","hypothecationLien":"","finalValuation":"","comments":"","assetType":""}],"teleVerification":[],"splitDisbursalDetails":[{"splitRemarks":"OK","splitCreditPeriod":"0","splitAmount":"700000.00","splitAccountNo":"123456041","splitAccNo":"123456041","principalStartDate":"7-Apr-2024","principalRecoveryOn":"S","paymentMode":"F","payableAt":"12","micrCode":"","inFavourOf":"A STORES NAGARAJU","ifscCode":"UTIB0000723","ftMode":"NT","effectiveDate":"22-Feb-2024","effectIRR":"","disbursementTo":"","disbursalDate":"22-Feb-2024","disbTo":"LS","chequeNo":"000000","chequeDate":"20-Feb-2024","cashBankAccount":"332","bpName":"LS"}],"sourcingDetail":{"tenureInMonths":"100","strength":"","specialConditionFor":"","sourcingBranch":"MUM","sourceState":"","sourceCode":"","schemeCurr":"","scheme":"542","resaonComments":"","relationshipManager":"","referralName":"","referralGroup":"","referralCode":"","reasonSpecialCondition":"","reasonDescription":"","promotionCurr":"","promotion":"","product":"HL","priority":"","loanPurposeDesc":"","loanPurpose":"27","loanAmount":"800100.00","finnoneUser":"3407","finnoneStage":"FINISH","existingCustomerName":"","dsa":"21","dme":"7682","dateOfReceipt":"16-Feb-2024","dateOfDisbursal":"","dateEncoded":"16-Feb-2024","custProfileType":"P","custProfile":"","crmExistingLan":"","channelCode":"001","branchId":"5","branchCode":"","bankBranch":"","applicationID":"589612","applicationFormNo":"589612","accountOfficerCode":"","accountOfficeName":""},"sourceSystem":"SFDC","repaymentDetails":[],"referenceDetails":[{"refZipCode":"","refTitle":"Mr","refSalutation":"a","refPhoneAreaCode":"","refPhone2":"","refPhone1":"8698651294","refOfficeExtNo":"","refMobile":"8698651294","refereeRelation":"F","refereeName":"a","refEmailId":"","refCity":"","refAddressLine5":"","refAddressLine4":"","refAddressLine3":"","refAddressLine2":"","refaddressLine1":"a"},{"refZipCode":"","refTitle":"Mrs","refSalutation":"Aa","refPhoneAreaCode":"","refPhone2":"","refPhone1":"8698651294","refOfficeExtNo":"","refMobile":"8698651294","refereeRelation":"C","refereeName":"Aa","refEmailId":"","refCity":"","refAddressLine5":"","refAddressLine4":"","refAddressLine3":"","refAddressLine2":"","refaddressLine1":"Qq"}],"rateRiskDetails":[{"lessorName":"","contributionRate":"","contributionAmt":"","consortiumType":"","commissionRate":"","bpType":""}],"propertyDetails":[{"wingName":"","verifyBy":"","typeofPurchase":"RESIDENTIAL","tranchDetails":[],"totalAmountFinanced":"800100.00","tobeRegisteredWithName":"","titleClearFlag":"","technicalVerification":"","TCTCCTNo":"","soleOwnerFlag":"","sellingPriceFairMarketValue":"","sellerPhoneNo":"","sellerName":"","sellerAddressTwo":"","sellerAddressOne":"","residualAgeOfProperty":"8","rentFlag":"","propValuationType":"","propTypeNew":"","propType":"","propState":"5","propPinCode":"400001","propertyValue":"84700000.00","propertyUsage":"","propertyInsurance":"","propertyHeldIn":"","propertyDesc":"MM","propertyCostFinanced":"800100.00","propertyAddressLine2":"HANUMAN CHAWL","propertyAddressLine1":"HANUMAN CHAWL","propCountry":"1","propCity":"12","propAddress3":"","propAddress2":"HANUMAN CHAWL","propAddress1":"HANUMAN CHAWL","projectName":"","presentRegisteredOwner":"A NAGARAJU","personalInsurance":"","nearestLandmark":"","mortageDetails":[{"totalCollateralValue":"","loanOutstanding":"","loanNumber":"","lienNumber":""}],"lotNo":"","lienDetails":[],"insuranceInsuredFlag":"","guaranteeTenure":"","guaranteeInFavour":"","guaranteeFlag":"","guaranteeEndDate":"","guaranteeAmount":"","fundsDetail":[],"developerBuilder":"","contractor":"","constructionPurchase":[],"collateralUsage":"","collateralGradeClassification":"","buildingName":"","builderClassificationType":"","blockNo":"","areasSqm":"2000.00","areaForPlot":"2000.00","areaForImprovements":"","areaForImprovement":"","architect":"","approved":"No","appraiser2Date":"","appraiser2":"","appraiser1Date":"","appraiser1":"","appraisedPropertyValue":"84700000.00","appraisalValue2":"","appraisalValue1":"","ageOfProperty":"8","additionalProperties":{}}],"personalDiscussion":[{"verificationMatch":"","timeFrame":"","staffStrength":"50","shareHoldingPattern":"","resiDetails":"","propertyDetails":"","placeOfMeeting":"","pfiRemark":"","pfiDoneBy":"","pfiDone":"","personContacted":"Tushar Musale UW","offDetails":"","natureOfFinancialTransaction":"","nameOfInterviewer":"Tushar Musale UW","majorVariationsInFinancial":"","mainSuppliers":"","mainProducts":"","mainClients":"","levelOfActivity":"","interviewerDecision":"Completed","interviewerComments":"","grossMonthlyPayable":"","grossMonthlyIncome":"","futureGrowthPlan":"","foir":"","empNo":"","empDetailNatureofBusi":"","emiComfortableWith":"","detailOfEndUseOfFunds":"","designation":"","decisionDate":"20-Feb-2024","dateOfMeeting":"20-Feb-2024","customerProfile":"","currentObligationDetails":"","crossSellRemarks":"","crossSell":"","clientMarketRef":"","bankingHabit":"","assetOwned":"","anyOthBusi":"","anyMisleadingInformation":"","analysisOfFinancials":"","aggregateExposure":"","additionalDocumentCollected":""}],"password":"qWI2wzG7ofqhTR1gsHM6Qw==","notepadDetails":[{"noteUser":"","noteReferenceDate":"20-Feb-2024","noteDetails":"A STORES NAGARAJU: a","noteDate":"20-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"AA-02732: OK","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Additional Remarks :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Personal/Family Details of Promoters : JN","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Income Related Comments :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Brief of Buisness Details of Applicant and Coapplicant :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"}],"loanDetails":{"tdsRate":"0","subventionPercentage":"","spreadID":"","reqInterestType":"E","repayFrequency":"M","rateTypeFloatingFlag":"Y","rateEMIFlag":"R","principalBaseUnit":"1","pemiType":"R","numberOfInstallments":"100","noOfDisbursal":"1","loanRest":"","loanPLRType":"PLR_HL","loanPLRRate":"20.50","loanEMI":"","ioiApplicable":"","interestTaxRate":"","interestTax":"","interestStartDate":"22-Feb-2024","interestRoundPrecision":"","interestRoundOff":"","interestRoundMethod":"","interestInAdvance":"","installmentRoundPrecision":"","installmentPlan":"E","installmentMode":"R","impactOnTenure":"Y","gracePeriod":"3","graceApplicableFlag":"N","floatingFrequency":"0","flatRate":"","fixedFor":"0","fisrtEmiDueMonth":"4","fisrtEmiDate":"7-Apr-2024","firstEmiDueYear":"2024","eirRate":"","effectiveRate":"14.75","dueDay":"07","downPaymentRate":"","downpayment":"","disburseTo":"LS","disbType":"MULTIPLE","disbAmount":"712640.00","depositAccount":"","chargeInterest":"Y","channelDSASubvention":"","capitalizeInterest":"N","businessIRR":"","assetCost":"84700000","advInstallment":"","addOnRate":"","addInterestSchedule":"N"},"jsonVersion":"LB-PL-NEv1.0","insuranceDetails":{"totalInsPremium":"","tctCCTNo":"","remarksOnCoverage":"","propDesc":"","premiumRemarks":"","others":"","noOfCollaterals":"","mortgagee":"","mailingAddress":"","locationOfRisk":"0","insuranceRequired":"","insurancePolicyType":"","insStartDate":"","insPremYr2":"","insPremYr1":"","insPolNumber":"PP000280","insEndDate":"","insCoverageType":"","insCompName":"","buildingDesc":"","boundariesright":"","boundariesRear":"","boundariesLeft":"","boundariesFront":"","appraisedValue":"100","amtInsuredStocks":"","amtInsuredOff":"","amtInsuredContents":"","amtInsuredBuilding":"","amtInsured":"","amtInsImp":""},"instrumentDetails":{"pdcByName":"A STORES NAGARAJU","pdcBy":"A","micrFlag":"","micrCode":"110211063","instrumentType":"Z","instrumentCity":"","instrumentBankBranch":"211","instrumentBank":"211","ifscCode":"","employeeCode":"","downloadToPDCMS":"N","destBankAccType":"10","destAccHolder":"A STORES NAGARAJU","customerAccNo":"123456041"},"initialMoneyDepositDetails":[{"imdUTRNo":"","imdTranDae":"","imdTdsByCustomer":"","imdStatus":"","imdSolId":"","imdReceiptNo":"","imdReason":"","imdPaymentMode":"","imdPaidOn":"","imdMicrCode":"","imdInFavourOf":"","imdIncomeTaxIdType":"","imdIncomeTaxIdNo":"","imdHostAccNo":"","imdHoldUnhold":"","imdHoldAccountNo":"","imdHoldAccount":"","imdHoldAccBankName":"","imdHoldAccBankBranch":"","imdFTMode":"","imdDrawnOn":"","imdDepositSlipType":"","imdDepositSlipNo":"","imdDepositSlipAmt":"","imdDealingBank":"","imdCustomerId":"","imdCurrency":"","imdCMSNumeric":"","imdCmsCode":"","imdCity":"MIRZAPUR","imdChqNo":"","imdChequeId":"","imdChequeDate":"","imdBankBranch":"","imdAmount":"4000","imdAccNo":"","ifscCode":""}],"gSTInfoDetails":{"gstState":"","gstReqd":"N","gstPinCode":"","gstNumber":"","gstCustomerType":"","gstCustomerName":"","gstCountry":"","gstCity":"","gstApplicantType":"","gstAddressLine3":"","gstAddressLine2":"","gstAddressLine1":"","gstAddress":""},"gradedRepaymentDetails":[{"slabSequence":"","slabRecoveryPtg":"","slabInstlTo":"","slabInstlFrom":"","slabEmi":""}],"fivCheckList":[{"quesNumber":"","quesDesc":"","answer":""}],"crossCollateral":[{"doneOn":"","crossCustomerName":"","applicationId":"","agreementType":""}],"confirmationLog":{"remarks":"","remark":"","relationship":"","positive":"","position":"","phoneUsed":"","negative":"","nameOfInformant":"","nameOfAgency":"","citizenship":"17","callStatus":"","callLogCounter":"","applicantName":"A STORES NAGARAJU","age":""},"collateralDetails":[],"chargesDetails":[{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"35","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"16522.00"},{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"600168","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"118.00"},{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"68","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"12640.00"}],"bussinessVerification":{"warehouseLoaction":"","warehouse":"","signatoryName":"","signatoryJobTitle":"","salesFigure":"","rentMortAmt":"","remarks":"","registeredName":"","registered":"","productsBrandsCarried":"","positive":"","phoneExt":"","percentOwnership":"","othPropOwned":"","operatingExpenses":"","noOfRegularEmp":"","noOfCustomerDay":"","negative":"","natureOfBusi":"","managementPosition":"","managementName":"","managementAge":"","location":"","lengthOfBusinessExis":"","creditReferencesName":"","creditReferencesAddress":"","creditReferencePhone":"","citizenship":"","busiType":"","businessPremisesOwner":"","businessPhone":"","businessName":"","businessAddress":"","branches":"","applicantName":"","age":""},"applicantDetails":[{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"PF","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"1","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"7","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"","uidToken":"","turnOver":"","topUpAmount":"","title":"MR.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"","selectPassportCountry":"","salutation":"A STORES NAGARAJU","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"ASSPG3151E","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"VBH","motherMaidenName":"VBH","minor":"","middleName":"STORES","maritalStatus":"S","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"NAGARAJU","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"129","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"M","fwCustomerId":"","fwAccountNo":"","fullName":"A STORES NAGARAJU","firstName":"A","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"PP","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"ENG","dsa":"21","drivingLicenseNo":"TS30520200003202","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"1-Jun-1983","custSegment":"9","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"100","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[{"finNoOfYearsHeld":"","finNoOfOutwardChqReturns":"0","finNoOfInwardChqReturns":"0","finBankStmtCollected":"","finBankRemarks":"","finBankName":"211","finBankMinBalance":"","finBankMaxBalance":"","finBankBranch":"AXIS BANK","finBankAvgBalance":"","finBankAccType":"SAVINGS","finBankAccountNo":"123456041"}],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"P","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"40","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"PERMNENT","addressLine3":"","addressLine2":"HANUMAN CHAWL","addressLine1":"HANUMAN CHAWL"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"OFFICE","addressLine3":"","addressLine2":"ROOM NO 28 HANUMAN CHAWL","addressLine1":"ROOM NO 28 HANUMAN CHAWL"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"Y","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"CURRES","addressLine3":"","addressLine2":"HANUMAN CHAWL","addressLine1":"HANUMAN CHAWL"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""},{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"","uidToken":"","turnOver":"","topUpAmount":"","title":"MRS.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"","selectPassportCountry":"","salutation":"A P NAGARAJU","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"DZXPK8172E","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"GANESHA","motherMaidenName":"GANESHA","minor":"","middleName":"P","maritalStatus":"S","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"NAGARAJU","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"F","fwCustomerId":"","fwAccountNo":"","fullName":"A P NAGARAJU","firstName":"A","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"RAVEENDRANATH TAGORE TUMMALA","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"GRAD","dsa":"21","drivingLicenseNo":"TS30520200003202","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"1-Jun-1983","custSegment":"10","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"0","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"G","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"40","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"424001","phone2":"","phone1":"","mobile":"9723509420","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"1857","areaCode":"1857","addressType":"CURRES","addressLine3":"","addressLine2":"DHULE","addressLine1":"DHULE"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"424001","phone2":"","phone1":"","mobile":"9723509420","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"1857","areaCode":"1857","addressType":"PERMNENT","addressLine3":"","addressLine2":"DHULE","addressLine1":"DHULE"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""},{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"12961886","uidToken":"","turnOver":"","topUpAmount":"","title":"MRS.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"ASAS","selectPassportCountry":"","salutation":"KAMLESHKUMAR JP RAJPUT","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"AMXPA4540L","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"ADAD","motherMaidenName":"ADAD","minor":"","middleName":"JP","maritalStatus":"M","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"RAJPUT","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"F","fwCustomerId":"","fwAccountNo":"","fullName":"KAMLESHKUMAR JP RAJPUT","firstName":"KAMLESHKUMAR","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"ENG","dsa":"21","drivingLicenseNo":"","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"11-Dec-1992","custSegment":"10","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"0","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"C","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"31","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400003","phone2":"","phone1":"","mobile":"9096856670","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"CURRES","addressLine3":"A","addressLine2":"A","addressLine1":"A"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"400003","phone2":"","phone1":"","mobile":"9096856670","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"PERMNENT","addressLine3":"A","addressLine2":"A","addressLine1":"A"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""}]}';
            LoanBoardingRequestWrapper.parse(JsonString);
            
            List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1};
                LoanBoardingRequestGenerator generator = new LoanBoardingRequestGenerator();
            generator.generate(msgs, 'Loan Boarding', 'Async');
            loanApp =[Select Id,name,BrchName__c from LoanAppl__c where Id =: loanApp.ID];//.BrchName__c='MUMBAI';
            System.assertEquals('MUMBAI',loanApp.BrchName__c);
            System.assertEquals(1, [SELECT COUNT() FROM LoanAppl__c WHERE Id = :loanApp.Id]);
            Test.stopTest();
            
        }
    }    
    
    
     @isTest
    public static void testGenerateMethod1() {
        Test.startTest();
        
        User us = TestDataFactory.UserData(true);
        
        System.runas(us){    
            //List<LoanAppl__c> loanApps =  new List<LoanAppl__c>();
            //LoanBoardingRequestGeneratorTest.testCalculateIMD1();
            TriggerBase.bypass('LoanAppl__c');
            TriggerBase.bypass('Applicant__c');
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            //LoanAppl__c.Total_PF_Amount__c ='18526';
            loanApp.BrchName__c='MUMBAI';
            loanApp.RemPFDeductFromDisbursementAmount__c='Yes';
            loanApp.FinnoneAppid__c='587653';
            loanApp.FirstEMIDueMonth__c='February';
            //loanApp.RMSMEmployeeID__c='RM12345';
            loanApp.LoanPurpose__c='Balance Transfer';
            loanApp.BrchCode__c='MUM';
            loanApp.Product__c='Small Ticket LAP';
            loanApp.SchmCode__c='HL - SELLER BT';
            loanApp.LeadSource__c='Direct';
            loanApp.ReqLoanAmt__c=500005;
            loanApp.LoanPLRType__c='PLR_HL';
            loanApp.Repayment_Frequency__c='M';
            loanApp.LoanPLRRate__c=20.5;
            loanApp.Rate_Type_Floating_Flag__c='Y';
            loanApp.EffectiveROI__c=5;
            loanApp.MoratGraceApplicable__c='N';
            loanApp.DisbursalType__c='Multiple';
            loanApp.DueDay__c='7';	
            //loanApp.FirstEMIDate__c='2023-02-07T01:55:43.000+0000';
            loanApp.Installment_Plan__c='E';
            loanApp.FirstEMIDueYear__c='2023';
            loanApp.Loan_Tenure_Months__c=180;
            loanApp.RMSMName__c = us.ID;
            //loanApps.add(loanApp);
            update loanApp;
            
            
            List<Applicant__c> listAppl=new List<Applicant__c>(); 
            Applicant__c appLi =new Applicant__c();
            appLi.Constitution__c= 'INDIVIDUAL';
            appLi.MobNumber__c= '8896944363';
            appLi.LName__c= 'Sample';
            appLi.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi.FName__c= 'Testing';
            appLi.Age__c= 32;
            appLi.MName__c= 'M';
            appLi.Gender__c= 'F';
            appLi.PassNo__c= 'S9265723';
            appLi.PAN__c= 'AZBPS1592F';
            appLi.KeyManName__c= 'Anu B';
            appLi.MariStatus__c= 'M';
            appLi.SpName__c= 'Abcd Sample';
            appLi.MthrMdnName__c= 'V';
            appLi.YearOfRegistration__c= null;
            appLi.DLNo__c= 'GJ0120090974832';
            appLi.VotIdEpicNo__c= null;
            appLi.EduQual__c= 'GRAD';
            appLi.CompanyName__c= null;
            appLi.Relationship__c= 'Business Associate';
            appLi.Nationality__c= 'INDIA';
            appLi.CustProfile__c= 'HOUSEWIFE';
            appLi.Title__c= 'Mr.';
            appLi.UCID__c= '12362638';
            appLi.DOI__c=   Date.newInstance(2000, 12, 9);
            appLi.ApplType__c= 'P';
            appLi.Religion__c= 'HINDU';
            appLi.Father_Name__c= 'Test FName';
            appLi.EmailId__c= 'abcd@gmail.com';
            appLi.Category__c= 'O';
            System.debug('loanApp.Id+'+loanApp.Id);
            appLi.LoanAppln__c=loanApp.Id;
            appLi.UCID__c='12345';
            appLi.MName__c='TestM';
            appLi.KeyManName__c='KeyMan';
            //insert appLi;
            listAppl.add(appLi);
            
            Applicant__c appLi1 =new Applicant__c();
            appLi1.Constitution__c= 'INDIVIDUAL';
            appLi1.MobNumber__c= '8896944363';
            appLi1.LName__c= 'Abcd';
            appLi1.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi1.FName__c= 'AppTwo';
            //appLi1.TabName__c= 'TEST USER';
            appLi1.Age__c= 24;
            appLi1.MName__c= 'M';
            appLi1.Gender__c= 'M';
            appLi1.PassNo__c= 'S9265723';
            appLi1.PAN__c= 'AZBPS1592F';
            appLi1.KeyManName__c= 'Anu B';
            appLi1.MariStatus__c= 'M';
            appLi1.SpName__c= 'Abcd Person';
            appLi1.MthrMdnName__c= 'V';
            appLi1.YearOfRegistration__c= null;
            appLi1.DLNo__c= 'GJ0120090974832';
            appLi1.VotIdEpicNo__c= null;
            appLi1.EduQual__c= 'GRAD';
            appLi1.CompanyName__c= null;
            appLi1.Relationship__c= 'Business Associate';
            appLi1.Nationality__c= 'INDIA';
            appLi1.CustProfile__c= 'HOUSEWIFE';
            appLi1.Title__c= 'Mr.';
            appLi1.UCID__c= '12362638';
            appLi1.DOI__c=   Date.newInstance(2001, 12, 9);
            appLi1.ApplType__c= 'C';
            appLi1.Religion__c= 'HINDU';
            appLi1.Father_Name__c= 'Test Data';
            appLi1.EmailId__c= 'abcd@gmail.com';
            appLi1.Category__c= 'O';
            appLi1.LoanAppln__c=loanApp.Id;
            appLi1.UCID__c='12345';
            appLi1.MName__c='TestM';
            appLi1.KeyManName__c='KeyMan';
            listAppl.add(appLi1);
            
            Applicant__c appLi2 =new Applicant__c();
            appLi2.Constitution__c= 'INDIVIDUAL';
            appLi2.MobNumber__c= '8896944363';
            appLi2.LName__c= 'Testing App';
            appLi2.DOB__c=  Date.newInstance(1980, 12, 9);
            appLi2.FName__c= 'App test';
            appLi2.Age__c= 24;
            //appLi2.TabName__c= 'TESTOne USER';
            appLi2.MName__c= 'M';
            appLi2.Gender__c= 'M';
            appLi2.PassNo__c= 'S9265723';
            appLi2.PAN__c= 'AZBPS1592Z';
            appLi2.KeyManName__c= 'Anu B';
            appLi2.MariStatus__c= 'M';
            appLi2.SpName__c= 'Hello Person';
            appLi2.MthrMdnName__c= 'V';
            appLi2.YearOfRegistration__c= null;
            appLi2.DLNo__c= 'GJ0120090974832';
            appLi2.VotIdEpicNo__c= null;
            appLi2.EduQual__c= 'GRAD';
            appLi2.CompanyName__c= null;
            appLi2.Relationship__c= 'Business Associate';
            appLi2.Nationality__c= 'INDIA';
            appLi2.CustProfile__c= 'HOUSEWIFE';
            appLi2.Title__c= 'Mr.';
            appLi2.UCID__c= '12362638';
            appLi2.DOI__c=   Date.newInstance(2002, 12, 9);
            appLi2.ApplType__c= 'C';
            appLi2.Religion__c= 'HINDU';
            appLi2.Father_Name__c= 'Test Data';
            appLi2.EmailId__c= 'abcd@gmail.com';
            appLi2.Category__c= 'O';
            appLi2.LoanAppln__c=loanApp.Id;
            appLi2.UCID__c='87645';
            appLi2.MName__c='Test Hey';
            appLi2.KeyManName__c='KeyMan';
            listAppl.add(appLi2);
            
            Applicant__c appLi3 =new Applicant__c();
            appLi3.Constitution__c= 'INDIVIDUAL';
            appLi3.MobNumber__c= '8896333363';
            appLi3.LName__c= 'Testing App';
            appLi3.DOB__c=  Date.newInstance(1981, 12, 9);
            appLi3.FName__c= 'App testing';
            appLi3.Age__c= 24;
            appLi3.MName__c= 'M';
            appLi3.Gender__c= 'M';
            //appLi2.TabName__c= 'TESTTwo USER';
            appLi3.PassNo__c= 'S9265723';
            appLi3.PAN__c= 'AZBPS1592F';
            appLi3.KeyManName__c= 'Ankur B';
            appLi3.MariStatus__c= 'M';
            appLi3.SpName__c= 'Hello Person';
            appLi3.MthrMdnName__c= 'V';
            appLi3.YearOfRegistration__c= null;
            appLi3.DLNo__c= 'GJ0120090974832';
            appLi3.VotIdEpicNo__c= null;
            appLi3.EduQual__c= 'GRAD';
            appLi3.CompanyName__c= null;
            appLi3.Relationship__c= 'Business Associate';
            appLi3.Nationality__c= 'INDIA';
            appLi3.CustProfile__c= 'HOUSEWIFE';
            appLi3.Title__c= 'Mr.';
            appLi3.UCID__c= '12362630';
            appLi3.DOI__c=   Date.newInstance(2002, 12, 9);
            appLi3.ApplType__c= 'C';
            appLi3.Religion__c= 'HINDU';
            appLi3.Father_Name__c= 'Test Data';
            appLi3.EmailId__c= 'abcd@gmail.com';
            appLi3.Category__c= 'O';
            appLi3.LoanAppln__c=loanApp.Id;
            appLi3.UCID__c='87645';
            appLi3.MName__c='Test Hey';
            appLi3.KeyManName__c='KeyMan';
            listAppl.add(appLi3);
            
            insert listAppl;
            
            
            //List<PD__c> liPerD =new List<PD__c>();
            /*PD__c perD =new PD__c();
            perD.CmpltDt__c=Date.newInstance(2024, 12, 9);
            //perD.AsgnTo__r.Name=us.Name;
            //perD.Appl__r.TabName__c=appLi.TabName__c;
            perD.Accompanying_By__c=us.Id;
            perD.AsgnTo__c=us.Id;
            perD.CmpltBy__c=us.Id;
            perD.SchDate__c=Date.newInstance(2023, 12, 9);
            perD.PDStatus__c='Completed';
            perD.IsCompleted__c=true;
            perD.Appl__c=appLi.Id;
            perD.LoanAppl__c=loanApp.id;
            
            liPerD.add(perD);
            
             PD__c perD1 =new PD__c();
            perD1.CmpltDt__c=Date.newInstance(2024, 12, 9);
            //perD.AsgnTo__r.Name=us.Name;
            //perD.Appl__r.TabName__c=appLi.TabName__c;
            perD1.Accompanying_By__c=us.Id;
            perD1.AsgnTo__c=us.Id;
            perD1.CmpltBy__c=us.Id;
            perD1.SchDate__c=Date.newInstance(2023, 12, 9);
            perD1.PDStatus__c='Completed';
            perD1.IsCompleted__c=true;
            perD1.Appl__c=appLi.Id;
            perD1.LoanAppl__c=loanApp.id;
            
            liPerD.add(perD1);
            
            insert liPerD;
            
            List<PDResp__c> liPerDisRes =new List<PDResp__c>();
            PDResp__c pdres =new PDResp__c();
            //pdres.done__c =true;
            pdres.Ques__c='Name of person with whom PD was conducted';
            pdres.Resp__c='Negative';
            pdres.PrsnlDisc__c=perD.Id;
            liPerDisRes.add(pdres);
            
            PDResp__c pdres1 =new PDResp__c();
            //pdres.done__c =true;
            pdres1.Ques__c='PD Closure Date';
            pdres1.Resp__c='Negative';
            pdres1.PrsnlDisc__c=perD1.Id;
            liPerDisRes.add(pdres1);
            
            insert liPerDisRes;
            */
            Disbursement__c disbObj =new Disbursement__c();
            disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
            disbObj.No_of_Disbur__c=1;
            disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
            disbObj.Princ_Rec_on__c='Amount Financed';
            disbObj.Loan_Appli__c= loanApp.id;
            disbObj.Disbur_No__c=1;            
            insert disbObj; 
            
            
            Split_Disbur__c spDisObj =new Split_Disbur__c();
            spDisObj.Disbur_To__c='Customer';
            spDisObj.DisburseRela__c=   disbObj.Id;         
            
            spDisObj.Effec_Date__c = Date.newInstance(2024, 1, 9);
            spDisObj.IFSC_Detail__c = 'ABCFDERT';
            spDisObj.Split_Cheque_Amt__c = 10000;
            spDisObj.Fedbank_Acc_No__c = '123456765433';
            spDisObj.Custo_Name__c = 'Abcd Test';
            spDisObj.Cheq_Favor_Acc_No__c = '123432456788';
            spDisObj.Remarks__c = 'test remarks';
            spDisObj.Cheq_DD_Date__c = Date.newInstance(2024, 1, 9);
            spDisObj.Cheq_Favor_Dets__c = 'DD';
            spDisObj.Payable_At__c = 'PUNE';
            spDisObj.Fund_Transf_Mode__c = 'IMPS';
            spDisObj.Pay_Mode__c = 'Cheque';
            spDisObj.Date_of_Disbur__c = Date.newInstance(2024, 1, 9);
            spDisObj.Cheq_DD_No__c = '234234432890';
            spDisObj.Fedbank_Acc_Nm__c = '234234432890';
            insert spDisObj;
            
            BRE__c breRes =new BRE__c();
            breRes.Name='SampleBreRes';
            breRes.LoanAppl__c=loanApp.Id;
            insert breRes;
            
            Insurance__c ins =new Insurance__c();
            ins.SumAmount__c=5000000;
            ins.PremiumAmount__c=54000;
            ins.LoanAppln__c=loanApp.Id;
            insert ins;
            
            MasterData__c mstrData=new MasterData__c();
            mstrData.Name= 'HDFC Life Insurance';
            mstrData.MPno__c= 'PP000280';
            insert mstrData;
            
            List<LonaApplCharges__c> listLoanAppChrg=new List<LonaApplCharges__c>();
            LonaApplCharges__c lAppChrgs = new LonaApplCharges__c();
            lAppChrgs.Amount__c= 18408;
            lAppChrgs.ChargeCodeID__c= '35';
            lAppChrgs.ChargeCodeDesc__c= 'AMT FINANCED';
            lAppChrgs.LoanApplication__c=loanApp.Id;
            listLoanAppChrg.add(lAppChrgs);
            
            LonaApplCharges__c lAppChrgs1 = new LonaApplCharges__c();
            lAppChrgs1.Amount__c= 18408;
            lAppChrgs1.ChargeCodeID__c= '68';
            lAppChrgs1.ChargeCodeDesc__c= 'AMT FINANCED';
            lAppChrgs1.LoanApplication__c=loanApp.Id;
            listLoanAppChrg.add(lAppChrgs1);
            
            insert listLoanAppChrg;
            
            ApplIMD__c appImd =new ApplIMD__c();
            appImd.City__c= 'GREATER NOIDA';
            appImd.PaymentMode__c= 'DD';
            appImd.MICRCode__c= '100002532';
            appImd.BankBrch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
            appImd.BankAccountNo__c= '7656465';
            appImd.IMDAmt__c= 2950;
            appImd.LoanAppln__c=loanApp.Id;
            insert appImd;
            
            
            List<Ref__c> listOfAllRef=new List<Ref__c>();
            
            Ref__c refObj=new Ref__c();
            refObj.RelationshipWthApp__c= 'B';
            refObj.FName__c= 'Test1';
            refObj.Add__c= 'Andheri east';
            refObj.Loan_Application__c=loanApp.Id;
            refObj.Applicant__c= appLi.Id;
            //refObj.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj);

            Ref__c refObj1=new Ref__c();
            refObj1.RelationshipWthApp__c= 'M';
            refObj1.FName__c= 'Test2';
            refObj1.Add__c= 'Andheri east New';
            refObj1.Loan_Application__c=loanApp.Id;
            refObj1.Applicant__c= appLi.Id;
            //refObj1.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj1);

            Ref__c refObj2=new Ref__c();
            refObj2.RelationshipWthApp__c= 'B';
            refObj2.FName__c= 'Test3';
            refObj2.Add__c= 'Andheri east';
            refObj2.Loan_Application__c=loanApp.Id;
            refObj2.Applicant__c= appLi.Id;
            //refObj2.PrsnlDis__c= perD.Id;
            listOfAllRef.add(refObj2);

            insert listOfAllRef;



            


            Id rtId = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
            
            BureauRespDtl__c burL =new BureauRespDtl__c();
            burL.ConsiderObligation__c= 'No';
            burL.RecordTypeId =rtId;
            burL.LoanName__c= 'SRIDEVI';
            burL.Source__c= 'Manual';
            burL.EMI__c= 12;
            burL.CloseDate__c= Date.newInstance(2023, 12, 9);
            burL.LoanAmount__c= 100000;
            burL.FinancierName__c= 'A.P. VARDHAMAN (MAHILA) CO-OP BANK LTD;HYDERABAD';
            burL.TenureLeft__c= 0;
            //burL.RecordType.name= 'Consumer Obligation';  
            burL.Treatment__c ='To continue - Obligate';
            burL.NoEMIPaid__c= 0;
            burL.CurrentOs__c= 20000;
            burL.LoanApplication__c=loanApp.Id;
            burL.Applicant__c=appLi.Id;
            insert burL;
            
            ApplAsset__c laAsset=new ApplAsset__c();
            laAsset.Resi_Age__c= 7;
            laAsset.PropSubType__c= 'DEL - COOPERATIVE SOCIETY';
            laAsset.Landmark__c= 'UJN';
            laAsset.Property_Carpet_area_Sq_Ft__c= 3000;
            laAsset.AddrLn1__c= 'TGV';
            laAsset.AddrLn2__c= 'TGB';
            laAsset.Approx_Age_of_Prop__c= 9;
            laAsset.Prop_Owners__c= 'Y';
            laAsset.Land_Area__c= 2500;
            laAsset.State__c= 'MAHARASHTRA';
            laAsset.FlatNo__c= 'YHG';
            laAsset.Is_it_an_APF__c= 'N';
            laAsset.PropType__c= 'RESIDENTIAL';
            laAsset.Builder_ID__c= 4321;
            laAsset.Pin_Code__c= '400074';
            laAsset.City__c= 'MUMBAI';
            laAsset.Property_Usage__c= 'SELF OCCUPIED';
            laAsset.PropSubTypeDesc__c= 'DELCS';
            laAsset.LoanAppln__c=loanApp.Id;
            laAsset.Prop_Owners__c= 'Y';
            laAsset.Appl__c=appLi.Id;
            
            insert laAsset;
            
            /**************************APPLICANT DATA*********************************** */
            
            ApplKyc__c appKyc = new ApplKyc__c();
            appKyc.PassExpDt__c=  Date.newInstance(2029, 12, 9);
            appKyc.kycDoc__c= 'Passport';
            appKyc.Applicant__c= appLi.ID;
            insert appKyc;
            
            List<ApplAddr__c> listAdds= new List<ApplAddr__c>();
            ApplAddr__c appAddress =new ApplAddr__c();
            appAddress.Applicant__c= appLi.ID;
            appAddress.MailAddr__c= true;
            appAddress.Country__c= 'India';
            appAddress.OwnType__c= 'R';
            appAddress.AddrStability__c= null;             
            appAddress.AddrTyp__c= 'Office Address';
            appAddress.City__c= 'GANGANAGAR';
            appAddress.State__c= 'RAJASTHAN';
            appAddress.AddrLine1__c= 'UJM';
            appAddress.AddrLine2__c= 'IKM';
            appAddress.Landmark__c= 'NEAR JOTIBA MANDAIR';
            appAddress.Pincode__c= '335002';
            appAddress.Locality__c= 'GANGANAGAR';
            listAdds.add(appAddress);
            
            ApplAddr__c appAddress1 =new ApplAddr__c();
            appAddress1.Applicant__c= appLi.ID;
            appAddress1.MailAddr__c= true;
            appAddress1.Country__c= 'India';
            appAddress1.OwnType__c= 'R';
            appAddress1.AddrStability__c= null;             
            appAddress1.AddrTyp__c= 'Office Address';
            appAddress1.City__c= 'GANGANAGAR';
            appAddress1.State__c= 'RAJASTHAN';
            appAddress1.AddrLine1__c= 'UJM';
            appAddress1.AddrLine2__c= 'IKM';
            appAddress1.Landmark__c= 'NEAR JOTIBA MANDAIR';
            appAddress1.Pincode__c= '335002';
            appAddress1.Locality__c= 'GANGANAGAR';
            listAdds.add(appAddress1);
            insert listAdds;
            
            
            Employer__c empYer= new Employer__c();
            empYer.name='TATA CONSULTANCY SERVICES';
            insert empYer;
            
            Industry__c indObj = new Industry__c();
            indObj.name='HEALTHCARE';
            insert indObj;
            
            List<ApplicantEmployment__c> listEmp =new List<ApplicantEmployment__c>();
            ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
            
            appEmp.TypeOfOrganisation__c= 'MN';
            appEmp.DesignationValues__c= null;
            appEmp.WorkingWithCurrentEmployer_Years__c= 6;
            //appEmp.IndustryType__r.name=indObj.name;
            appEmp.EmployerName__c= empYer.Id;
            appEmp.TotalWorkExperience_Months__c= 0;
            appEmp.NatureOfBusinessIndividual__c= 'M';
            appEmp.NatureOfBusinessCorporate__c= 'S';
            appEmp.GST_Registered__c= 'Yes';
            appEmp.LoanApplicant__c=appLi3.ID;
            listEmp.add(appEmp);
            
            ApplicantEmployment__c appEmp1 = new ApplicantEmployment__c();
            
            appEmp1.TypeOfOrganisation__c= 'MN';
            appEmp1.DesignationValues__c= null;
            appEmp1.WorkingWithCurrentEmployer_Years__c= 6;
            appEmp1.EmployerName__c= empYer.Id;
            appEmp1.TotalWorkExperience_Months__c= 0;
            appEmp1.NatureOfBusinessIndividual__c= 'M';
            appEmp1.NatureOfBusinessCorporate__c= 'S';
            //appEmp1.GST_Registered__c= 'No';
            appEmp1.LoanApplicant__c=appLi1.ID;
            listEmp.add(appEmp1);
            
            ApplicantEmployment__c appEmp2 = new ApplicantEmployment__c();
            
            appEmp2.TypeOfOrganisation__c= 'MN';
            appEmp2.DesignationValues__c= null;
            appEmp2.WorkingWithCurrentEmployer_Years__c= 6;
            appEmp2.EmployerName__c= empYer.Id;
            appEmp2.TotalWorkExperience_Months__c= 0;
            appEmp2.NatureOfBusinessIndividual__c= 'M';
            appEmp2.NatureOfBusinessCorporate__c= 'S';
            appEmp1.GST_Registered__c= 'No';
            appEmp2.LoanApplicant__c=appLi.ID;
            listEmp.add(appEmp2);
            
            
            insert listEmp;
            
            //tbd
            Industry__c indu=new Industry__c();
            indu.IndustryID__c= '21';
            indu.Name= 'INFORMATION TECHNOLOGY';
            
            
            //EmployerName__r
            //'Name'= 'TATA CONSULTANCY SERVICES'
            
            ApplGST__c appGst =new ApplGST__c();
            appGst.GSTIN__c= '78965423';
            appGst.City__c='Pune';
            appGst.RegisteredAddress_GST__c= 'Near Durga Temple Pune';
            appGst.Main_GSTIN__c= true;
            appGst.Applicant__c= appLi.ID;
            insert appGst;
            
            ApplBanking__c appBank =new ApplBanking__c();
            appBank.AC_No__c= '6583467';
            appBank.AccountType__c= 'CC';
            appBank.Bank_Branch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
            appBank.BankName__c= 'STATE BANK OF INDIA';
            appBank.Bank_City__c= 'GREATER NOIDA';
            appBank.Bank_Code__c='007';

            appBank.Appl__c= appLi.ID;
            appBank.LoanAppl__c=loanApp.Id;
            insert appBank;
            


            Repayment_Account__c repayAcc=new Repayment_Account__c ();
            repayAcc.Is_Active__c =true;
            repayAcc.Loan_Application__c= loanApp.Id;
            repayAcc.Account_Number__c='4343201000507';
            repayAcc.MICR_Code__c='147002034';
            repayAcc.Bank_Branch__c='STATE BANK OF INDIA , PRAGATI BHAWAN, URBAN ESTAT';
            repayAcc.Bank_Name__c='SATE BANK OF PATIALA';
            repayAcc.IFSC_Code__c='NPCI0000001';
            repayAcc.Repayment_Mode__c='PDC';
            repayAcc.Applicant_Banking__c=appBank.Id;
            insert repayAcc;


            DocMstr__c  docmstr=new DocMstr__c ();

            List<DocDtl__c> listDocDtl=new List<DocDtl__c>();
            DocDtl__c appDocDtls =new DocDtl__c();
            appDocDtls.LAN__c= loanApp.Id;
            appDocDtls.OSV__c= true;
            appDocDtls.DocTyp__c= 'PAN';
            appDocDtls.Appl__c=appLi.ID;
            appDocDtls.DocStatus__c ='PDD';
			appDocDtls.DocSubTyp__c ='Photograph of Property Visited';
			appDocDtls.TargetDt__c=Date.newInstance(2024, 12, 9);
			appDocDtls.ReceivedDt__c=Date.newInstance(2025, 12, 9);
			
listDocDtl.add(appDocDtls);

DocDtl__c appDocDtls1 =new DocDtl__c();
            appDocDtls1.LAN__c= loanApp.Id;
            appDocDtls1.OSV__c= true;
            appDocDtls1.DocTyp__c= 'PAN';
            appDocDtls1.Appl__c=appLi.ID;
            appDocDtls1.DocStatus__c ='OTC';
			appDocDtls1.DocSubTyp__c ='Interest bearing Letter-Top up';
			appDocDtls1.TargetDt__c=Date.newInstance(2024, 12, 9);
			appDocDtls1.ReceivedDt__c=Date.newInstance(2025, 12, 9);
			
listDocDtl.add(appDocDtls1);

insert listDocDtl;	
            
            List<Applicant_Income__c> listAppInc=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc =new Applicant_Income__c();
            Id appIncId = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId(); 
            System.debug('Id appIncId:'+appIncId);
            appInc.Salary__c =100000;
            appInc.RecordtypeId=appIncId;   
            //appInc.RecordType.DeveloperName = 'CashSal';
            appInc.Applicant__c=appLi.ID;
            listAppInc.add(appInc);
            
            
            Applicant_Income__c appInc1 =new Applicant_Income__c ();
            //Id appIncId1 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();   
            appInc1.RecordtypeId=appIncId; 
            appInc1.Salary__c =100000;
            //appInc1.RecordType.DeveloperName = 'CashSal';
            appInc1.Applicant__c=appLi.ID;  
            listAppInc.add(appInc1);
            
            
            Applicant_Income__c appInc2 =new Applicant_Income__c ();
            //Id appIncId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();   
            appInc2.RecordtypeId=appIncId;
            //appInc2.RecordType.DeveloperName = 'CashSal';
            appinc2.Salary__c=100000 ;
            appInc2.Applicant__c=appLi.ID; 
            listAppInc.add(appInc2);
            
            //insert listAppInc;
            
            
            
            List<Applicant_Income__c> liBankCr =new List<Applicant_Income__c>();    
            Applicant_Income__c appIncCr =new Applicant_Income__c ();
            appIncCr.Net_Salary__c=5000;
            Id appIncIdCr = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Bank Credit Salary').getRecordTypeId(); 
            appIncCr.RecordtypeId=appIncIdCr;     
            
            appIncCr.Applicant__c=appLi.ID;
            liBankCr.add(appIncCr);
            listAppInc.addAll(liBankCr);   
            
            
            List<Applicant_Income__c> listAppInc1=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc3 =new Applicant_Income__c ();
            appInc3.Agricultural_Income_Year__c=2023;
            appInc3.Agricultural_Yearly_Income__c=40000;   
            Id appIncId3 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();   
            appInc3.RecordtypeId=appIncId3; 
            // appInc3.RecordType.DeveloperName = 'AgriIncome';
            appInc3.Applicant__c=appLi.ID;
            listAppInc1.add(appInc3);
            
            Applicant_Income__c appInc4 =new Applicant_Income__c ();
            appInc4.Agricultural_Income_Year__c=2023;
            appInc4.Agricultural_Yearly_Income__c=40000;
            //Id appIncId4 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();   
            appInc4.RecordtypeId=appIncId3;
            //appInc4.RecordType.DeveloperName = 'AgriIncome';
            appInc4.Applicant__c=appLi.ID;
            listAppInc1.add(appInc4);
            
            listAppInc.addAll(listAppInc1);
            //insert listAppInc1;
            
            
            List<Applicant_Income__c> listAppInc2=new List<Applicant_Income__c>();
            Applicant_Income__c appInc12 =new Applicant_Income__c ();
            appInc12.Month3_Rental_Credited_Amount__c=2023;
            appInc12.Month2_Rental_Credited_Amount__c=40000;
            appInc12.Month1_Rental_Credited_Amount__c=5000;
            //appInc12.RecordType.DeveloperName = 'Rental_woBanking';
            Id appIncId12 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental woBanking').getRecordTypeId();   
            appInc12.RecordtypeId=appIncId12;
            appInc12.Applicant__c=appLi.ID;
            listAppInc2.add(appInc12);
            
            
            
            Applicant_Income__c appInc5 =new Applicant_Income__c ();
            appInc5.Month3_Rental_Credited_Amount__c=2023;
            appInc5.Month2_Rental_Credited_Amount__c=40000;
            appInc5.Month1_Rental_Credited_Amount__c=5000;
            // appInc5.RecordType.DeveloperName = 'Rental_woBanking';
            //Id appIncId5 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental woBanking').getRecordTypeId();   
            appInc5.RecordtypeId=appIncId12;
            appInc5.Applicant__c=appLi.ID;
            listAppInc2.add(appInc5);
            
            //insert listAppInc2;
            listAppInc.addAll(listAppInc2);
            
            List<Applicant_Income__c> listAppInc3=new List<Applicant_Income__c>();
            Applicant_Income__c appInc6 =new Applicant_Income__c ();
            appInc6.Net_Salary__c=7000 ;
            appInc6.Month1_Rental_Credited_Amount__c=11000;
            appInc6.Month2_Rental_Credited_Amount__c=11000;
            appInc6.Month3_Rental_Credited_Amount__c=11000;    
            //appInc6.RecordType.DeveloperName = 'RentalwBank';
            Id appIncId6 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc6.RecordtypeId=appIncId6; 
            appInc6.Applicant__c=appLi.ID;
            listAppInc3.add(appInc6);
            
            
            
            Applicant_Income__c appInc7 =new Applicant_Income__c ();
            appInc7.Net_Salary__c=7000 ;
            appInc7.Month1_Rental_Credited_Amount__c=11000;
            appInc7.Month2_Rental_Credited_Amount__c=11000;
            appInc7.Month3_Rental_Credited_Amount__c=11000;     
            //Id appIncId7 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc7.RecordtypeId=appIncId6; 
            //appInc7.RecordType.DeveloperName = 'RentalwBank';
            appInc7.Applicant__c=appLi.ID;        
            listAppInc3.add(appInc7);
            
            Applicant_Income__c appInc8 =new Applicant_Income__c ();
            appInc8.Net_Salary__c=7000 ;
            //Id appIncId8 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();   
            appInc8.RecordtypeId=appIncId6;
            appInc8.Month1_Rental_Credited_Amount__c=12000;
            appInc8.Month2_Rental_Credited_Amount__c=12000;
            appInc8.Month3_Rental_Credited_Amount__c=14000;
            //appInc8.RecordType.DeveloperName = 'RentalwBank';
            appInc8.Applicant__c=appLi.ID;
            listAppInc3.add(appInc8);
            
            listAppInc.addAll(listAppInc3);
            
            List<Applicant_Income__c> listAppInc4=new List<Applicant_Income__c>();
            
            Applicant_Income__c appInc9 =new Applicant_Income__c ();
            appInc9.Monthly_Pension_Credited__c=9000 ;
            Id appIncId9 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc9.RecordtypeId=appIncId9;
            //appInc9.RecordType.DeveloperName = 'Pension';
            appInc9.Applicant__c=appLi.ID;
            listAppInc4.add(appInc9);
            
            Applicant_Income__c appInc10 =new Applicant_Income__c ();
            appInc10.Monthly_Pension_Credited__c=9000;
            // Id appIncId10 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc10.RecordtypeId=appIncId9;
            //appInc10.RecordType.DeveloperName = 'Pension';
            appInc10.Applicant__c=appLi.ID;        
            listAppInc4.add(appInc10);
            
            Applicant_Income__c appInc11 =new Applicant_Income__c ();
            appInc11.Monthly_Pension_Credited__c=9000;
            //Id appIncId11 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();   
            appInc11.RecordtypeId=appIncId9;
            //appInc10.RecordType.DeveloperName = 'Pension';
            appInc11.Applicant__c=appLi.ID;           
            listAppInc4.add(appInc11);
            
            
            listAppInc.addAll(listAppInc4);
            
            insert listAppInc;
            
            IntgMsg__c intgMsg1 = new IntgMsg__c();
            intgMsg1.Name='Loan Boarding';
            intgMsg1.BU__c='HL / STL';
            intgMsg1.Status__c='New';
            intgMsg1.MStatus__c='Blank';
            intgMsg1.RefObj__c='LoanAppl__c';
            intgMsg1.RefId__c = loanApp.Id;
            intgMsg1.Resp__c='';
            intgMsg1.Svc__c='Loan Boarding';
            //insert new List<IntgMsg__c>{intgMsg1};
            insert     intgMsg1;
            TriggerBase.clearBypass('LoanAppl__c');
            TriggerBase.clearBypass('Applicant__c');
            
            
            String JsonString = '{"userId":"finn1lb","unqRequestId":"L0000002879#IM0000020415","tradeInDetail":[{"yearPurchased":"","vin":"","valuation2":"","valuation1":"","tradeInInsured":"","subModel":"","registrationNo":"","natureOfOwnerShip":"","model":"","mileageKmHr":"","hypothecationLien":"","finalValuation":"","comments":"","assetType":""}],"teleVerification":[],"splitDisbursalDetails":[{"splitRemarks":"OK","splitCreditPeriod":"0","splitAmount":"700000.00","splitAccountNo":"123456041","splitAccNo":"123456041","principalStartDate":"7-Apr-2024","principalRecoveryOn":"S","paymentMode":"F","payableAt":"12","micrCode":"","inFavourOf":"A STORES NAGARAJU","ifscCode":"UTIB0000723","ftMode":"NT","effectiveDate":"22-Feb-2024","effectIRR":"","disbursementTo":"","disbursalDate":"22-Feb-2024","disbTo":"LS","chequeNo":"000000","chequeDate":"20-Feb-2024","cashBankAccount":"332","bpName":"LS"}],"sourcingDetail":{"tenureInMonths":"100","strength":"","specialConditionFor":"","sourcingBranch":"MUM","sourceState":"","sourceCode":"","schemeCurr":"","scheme":"542","resaonComments":"","relationshipManager":"","referralName":"","referralGroup":"","referralCode":"","reasonSpecialCondition":"","reasonDescription":"","promotionCurr":"","promotion":"","product":"HL","priority":"","loanPurposeDesc":"","loanPurpose":"27","loanAmount":"800100.00","finnoneUser":"3407","finnoneStage":"FINISH","existingCustomerName":"","dsa":"21","dme":"7682","dateOfReceipt":"16-Feb-2024","dateOfDisbursal":"","dateEncoded":"16-Feb-2024","custProfileType":"P","custProfile":"","crmExistingLan":"","channelCode":"001","branchId":"5","branchCode":"","bankBranch":"","applicationID":"589612","applicationFormNo":"589612","accountOfficerCode":"","accountOfficeName":""},"sourceSystem":"SFDC","repaymentDetails":[],"referenceDetails":[{"refZipCode":"","refTitle":"Mr","refSalutation":"a","refPhoneAreaCode":"","refPhone2":"","refPhone1":"8698651294","refOfficeExtNo":"","refMobile":"8698651294","refereeRelation":"F","refereeName":"a","refEmailId":"","refCity":"","refAddressLine5":"","refAddressLine4":"","refAddressLine3":"","refAddressLine2":"","refaddressLine1":"a"},{"refZipCode":"","refTitle":"Mrs","refSalutation":"Aa","refPhoneAreaCode":"","refPhone2":"","refPhone1":"8698651294","refOfficeExtNo":"","refMobile":"8698651294","refereeRelation":"C","refereeName":"Aa","refEmailId":"","refCity":"","refAddressLine5":"","refAddressLine4":"","refAddressLine3":"","refAddressLine2":"","refaddressLine1":"Qq"}],"rateRiskDetails":[{"lessorName":"","contributionRate":"","contributionAmt":"","consortiumType":"","commissionRate":"","bpType":""}],"propertyDetails":[{"wingName":"","verifyBy":"","typeofPurchase":"RESIDENTIAL","tranchDetails":[],"totalAmountFinanced":"800100.00","tobeRegisteredWithName":"","titleClearFlag":"","technicalVerification":"","TCTCCTNo":"","soleOwnerFlag":"","sellingPriceFairMarketValue":"","sellerPhoneNo":"","sellerName":"","sellerAddressTwo":"","sellerAddressOne":"","residualAgeOfProperty":"8","rentFlag":"","propValuationType":"","propTypeNew":"","propType":"","propState":"5","propPinCode":"400001","propertyValue":"84700000.00","propertyUsage":"","propertyInsurance":"","propertyHeldIn":"","propertyDesc":"MM","propertyCostFinanced":"800100.00","propertyAddressLine2":"HANUMAN CHAWL","propertyAddressLine1":"HANUMAN CHAWL","propCountry":"1","propCity":"12","propAddress3":"","propAddress2":"HANUMAN CHAWL","propAddress1":"HANUMAN CHAWL","projectName":"","presentRegisteredOwner":"A NAGARAJU","personalInsurance":"","nearestLandmark":"","mortageDetails":[{"totalCollateralValue":"","loanOutstanding":"","loanNumber":"","lienNumber":""}],"lotNo":"","lienDetails":[],"insuranceInsuredFlag":"","guaranteeTenure":"","guaranteeInFavour":"","guaranteeFlag":"","guaranteeEndDate":"","guaranteeAmount":"","fundsDetail":[],"developerBuilder":"","contractor":"","constructionPurchase":[],"collateralUsage":"","collateralGradeClassification":"","buildingName":"","builderClassificationType":"","blockNo":"","areasSqm":"2000.00","areaForPlot":"2000.00","areaForImprovements":"","areaForImprovement":"","architect":"","approved":"No","appraiser2Date":"","appraiser2":"","appraiser1Date":"","appraiser1":"","appraisedPropertyValue":"84700000.00","appraisalValue2":"","appraisalValue1":"","ageOfProperty":"8","additionalProperties":{}}],"personalDiscussion":[{"verificationMatch":"","timeFrame":"","staffStrength":"50","shareHoldingPattern":"","resiDetails":"","propertyDetails":"","placeOfMeeting":"","pfiRemark":"","pfiDoneBy":"","pfiDone":"","personContacted":"Tushar Musale UW","offDetails":"","natureOfFinancialTransaction":"","nameOfInterviewer":"Tushar Musale UW","majorVariationsInFinancial":"","mainSuppliers":"","mainProducts":"","mainClients":"","levelOfActivity":"","interviewerDecision":"Completed","interviewerComments":"","grossMonthlyPayable":"","grossMonthlyIncome":"","futureGrowthPlan":"","foir":"","empNo":"","empDetailNatureofBusi":"","emiComfortableWith":"","detailOfEndUseOfFunds":"","designation":"","decisionDate":"20-Feb-2024","dateOfMeeting":"20-Feb-2024","customerProfile":"","currentObligationDetails":"","crossSellRemarks":"","crossSell":"","clientMarketRef":"","bankingHabit":"","assetOwned":"","anyOthBusi":"","anyMisleadingInformation":"","analysisOfFinancials":"","aggregateExposure":"","additionalDocumentCollected":""}],"password":"qWI2wzG7ofqhTR1gsHM6Qw==","notepadDetails":[{"noteUser":"","noteReferenceDate":"20-Feb-2024","noteDetails":"A STORES NAGARAJU: a","noteDate":"20-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"AA-02732: OK","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Additional Remarks :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Personal/Family Details of Promoters : JN","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Income Related Comments :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"},{"noteUser":"","noteReferenceDate":"22-Feb-2024","noteDetails":"Brief of Buisness Details of Applicant and Coapplicant :J","noteDate":"22-Feb-2024","noteCode":"COMMENT"}],"loanDetails":{"tdsRate":"0","subventionPercentage":"","spreadID":"","reqInterestType":"E","repayFrequency":"M","rateTypeFloatingFlag":"Y","rateEMIFlag":"R","principalBaseUnit":"1","pemiType":"R","numberOfInstallments":"100","noOfDisbursal":"1","loanRest":"","loanPLRType":"PLR_HL","loanPLRRate":"20.50","loanEMI":"","ioiApplicable":"","interestTaxRate":"","interestTax":"","interestStartDate":"22-Feb-2024","interestRoundPrecision":"","interestRoundOff":"","interestRoundMethod":"","interestInAdvance":"","installmentRoundPrecision":"","installmentPlan":"E","installmentMode":"R","impactOnTenure":"Y","gracePeriod":"3","graceApplicableFlag":"N","floatingFrequency":"0","flatRate":"","fixedFor":"0","fisrtEmiDueMonth":"4","fisrtEmiDate":"7-Apr-2024","firstEmiDueYear":"2024","eirRate":"","effectiveRate":"14.75","dueDay":"07","downPaymentRate":"","downpayment":"","disburseTo":"LS","disbType":"MULTIPLE","disbAmount":"712640.00","depositAccount":"","chargeInterest":"Y","channelDSASubvention":"","capitalizeInterest":"N","businessIRR":"","assetCost":"84700000","advInstallment":"","addOnRate":"","addInterestSchedule":"N"},"jsonVersion":"LB-PL-NEv1.0","insuranceDetails":{"totalInsPremium":"","tctCCTNo":"","remarksOnCoverage":"","propDesc":"","premiumRemarks":"","others":"","noOfCollaterals":"","mortgagee":"","mailingAddress":"","locationOfRisk":"0","insuranceRequired":"","insurancePolicyType":"","insStartDate":"","insPremYr2":"","insPremYr1":"","insPolNumber":"PP000280","insEndDate":"","insCoverageType":"","insCompName":"","buildingDesc":"","boundariesright":"","boundariesRear":"","boundariesLeft":"","boundariesFront":"","appraisedValue":"100","amtInsuredStocks":"","amtInsuredOff":"","amtInsuredContents":"","amtInsuredBuilding":"","amtInsured":"","amtInsImp":""},"instrumentDetails":{"pdcByName":"A STORES NAGARAJU","pdcBy":"A","micrFlag":"","micrCode":"110211063","instrumentType":"Z","instrumentCity":"","instrumentBankBranch":"211","instrumentBank":"211","ifscCode":"","employeeCode":"","downloadToPDCMS":"N","destBankAccType":"10","destAccHolder":"A STORES NAGARAJU","customerAccNo":"123456041"},"initialMoneyDepositDetails":[{"imdUTRNo":"","imdTranDae":"","imdTdsByCustomer":"","imdStatus":"","imdSolId":"","imdReceiptNo":"","imdReason":"","imdPaymentMode":"","imdPaidOn":"","imdMicrCode":"","imdInFavourOf":"","imdIncomeTaxIdType":"","imdIncomeTaxIdNo":"","imdHostAccNo":"","imdHoldUnhold":"","imdHoldAccountNo":"","imdHoldAccount":"","imdHoldAccBankName":"","imdHoldAccBankBranch":"","imdFTMode":"","imdDrawnOn":"","imdDepositSlipType":"","imdDepositSlipNo":"","imdDepositSlipAmt":"","imdDealingBank":"","imdCustomerId":"","imdCurrency":"","imdCMSNumeric":"","imdCmsCode":"","imdCity":"MIRZAPUR","imdChqNo":"","imdChequeId":"","imdChequeDate":"","imdBankBranch":"","imdAmount":"4000","imdAccNo":"","ifscCode":""}],"gSTInfoDetails":{"gstState":"","gstReqd":"N","gstPinCode":"","gstNumber":"","gstCustomerType":"","gstCustomerName":"","gstCountry":"","gstCity":"","gstApplicantType":"","gstAddressLine3":"","gstAddressLine2":"","gstAddressLine1":"","gstAddress":""},"gradedRepaymentDetails":[{"slabSequence":"","slabRecoveryPtg":"","slabInstlTo":"","slabInstlFrom":"","slabEmi":""}],"fivCheckList":[{"quesNumber":"","quesDesc":"","answer":""}],"crossCollateral":[{"doneOn":"","crossCustomerName":"","applicationId":"","agreementType":""}],"confirmationLog":{"remarks":"","remark":"","relationship":"","positive":"","position":"","phoneUsed":"","negative":"","nameOfInformant":"","nameOfAgency":"","citizenship":"17","callStatus":"","callLogCounter":"","applicantName":"A STORES NAGARAJU","age":""},"collateralDetails":[],"chargesDetails":[{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"35","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"16522.00"},{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"600168","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"118.00"},{"periodicCharge":"N","chargeToBeFinanced":"N","chargeId":"68","chargeCalculatedOn":"AMT FINANCED","chargeAmount":"12640.00"}],"bussinessVerification":{"warehouseLoaction":"","warehouse":"","signatoryName":"","signatoryJobTitle":"","salesFigure":"","rentMortAmt":"","remarks":"","registeredName":"","registered":"","productsBrandsCarried":"","positive":"","phoneExt":"","percentOwnership":"","othPropOwned":"","operatingExpenses":"","noOfRegularEmp":"","noOfCustomerDay":"","negative":"","natureOfBusi":"","managementPosition":"","managementName":"","managementAge":"","location":"","lengthOfBusinessExis":"","creditReferencesName":"","creditReferencesAddress":"","creditReferencePhone":"","citizenship":"","busiType":"","businessPremisesOwner":"","businessPhone":"","businessName":"","businessAddress":"","branches":"","applicantName":"","age":""},"applicantDetails":[{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"PF","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"1","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"7","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"","uidToken":"","turnOver":"","topUpAmount":"","title":"MR.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"","selectPassportCountry":"","salutation":"A STORES NAGARAJU","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"ASSPG3151E","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"VBH","motherMaidenName":"VBH","minor":"","middleName":"STORES","maritalStatus":"S","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"NAGARAJU","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"129","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"M","fwCustomerId":"","fwAccountNo":"","fullName":"A STORES NAGARAJU","firstName":"A","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"PP","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"ENG","dsa":"21","drivingLicenseNo":"TS30520200003202","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"1-Jun-1983","custSegment":"9","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"100","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[{"finNoOfYearsHeld":"","finNoOfOutwardChqReturns":"0","finNoOfInwardChqReturns":"0","finBankStmtCollected":"","finBankRemarks":"","finBankName":"211","finBankMinBalance":"","finBankMaxBalance":"","finBankBranch":"AXIS BANK","finBankAvgBalance":"","finBankAccType":"SAVINGS","finBankAccountNo":"123456041"}],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"P","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"40","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"PERMNENT","addressLine3":"","addressLine2":"HANUMAN CHAWL","addressLine1":"HANUMAN CHAWL"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"OFFICE","addressLine3":"","addressLine2":"ROOM NO 28 HANUMAN CHAWL","addressLine1":"ROOM NO 28 HANUMAN CHAWL"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400001","phone2":"","phone1":"","mobile":"8698651294","mailingAddressFlag":"Y","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"tushumusale@gmail.com","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"CURRES","addressLine3":"","addressLine2":"HANUMAN CHAWL","addressLine1":"HANUMAN CHAWL"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""},{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"","uidToken":"","turnOver":"","topUpAmount":"","title":"MRS.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"","selectPassportCountry":"","salutation":"A P NAGARAJU","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"DZXPK8172E","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"GANESHA","motherMaidenName":"GANESHA","minor":"","middleName":"P","maritalStatus":"S","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"NAGARAJU","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"F","fwCustomerId":"","fwAccountNo":"","fullName":"A P NAGARAJU","firstName":"A","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"RAVEENDRANATH TAGORE TUMMALA","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"GRAD","dsa":"21","drivingLicenseNo":"TS30520200003202","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"1-Jun-1983","custSegment":"10","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"0","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"G","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"40","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"424001","phone2":"","phone1":"","mobile":"9723509420","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"1857","areaCode":"1857","addressType":"CURRES","addressLine3":"","addressLine2":"DHULE","addressLine1":"DHULE"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"424001","phone2":"","phone1":"","mobile":"9723509420","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"1857","areaCode":"1857","addressType":"PERMNENT","addressLine3":"","addressLine2":"DHULE","addressLine1":"DHULE"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""},{"yearOfBusinessInCountry":"","workDetailsSalaried":{"yearPreviousJobYr":"","yearPreviousJobMon":"","yearPresentJob":"","workPermitNo":"","websiteAddress":"","uanNumber":"","typeOfOwnership":"","typeOfOrg":"","tradeLicenseNo":"","tradeLicenseExpiryDate":"","totalWorkExp":"","subIndustryWork":"","subIndEmplyment":"","shareHolding":"","prevEmployerPhoneNo":"","prevEmployerName":"","prevEmployerAddress":"","pranNo":"","pfNumber":"","othersWork":"","noOfpartners":"","nonEarning":"","natureOfBusinessWork":"","natureOfBusinessSelf":"","nameOfPOAHolder":"","mcaNumber":"","lengthOfBusiness":"","labourIdNo":"","labourIdExpiryDate":"","indutsryWork":"","industryEmployment":"","emplyementType":"","employmentStatus":"","employerRating":"","employerRanking":"","employerName":"","employeeNo":"","designation":"","department":"","dateOfInceptionWork":"","businessName":"","associatedSinceInception":""},"whetherResi":"N","webCibilScore":"","vpaUpiTertiary":"","vpaUpiSecondary":"","vpaUpiPrimary":"","voterId":"","visaType":"","visaNo":"","visaExpiryDate":"","university":"","uniqueCustomerId":"12961886","uidToken":"","turnOver":"","topUpAmount":"","title":"MRS.","tenureInMonths":"100","taxIdentificationNoJuridiction":"","tanNo":"","subIndustry":"","stakeHolderDetails":[{"corpStakeRelatedNameOfCompany":"","corpStakeholderTotalExp":"","corpStakeholderTitle":"","corpStakeholderTIN":"","corpStakeholderStakePercent":"","corpStakeHolderPosition":"","corpStakeHolderPhone":"","corpStakeholderPassportNo":"","corpStakeholderNationality":"","corpStakeholderMidName":"","corpStakeholderLastName":"","corpStakeholderJoinedSince":"","corpStakeholderIdType":"","corpStakeholderIdNo":"","corpStakeholderGender":"","corpStakeholderFirstName":"","corpStakeholderDOI":"","corpStakeholderDINNo":"","corpStakeholderContactType":"","corpStakeholderConsiderGrading":"","corpStakeholderCompanyName":""}],"staffId":"","staffGrade":"","sssGSIS":"","spousePassportCountry":"","spousePassNo":"","spousePassIssueDate":"","spousePassExpiryDate":"","spouseName":"ASAS","selectPassportCountry":"","salutation":"KAMLESHKUMAR JP RAJPUT","salaryAssign":"","ruralUrbanCustomer":"","rollOverType":"","resType":"","residentOfCountrySince":"","residency":"","rentPerMonth":"","religion":"HINDU","relation":"SFI","relatedTitle":"","relatedPersonCKyc":"","relatedIdProofCollected":"","relatedIdNo":"","relatedIdExpiryDate":"","relatedIdDocName":"","relatedGuardianMinor":"","relatedFullname":"","relatedCkycNo":"","relatedAssignee":"","region":"","rationCardNo":"","rankEmp":"","qualifyingYear":"","propertyOwner":"Y","professionalQual":"","preferredIrr":"","pmayBankRelation":"","placeOfBirth":"","passportNo":"","passportIssuedate":"","passportIssueCountry":"","passportFileNo":"","passportExpiryDate":"","pan":"AMXPA4540L","paidUpCapital":"","outstandingAmt":"","otherIdNo":"","oldagreementId":"","nregaJobCard":"","noOfDependents":"","noOfChildInHigh":"","noOfChildInElem":"","noOfChildInCollege":"","noOfChidNotYet":"","noOfCars":"","natureOfBusinessCorp":"","nationality":"1","nationalFlag":"Y","mscInfoDetails":{"mscdetails9":"","mscdetails8":"","mscdetails7":"","mscdetails6":"","mscdetails5":"","mscdetails4":"","mscdetails30":"","mscdetails3":"","mscdetails29":"","mscdetails28":"","mscdetails27":"","mscdetails26":"","mscdetails25":"","mscdetails24":"","mscdetails23":"","mscdetails22":"","mscdetails21":"","mscdetails20":"","mscdetails2":"","mscdetails19":"","mscdetails18":"","mscdetails17":"","mscdetails16":"","mscdetails15":"","mscdetails14":"","mscdetails13":"","mscdetails12":"","mscdetails11":"","mscdetails10":"","mscdetails1":""},"motherName":"ADAD","motherMaidenName":"ADAD","minor":"","middleName":"JP","maritalStatus":"M","losNo":"","liabilityDetails":[],"lenOfBusiness":"","leadId":"","lastSchoolAttended":"","lastname":"RAJPUT","jobTitle":"","isTopUpLoan":"","isStaff":"","isoCountryCodeJuridiction":"","isoCountryCodeBirth":"","isExistingCustomer":"","isDeletionRelatedPerson":"","initials":"","indvCorpFlag":"I","industryClassification":"","incomeDetails":[],"idProofCollectedCkyc":"","idExpiryDate":"","idDocName":"","hostSystemCustId":"","hostSystemAccNo":"","hostAccNo":"","guardian":"","groupName":"","group":"","govtIdNo":"","gender":"F","fwCustomerId":"","fwAccountNo":"","fullName":"KAMLESHKUMAR JP RAJPUT","firstName":"KAMLESHKUMAR","finnoneLanNo":"","finalRiskStatus":"","finalRiskGrade":"","fdDetails":[{"finFdRate":"","finFdNo":"","finFdMaturityDate":"","finFdBranch":"","finFdBankName":"","finFdAmount":""}],"fatherName":"","familyName":"","existingCreditCardNo":"","entityFlag":"","endOfService":"","employeeDepartment":"","empIDCGSG":"","eduQualification":"","educQual":"ENG","dsa":"21","drivingLicenseNo":"","drivingLicenseIssuedAt":"","drivingLicenseExpiryDate":"","docCollectionDetails":[{"originalDoc":"","docValidityDate":"","document":"235","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Accepted Sanction letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"240","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Cheque Submission Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"239","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"Disbursement Request Form","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"241","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"19-Feb-2024","docReason":"","docName":"End Use Letter","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"19","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Loan Agreement","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"234","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents NACH","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"602","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Repayment Documents SPDCs","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"337","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"Registered Sale Deed in the name of borrower","docDesc":""},{"originalDoc":"","docValidityDate":"","document":"257","docTargetDate":"","docStatus":"C","docRICReqd":"N","docRemarks":"","docReceivedDate":"20-Feb-2024","docReason":"","docName":"PSD Critical OTC 1","docDesc":""}],"dncFlag":"","dmeDST":"","demoCorpRatingDetails":[{"corpRatingValidTillDate":"","corpRatingRemarks":"","corpRatingGrade":"","corpRatingAgency":"","corpPurposeOfRating":"","corpPublishingDate":""}],"degree":"","deductionDetails":[],"dateOfInception":"","dateOfClosure":"","dateOfBirth":"11-Dec-1992","custSegment":"10","customerId":"","currency":"","corpTradeLicenseNo":"","corpTradeLicenseExpiryDate":"","corpOrgType":"","corpDesignation":"","contactPersonDesignation":"","contactPerson":"","constitution":"2","companyWebsite":"","companyNameNatLang":"","companyName":"","companyListed":"N","citizenship":"17","cinRegistrationNo":"","cifNo":"","cibilScore":"NA","category":"O","carOwnership":"","cardDetails":[],"bussFinanRatingDetails":[],"branch":"","beneficiaryParent":"N","beneficiaryOwnerPercent":"0","beneficiaryCriteria":"0","bankType":"","bankname":"","bankDetails":[],"authCapital":"","atWhatDayYouArePaid":"","assetModel":"","assetMake":"","assetCat":"","applicantType":"C","applicantCustomDetail":{"customFieldCust1":"NPM"},"aliasName":"","aipTenure":"","aipAmount":"","age":"31","addressDocName":"","addressDetails":[{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"O","poBox":"","pinCode":"400003","phone2":"","phone1":"","mobile":"9096856670","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"CURRES","addressLine3":"A","addressLine2":"A","addressLine1":"A"},{"stayDurationCurrAddressYr":"","stayDurationCurrAddressMon":"","stayDurationCityYear":"","stayDurationCityMon":"","state":"5","smsMobileSecondary":"","smsMobilePrimary":"","smsFlag":"","propertyStatus":"M","poBox":"","pinCode":"400003","phone2":"","phone1":"","mobile":"9096856670","mailingAddressFlag":"N","landmark":"","inactiveAddress":"","inactive":"","fax":"","extension":"","emailId":"","district":"","country":"1","copyaddress":"","city":"12","areaCode":"12","addressType":"PERMNENT","addressLine3":"A","addressLine2":"A","addressLine1":"A"}],"additionRelatedPerson":"","additionalIdNo3":"","additinalId2":"","accountType":"","accountNo":""}]}';
            LoanBoardingRequestWrapper.parse(JsonString);
            
            List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1};
                LoanBoardingRequestGenerator generator = new LoanBoardingRequestGenerator();
            generator.generate(msgs, 'Loan Boarding', 'Async');
            loanApp =[Select Id,name,BrchName__c from LoanAppl__c where Id =: loanApp.ID];//.BrchName__c='MUMBAI';
            System.assertEquals('MUMBAI',loanApp.BrchName__c);
            System.assertEquals(1, [SELECT COUNT() FROM LoanAppl__c WHERE Id = :loanApp.Id]);
            Test.stopTest();
            
        }
    }    
    
}