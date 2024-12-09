import { LightningElement, track } from 'lwc';

export default class CreateLeadComponent extends LightningElement {
    @track radioOptions = [
        { label: 'Mobile OTP Consent', value: 'option1' },
        { label: 'Physical Consent Upload', value: 'option2' }
      ];
    
}