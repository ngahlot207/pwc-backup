public without sharing class AppleNotificationInvocableClass {
    
    @InvocableMethod(label='Send Ios Notification' description='Send Ios Notification' category='Notification')
    public static void AppleNotificationInvocableClass(List<InputVariables> inputvariable) {

        AppleNotification.sendAppleNotification(inputvariable.get(0).title, inputvariable.get(0).body, inputvariable.get(0).recipientIds, inputvariable.get(0).targetId);
    }

    Public class InputVariables{
        @InvocableVariable
        public String title;
        @InvocableVariable
        public String body;
        @InvocableVariable
        public String targetId;
        @InvocableVariable
        public list<String> recipientIds;
       
    }
}