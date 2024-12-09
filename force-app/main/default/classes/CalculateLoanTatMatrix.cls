public class CalculateLoanTatMatrix {
	
	Public static Final String HOLDTATNAMES= System.Label.Exclude_Hold_Time_TAT_Name;
    public static void calculateTAT(Set<Id> loanapplicationIds){
        Map<String,LoanTATMatrix__c> loanTatMatrixMap = new Map<String,LoanTATMatrix__c>();
		Map<String,List<String>> stagetoTATMapping = new Map<String,List<String>>();
        Set<String> tatNames = new Set<String>();
		for(TATApplicability__mdt tatmdt: [SELECT Id,Stage__c,TATName__c FROM TATApplicability__mdt]){
			if(stagetoTATMapping.containsKey(tatmdt.Stage__c)){
				stagetoTATMapping.get(tatmdt.Stage__c).add(tatmdt.TATName__c);
                tatNames.add(tatmdt.TATName__c);
			}else{
				stagetoTATMapping.put(tatmdt.Stage__c,new List<String>{tatmdt.TATName__c});
			}	
            tatNames.add(tatmdt.TATName__c);
			
		}
        for(LoanAppl__c loanApp: [SELECT Id,Stage__c,FinnSubDtTime__c,DocGenerationDateTime__c,Lead__c,SubStage__c,Lead__r.CreatedDate,CreatedDate,(Select id,DateofReceiptbyOps__c from Document_Dispatch__r order by DateofReceiptbyOps__c DESC),(SELECT Decision__c,Date_Time__c,CreatedDate FROM UWDecisions__r ORDER BY CreatedDate),(SELECT ID,Status__c,EntryTime__c,ExitTime__c,TimeSpentHrs__c,Stage__c,Sub_Stage__c,ApplicableTATs__c,HoldReason__c FROM Loan_TATs__r ORDER BY CreatedDate) FROM LoanAppl__c WHERE Id IN:loanapplicationIds]){
			
			loanTatMatrixMap = getTAT(loanApp,tatNames,loanTatMatrixMap);
        }
        
        if(!loanTatMatrixMap.isEmpty()){
            upsert loanTatMatrixMap.values() UniqueId__c;
        }
        
		
    }
	
	public static Map<String,LoanTATMatrix__c> getTAT(LoanAppl__c loanApp,Set<String> tatNames,Map<String,LoanTATMatrix__c> loanTatMatrixMap){
		//List<String> listTatNames = stagetoTATMapping.get(loanApp.Stage__c);
		system.debug('loanApp'+loanApp);
        system.debug('tatNames'+tatNames);
        system.debug('loanTatMatrixMap'+loanTatMatrixMap);
		LoanTATMatrix__c tatMatrixSobj;
		String stageName = loanApp.Stage__c;
		Decimal holdTAT= 0;
		Decimal diffMilliSecs;
		Decimal inhours;
		Decimal totalTATtime;
		Boolean validTAT = false;
        Decimal firstDecisionTAT= 0;
        DateTime firstEntryDateTime;
        Decimal holdReasonTATForDocumentAwaited = 0;
		for(String tatName : tatNames){
			validTAT = false;
			holdTAT = 0;
			totalTATtime = 0;
            holdReasonTATForDocumentAwaited = 0;
			tatMatrixSobj = new LoanTATMatrix__c();
			tatMatrixSobj.LoanApp__c = loanApp.Id;
            tatMatrixSobj.UniqueId__c = loanApp.Id+'-'+tatName;
            tatMatrixSobj.TATName__c = tatName;
			if(tatName == 'Lead to Login' && loanApp.Lead__c != NULL){
				diffMilliSecs = Decimal.valueOf(loanApp.CreatedDate.getTime() - loanApp.Lead__r.CreatedDate.getTime());
				inhours = diffMilliSecs/1000/60/60;
				tatMatrixSobj.TimeSpentInhrs__c = inhours;
				loanTatMatrixMap.put(loanApp.Id+'-'+tatName,tatMatrixSobj);
				continue;
			}else if(tatName == 'Lead to Disbursement TAT' && loanApp.FinnSubDtTime__c != NULL && loanApp.Lead__c != NULL){
				diffMilliSecs = Decimal.valueOf(loanApp.FinnSubDtTime__c.getTime() - loanApp.Lead__r.CreatedDate.getTime());
				inhours = diffMilliSecs/1000/60/60;
				tatMatrixSobj.TimeSpentInhrs__c = inhours;
				loanTatMatrixMap.put(loanApp.Id+'-'+tatName,tatMatrixSobj);
				continue;
			}else if(tatName == 'Login to Disbursement TAT' && loanApp.FinnSubDtTime__c != NULL){
				diffMilliSecs = Decimal.valueOf(loanApp.FinnSubDtTime__c.getTime() - loanApp.CreatedDate.getTime());
				inhours = diffMilliSecs/1000/60/60;
				tatMatrixSobj.TimeSpentInhrs__c = inhours;
				loanTatMatrixMap.put(loanApp.Id+'-'+tatName,tatMatrixSobj);
				continue;
            }else if(tatName == 'NDC 2 to Disbursement' && loanApp.FinnSubDtTime__c != NULL 
                     && loanApp.Document_Dispatch__r.size() > 0 && loanApp.Document_Dispatch__r[0].DateofReceiptbyOps__c != null){
                diffMilliSecs = Decimal.valueOf(loanApp.FinnSubDtTime__c.getTime() - loanApp.Document_Dispatch__r[0].DateofReceiptbyOps__c.getTime());
				inhours = diffMilliSecs/1000/60/60;
				tatMatrixSobj.TimeSpentInhrs__c = inhours;
				loanTatMatrixMap.put(loanApp.Id+'-'+tatName,tatMatrixSobj);
				continue;
            }
			for(LoanTAT__c stageTAT: loanApp.Loan_TATs__r){
				
				if(!String.isBlank(stageTAT.ApplicableTATs__c) && stageTAT.ApplicableTATs__c.contains(tatName)){
					
                    if(tatName == 'Underwriter to Rejection'  && stageTAT.Status__c == 'Rejected'){
                        //loanApp.Loan_TATs__r is always sorted by createddate so we will look for First Status as Rejected and entry is there in ApplicableTATs field
                    	//break the loop
                    	break;
                    }else if((tatName == 'Underwriter TAT' || tatName == 'Decision TAT') && (stageTAT.Status__c == 'Approved'|| stageTAT.Status__c =='Rejected' || stageTAT.Status__c =='Soft Approved')){
                        //loanApp.Loan_TATs__r is always sorted by createddate so we will look for First Status as Rejected and entry is there in ApplicableTATs field
                    	//break the loop
                    	break;
                    }else if((tatName == 'Sanction TAT') && (stageTAT.Status__c == 'Approved' || stageTAT.Status__c =='Soft Approved')){
                        //loanApp.Loan_TATs__r is always sorted by createddate so we will look for First Status as Rejected and entry is there in ApplicableTATs field
                    	//break the loop
                    	break;
                    }
                    if(stageTAT.ExitTime__c != NULL && tatName != 'Sanction to Document generation' && tatName != 'Document Generation to Document Submission'){
                        diffMilliSecs = Decimal.valueOf(stageTAT.ExitTime__c.getTime() - stageTAT.EntryTime__c.getTime());
                        inhours = diffMilliSecs/1000/60/60;
                        totalTATtime+=inhours;
                        validTAT = true;
                    }else if(tatName == 'Sanction to Document generation' && loanApp.DocGenerationDateTime__c != null){
                        diffMilliSecs = Decimal.valueOf( loanApp.DocGenerationDateTime__c.getTime() - stageTAT.EntryTime__c.getTime());
                        inhours = diffMilliSecs/1000/60/60;
                        totalTATtime+=inhours;
                        validTAT = true;
                        break;
                        
                    }else if(tatName == 'Document Generation to Document Submission' && stageTAT.ExitTime__c != NULL && loanApp.DocGenerationDateTime__c != NULL){
                        //for this we have to consider the latest exit time and list will always be in sorted order.
                        diffMilliSecs = Decimal.valueOf(stageTAT.ExitTime__c.getTime() - loanApp.DocGenerationDateTime__c.getTime());
                        inhours = diffMilliSecs/1000/60/60;
                        totalTATtime=inhours;
                        validTAT = true;
                        continue;
                    }
					
                    
                    
                    
				}
				if(HOLDTATNAMES.contains(tatName)&& !String.isBlank(stageTAT.ApplicableTATs__c) && stageTAT.ApplicableTATs__c.contains(tatName)){
					if(stageTAT.Status__c == 'Hold' && stageTAT.ExitTime__c != NULL){
						diffMilliSecs = Decimal.valueOf(stageTAT.ExitTime__c.getTime() - stageTAT.EntryTime__c.getTime());
						inhours = diffMilliSecs/1000/60/60;
						holdTAT+=inhours;
                        if(stageTAT.HoldReason__c == 'Information/ documentation awaited'){
                            holdReasonTATForDocumentAwaited+=inhours;
                        }
						validTAT = true;
					}
					
				}
			}
			
            if(tatName != 'Sales TAT'){
                totalTATtime=totalTATtime-holdTAT;
            }else{
                totalTATtime=totalTATtime+holdReasonTATForDocumentAwaited;
            }
			
			
			if(validTAT){
				tatMatrixSobj.TimeSpentInhrs__c = totalTATtime;
				loanTatMatrixMap.put(loanApp.Id+'-'+tatName,tatMatrixSobj);
			}
			
		}
		return loanTatMatrixMap;
	}
}