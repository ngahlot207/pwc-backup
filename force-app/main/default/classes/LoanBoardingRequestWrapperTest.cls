@isTest
public class LoanBoardingRequestWrapperTest {

    @isTest
    static void testLoanBoardingRequestWrapper() {
        // Create an instance of LoanBoardingRequestWrapper
        LoanBoardingRequestWrapper loanBoardingRequest = new LoanBoardingRequestWrapper();

        // Test MortageDetails
        LoanBoardingRequestWrapper.MortageDetails mortageDetails = new LoanBoardingRequestWrapper.MortageDetails();
        mortageDetails.lienNumber = '12345';
        mortageDetails.loanOutstanding = '50000';
        mortageDetails.totalCollateralValue = '100000';
        mortageDetails.loanNumber = 'L123';

        // Test PropertyDetails
        LoanBoardingRequestWrapper.PropertyDetails propertyDetails = new LoanBoardingRequestWrapper.PropertyDetails();
        propertyDetails.propPinCode = '123456';
        propertyDetails.areaForPlot = 'PlotA';
        // Set other property details...

        // Test CollateralDetails
        LoanBoardingRequestWrapper.CollateralDetails collateralDetails = new LoanBoardingRequestWrapper.CollateralDetails();
        collateralDetails.collLodgement = 'Lodgement123';
        // Set other collateral details...

        // Test SourcingDetail
        LoanBoardingRequestWrapper.SourcingDetail sourcingDetail = new LoanBoardingRequestWrapper.SourcingDetail();
        sourcingDetail.schemeCurr = 'Scheme1';
        sourcingDetail.loanPurposeDesc = 'Purchase Property';
        // Set other sourcing details...

        // Test RateRiskDetails
        LoanBoardingRequestWrapper.RateRiskDetails rateRiskDetails = new LoanBoardingRequestWrapper.RateRiskDetails();
        rateRiskDetails.commissionRate = '5%';
        // Set other rate risk details...

        // Test ReferenceDetails
        LoanBoardingRequestWrapper.ReferenceDetails referenceDetails = new LoanBoardingRequestWrapper.ReferenceDetails();
        referenceDetails.refCity = 'City1';
        // Set other reference details...

        // Test DemoCorpRatingDetails
        LoanBoardingRequestWrapper.DemoCorpRatingDetails demoCorpRatingDetails = new LoanBoardingRequestWrapper.DemoCorpRatingDetails();
        demoCorpRatingDetails.corpRatingRemarks = 'Good';
        // Set other demo corp rating details...

        // Test DocCollectionDetails
        LoanBoardingRequestWrapper.DocCollectionDetails docCollectionDetails = new LoanBoardingRequestWrapper.DocCollectionDetails();
        docCollectionDetails.docName = 'Document1';
        // Set other document collection details...

        // Add all details to the main wrapper
        propertyDetails.mortageDetails = new List<LoanBoardingRequestWrapper.MortageDetails>{mortageDetails};
        propertyDetails.lienDetails = new List<LoanBoardingRequestWrapper.RepaymentDetails>{/* Add RepaymentDetails if needed */};
        propertyDetails.tranchDetails = new List<LoanBoardingRequestWrapper.RepaymentDetails>{/* Add RepaymentDetails if needed */};
        propertyDetails.constructionPurchase = new List<LoanBoardingRequestWrapper.RepaymentDetails>{/* Add RepaymentDetails if needed */};
        propertyDetails.fundsDetail = new List<LoanBoardingRequestWrapper.RepaymentDetails>{/* Add RepaymentDetails if needed */};

        // Set other details in the main wrapper...

        // Perform assertions or additional testing as needed
        System.assertEquals('123456', propertyDetails.propPinCode, 'Property Pin Code should match');

        // Add more assertions based on your testing requirements
    }
}