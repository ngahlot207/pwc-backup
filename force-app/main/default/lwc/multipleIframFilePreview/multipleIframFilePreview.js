import { LightningElement, api, wire, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getContentDistributionLink from '@salesforce/apex/ContentDistributionController.getContentDistributionLink';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import CommunityUrl from '@salesforce/label/c.Community_DSA_Url';
import Id from '@salesforce/user/Id';

export default class MultipleIframFilePreview extends LightningElement {
  @api contDocId;
  _recordForPrev;
  @track url;
  @track showimage = false;
  @track showpdf = false;
  @track currentUserId = Id;

  @api get recordForPrev() {
    return this._recordForPrev;
  }
  set recordForPrev(value) {
    console.log(' >>>>>>>>>>>>>>>>>>>> ' + JSON.stringify(value));
    this._recordForPrev = value;
    if (typeof this._recordForPrev !== 'undefined') {
      this.createContentDistributionLink();
    }
  }

  createContentDistributionLink() {
    console.log('this._recordForPrev.contDocType' + this._recordForPrev.contDocType);
    console.log('FORM_FACTOR' + FORM_FACTOR);
    
    if (FORM_FACTOR === 'Small') {
      console.log('inmobile');
      getContentDistributionLink({ conVerId: this._recordForPrev.Id })
        .then(result => {
          console.error('result calling Apex method:', result);
          this.url = result[0].DistributionPublicUrl;
          console.error('this.url', this.url);
          this.showpdf = true;
        })
        .catch(error => {
          console.error('Error calling Apex method:', error);
        });
    } else {
      console.log('>>>>>>' + this._recordForPrev.contDocId);
      this.fetchUserDetails().then(profileName => {
        this.handleUserProfile(profileName);
      });
    }
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
      this.url = `${CommunityUrl}/sfc/servlet.shepherd/document/download/${this._recordForPrev.contDocId}`;
      console.log('DSA user URL: ' + this._recordForPrev.contDocId);
    } else {
      this.url = '/sfc/servlet.shepherd/document/download/' + this._recordForPrev.contDocId;
    }
    this.handleClick();
    console.log('this.url' + this.url);
  }

  handleClick() {
    if (['PDF', 'doc', 'pdf', 'docx', 'mp4','png','xlsx'].includes(this._recordForPrev.contDocType)) {
      this.showimage = false;
      this.showpdf = true;
    } else {
      this.showpdf = false;
      this.showimage = true;
    }
  }

  closeModal() {
    var selectedEvent = new CustomEvent('closepreview');
    this.dispatchEvent(selectedEvent);
  }
}