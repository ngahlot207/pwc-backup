import { LightningElement, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDocumentDetail from '@salesforce/apex/FileUploadCoApplicant.createDocumentDetail';
import uploadFile from '@salesforce/apex/FileUploadCoApplicant.uploadFile';
import getRelatedFilesByRecordId from '@salesforce/apex/FileUploadCoApplicant.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation'; 
import deleteFileRecord from '@salesforce/apex/FileUploadCoApplicant.deleteFileRecord';
import { refreshApex } from '@salesforce/apex';
// Custom labels
import FileUpload_Del_ErrorMessage from '@salesforce/label/c.FileUpload_Del_ErrorMessage';
import FileUpload_Del_SuccessMessage from '@salesforce/label/c.FileUpload_Del_SuccessMessage';

export default class pwc1TaskFileUpload extends NavigationMixin(LightningElement) {
    // loanAppId will be the parameter passed from the metadata. This will be the loan applicantion Id
    @api loanAppId = 'a08C4000006Ayh2IAC';
    fileData
    // applicantId will be the parameter passed from the metadata. This will be the loan applicantion Id
    @api applicantId = 'a0AC4000000EYEjMAO';
    customLabel = {
        FileUpload_Del_ErrorMessage,
        FileUpload_Del_SuccessMessage

    }
    filesList = []
    wiredResult;
    openfileUpload(event) {
        const file = event.target.files[0];
        var reader = new FileReader();

        reader.onload = async () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'loanAppId': this.loanAppId,
                'applicantId': this.applicantId
            };
            console.log(this.fileData);

            await this.uploadFileAndShowToast(); // Call the method using await
        };

        reader.readAsDataURL(file);
    }

    async uploadFileAndShowToast() {
        const { base64, filename, loanAppId, applicantId } = this.fileData;
        try {
            // Assuming uploadFile is a promise-based function
            await uploadFile({ base64, filename, loanAppId, applicantId });
            //this.fileData = null;
            let title = `${filename} uploaded successfully!!`;
            this.toast(title);
            
            refreshApex(this.wiredResult);
            this.fileData = null;
        } catch (error) {
            console.error(error);
        }
    }


   

    deleteHandal(event){
        console.log(event.target.dataset.id);
        var deleteRecordId = event.target.dataset.id;
        if(deleteRecordId){
            deleteFileRecord({deleteRecordId: deleteRecordId})
            .then(respons =>{
                console.log('Response received!! '+respons);
    
                this.dispatchEvent( new ShowToastEvent({
                                title: "Success",
                                message: this.customLabel.FileUpload_Del_SuccessMessage,
                                variant: "success",
                  })
              )
              console.log('refreshinh----->');
              refreshApex(this.wiredResult);
              })         
              .catch((error) => {
                this.dispatchEvent( new ShowToastEvent({
                                title: this.customLabel.FileUpload_Del_ErrorMessage,
                                message: error.body.message,
                                variant: "error",
                  }),
                 
                );
            });
        }else{
            this.dispatchEvent( new ShowToastEvent({
                title: "Error deleting record",
                message: error.body.message,
                variant: "error",
            }))
        }
   
       
      }

    

    handleClick() {
        createDocumentDetail({ applValue: this.applValue, lanValue: this.lanValue })
            .then(result => {
                if (result) {
                    // Record created successfully
                    // You can display a success message or perform other actions here
                } else {
                    // Handle any errors or show an error message
                }
            })
            .catch(error => {
                console.error(error); // Handle errors
            });


        // const {base64, filename, recordId} = this.fileData
        // uploadFile({ base64, filename, recordId }).then(result=>{
        //     this.fileData = null
        //     let title = `${filename} uploaded successfully!!`
        //     this.toast(title)
        // })
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }



    // @api recordId

   
    @wire(getRelatedFilesByRecordId,{loanAppId: '$loanAppId', applicantId : '$applicantId'})
    wiredResult(result) {
        this.wiredResult = result;
        if (result.data) {
            console.log("wire:", result.data);
            this.filesList = Object.keys(result.data).map(item =>({
               
                "label":result.data[item],
                "value":item
            }))
            console.log("filesListthis", JSON.stringify(this.filesList));
            if (result.error) {
                console.log(result.error)
            }
          
        }
    }
    priviewHandler(event){
        console.log(event.target.dataset.id);
        this[NavigationMixin.Navigate]({
          type:'standard__namedPage',
            attributes:{
                pageName:'filePreview'
            },
            state:{
                selectedRecordId: event.target.dataset.id
            } 
        }) 
   }
   
}