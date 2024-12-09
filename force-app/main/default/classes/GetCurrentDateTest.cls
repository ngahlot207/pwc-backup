@isTest
public class GetCurrentDateTest {

    @isTest
    static void testGetCurrentDate() {
        // Call the getDate method from GetCurrentDate class
        Date currentDate = GetCurrentDate.getDate();

        // Assert that the returned date is not null
        System.assertNotEquals(null, currentDate);

        // Assert that the returned date matches today's date
        System.assertEquals(Date.today(), currentDate);
    }
}