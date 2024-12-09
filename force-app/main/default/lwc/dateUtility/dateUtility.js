// Supported Format ::  2024-05-02T07:38:24.000Z =>  02-May-2024, 1:08 PM
const formattedDateTimeWithoutSeconds=(dateTimeValue)=>{
        
        if (!dateTimeValue) {
            return '';
        }
        const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        const dateTime = new Date(dateTimeValue);
        const month = months[dateTime.getMonth()];
        if(dateTime.getDate() && dateTime.getFullYear()){
        const day = ('0' + dateTime.getDate()).slice(-2);    
        const formattedDate = `${day}-${month}-${dateTime.getFullYear()}`;
        const ampm = dateTime.getHours() >= 12 ? 'PM' : 'AM';
        const hours = dateTime.getHours() % 12 || 12;
        const minutes = ('0' + dateTime.getMinutes()).slice(-2);
         return `${formattedDate}, ${hours}:${minutes} ${ampm}`;
        }else{
       return '';
        }
    }

    //  Supported Format :: "LoanDisbDate__c":"2023-10-28",
const formattedDate=(dateTimeValue)=>{
        
        if (!dateTimeValue) {
            return '';
        }
        const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        const dateTime = new Date(dateTimeValue);
        const month = months[dateTime.getMonth()];

        if(dateTime.getDate() && dateTime.getFullYear()){
        const day = ('0' + dateTime.getDate()).slice(-2);    
        const formattedDate = `${day}-${month}-${dateTime.getFullYear()}`;
        
         return formattedDate;
        }else{
       return '';
        }
    }


//Supported format :: 2024-05-06T11:43:44.000Z => 06-May-2024 5:13:47 PM
const formattedDateTimeWithSeconds=(date) =>{
        const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
 
        if(date.getDate() && date.getFullYear()){
        const day = ('0' + date.getDate()).slice(-2);
        const month = months[date.getMonth()];
        const year = date.getFullYear();
        let formattedDate = `${day}-${month}-${year}`;
 
        // Check if the input date has time information
        if (date.getHours() || date.getMinutes() || date.getSeconds()) {
            let hours = date.getHours();
            const minutes = ('0' + date.getMinutes()).slice(-2);
            const seconds = ('0' + date.getSeconds()).slice(-2);
            const ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; // the hour '0' should be '12'
            formattedDate += ` ${hours}:${minutes}:${seconds} ${ampm}`;
        }
 
        return formattedDate;
    }else{
        return '';
    }

}

// Supported Format ::  2020-03-20  =>20-Mar-2020
function formatDateFunction(inputDate) {
    if (!inputDate) {
        return ''; // return empty string if inputDate is null or undefined
    }

    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const parts = inputDate.split('-');

    // Check if inputDate has valid format
    if (parts.length !== 3) {
        return ''; // return empty string if inputDate format is invalid
    }

    const day = parts[2];
    const month = months[parseInt(parts[1]) - 1];
    const year = parts[0];

    return `${day}-${month}-${year}`;
}



export { formattedDateTimeWithoutSeconds , formattedDateTimeWithSeconds ,formattedDate,formatDateFunction};