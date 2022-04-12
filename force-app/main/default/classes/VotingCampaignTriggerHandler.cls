public with sharing class VotingCampaignTriggerHandler extends CustomMDTTriggerHandler{
    public List<Voting_Campaign__c> newCampaign = new List<Voting_Campaign__c>();
    public List<Voting_Campaign__c> oldCampaign = new List<Voting_Campaign__c>();

    public VotingCampaignTriggerHandler(List<Voting_Campaign__c> nCampaign, List<Voting_Campaign__c> oCampaign){
        this.newCampaign = nCampaign;
        this.oldCampaign = oCampaign;
    }

    public VotingCampaignTriggerHandler() {
        this((List<Voting_Campaign__c>)Trigger.New, (List<Voting_Campaign__c>)Trigger.old);

    }

    public override void afterInsert(){
            CreateGroupAfterCreateCampaign.createGroup(newCampaign);
            System.enqueueJob(new CreateGroupAfterCreateCampaign(newCampaign));
    }

    public override void beforeDelete(){
        DeleteGroup.deleteGroup(oldCampaign);
    }

}
