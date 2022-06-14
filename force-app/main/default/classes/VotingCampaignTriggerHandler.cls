/**
 * handling functionality to call on different actions on Voting Campaign object 
 */ 
public with sharing class VotingCampaignTriggerHandler extends CustomMDTTriggerHandler{
    public List<Voting_Campaign__c> newCampaigns = new List<Voting_Campaign__c>();
    public List<Voting_Campaign__c> oldCampaigns = new List<Voting_Campaign__c>();
    /**
     * @description constructor with arguments for VotingCampaignTriggerHandler object
     * @param  nCampaigns newCampaigns list of new(basically Trigger.new) Voting Campaign objects
     * @param  oCampaigns oldCampaigns list of old(basically Trigger.old) Voting Campaign objects
     */ 
    public VotingCampaignTriggerHandler(List<Voting_Campaign__c> nCampaigns, List<Voting_Campaign__c> oCampaigns){
        this.newCampaigns = nCampaigns;
        this.oldCampaigns = oCampaigns;
    }
    /**
     * @description default constructor for VotingCampaignTriggerHandler object 
     */
    public VotingCampaignTriggerHandler() {
        this((List<Voting_Campaign__c>)Trigger.New, (List<Voting_Campaign__c>)Trigger.old);

    }
    /**
     * @description invoked after Voting_Campaign__c object(list of objects) is inserted
     * Invokes method to add user for Configurators public groups
     */ 
    public override void afterInsert(){          
        System.enqueueJob(new AddConfiguratorsQueueable(new VotingCampaignUtil().createGroupsAfterCreateCampaign(newCampaigns)));
    }
    /**
     * @description invoked after Voting_Campaign__c object(list of objects) is deleted
     * Invokes method to delete public groups attached to voting campaigns
     */
    public override void beforeDelete(){
        new VotingCampaignUtil().deleteGroupsAfterDeleteCampaign(oldCampaigns);
    }

}
