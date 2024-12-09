import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import icons from '@salesforce/resourceUrl/Icons';
import CURRENTUSERID from '@salesforce/user/Id';
//Labels
import csvFileHeader from '@salesforce/label/c.Bulk_Upload_Lead_CSV_Header';
import csvFilename from '@salesforce/label/c.Bulk_Upload_Lead_CSV_Filename';
import logFilename from '@salesforce/label/c.Bulk_Upload_Uploaded_Lead_Log_Filename';
import csvRowInfo from '@salesforce/label/c.Bulk_Upload_Lead_CSV_Row_Info';
import allowedRole from '@salesforce/label/c.Allowed_User_role_For_Bulk_Upload_Lead';
import templateDownloadSuccessMessage from '@salesforce/label/c.Bulk_Upload_Lead_Template_Download_Success_Message';
import filesUploadSuccessMessage from '@salesforce/label/c.Bulk_Upload_Lead_Files_Upload_Success_Message';
import filesUploadErrorMessage from '@salesforce/label/c.Bulk_Upload_Lead_Files_Upload_Error_Message';
import filesUploadSuccessErrorMessage from '@salesforce/label/c.Bulk_Upload_Lead_Files_Upload_SuccessError_Message';
//apex
import processCSV from '@salesforce/apex/LeadBulkUpload.processFile';
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";


export default class LeadBulkUpload extends NavigationMixin(LightningElement) {
    isSpinnerOn = true;
    csvFileName = csvFilename;
    logFileName = logFilename;
    csvHeader = csvFileHeader;
    @track allowedUserRole = allowedRole.split(',');
    successIcon = icons + '/success_green_circle_tick.svg';
    failureIcon = icons + '/failure_cross.svg';
    displayFileUpload = false;
    fileSize = "";
    uploadStatus = "";
    numberOfSuccessRecords = 0;
    numberOfFailedRecords = 0;
    progressVal = 0;
    isProgressbarOn = false;
    isUploadButtonDisable = false;
    @track userRole;
    @track allowedUpload = false;

    get isUploadSuccess() {
        return this.uploadStatus === "success";
    }

    get isUploadPartialSuccess() {
        return this.uploadStatus === "partial";
    }

    get isUploadFailure() {
        return this.uploadStatus === "failure";
    }

    get displayUploadFailSection() {
        return this.isUploadPartialSuccess || this.isUploadFailure;
    }

    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1'
    }
    // handleteamHierIdChange() {
    //     let tempParams = this.teamHierParam;
    //     tempParams.queryCriteria = ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1';
    //     this.teamHierParam = { ...tempParams };

    // }
    // @wire(getSobjectData, { params: '$teamHierParam' })
    // teamHierHandler({ data, error }) {
    //     if (data) {
    //         if (data.parentRecords !== undefined) {
    //             console.log('USER TH  Details ', data.parentRecords, this.allowedUserRole);
    //             this.userRole = data.parentRecords[0].EmpRole__c
    //             if (this.allowedUserRole.includes(this.userRole)) {
    //                 this.allowedUpload = true;
    //             }
    //         }
    //         this.isSpinnerOn = false;

    //     }
    //     if (error) {
    //         this.isSpinnerOn = false;
    //         console.error('ERROR CASE DETAILS:::::::#499', error)
    //     }
    // }

    connectedCallback() {
        console.log('TH Details Query ', this.teamHierParam);
        getSobjectData({ params: this.teamHierParam })
            .then((res) => {
                console.log('result of TH res ', res);
                let result = res.parentRecords[0];
                console.log('result of TH  ', result);
                if (result !== undefined) {
                    console.log('USER TH  Details ', result, this.allowedUserRole);
                    this.userRole = result.EmpRole__c
                    if (this.allowedUserRole.includes(this.userRole)) {
                        this.allowedUpload = true;
                    }
                }
                this.isSpinnerOn = false;
            })
            .catch((err) => {
                this.isSpinnerOn = false;
                console.error('ERROR loading TH', err)
            });
    }

    disconnectedCallback() {
        // it's needed for the case the component gets disconnected
        // and the progress is being increased
        clearInterval(this._interval);
    }


    resetModal() {
        this.displayFileUpload = false;
        this.fileSize = "";
        this.uploadStatus = "";
        this.numberOfSuccessRecords = 0;
        this.numberOfFailedRecords = 0;
        this.isProgressbarOn = false;
        this.isUploadButtonDisable = false;
    }

    progressBar(isProgressing) {
        //console.log('progressbar called');
        if (isProgressing) {
            this.isProgressbarOn = true;
            // start
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this._interval = setInterval(() => {
                this.progressVal = this.progressVal === 100 ? 0 : this.progressVal + 25;
            }, 100);
        } else {
            // stop
            this.isProgressbarOn = false;
            clearInterval(this._interval);
        }
    }

    buttonClickHandler(event) {
        let buttonName = event.target.dataset.id;
        console.log('buttonName=>' + buttonName);
        if (buttonName === 'cancel' || buttonName === 'close' || buttonName === 'done') {
            //window.history.back();
            this.resetModal();
            this.navigationMethod('standard__objectPage', 'Lead', 'home');
        }
        else if (buttonName === "upload") {
            this.handleFileUploadButtonClick(event.target);
        }
        else if (buttonName === "download") {
            //console.log('clicked download')
            this.handleDownloadButtonClick(event.target);
        }
        else if (buttonName === "fileclose") {
            this.handleFileCloseButtonClick(event.target);
        }
        else if (buttonName === "downloadlog") {
            this.handleDownloadLogButton(event.target);
        }
        this.fireButtonEvent(event.target.dataset.id);
    }

    handleFileUploadButtonClick(button) {
        let inputFile = this.template.querySelector('[data-id="fileInput"]');
        if (inputFile) {
            inputFile.click();
        }
    }

    handleFileCloseButtonClick() {
        this.resetModal();
        const inputFile = this.template.querySelector('[data-id="fileInput"]');
        if (inputFile) {
            inputFile.value = "";
        }
    }

    handleFileChange() {
        this.isUploadButtonDisable = true; //disable Upload File button
        //console.log('inside handleFileChange');
        var self = this;
        let file = this.template.querySelector('input').files[0],
            reader = new FileReader(),
            excelArr = [];

        self.csvFileName = file.name.split(".")[0];
        self.fileSize = Math.ceil(file.size / 1000);
        self.displayFileUpload = true;
        reader.readAsText(file);

        reader.onload = function (event) {

            //get the file and split and get the rows in an array
            let rows = event.target.result.split('\n'),
                copyRow = JSON.parse(JSON.stringify(rows)),
                header = copyRow[0].substring(0, copyRow[0].length - 1).split(','),
                excelHeader = header.filter(e => { return e });
            if (rows.length == 1) {
                self.showNotification('Error!', 'Please add data in excel', 'error');
                self.uploadStatus = "failure";
                return;
            }
            if (self.csvHeader != excelHeader.toString()) {

                self.showNotification('Error!', 'Unsupported Upload Format', 'error');
                self.uploadStatus = "failure";
                self.displayFileUpload = false;
                self.isUploadButtonDisable = false;
                return;
            }

            if (rows.length - 2 > 1000) {
                self.showNotification('Error!', 'Maximum 1000 Leads can be uploaded at a time', 'error');
                return;
            }

            self.progressBar(true); //calling progessBar method to start

            //checking for duplicate row in csv and eliminate that row
            var keys = {}; // store the keys that have processed
            var afterEleminateDuplicateRows = []; // array with accepted rows
            for (let i = 0; i < rows.length; i++) {
                let singleRowData = rows[i].replace(/(".*?")/g, (match) => match.replace(/,/g, "\u0000")); //replacing comma with NULL  where comma inside "" string(ie.Residential address field)
                singleRowData = singleRowData.split(',').map(item => item.replace(/\u0000/g, ',')); //adding comma again to NULL space after splitting
                let key = singleRowData[0] + '|' + singleRowData[2] + '|' + singleRowData[3] + singleRowData[10];
                if (key in keys) {
                    console.log("Duplicate at " + i + " is ignored");
                } else {
                    keys[key] = 1; // register key
                    afterEleminateDuplicateRows.push(singleRowData.join(','));
                }
            }
            //console.log('afterEleminateDuplicateRows=>'+JSON.stringify(afterEleminateDuplicateRows));
            rows = afterEleminateDuplicateRows;

            //move line by line
            for (let i = 1; i < rows.length - 1; i++) {
                //split by separator (,) and get the columns
                let currentRow = rows[i].replace(/(".*?")/g, (match) => match.replace(/,/g, "\u0000"));//replacing comma with NULL where comma inside "" string(ie.Residential address field)
                //console.log('currentRow=>'+currentRow);
                var isNotValid = /^[0-9,.]*$/.test(currentRow);
                //console.log('isNotValid=>'+isNotValid);
                if (!isNotValid) {
                    let cols = currentRow.split(',').map(item => item.replace(/\u0000/g, ',')),//adding comma again to NULL spsce after splitting
                        data = {};
                    //console.log('cols=>'+cols);
                    for (let j = 0; j < cols.length; j++) {
                        //the value of the current column.
                        let value = cols[j];
                        data[header[j]] = value;
                        //console.log('value=>'+value);
                        //console.log('data=>'+JSON.stringify(data));
                    }
                    excelArr.push(data);
                }
            }
            console.log('excelArr=>' + JSON.stringify(excelArr));
            //self.isSpinnerOn=true; //spinner on  
            //calling apex method 
            processCSV({ leadsStr: JSON.stringify(excelArr), csvHeader: JSON.stringify(excelHeader) })
                .then(res => {
                    //self.isSpinnerOn=false; //spinner off
                    self.progressBar(false); //calling progessBar method to
                    console.log('res : ', res)//;console.log(res);
                    let csvHeader = 'Status,' + excelHeader + '\n';

                    res.csvHeader = csvHeader;
                    self.serverResponse = res;
                    console.log('self.serverResponse=>' + JSON.stringify(self.serverResponse));
                    if (res.errorRowCounter > 0 && res.successRowCounter > 0) {
                        self.uploadStatus = "partial";
                        self.successErrorRowsMessage = csvRowInfo.replace('XXX', res.successRowCounter).replace('YYY', res.errorRowCounter);
                        self.numberOfSuccessRecords = res.successRowCounter;
                        self.numberOfFailedRecords = res.errorRowCounter;
                        self.showNotification('Warning!', filesUploadSuccessErrorMessage, 'warning');
                        if (res.errorString) {
                            const rows = Object.keys(res.errorString);
                            rows.reverse().forEach(row => {
                                let errorMessages = row + ' : ' + res.errorString[row];
                                self.showNotification('Error!', errorMessages, 'error', 'sticky');
                            });

                        }
                    }
                    else if (res.errorRowCounter > 0 && res.successRowCounter <= 0) {
                        self.uploadStatus = "failure";
                        self.showNotification('Error!', filesUploadErrorMessage, 'error');
                        if (res.errorString) {
                            const rows = Object.keys(res.errorString);
                            rows.reverse().forEach(row => {
                                let errorMessages = row + ' : ' + res.errorString[row];
                                self.showNotification('Error!', errorMessages, 'error', 'sticky');
                            });

                        }
                    }
                    else if (res.errorRowCounter <= 0 && res.successRowCounter > 0) {
                        self.uploadStatus = "success";
                        self.showNotification('Success!', filesUploadSuccessMessage, 'success');
                    }
                })
                .catch(error => {
                    //self.isSpinnerOn=false; //spinner off
                    self.progressBar(false); //calling progessBar method to stop progrssing
                    //console.log('error:= ',error,'==>' );console.log(JSON.stringify(error.message));
                    let errorMessage = error.message + ' \n Please contact System Administrator and share the error message.';
                    self.showNotification('Error!', errorMessage, 'error');
                })
        }
    }

    handleDownloadLogButton(button) {
        //console.log('dowload log file');
        //console.log('length=>'+this.serverResponse.csvData.length);
        let csv = this.serverResponse.csvHeader;
        for (let i = 0; i < this.serverResponse.csvData.length; i++) {
            csv += this.serverResponse.csvData[i].join(',');
            csv += "\n";
        }
        //console.log('csv=>'+JSON.stringify(csv));
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv).replaceAll('#', '%23');
        hiddenElement.target = '_blank';

        //provide the name for the CSV file to be downloaded
        hiddenElement.download = this.logFileName + '.csv';
        hiddenElement.click();
    }

    fireButtonEvent(name) {
        const event = new CustomEvent(
            'buttonclick', {
            detail: { 'buttonName': name }
        }
        );
        this.dispatchEvent(event);
    }

    handleDownloadButtonClick() {
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.csvHeader);
        hiddenElement.target = '_blank';
        //provide the name for the CSV file to be downloaded
        hiddenElement.download = this.csvFileName + '.csv';
        hiddenElement.click();
        console.log('csvHeader is : ' + this.csvHeader);
        this.showNotification('Success!', templateDownloadSuccessMessage, 'success');
    }


    showNotification(_title, _message, _variant, _mode = 'dismissible') {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
            mode: _mode, // Set mode from the argument
        });
        this.dispatchEvent(evt);
    }

    navigationMethod(_type, _objectApiName, _action) {
        //console.log('Navigation call');
        this[NavigationMixin.Navigate]({
            type: _type,
            attributes: {
                objectApiName: _objectApiName,
                actionName: _action,
            },
        });
    }

}