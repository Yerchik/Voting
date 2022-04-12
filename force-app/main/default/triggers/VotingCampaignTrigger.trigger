trigger VotingCampaignTrigger on Voting_Campaign__c (after insert, before delete) {
    new CustomMDTTriggerHandler().run();
}