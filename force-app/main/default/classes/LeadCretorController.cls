public class LeadCretorController {
    @AuraEnabled
    public static String uploadLeadsFromCSV(String csvString) {
        List<Lead> leadsToInsert = new List<Lead>();

        // Split CSV by lines
        List<String> lines = csvString.split('\n');
        

        // Assume the first line is the header
        List<String> headers = lines[0].split(',');

        // Process each subsequent line
        for (Integer i = 1; i < lines.size(); i++) {
            List<String> fields = lines[i].split(',');

            Lead lead = new Lead();
            for (Integer j = 0; j < headers.size(); j++) {
                String header = headers[j].trim();
                String field = fields[j].trim();

                // Set the lead fields dynamically
                if (header == 'FirstName') {
                    lead.FirstName = field;
                } else if (header == 'LastName') {
                    lead.LastName = field;
                } else if (header == 'Company') {
                    lead.Company = field;
                } else if (header == 'Email') {
                    lead.Email = field;
                } else if (header == 'Phone') {
                    lead.Phone = field;
                }
                // Add other lead fields as needed
            }

            leadsToInsert.add(lead);
        }

        // Insert leads and return a status message
        try {
            if (!leadsToInsert.isEmpty()) {
                insert leadsToInsert;
                return 'Successfully uploaded ' + leadsToInsert.size() + ' leads.';
            } else {
                return 'No leads to upload.';
            }
        } catch (DmlException e) {
            return 'Error inserting leads: ' + e.getMessage();
        }
    }
}