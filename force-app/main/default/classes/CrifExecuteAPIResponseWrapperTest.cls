@isTest
public class CrifExecuteAPIResponseWrapperTest {
 static testMethod void testWrp()
    {
        String jsonSample = '{"StrategyOneResponse":{"Header":{"InquiryCode":"REQUESTID","ProcessCode":"Fedfina_MSE","OrganizationCode":"ORGID"},"Body":{"application":{"Variables":{"call_id":123.45,"application_id":"App123","login_acceptance_date":"2023-01-01"}}}}}';

        CrifExecuteAPIResponseWrapper responseWrapper = CrifExecuteAPIResponseWrapper.parse(jsonSample);

        System.assertEquals('REQUESTID', responseWrapper.StrategyOneResponse.Header.InquiryCode);
        System.assertEquals('Fedfina_MSE', responseWrapper.StrategyOneResponse.Header.ProcessCode);
        System.assertEquals('ORGID', responseWrapper.StrategyOneResponse.Header.OrganizationCode);
        System.assertEquals(123.45, responseWrapper.StrategyOneResponse.Body.application.Variables.call_id);
        System.assertEquals('App123', responseWrapper.StrategyOneResponse.Body.application.Variables.application_id);
    }

}