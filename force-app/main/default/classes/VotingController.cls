public with sharing class VotingController {
    public VotingController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Question__c> getQuestion(ID campaignId) {
        return  [SELECT Id, Name FROM Question__c WHERE Id IN (SELECT Question__c FROM Question_for_Campaing__c WHERE Campaing__r.Id = :campaignId)];
    }

    @AuraEnabled(cacheable=true)
    public static List<Option__c> getOption(ID questionId) {
        return  [SELECT Id, Name FROM Option__c WHERE Id IN (SELECT Option__c FROM Question_Option__c WHERE Question__r.id = :questionId)];
    }

    @AuraEnabled(cacheable=true)
    public static String getOpportunity(ID campaignId) {
        Id userId = UserInfo.getUserId();
        if ([SELECT Id FROM Answer__c WHERE Campaing__c = :campaignId AND Vouter__c = :userId].size() > 0) 
            return 'voted';
        return [SELECT Status__c FROM Voting_Campaign__c WHERE Id = :campaignId LIMIT 1].Status__c;    
    }

    @AuraEnabled
    public static void getAnsver(Id campaignId, Map<Id,Id> answers){
        List<Answer__c> answersToInsert = new List<Answer__c>();
        for (Id question : answers.keySet()) {
            answersToInsert.add(new Answer__c(Campaing__c = campaignId, Choosen_Answer__c = answers.get(question), Question__c = question , Vouter__c = UserInfo.getUserId() ));
        }
        insert answersToInsert;
    }
}
