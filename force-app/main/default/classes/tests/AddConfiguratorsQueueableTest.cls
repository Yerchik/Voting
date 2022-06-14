/**
 * contains tests for AddConfiguratorsQueueable class
 */
@isTest
public with sharing class AddConfiguratorsQueueableTest {
    //number of items to insert
    private static final Integer NUMBER_OF_INSERTS = 20;
    /**
     * @description setup description
     */ 
    @TestSetup
    static void setup(){
        //creating and inserting initial list of campaigns
        List<Voting_Campaign__c> campaigns = new List<Voting_Campaign__c>();
        //20 items to check bulk insert
        for(Integer i = 0; i < AddConfiguratorsQueueableTest.NUMBER_OF_INSERTS; i++){
            campaigns.add(new Voting_Campaign__c(Campaign_Name__c='Test' + i));
        }
        Test.startTest();
        insert campaigns;
        Test.stopTest();
    }
    /**
     * @description test metod for AddConfiguratorsQueueable class
     */
    @isTest
    static void configuratorsAssignmentTest(){
        //creating list of names for test groups
        List<String> groupsNames = new List<String>();
        for(Voting_Campaign__c campaign :[SELECT Name FROM Voting_Campaign__c WHERE Campaign_Name__c LIKE 'Test%' ]){
            groupsNames.add('CMP-' + campaign.Name + '-Configurators');
        }
        //creating list of test groups of configurator
        List<Group> groups = [SELECT Id FROM Group WHERE Name IN :groupsNames];
        //creating list of Id for test groups of configurator
        Set<Id> groupsId = (new Map<Id,Group>(groups)).keySet(); 
        //finding number of group member in test groups of configurator
        System.assertEquals(AddConfiguratorsQueueableTest.NUMBER_OF_INSERTS, [SELECT COUNT() FROM GroupMember WHERE GroupId in :groupsId]);
    }
}
