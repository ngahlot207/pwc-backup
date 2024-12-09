import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getContentDistributionLink from '@salesforce/apex/ContentDistributionController.getContentDistributionLink';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import CommunityUrl from '@salesforce/label/c.Community_DSA_Url';
import Id from '@salesforce/user/Id';

export default class IFramePreview extends LightningElement {
    @api contDocId;
    @api cvId;
    @api contDocType;
    @track currentUserId = Id;
    @track url;
    @track isVideo = false;
    @track showFrame = false;
    @track isImage = false; // New flag to indicate image type

  connectedCallback() {
        console.log('contDocId: ' + this.contDocId);
        console.log('contDocType: ' + this.contDocType);
        console.log('Form Factor: ' + FORM_FACTOR);
        console.log('cvId: ' + this.cvId);

        if (FORM_FACTOR === 'Small') {
            console.log('In mobile');
            this.handleMobileView();
        } else {
            this.fetchUserDetails()
                .then(profileName => {
                    console.log('profileName');
                    this.handleUserProfile(profileName);
                })
                .catch(error => {
                    console.error('Error fetching user profile:', error);
                });
        }
    }

    handleMobileView() {
      getContentDistributionLink({ conVerId: this.cvId })
        .then(result => {
                console.error('Result from Apex method:', result);
          this.url = result[0].DistributionPublicUrl;
          console.error('this.url', this.url);
                this.checkDocumentType();
        })
        .catch(error => {
          console.error('Error calling Apex method:', error);
        });
    }

    fetchUserDetails() {
        const UserParams = {
            ParentObjectName: 'User',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Profile.Name'],
            childObjFields: [],
            queryCriteria: ` WHERE Id = '${this.currentUserId}'`
        };

        return getSobjectDataNonCacheable({ params: UserParams })
            .then(result => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('User profile records:', JSON.stringify(result.parentRecords));
                    return result.parentRecords[0].Profile.Name;
      }
                return null;
            })
            .catch(error => {
                console.error('Error fetching user details:', error);
                throw error;
            });
    }

    handleUserProfile(profileName) {
        if (profileName === 'DSA') {
            this.url = `${CommunityUrl}/sfc/servlet.shepherd/document/download/${this.contDocId}`;
            console.log('DSA user URL: ' + this.url);
        } else {
            this.url = `/sfc/servlet.shepherd/document/download/${this.contDocId}`;
            console.log('Document ID: ' + this.contDocId);
        }
        this.checkDocumentType();
  }
  
    checkDocumentType() {
        console.log('this.contDocType: ' + this.contDocType);
        const lowerDocType = this.contDocType.toLowerCase();
        if (['mp4', 'pdf', 'doc', 'docx'].includes(lowerDocType)) {
            this.isVideo = lowerDocType === 'mp4';
      this.showFrame = true;
            this.isImage = false;
        } else if (['jpg', 'jpeg','png', 'gif'].includes(lowerDocType)) { // Check for image types
            this.isImage = true;
            this.showFrame = false;
    } else {
      this.showFrame = false;
            this.isImage = false;
    }
  }

  closeModal() {
        const selectedEvent = new CustomEvent('closepreview');
    this.dispatchEvent(selectedEvent);
  }
}