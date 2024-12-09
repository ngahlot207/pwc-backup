@isTest
public class AddTrancheDisRequestGeneratorTest {
    
    static testmethod void AddTrancheDisRequestGeneratorTestMethod(){
        
        Test.startTest();
        
        User us = TestDataFactory.UserData(true);
        
        System.runas(us){    
            //List<LoanAppl__c> loanApps =  new List<LoanAppl__c>();
            //LoanBoardingRequestGeneratorTest.testCalculateIMD1();
        TriggerBase.bypass('LoanAppl__c');
        TriggerBase.bypass('Applicant__c');
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appt=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        
        ApplKyc__c apl=new ApplKyc__c(kycDoc__c='Aadhaar',Applicant__c=appt.Id);
        insert apl;
            
       Disbursement__c disbObj =new Disbursement__c();
            disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
            disbObj.No_of_Disbur__c=1;
            disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
            disbObj.Princ_Rec_on__c='Amount Financed';
            disbObj.Loan_Appli__c= loanApp.id;
            disbObj.Disbur_No__c=1;
            disbObj.Total_Disb_Amt__c=10000;            
            insert disbObj;
            

            Split_Disbur__c sp1=new Split_Disbur__c();
            sp1.Split_Cheque_Amt__c =5000;
            sp1.Pay_Mode__c='Cheque';
            sp1.Fund_Transf_Mode__c='NEFT';
            sp1.IFSC_Detail__c='SBIN001000';
            sp1.Cheq_Favor_Dets__c='abcd';
            sp1.DisburseRela__c=disbObj.Id;
            insert sp1;

            
        
            List<MasterData__c> listMstr =new List<MasterData__c>();
            
            MasterData__c mstrData=new MasterData__c();
            mstrData.Name= 'HDFC Life Insurance';
            mstrData.MPno__c= 'PP000280';
            mstrData.Type__c= 'CashBank Account';
            mstrData.FinnoneCode__c='507';
            mstrData.name ='AHMEDABAD FEDERAL BANK 23388';
            listMstr.add(mstrData);
            
            MasterData__c mstrData1=new MasterData__c();
            mstrData1.Name= 'HDFC Life Insurance';
            mstrData1.FinnoneVal__c= 'ECS';
            mstrData1.Type__c= 'Payment Mode';
            mstrData1.FinnoneCode__c='E';
            mstrData1.name ='ECS';
            listMstr.add(mstrData1);
            
            
            MasterData__c mstrData2=new MasterData__c();
            mstrData2.Name= 'ONLINE TRANSFER';
            mstrData2.Type__c= 'Fund Transfer Mode';
            mstrData2.FinnoneCode__c='OT';
            mstrData2.name ='ONLINE TRANSFER';
            listMstr.add(mstrData2);
            
            MasterData__c mstrData3=new MasterData__c();
            mstrData3.Name= 'NEFT';
            mstrData3.Type__c= 'Fund Transfer Mode';
            mstrData3.FinnoneCode__c='NT';
            mstrData3.name ='NEFT';
            listMstr.add(mstrData3);

            insert listMstr;    
            
            
            
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
                    
        	IntgMsg__c intmsg = new IntgMsg__c();
            intmsg.Name='Additional Tranche Disbursal';
            intmsg.BU__c='HL / STL';
            intmsg.Status__c='New';
            intmsg.MStatus__c='Blank';
            intmsg.RefObj__c='Disbursement__c';
            intmsg.RefId__c = disbObj.Id;
            intmsg.ParentRefId__c=loanApp.Id;
            intmsg.ParentRefObj__c='LoanAppl__c';
            //intmsg.Resp__c='';
            intmsg.Svc__c='Additional Tranche Disbursal';
            //insert     intmsg;
            TriggerBase.clearBypass('LoanAppl__c');
            TriggerBase.clearBypass('Applicant__c');    
        
        
        TriggerBase.bypass('IntgMsg__c');
        
        intMsglist.add(intmsg);
        insert intMsglist;    
        AddTrancheDisRequestGenerator addTrReq = new AddTrancheDisRequestGenerator();
        addTrReq.generate(intMsglist,'Additional Tranche Disbursal','Async');
        TriggerBase.clearBypass('IntgMsg__c');
        
        
        }
    } 
      
}