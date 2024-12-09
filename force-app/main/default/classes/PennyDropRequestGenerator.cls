public class PennyDropRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        List<Id> Ids =new List<Id>();
        Set<Id> repayAccVerIds = new Set<Id>();
        Set<Id> splitDisbIds = new Set<Id>();
        
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c);
            
            if(intMsg.RefObj__c=='RepayAccVerify__c'){
                repayAccVerIds.add(intMsg.RefId__c);
            }
            else if(intMsg.RefObj__c=='Split_Disbur__c'){
                splitDisbIds.add(intMsg.RefId__c);
            }
        } 
        
        try{
            if(!Ids.isempty()){
                List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>();
                
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Penny_drop');
                
                Set<String> BranchCode=new Set<String>();
                Set<Id> SchemeId =new Set<Id>();
                Set<Id> applicantbankId =new Set<Id>();
                
                Map<Id,RepayAccVerify__c> RepayAccVerifymap =new Map<Id,RepayAccVerify__c>();
                Map<Id,Split_Disbur__c> splitDisbMap = new Map<Id,Split_Disbur__c>();
                for(RepayAccVerify__c repaylist:[Select Id,LoanAppl__r.BrchCode__c,LoanAppl__r.SchemeId__c,LoanAppl__r.Product__c,
                                                 RepayAcc__r.IFSC_Code__c,RepayAcc__r.Applicant_Banking__c,
                                                 TransRefNo__c,NameRetuFromPennyDrop__c,PennyDropDateTime__c,LoanAppl__r.FinnoneAppid__c from RepayAccVerify__c Where Id IN:repayAccVerIds]){
                                                     
                                                     RepayAccVerifymap.put(repaylist.Id,repaylist);
                                                     BranchCode.add(repaylist.LoanAppl__r.BrchCode__c);
                                                     SchemeId.add(repaylist.LoanAppl__r.SchemeId__c);
                                                     applicantbankId.add(repaylist.RepayAcc__r.Applicant_Banking__c);
                                                 }
                
                for(Split_Disbur__c splitDisbur : [Select id,name,Cheq_Favor_Acc_No__c,IFSC_Detail__c,Custo_Name__c,Benef_Nm_of_Penny_Drop__c, PennyDrpTxnRefNo__c,PennyDrpResTime__c,DisburseRela__c,DisburseRela__r.Loan_Appli__c, DisburseRela__r.Loan_Appli__r.Product__c, DisburseRela__r.Loan_Appli__r.SchemeId__c,DisburseRela__r.Loan_Appli__r.BrchCode__c, DisburseRela__r.Loan_Appli__r.FinnoneAppid__c  FROM Split_Disbur__c WHERE ID IN:splitDisbIds ]){
                    splitDisbMap.put(splitDisbur.Id,splitDisbur);
                    BranchCode.add(splitDisbur.DisburseRela__r.Loan_Appli__r.BrchCode__c);
                    SchemeId.add(splitDisbur.DisburseRela__r.Loan_Appli__r.SchemeId__c);
                }
                
                Map<String,BankBrchMstr__c> BankBrchMstrmap =new Map<String,BankBrchMstr__c>();
                for(BankBrchMstr__c BankBrchMstrlist:[Select id,BrchCode__c,OffcCode__c from BankBrchMstr__c Where BrchCode__c IN:BranchCode]){
                    BankBrchMstrmap.put(BankBrchMstrlist.BrchCode__c,BankBrchMstrlist);
                }
                
                Map<Id,SchMapping__c> SchMapping = new Map<Id,SchMapping__c>([Select Id,SchmId__c FROM SchMapping__c WHERE ID IN:SchemeId]);
                
                Map<Id,ApplBanking__c> ApplBankingmap =new Map<Id,ApplBanking__c>([Select Id,Appl__r.FullName__c from ApplBanking__c Where id IN:applicantbankId ]);
                
                for(IntgMsg__c integrationmsg:msgs){
                    
                    PennyDropRequestWrapper request =new PennyDropRequestWrapper();
                    
                    if(RepayAccVerifymap.containskey(integrationmsg.RefId__c) || splitDisbMap.containsKey(integrationmsg.RefId__c)){
                        
                        request.user= svc.Username__c;
                        request.password= svc.Password__c;
                        request.requestId= GlobalUtility.getUniqueNumber();//'jyJUpRC8EaIan7WI5QtYv0';
                       	request.sourceId= svc.SourceSystem__c;
                        request.chequeStatus='S';
                        request.ftMode= 'IM';
                        request.modeOfPayment= 'F';
                        request.receiptAmount= '1';
                        request.receiptChannel= 'FEDBANK';
                        request.dealingBank= '497';
                        request.drawnOn= '485';
                        request.imdFlag= 'P';
                        request.bpType= 'LS'; 
                        request.bpId= '';
                        request.receiptNo= '';//23155';//
                        request.imdCustom5= '';//10010200015128'; // Not sure//  
						request.imdCustom6= 'Penny Drop';                        
                        
                        if(integrationmsg.RefObj__c=='RepayAccVerify__c'){
                            
                            RepayAccVerify__c repayacc=RepayAccVerifymap.get(integrationmsg.RefId__c);
                            
                            request.applicationId= repayacc.LoanAppl__c!=null?repayacc.LoanAppl__r.FinnoneAppid__c:'';// '586144';
                            request.inFavourOf= ApplBankingmap.containsKey(repayacc.RepayAcc__r.Applicant_Banking__c)?ApplBankingmap.get(repayacc.RepayAcc__r.Applicant_Banking__c).Appl__r.FullName__c:''; //'AJIT';
                            request.productFlag= (repayacc.LoanAppl__r.Product__c=='Small Ticket LAP' || repayacc.LoanAppl__r.Product__c=='Loan Against Property')?'LAP':'HL';// refer IMD request
                            request.schemeId= SchMapping.containskey(repayacc.LoanAppl__r.SchemeId__c)?SchMapping.get(repayacc.LoanAppl__r.SchemeId__c).SchmId__c:''; // refer IMD request
                            request.branch= BankBrchMstrmap.containskey(repayacc.LoanAppl__r.BrchCode__c)?BankBrchMstrmap.get(repayacc.LoanAppl__r.BrchCode__c).OffcCode__c:'';// refer IMD request
                            request.receiptDate= repayacc.PennyDropDateTime__c !=null ? String.valueOf(DateTime.newInstance(repayacc.PennyDropDateTime__c.year(), repayacc.PennyDropDateTime__c.month(), repayacc.PennyDropDateTime__c.day()).format('dd-MMM-yyyy')) : '';//'02-OCT-2022';
                            request.chequeDate= repayacc.PennyDropDateTime__c !=null ? String.valueOf(DateTime.newInstance(repayacc.PennyDropDateTime__c.year(), repayacc.PennyDropDateTime__c.month(), repayacc.PennyDropDateTime__c.day()).format('dd-MMM-yyyy')) : '';//'01-OCT-2022';
                            request.utrNo= repayacc.TransRefNo__c!=null?repayacc.TransRefNo__c:'';//TransRefNo__c
                            request.imdCustom2= ApplBankingmap.containsKey(repayacc.RepayAcc__r.Applicant_Banking__c)?ApplBankingmap.get(repayacc.RepayAcc__r.Applicant_Banking__c).Appl__r.FullName__c:''; // Customer Name/Applicant Name
                            request.imdCustom3= repayacc.NameRetuFromPennyDrop__c!=null?repayacc.NameRetuFromPennyDrop__c:'';// NameRetuFromPennyDrop__c
                            request.imdCustom4= repayacc.RepayAcc__r.IFSC_Code__c!=null?repayacc.RepayAcc__r.IFSC_Code__c:''; //RepayAcc__r.IFSC_Code__c
                        
                        }
                        else if(integrationmsg.RefObj__c=='Split_Disbur__c'){
                            
                            Split_Disbur__c splitDisbur = splitDisbMap.get(integrationmsg.RefId__c);
                            
                            request.applicationId= splitDisbur.DisburseRela__r.Loan_Appli__c!=null && splitDisbur.DisburseRela__r.Loan_Appli__r.FinnoneAppid__c != null ? splitDisbur.DisburseRela__r.Loan_Appli__r.FinnoneAppid__c:'';
                            request.inFavourOf= splitDisbur.Custo_Name__c!=null ? splitDisbur.Custo_Name__c : '';
                            request.productFlag= splitDisbur.DisburseRela__r.Loan_Appli__c!=null && (splitDisbur.DisburseRela__r.Loan_Appli__r.Product__c=='Small Ticket LAP' || splitDisbur.DisburseRela__r.Loan_Appli__r.Product__c=='Loan Against Property')?'LAP':'HL';
                            request.schemeId= SchMapping.containskey(splitDisbur.DisburseRela__r.Loan_Appli__r.SchemeId__c)?SchMapping.get(splitDisbur.DisburseRela__r.Loan_Appli__r.SchemeId__c).SchmId__c:'';
                            request.branch= BankBrchMstrmap.containskey(splitDisbur.DisburseRela__r.Loan_Appli__r.BrchCode__c)?BankBrchMstrmap.get(splitDisbur.DisburseRela__r.Loan_Appli__r.BrchCode__c).OffcCode__c:'';
                            request.receiptDate = splitDisbur.PennyDrpResTime__c !=null ? String.valueOf(DateTime.newInstance(splitDisbur.PennyDrpResTime__c.year(), splitDisbur.PennyDrpResTime__c.month(), splitDisbur.PennyDrpResTime__c.day()).format('dd-MMM-yyyy')) : '';
                            request.chequeDate = splitDisbur.PennyDrpResTime__c !=null ? String.valueOf(DateTime.newInstance(splitDisbur.PennyDrpResTime__c.year(), splitDisbur.PennyDrpResTime__c.month(), splitDisbur.PennyDrpResTime__c.day()).format('dd-MMM-yyyy')) : '';
                            request.utrNo= splitDisbur.PennyDrpTxnRefNo__c!=null?splitDisbur.PennyDrpTxnRefNo__c:'';
                            request.imdCustom2= splitDisbur.Custo_Name__c!=null ? splitDisbur.Custo_Name__c : '';
                            request.imdCustom3= splitDisbur.Benef_Nm_of_Penny_Drop__c!=null?splitDisbur.Benef_Nm_of_Penny_Drop__c:'';
                            request.imdCustom4= splitDisbur.IFSC_Detail__c!=null?splitDisbur.IFSC_Detail__c:'';
                        
                        }
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=integrationmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(integrationMessage);
                        
                    }
                    
                     
                }
                if (!updateIntMsgList.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c', 'Status__c'};
                        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                }
                uow.commitWork();
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'PennyDropRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}