@istest
public class CloneMetadataUtilityTest {
    
    @isTest
    static void cloneMetadataUtilityTestMethod() {
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
            'Applicant',
            'BT + Top Up'
        );
        system.assertEquals('Yes', returnDat.cloneStatus);
        
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat1 = CloneMetadataUtility.getCloneStatus(
            'Applicant',
            'Top Up'
        );
        system.assertEquals('Yes', returnDat1.cloneStatus);
        
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat2 = CloneMetadataUtility.getCloneStatus(
            'Applicant',
            'Different Property'
        );
        system.assertEquals('Yes', returnDat2.cloneStatus);
        
         CloneMetadataUtility.CloneMtdUtilityWrpr returnDat3 = CloneMetadataUtility.getCloneStatus(
            'Applicant',
            'Other'
        );
        system.assertEquals('Yes', returnDat3.cloneStatus);
        CloneMetadataUtility.CloneMtdUtilityWrpr returnData = CloneMetadataUtility.getCloneStatus(null,null);
    }
}