import { LightningElement,track,wire } from 'lwc';
import readFileFromRecord from '@salesforce/apex/ReadFileData.readFileFromRecord';
import insertRecords from '@salesforce/apex/CSVController.insertRecords';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs'
import { createRecord } from 'lightning/uiRecordApi';
import getJsonToExcelMetadata from '@salesforce/apex/ExcelDataToJsonApexClass.getJsonToExcelMetadataForAppliBank';
import jsonExcelMetadataForAppliDetail from '@salesforce/apex/ExcelDataToJsonApexClass.MetadataForAppliBankDetail';
let XLS = {};

export default class ExcelDataUploadComp extends LightningElement {
    @track acceptedFormats = ['.xls', '.xlsx','.csv'];
    @track _foreditableTableData=[];
    version

    @track finalStr;
    async connectedCallback() {
        await loadScript(this, SheetJS1); // load the library
        // At this point, the library is accessible with the `XLSX` variable
        this.version = XLSX.version;
        console.log('version: '+this.version);  
    }
     
     
    fieldAPIToSourceColumnMap;
    convertDate(originalDate) {
        const excelSerialDate = parseInt(originalDate);
        const millisecondsInDay = 24 * 60 * 60 * 1000; // Number of milliseconds in a day
        const dateOffset = (excelSerialDate - 25569) * millisecondsInDay; // Offset from 1/1/1970
        const targetDate = new Date(dateOffset);
        const month = targetDate.getMonth() + 1; // Month is zero-based, so add 1
        const day = targetDate.getDate();
        const year = targetDate.getFullYear();
        const formattedDate = `${month.toString().padStart(2, '0')}/${day.toString().padStart(2, '0')}/${year}`;
        return formattedDate;
    }
    
    

    handleUploadFinished(event){
        console.log('infilesssss')
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0) {   
            console.log('uploadedFiles.length'+uploadedFiles.length)
            this.ExcelToJSON(uploadedFiles[0])
        }
    }

    ExcelToJSON(file){
        
        if (file) {
            console.log('if file true');
            const reader = new FileReader();
            reader.onload = () => {
                console.log('onload')
                const workbook = XLSX.read(reader.result, { type: 'binary' });
                const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
                const sheet = workbook.Sheets[sheetName];
                const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
              //  console.log('jsonData'+jsonData); // Output JSON data to console
              
                var data = JSON.stringify(jsonData);
                console.log('dtaaaaaaaaaa',JSON.stringify(data));
               
                const records = JSON.parse(data);
              //  console.log('objobjobjobj>>>>>>>>>',records);
                console.log('objobjobjobj>>>>>>>>>jsonStr',JSON.stringify(records));
                
               // this.createRecordForSave(records);
                insertRecords({ recordsJson: data })
    .then(result => {
        console.log('Result of new class:'+JSON.stringify(result));
         
    })
    .catch(error => {
        console.log(error);
    });
             };
            reader.readAsBinaryString(file);
            
        }
         
    }
    
    getFormattedDate(dateFormat) {
        const dateParts = dateFormat.split('/');
        const monthNumber = parseInt(dateParts[0]);
        const year = dateParts[2];
        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        const monthAbbreviation = months[monthNumber - 1];
        return `${monthAbbreviation}-${year}`;
    }

    



}