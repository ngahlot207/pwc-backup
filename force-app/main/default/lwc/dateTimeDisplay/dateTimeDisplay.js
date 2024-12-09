import { LightningElement, api } from 'lwc';

export default class DateTimeDisplay extends LightningElement {
    @api dateTime;
    get formattedDateTime() {
        if (this.dateTime) {
            console.log('dateTime is ', this.dateTime);
            const rawDate = new Date(this.dateTime);
            const day = rawDate.getDate().toString().padStart(2, '0');
            const month = (rawDate.getMonth() + 1).toString().padStart(2, '0'); // Month is zero-based
            const year = rawDate.getFullYear();
            const hours = rawDate.getHours();
            const minutes = rawDate.getMinutes().toString().padStart(2, '0');

            // Convert hours to AM/PM format
            const amPm = hours >= 12 ? 'PM' : 'AM';
            const formattedHours = (hours % 12 || 12).toString().padStart(2, '0');

            return `${day}/${month}/${year} ${formattedHours}:${minutes} ${amPm}`;
        }
        return '';
    }
}