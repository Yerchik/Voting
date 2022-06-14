import { LightningElement, track, api, wire } from 'lwc';
import getUsers from '@salesforce/apex/UserUtil.getUsers';
import getAllAvailableUsers from '@salesforce/apex/UserUtil.getAllAvailableUsers';
import getCurrentUsers from '@salesforce/apex/UserUtil.getCurrentUsers';
import insertUsers from '@salesforce/apex/UserUtil.insertUsers';

//columns for the table
const COLUMNS = [
    {
        label: 'Name', fieldName: "UserURL", type: 'url',
        typeAttributes: {
            label: {
                fieldName: "Name"
            },
            target: '_blank'
        }
    },
    {
        label: 'Username',
        fieldName: 'Username',
        type: 'text'
    }
];

export default class UserList extends LightningElement {
    //type of user 
    @api componentLabel;
    //id of current record
    @api recordId;
    //should list be editable
    @api editable;
    //list of users of current type
    @track users;
    //columns
    columns = COLUMNS;

    //name of list shown to user
    listName;
    //recordType name
    recordTp;
    connectedCallback() {
        getUsers({ campaignId: this.recordId, lim: 5, userType: this.componentLabel }).then(response => {
            //different table lable for different componentLabel arguement
            this.listName = this.componentLabel;
            this.recordTp = this.componentLabel;
            //adding links to profiles
            this.users = response;
            this.users.forEach(item => {
                item.UserURL = '/' + item.Id;
            });
        }).catch(error => {
            console.log('Error: ' + error);
        });
    }
    @track options = [];
    @track values = [];
    updatedValues;
    @wire(getAllAvailableUsers, { campaignId: '$recordId', recordTp: '$recordTp' })
    wiredUsers({ error, data }) {
        if (data) {
            data.forEach(item => this.options.push({ 'label': item.Name, 'value': item.Id }));
        } else if (error) {
            this.error = error;
            this.options = undefined;
        }
    }

    @wire(getCurrentUsers, { campaignId: '$recordId', recordTp: '$recordTp' })
    wiredUsersIn({ error, data }) {
        if (data) {
            data.forEach(item => this.values.push( item.User_of_Role__c ));
        } else if (error) {
            this.error = error;
            this.values = undefined;
        }
    }
    @track isEditOpen = false;
    handleChange(event) {
        const selectedOpts = event.detail.value;
        this.updatedValues = selectedOpts;
    }
    
    openEdit() {
        this.isEditOpen = true;
    }
    closeEdit() {
        this.isEditOpen = false;
    }
    submitEdit() {
        insertUsers({ campaignId: this.recordId, recordTp: this.recordTp, oldIds: this.values, newIds: this.updatedValues })
        this.isEditOpen = false;    
    }

}