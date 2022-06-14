/**
 * contains tests for VotingCampaignUtil class
 */
@isTest
public with sharing class VotingCampaignUtilTest {
    /**
     * @description setup description
     */ 
    @TestSetup
    static void setup(){
        //creating and inserting initial campaign
        Voting_Campaign__c campaign = new Voting_Campaign__c(Campaign_Name__c = 'test');
        Test.startTest();
        insert campaign;
        Test.stopTest();
    }
    /**
     * @description test metod for createGroupsAfterCreateCampaign metod
     */
    @isTest
    static void createGroupsAfterCreateCampaign(){
        //creating test campaign
        Voting_Campaign__c campaign = [SELECT Name FROM Voting_Campaign__c WHERE Campaign_Name__c = 'Test' LIMIT 1];
        //creating name for test groups
        String nameOfGroups = '%' + campaign.Name + '%';
        //finding number of test group
        System.assertEquals(4, [SELECT COUNT() FROM Group WHERE Name LIKE :nameOfGroups]);
    }   
    /**
     * @description test metod for deleteGroupsAfterDeleteCampaign metod
     */
    @isTest
    static void deleteGroupsAfterDeleteCampaign(){
        //creating test campaign
        Voting_Campaign__c campaignToDelete = [SELECT Name FROM Voting_Campaign__c WHERE Campaign_Name__c = 'Test' LIMIT 1];
        //creating name for test groups
        String groupsNames = '%' + campaignToDelete.Name + '%';
        //deleting test campaign
        delete campaignToDelete;
        //finding number of left test groupі
        System.assertEquals(0, [SELECT COUNT() FROM Group WHERE Name LIKE :groupsNames]);
    }
}