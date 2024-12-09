import { LightningElement,track,wire } from 'lwc';
import readFileFromRecord from '@salesforce/apex/ReadFileData.readFileFromRecord';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs'
import { createRecord } from 'lightning/uiRecordApi';
import getJsonToExcelMetadata from '@salesforce/apex/ExcelDataToJsonApexClass.getJsonToExcelMetadataForAppliBank';
import jsonExcelMetadataForAppliDetail from '@salesforce/apex/ExcelDataToJsonApexClass.MetadataForAppliBankDetail';
import updateData from '@salesforce/apex/ExcelDataToJsonApexClass.upsertSobjDataWIthRelatedChilds';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
//import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import workbook from "@salesforce/resourceUrl/writeexcelfile";
let XLS = {};

export default class ExcelDataToJson extends LightningElement {
    @track acceptedFormats = ['.xls', '.xlsx'];
    @track _foreditableTableData=[];
    version
    async connectedCallback() {
        await loadScript(this, SheetJS1); // load the library
        // At this point, the library is accessible with the `XLSX` variable
        this.version = XLSX.version;
        console.log('version: '+this.version);  

        await loadScript(this, workbook )
            .then(async (data) => {
                console.log("success------>>>", data);
            })
            .catch(error => {
                console.log("failure-------->>>>", error);
            });
    }
    @wire(getJsonToExcelMetadata)
    wiredJsonToExcelMetadata({ error, data }) {
        if (data) {
            console.log('Metadata Retrieved: ', data);
            let fieldAPIToSourceColumnMap = {};
            data.forEach(record => {
                fieldAPIToSourceColumnMap[record.Field_API_Name__c] = record.SourceColumn__c;
            });
            this.fieldAPIToSourceColumnMap=fieldAPIToSourceColumnMap;
            console.log('fieldAPIToSourceColumnMap'+JSON.stringify(this.fieldAPIToSourceColumnMap))

        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }
    @track metadataForAppliDetail;
    @wire(jsonExcelMetadataForAppliDetail)
    wiredMetadataForAppBnkDetail({ error, data }) {
        if (data) {
            console.log('Metadata Retrieved for applibnkdeatil: ', data);
            this.metadataForAppliDetail=data;
            
        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
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
    
    async readFromFile() {
        let returnVal = await readFileFromRecord({recordId:'0012w00001aFxzbAAC'})
        let wb = XLS.read(returnVal, {type:'base64', WTF:false});
        console.log(this.to_json(wb));
    }

    to_json(workbook) {
        var result = {};
		workbook.SheetNames.forEach(function(sheetName) {
			var roa = XLS.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
			if(roa.length) result[sheetName] = roa;
		});
		return JSON.stringify(result, 2, 2);
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
            const reader = new FileReader();
            reader.onload = () => {
                const workbook = XLSX.read(reader.result, { type: 'binary' });
                const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
                const sheet = workbook.Sheets[sheetName];
                const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
              //  console.log('jsonData'+jsonData); // Output JSON data to console
              
                var data = JSON.stringify(jsonData);
               const records = JSON.parse(data);
               console.log('objobjobjobj>>>>>>>>>jsonStr',JSON.stringify(records));
                
                this.createRecordForSave(records);
                
             };
            reader.readAsBinaryString(file);
            
        }
        /*var reader = new FileReader();
        console.log('488888>>>>>>')
        reader.onload = event => {
            var data=event.target.result;
            var workbook=XLS.read(data, {
                type: 'binary'
            });
            console.log('>>>>>>>>')
            var XL_row_object= XLSX.utils.sheet_to_row_object_array(sheet, { header: 1 });
          //  var XL_row_object = XLS.utils.sheet_to_row_object_array(workbook.Sheets["Sheet1"]);
            var data = JSON.stringify(XL_row_object);
            console.log('dtaaaaaaaaaa',JSON.stringify(data));
        };
        reader.onerror = function(ex) {
            this.error=ex;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while reding the file',
                    message: ex.message,
                    variant: 'error',
                }),
            );
        };
        reader.readAsBinaryString(file);*/
    }
    get options() {
        return [
            { label: 'Y', value: 'Y' },
            { label: 'N', value: 'N' },
           
        ];
    }
    listOfAllAppBnkDetailRecs;
    wrapBankObj={};
    createRecordForSave(records){
        
        const listAllbnkDetailRec=[];
        const appBnkDtailRec=[{"ApplBanking__c":"","Month__c":"","Year__c":"","ValueSummationCredit__c":'',"ValueSummationDebit__c":'',"CountofCredit__c":'',"CountofDebit__c":'',"InwardReturnsCount__c":'',"OutwardReturnsCount__c":'',"StopPaymentCount__c":'',"MinBalanceCharges__c":"","BalanceAt_1st__c":'',"BalanceAt_5th__c":'',"BalanceAt_10th__c":'',"BalanceAt_15th__c":'',"BalanceAt_20th__c":'',"BalanceAt_25th__c":'',"AverageBankBalance__c":''}];
        //console.log('records[jjjj]'+records[3]['__EMPTY_1'])
        /*this.wrapBankObj["Name_of_the_Primary_Account_Holder_s__c"] = records[0]['__EMPTY_2'] !=='undefined' ?  records[0]['__EMPTY_2']: "";
        this.wrapBankObj["AccountName__c"] = records[1]['__EMPTY_1'] !=='undefined' ?  records[1]['__EMPTY_1']: "";
        this.wrapBankObj["AC_No__c"] = records[2]['__EMPTY_1'] !=='undefined' ?  records[2]['__EMPTY_1']: "";

        this.wrapBankObj["PeriodOfBanking__c"] = records[3]['__EMPTY_1'] !=='undefined' ?  records[3]['__EMPTY_1']: "";
        this.wrapBankObj["BankName__c"] = records[1]['__EMPTY_8'] !=='undefined' ?  records[1]['__EMPTY_8']: "";
        this.wrapBankObj["AccountType__c"] = records[2]['__EMPTY_8'] !=='undefined' ?  records[2]['__EMPTY_8']: "";
        this.wrapBankObj["EMIPaidfromthisAccount__c"] = records[4]['__EMPTY_2'] !=='undefined' ?  records[4]['__EMPTY_2']: "";
        console.log(' this.wrapBankObj'+ JSON.stringify(this.wrapBankObj))*/
        let wrapBankObjnew={};

        wrapBankObjnew["Name_of_the_Primary_Account_Holder_s__c"]=records[0][this.fieldAPIToSourceColumnMap["Name_of_the_Primary_Account_Holder_s__c"]];
       // wrapBankObjnew["AccountName__c"]=records[1][this.fieldAPIToSourceColumnMap["AccountName__c"]];
       //wrapBankObjnew["EMIPaidfromthisAccount__c"]=records[4][this.fieldAPIToSourceColumnMap["EMIPaidfromthisAccount__c"]];
       //wrapBankObjnew["PeriodOfBanking__c"]=records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]];
        //wrapBankObjnew["BankName__c"]=records[1][this.fieldAPIToSourceColumnMap["BankName__c"]];
        wrapBankObjnew["AC_No__c"]=records[2][this.fieldAPIToSourceColumnMap["AC_No__c"]];
        const [startDateString, endDateString] = records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]].split(" to ");
        wrapBankObjnew["PeriodOfBankingStart__c"]=new Date(startDateString);
        wrapBankObjnew["PeriodOfBankingEnd__c"]=new Date(endDateString);
         wrapBankObjnew["AccountType__c"]=records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]];
        wrapBankObjnew["Appl__c"]='a0AC4000000Jf7VMAS';
        wrapBankObjnew["LoanAppl__c"]='a08C40000085RCfIAM';
        this.wrapBankObj=wrapBankObjnew;
        console.log('this.wrapBankObjnew'+JSON.stringify(wrapBankObjnew))
        this._foreditableTableData=[];           
      
        for(let i=7; i<records.length-2; i++){
            const newRecord = { ...appBnkDtailRec[0], Month__c: "", Year__c: "", ValueSummationDebit__c: "", ValueSummationCredit__c: "", CountofDebit__c: "", CountofCredit__c:"",InwardReturnsCount__c:"",OutwardReturnsCount__c:"", StopPaymentCount__c:"", MinBalanceCharges__c:"", BalanceAt_1st__c:"", BalanceAt_5th__c:"", BalanceAt_10th__c:"",BalanceAt_15th__c:"", BalanceAt_20th__c:"", BalanceAt_25th__c:""};
            for(const rec of this.metadataForAppliDetail){
                console.log('recrecrec'+rec.SourceColumn__c)
                if(rec.Field_API_Name__c =='Month__c,Year__c'){
                    const dateOfPeriod = records[i][rec.SourceColumn__c];
                    var dateFormat=this.convertDate(dateOfPeriod);
                    const monthNdYear=this.getFormattedDate(dateFormat);
                    const [month, year] = monthNdYear.split('-');
                    newRecord.Month__c=month;
                    newRecord.Year__c=year;
                }else if(rec.Field_API_Name__c =='CountofDebit__c' || rec.Field_API_Name__c =='CountofCredit__c'){
                    newRecord[rec.Field_API_Name__c]= parseFloat(records[i][rec.SourceColumn__c]);
                }
                else{
                    newRecord[rec.Field_API_Name__c]= records[i][rec.SourceColumn__c];
                }
                
            }
            this._foreditableTableData.push(newRecord)
            console.log('this._foreditableTableData>>'+this._foreditableTableData)
            /*const dateOfPeriod = records[i]['Banking -1'];
            var dateFormat=this.convertDate(dateOfPeriod);
            const monthNdYear=this.getFormattedDate(dateFormat);
            const [month, year] = monthNdYear.split('-');
            const ValueSummationDebit = records[i]['__EMPTY'] !=='undefined' ?  records[i]['__EMPTY']: "";
            const valueSummationCredit = records[i]['__EMPTY_1'] !=='undefined' ?  records[i]['__EMPTY_1']: "";
            const CountofDebit = records[i]['__EMPTY_2'] !=='undefined' ?  records[i]['__EMPTY_2']: "";
            const CountofCredit = records[i]['__EMPTY_3'] !=='undefined' ?  records[i]['__EMPTY_3']: "";
            const InwardReturnsCount = records[i]['__EMPTY_4'] !=='undefined' ?  records[i]['__EMPTY_4']: "";
            const OutwardReturnsCount = records[i]['__EMPTY_5'] !=='undefined' ?  records[i]['__EMPTY_5']: "";
            const StopPaymentCount = records[i]['__EMPTY_6'] !=='undefined' ?  records[i]['__EMPTY_6']: "";
            const MinBalanceCharges = records[i]['__EMPTY_7'] !=='undefined' ?  records[i]['__EMPTY_7']: "";
            const BalanceAt_1st = records[i]['__EMPTY_8'] !=='undefined' ?  records[i]['__EMPTY_8']: "";
            const BalanceAt_5th = records[i]['__EMPTY_9'] !=='undefined' ?  records[i]['__EMPTY_9']: "";
            const BalanceAt_10th = records[i]['__EMPTY_10'] !=='undefined' ?  records[i]['__EMPTY_10']: "";
            const BalanceAt_15th = records[i]['__EMPTY_11'] !=='undefined' ?  records[i]['__EMPTY_11']: "";
            const BalanceAt_20th = records[i]['__EMPTY_12'] !=='undefined' ?  records[i]['__EMPTY_12']: "";
            const BalanceAt_25th = records[i]['__EMPTY_13'] !=='undefined' ?  records[i]['__EMPTY_13']: "";
            const ValueSummationDebit = records[i]['__EMPTY'] !=='undefined' ?  records[i]['__EMPTY']: "";
            const valueSummationCredit = records[i]['__EMPTY_1'] !=='undefined' ?  records[i]['__EMPTY_1']: "";
            const CountofDebit = '';
            const CountofCredit = '';
            const InwardReturnsCount = records[i]['__EMPTY_4'] !=='undefined' ?  records[i]['__EMPTY_4']: "";
            const OutwardReturnsCount = records[i]['__EMPTY_5'] !=='undefined' ?  records[i]['__EMPTY_5']: "";
            const StopPaymentCount = records[i]['__EMPTY_6'] !=='undefined' ?  records[i]['__EMPTY_6']: "";
            const MinBalanceCharges = records[i]['__EMPTY_7'] !=='undefined' ?  records[i]['__EMPTY_7']: "";
            const BalanceAt_1st = records[i]['__EMPTY_8'] !=='undefined' ?  records[i]['__EMPTY_8']: "";
            const BalanceAt_5th = records[i]['__EMPTY_9'] !=='undefined' ?  records[i]['__EMPTY_9']: "";
            const BalanceAt_10th = records[i]['__EMPTY_10'] !=='undefined' ?  records[i]['__EMPTY_10']: "";
            const BalanceAt_15th = records[i]['__EMPTY_11'] !=='undefined' ?  records[i]['__EMPTY_11']: "";
            const BalanceAt_20th = records[i]['__EMPTY_12'] !=='undefined' ?  records[i]['__EMPTY_12']: "";
            const BalanceAt_25th = records[i]['__EMPTY_13'] !=='undefined' ?  records[i]['__EMPTY_13']: "";
            

            const newRecord = { ...appBnkDtailRec[0], Month__c: month, Year__c: year, ValueSummationDebit__c: ValueSummationDebit, ValueSummationCredit__c: valueSummationCredit, CountofDebit__c: CountofDebit, CountofCredit__c:CountofCredit,InwardReturnsCount__c:InwardReturnsCount,OutwardReturnsCount__c:OutwardReturnsCount, StopPaymentCount__c:StopPaymentCount, MinBalanceCharges__c:MinBalanceCharges, BalanceAt_1st__c:BalanceAt_1st, BalanceAt_5th__c:BalanceAt_5th, BalanceAt_10th__c:BalanceAt_10th,BalanceAt_15th__c:BalanceAt_15th, BalanceAt_20th__c:BalanceAt_20th, BalanceAt_25th__c:BalanceAt_25th};
            this._foreditableTableData.push(newRecord)*/

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
    handleSaveData(){
        console.log('inhandleSavedata')
        let ChildRecords = [];
        let DataRecords = [];
        let upsertDataList=[];
        let childRecordObj = {};
        this.wrapBankObj.sobjectType='ApplBanking__c'; 
        if(this._foreditableTableData){
            for(var i=0;i<this._foreditableTableData.length;i++){
            childRecordObj = {...this._foreditableTableData[i]};
            childRecordObj.sobjectType='ApplBankDetail__c',
            ChildRecords.push(childRecordObj);
           }  
        }
        let upsertData={                       
            parentRecord:this.wrapBankObj,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'ApplBanking__c'
        }
        console.log('DataRecords>>>>>>>>>>>>>>>>>',JSON.stringify(upsertData))
        updateData ({upsertData:upsertData})
            .then(result => {  
                console.log('resultresultresultresultresult'+JSON.stringify(result))  
                
            }).catch(error => {
                
                console.log(error);
        })
    }
    columnHeader = ['Name', 'Age', 'Location']
    conatctData=[
        { Name: 'John', Age: 30, Location: 'New York' },
        { Name: 'Alice', Age: 25, Location: 'San Francisco' },
        { Name: 'Bob', Age: 35, Location: 'Los Angeles' }
    ];
    exportToExcel(){
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        // Add the data rows
        this.conatctData.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.Name+'</th>'; 
            doc += '<th>'+record.Age+'</th>'; 
            doc += '<th>'+record.Location+'</th>';
            
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Contact Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}