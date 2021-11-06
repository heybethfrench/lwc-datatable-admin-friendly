import { LightningElement, wire, track, api} from 'lwc';
import getTableOutput from '@salesforce/apex/datatableHelper.getTableOutput';
export default class ReusableLightnigDatatable extends LightningElement {
 
    @api fieldSetName;
    @api theObject;
    @api isSortable;

    @track error;
    @track recordList;
    @track sortBy;
    @track sortDirection;
    @track fieldSetMembers;

    @wire(getTableOutput, {fieldSetName:'$fieldSetName', theObject : '$theObject', isSortable : '$isSortable'})
    wiredAccounts({
        error,
        data
    }) {
        if(data) {
            this.recordList = data.recordList;
            this.fieldSetMembers = data.fields;
        } else if (error) {
            this.error = error;
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.recordList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.recordList = parseData;
        
    }
}