@istest
public class UiThemeControllerTest {

    @isTest
    static void uiThemeControllerMethod(){
        String returnVal = UiThemeController.getUiTheme();
        system.assertEquals('Theme3',returnVal);
    }
}