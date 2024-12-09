@IsTest
public class CrifExecuteAPIRequestWrapperTest {
	@IsTest
	public static void testParse() { 
        String jsonString = '{"StrategyOneRequest":{"Header":"","Body":{"APPLICATION":{"Variables":{"summary_total_loan_amount_including_insurance":0.0}}}}}';
        CrifExecuteAPIRequestWrapper obj = CrifExecuteAPIRequestWrapper.parse(jsonString);
		System.assert(obj != null);
	}
}