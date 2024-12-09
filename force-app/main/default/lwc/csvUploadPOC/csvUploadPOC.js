import { LightningElement, api, track } from 'lwc';

import saveFile from '@salesforce/apex/CsvUploadControllerPOC.saveFile';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [

{ label: 'Field1', fieldName: 'Field1__c' },

{ label: 'Field2', fieldName: 'Field2__c'},

{ label: 'Field3', fieldName: 'Field3__c' },

{ label: 'Field4', fieldName: 'Field4__c'}

];

export default class LwcCSVUploader extends LightningElement {

@api recordid;

@track columns = columns;

@track data;

@track fileName = '';

@track UploadFile = 'Upload CSV File';

@track showLoadingSpinner = false;

@track isTrue = false;

selectedRecords;

filesUploaded = [];

file;

fileContents;

fileReader;

content;

MAX_FILE_SIZE = 1500000;

handleFilesChange(event) {

if (event.target.files.length > 0) {

this.filesUploaded = event.target.files;

this.fileName = this.filesUploaded[0].name;

}

}

handleSave() {

if (this.filesUploaded.length > 0) {

this.uploadFile();

} else {

this.fileName = 'Please select a CSV file to upload!!';

}

}

uploadFile() {

if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {

console.log('File Size is too large');

return;

}

this.showLoadingSpinner = true;

this.fileReader = new FileReader();

this.fileReader.onloadend = () => {

this.fileContents = this.fileReader.result;

this.saveFile();

};

this.fileReader.readAsText(this.filesUploaded[0]);

}

saveFile() {

try {

saveFile({ base64Data: JSON.stringify(this.fileContents), cdbId: this.recordid })

.then(result => {

if (result === null || result.length === 0) {

this.dispatchEvent(

new ShowToastEvent({

title: 'Warning',

message: 'The CSV file does not contain any data',

variant: 'warning',

}),

);

}

else {

this.data = result;

this.fileName = this.fileName + ' – Uploaded Successfully';

this.isTrue = false;

this.showLoadingSpinner = false;

this.dispatchEvent(

new ShowToastEvent({

title: 'Success!!',

message: this.filesUploaded[0].name + ' – Uploaded Successfully!!!',

variant: 'success',

}),

);

}

})

.catch(error => {

console.error(error);

this.showLoadingSpinner = false;

this.dispatchEvent(

new ShowToastEvent({

title: 'Error while uploading File',

message: error.message,

variant: 'error',

}),

);

});

} catch (error) {

console.error(error);

this.showLoadingSpinner = false;

this.dispatchEvent(

new ShowToastEvent({

title: 'Error',

message: 'An unexpected error occurred.',

variant: 'error',

}),

);

}

}

}