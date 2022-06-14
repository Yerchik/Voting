import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQuestion from '@salesforce/apex/VotingController.getQuestion';
import getOption from '@salesforce/apex/VotingController.getOption';
import getAnsver from '@salesforce/apex/VotingController.getAnsver';
import getOpportunity from '@salesforce/apex/VotingController.getOpportunity';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const NAME_FIELD  = 'Voting_Campaign__c.Campaign_Name__c';
const DESCRIPTION_FIELD  = 'Voting_Campaign__c.Description__c';	
const CampaignFields = [NAME_FIELD, DESCRIPTION_FIELD];

export default class Vote extends LightningElement {
    @api recordId;
    name;
    description;

    @track isVoteOpen = false;
    
    @track questions = [];

    @wire(getRecord, { recordId: '$recordId', fields: CampaignFields })
    loadName({ error, data }) {
        if (error) {
            this.error = error;
            this.name = undefined;
        } else if (data) {
            this.name =  getFieldValue(data, NAME_FIELD);
            this.description = getFieldValue(data, DESCRIPTION_FIELD);
        }
    }

    @wire(getQuestion, { campaignId: '$recordId'})
    async wiredQuestion({ error, data }) {
        if (data) {
            data.forEach(async item  =>  {
                let value =  await this.getOptions(item.Id);
                this.questions.push({ 'Name': item.Name, 'Id': item.Id, 'value': value});
        });
        } else if (error) {
            this.error = error;
            this.questions = undefined;
        }
    }

    @wire(getOpportunity, { campaignId: '$recordId'})
    wiredOpportunity({ error, data }) {
        if (data) {
            let result = data;
            if (result === 'voted') {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No access!',
                    message: 'You already voted on this campaign!',
                }));
            }else if (result === 'Launched') {
                this.isVoteOpen = true;
            }else{
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No access!',
                    message: 'Campaign is' + result + ' !',
                }));
            }
        } else if (error) {
            this.error = error;
        }
    }

    async getOptions(id){
        let options = [];
        let response = await getOption({questionId: id});
        response.forEach(item => {
            options.push({ label: item.Name, value: item.Id})
        })
        return  options;
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    async saveAction(){
        let answers = {};
        let input = this.template.querySelectorAll("lightning-radio-group");
        input.forEach( item  =>  {
            let questionId = item.name;
            let answerId = item.value;
            answers[questionId]= answerId;
        })
        getAnsver({campaignId: this.recordId, answers: answers }); 
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!',
            message: 'Thank you for voting!',
            variant: 'success'
        }));
    }


    

}