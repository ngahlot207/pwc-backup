public class FormReceiverController {
    public String submittedName { get; set; }
    public String submittedEmail { get; set; }

    public FormReceiverController() {
        // Retrieve the form data from the request parameters
        Map<String, String> params = ApexPages.currentPage().getParameters();
        system.debug(params);
        submittedName = params.get('name');
        submittedEmail = params.get('email');
        
        // Optionally, you can add logic to handle missing or invalid data
        if (submittedName == null || submittedEmail == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Form data is incomplete.'));
        }
    }
}