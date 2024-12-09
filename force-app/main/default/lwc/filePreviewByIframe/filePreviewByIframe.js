import { LightningElement, track, api } from 'lwc';
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import { NavigationMixin } from "lightning/navigation";
import communityUrl from '@salesforce/label/c.community_Url'
export default class FilePreviewByIframe extends NavigationMixin(LightningElement) {
    recordId = '069C4000001JTIfIAO';
    isReadOnly;
    themeType;
    theIframe;
    @track IframeView;
    base64PDF;
    connectedCallback() { 
       
        this.isReadOnly = false;
        this.isCpa = true;
        getUiTheme()
            .then((result) => {
                console.log('result for theme is=>>>>>', result);
                this.themeType = result;
            })
            .catch((error) => {

            });
    }
    handleClick(event) {
       
        console.log('new url@@@@'+this.themeType);
        this.contDocId = this.recordId;
       // if (this.themeType == 'Theme4d') {
        if (this.themeType != 'Theme4d') {
            console.log('inside salesforce '+this.contDocId);
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "filePreview"
                },
                state: {
                    selectedRecordId: this.contDocId
                }
            });
        } else {
            console.log('in console');
            //this.IframeView=true;
            const vfPageName = 'iframevfpage'; // Replace with your VF page name
            const vfPageUrl = '/apex/iframevfpage';
            
            window.location.href = vfPageUrl;
             
        }   

    }
    hideModalBox(event){
        this.IframeView=false;
    }
    
    get fullUrl() {
        //return 'sfc/servlet.shepherd/document/download/069C4000001K3SbIAK'
        return 'https://fedbank--dev.sandbox.my.site.com/LOS/sfc/servlet.shepherd/version/renditionDownload%3Frendition=THUMB720BY480&versionId=068C4000001KmpVIAS'
       //return 'https://fedbank--dev.sandbox.lightning.force.com/sfc/servlet.shepherd/version/renditionDownload%3Frendition=THUMB720BY480&versionId=068C4000001KmpVIAS'
    }
    handleClickpdf(){
        console.log('inhhhhhh')
        this.IframeView=true;
        
    }
    

}