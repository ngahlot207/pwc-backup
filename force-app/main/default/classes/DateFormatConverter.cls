public class DateFormatConverter {
    public static boolean checkDateFormat(String dateString){
        try {
            Date dateValue = DateFormatConverter.convertStringToDate(dateString);
            System.debug('Converted Date: ' + dateValue);
            
            dateValue = DateFormatConverter.convertStringToDate(dateString);//('20-06-1992');
            System.debug('Converted Date: ' + dateValue);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
        
    }
    public static Date convertStringToDate(String dateString) {
        if (String.isBlank(dateString)) {
            throw new IllegalArgumentException('Date string cannot be null or empty.');
        }
        
        Date parsedDate;
        
        // Check for dd/MM/yyyy format
        String regexSlashFormat = '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\\d{4}$';
        Pattern patternSlash = Pattern.compile(regexSlashFormat);
        Matcher matcherSlash = patternSlash.matcher(dateString);
        
        // Check for dd-MM-yyyy format
        String regexDashFormat = '^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-\\d{4}$';
        Pattern patternDash = Pattern.compile(regexDashFormat);
        Matcher matcherDash = patternDash.matcher(dateString);
        
        if (matcherSlash.matches()) {
            // Convert dd/MM/yyyy to Date
            String[] parts = dateString.split('/');
            parsedDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
        } else if (matcherDash.matches()) {
            // Convert dd-MM-yyyy to Date
            String[] parts = dateString.split('-');
            parsedDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
        } else {
            throw new IllegalArgumentException('Invalid date format. Expected formats: dd/MM/yyyy or dd-MM-yyyy.');
        }
        
        return parsedDate;
    }
}