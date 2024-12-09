public class IntegrationInboundprocessor {
    
    
    public static void inboundProcess(list<IntgMsg__c> intMsglist)
    {
        System.debug(':::::::::IntegrationInboundprocessor');
        List<IntgMsg__c> paytmResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> imdResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> enachStatusResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> finnoneCallbackList = new List<IntgMsg__c>();
        List<IntgMsg__c> otcpddStatusResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> perfiosCallbackResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> trackwizzCKYCCallbackResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> masterDataSyncResponseList = new List<IntgMsg__c>();
        List<IntgMsg__c> finfortGSTCallback = new List<IntgMsg__c>();
        List<IntgMsg__c> finFortOrderStatusCallback = new List<IntgMsg__c>();
        List<IntgMsg__c> probeCallback = new List<IntgMsg__c>();
        List<IntgMsg__c> hunterCallback = new List<IntgMsg__c>();
        List<IntgMsg__c> perfiosConsentNotification = new List<IntgMsg__c>();
        List<IntgMsg__c> perfiosReportNotification = new List<IntgMsg__c>();
        
        for(IntgMsg__c intms: intMsglist)
        {	
            if(intms.Name=='IMD Cheque status'){
                imdResponseList.add(intms);
            }
            else if(intms.Name=='Enach Status Callback'){
                enachStatusResponseList.add(intms);
            }
            else if(intms.Name==System.label.FinnoneCallbackServiceName){
                finnoneCallbackList.add(intms);
            }
            else if(intms.Name=='OTCPDDStatusUpdate'){
                otcpddStatusResponseList.add(intms);
            }
            else if(intms.Name =='Perfios Callback'){
                perfiosCallbackResponseList.add(intms);
            }
            else if(intms.Name == 'Trackwizz CKYC Callback'){
                trackwizzCKYCCallbackResponseList.add(intms);
            }else if(intms.Name == 'Master data Sync'){
                masterDataSyncResponseList.add(intms);
            }
            else if(intms.Name == 'Crimecheck Callback'){
                
            }
            else if(intms.Name == 'BillDesk Callback'){
                
            }
            else if(intms.Name == 'FinFort Order Status Callback'){
                finFortOrderStatusCallback.add(intms);
            }
            else if(intms.Name == 'Probe42 Callback'){
                probeCallback.add(intms);
            }
            else if(intms.Name == 'Hunter Callback'){
                hunterCallback.add(intms);
            }
            else if(intms.Name == 'Perfios Consent Notification'){
                perfiosConsentNotification.add(intms);
            }
            else if(intms.Name == 'Perfios Report Notification'){
                perfiosReportNotification.add(intms);
            }
            
           // else if(intms.Name == 'Finfort GST Callback'){
             //   finfortGSTCallback.add(intms);
           // }
            else{
            //if(intms.Svc__c=='Paytmcallback'){
                paytmResponseList.add(intms);
            //}
            }
        }
        
        if(!paytmResponseList.isEmpty()){
            system.debug(paytmResponseList);
            PaytmCallbackResponseprocessor.process(paytmResponseList);
        }
        if(!imdResponseList.isEmpty()){
            system.debug(imdResponseList);
            IMDCallbackResponseProcessor.process(imdResponseList);
        }
        if(!enachStatusResponseList.isEmpty()){
            EnachStatusCallbackResponseProcessor.process(enachStatusResponseList);
        }
        if(!finnoneCallbackList.isEmpty()){
            FinnoneCallbackResponseProcessor.process(finnoneCallbackList);
        }
        if(!otcpddStatusResponseList.isEmpty()){
            OTCPDDStatusCallbackResponseProcessor.process(otcpddStatusResponseList);
        }
        if(!perfiosCallbackResponseList.isEmpty()){
            PerfiosCallbackResponseProcessor.process(perfiosCallbackResponseList);
        }
        if(!trackwizzCKYCCallbackResponseList.isEmpty()){
            TrackwizzCKYCCallbackResponseProcessor.process(trackwizzCKYCCallbackResponseList);
        }
        if(!masterDataSyncResponseList.isEmpty()){
            MasterDataSyncProcessor.process(masterDataSyncResponseList);
        }
         if(!finFortOrderStatusCallback.isEmpty()){
             FinFortOrderStatusCallbackProcessor.process(finFortOrderStatusCallback);
         }  
        if(!probeCallback.isEmpty()){
            ProbeCallbackResponseProcessor.process(probeCallback);
        }
        if(!hunterCallback.isEmpty()){
            HunterCallbackResponseProcessor.process(hunterCallback);
        }
        if(!perfiosConsentNotification.isEmpty()){
            PerfiosAAConsentCallbackRespProcessor.process(perfiosConsentNotification);
        }
        if(!perfiosReportNotification.isEmpty()){
            PerfiosAAReportCallbackRespProcessor.process(perfiosReportNotification);
        }
        //if(!finfortGSTCallback.isEmpty()){
        //    FinfortCallbackprocessor.process(finfortGSTCallback);
       // }
       
    }

}