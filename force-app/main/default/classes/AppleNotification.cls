public without sharing class AppleNotification {
    public static void sendAppleNotification(String title,string body,List<String> recipientIds,String targetId) {
        Messaging.PushNotification msg = new Messaging.PushNotification();

        // Assembling the necessary payload parameters for Apple.
        // Apple params are: 
        // (<alert text>,<alert sound>,<badge count>,
        // <free-form data>)
        // This example doesn't use badge count or free-form data.
        // The number of notifications that haven't been acted
        // upon by the intended recipient is best calculated
        // at the time of the push. This timing helps
        // ensure accuracy across multiple target devices.
        Map<String, Object> applePayload = 
            Messaging.PushNotificationPayload.apple(title, '', null, null);

        Map<String, Object> aps = (Map<String, Object>)applePayload.get('aps');
        system.debug(applePayload);
        Map<String,String> alertPayLoad = new Map<String,String>();
        alertPayLoad.put('title',title);
        alertPayLoad.put('body',body);
        alertPayLoad.put('sid',targetId);
        aps.put('content-available',1);
        //aps.put('sid',targetId);
        //aps.put('alertBody',body);
        //aps.put('alertTitle',title);
        aps.put('alert',alertPayLoad);

        // Adding the assembled payload to the notification
        msg.setPayload(applePayload);

        // Adding recipient users to list
        Set<String> users = new Set<String>();
        users.addAll(recipientIds);
                        

        // Sending the notification to the specified app and users.
        // Here we specify the API name of the connected app.  
        msg.send('fedfina_los', users);
    }
}