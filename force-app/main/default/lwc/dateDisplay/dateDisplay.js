import { LightningElement, api } from 'lwc';

export default class DateDisplay extends LightningElement {
    @api birthDate;
    get formattedDate() {
        if (this.birthDate) {
            console.log('birthDate is ', this.birthDate);
            const rawDate = new Date(this.birthDate);
            const day = rawDate.getDate().toString().padStart(2, '0');
            const month = (rawDate.getMonth() + 1).toString().padStart(2, '0'); // Month is zero-based
            const year = rawDate.getFullYear();
            return `${day}/${month}/${year}`;
        }
        return '';
    }
}