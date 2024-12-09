@isTest
public class RiskRatingRequestWrapperTest {

    @isTest
    static void testRiskRatingRequestWrapper() {
        RiskRatingRequestWrapper riskRatingRequest = new RiskRatingRequestWrapper();
        riskRatingRequest.RiskProfilingRequest = new RiskRatingRequestWrapper.RiskProfilingRequest();
        riskRatingRequest.RiskProfilingRequest.ApiToken = '39475a23-6dd8-43db-8a31-e12dc969324c';
        RiskRatingRequestWrapper.RecordRequestDetail recordDetail = new RiskRatingRequestWrapper.RecordRequestDetail();
        recordDetail.TransactionId = 'T1';
        riskRatingRequest.RiskProfilingRequest.RecordRequestDetails = new RiskRatingRequestWrapper.RecordRequestDetails();
        riskRatingRequest.RiskProfilingRequest.RecordRequestDetails.RecordRequestDetail = new List<RiskRatingRequestWrapper.RecordRequestDetail>{recordDetail};
            
        RiskRatingRequestWrapper wrp = new RiskRatingRequestWrapper();
        RiskRatingRequestWrapper wrp1 = new RiskRatingRequestWrapper();
        wrp1=  RiskRatingRequestWrapper.parse(JSON.serialize(wrp));    
 
        system.Assert(true);            
        System.assertEquals('39475a23-6dd8-43db-8a31-e12dc969324c', riskRatingRequest.RiskProfilingRequest.ApiToken);
    }
}