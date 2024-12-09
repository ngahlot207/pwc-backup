public class NumberToStringConverter {

    @testVisible private static final String[] ones = new String[]{'', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'};
    @testVisible private static final String[] tens = new String[]{'', 'Ten', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
    @testVisible private static final String[] teens = new String[]{'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};

    @AuraEnabled(cacheable=true)
    public static String convertToWords(Integer num) {
        if (num == 0) {
            return 'Zero';
        }
       
        return convertToWordsHelper(num) + ' Rupees';
    }
   
    @testVisible
    private static String convertToWordsHelper(Integer num) {
        String words = '';
       
        if (num < 10) {
            words += ones[num];
        } else if (num < 20) {
            words += teens[num - 10];
        } else if (num < 100) {
            words += tens[num / 10] + ' ' + ones[Math.mod(num,10)];
        } else if (num < 1000) {
            words += ones[num / 100] + ' Hundred ' + convertToWordsHelper(Math.mod(num,100));
        } else if (num < 100000) {
            words += convertToWordsHelper(num / 1000) + ' Thousand ' + convertToWordsHelper(Math.mod(num,1000));
        } else if (num < 10000000) {
            words += convertToWordsHelper(num / 100000) + ' Lakh ' + convertToWordsHelper(Math.mod(num,100000));
        } else {
            words += convertToWordsHelper(num / 10000000) + ' Crore ' + convertToWordsHelper(Math.mod(num,10000000));
        }
       
        return words.trim();
    }
}