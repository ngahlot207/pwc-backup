public class UiThemeController {

    @AuraEnabled
    public static String getUiTheme(){
        String themeType = UserInfo.getUITheme();
        system.debug('themeType' + themeType);
        return themeType;
    }
}