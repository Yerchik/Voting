/**
 * contains methods with Location for userList LWC component
 */
public with sharing class UserUtil {
    public UserUtil() {

    }

    /**
     * @description return list of users of type for campaign
     * @param  campaignId campaign Id
     * @param userType type of user
     * @return list of users in public groups
     */ 
    @AuraEnabled
    public static List<User> getUsers(ID campaignId, Integer lim, String userType) {
        Voting_Campaign__c vc = [SELECT ID, Name FROM Voting_Campaign__c WHERE ID = :campaignId LIMIT 1];
        String filter = '%' + vc.Name + '-' + userType + 's';
        Set<ID> groupsId = (new Map<ID, SObject>([SELECT Id FROM Group WHERE Name LIKE :filter]).keySet());
        return  [SELECT Id, Name, Username FROM User WHERE ID IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groupsId ) LIMIT :lim];
    }

     /**
     * @description return list of users with role for campaign
     * @param campaignId campaign Id
     * @param recordTp record type of campaign
     * @return list id of user with role for campaign
     */ 
    @AuraEnabled(cacheable=true)
    public static List<Role_of_Campaing__c> getCurrentUsers(ID campaignId, String recordTp) {
        Id idRecordType = Schema.SObjectType.Role_of_Campaing__c.getRecordTypeInfosByName().get(recordTp).getRecordTypeId();
        return [SELECT User_of_Role__c FROM Role_of_Campaing__c WHERE Campaing__r.Id = :campaignId AND RecordTypeId = :idRecordType];
    }

    /**
     * @description return list of available users for campaign
     * @param campaignId campaign Id
     * @param recordTp record type of campaign
     * @return list of available users for campaign
     */ 
    @AuraEnabled(cacheable=true)
    public static List<User> getAllAvailableUsers(ID campaignId, String recordTp) {
        Id idRecordType = Schema.SObjectType.Role_of_Campaing__c.getRecordTypeInfosByName().get(recordTp).getRecordTypeId();
        List<Role_of_Campaing__c> campaignWithoutUserId = [SELECT User_of_Role__c FROM Role_of_Campaing__c WHERE Campaing__r.Id = :campaignId AND RecordTypeId != :idRecordType];
        List<Id> userId = new List<Id>();                   
        for (Role_of_Campaing__c campaign : campaignWithoutUserId) {
            userId.add(campaign.User_of_Role__c);
        }
        return [SELECT Id, Name
            FROM User
            WHERE Id NOT IN :userId];
    }
    
    /**
     * @description manage users in campaign
     * @param campaignId campaign Id
     * @param recordTp record type of campaign
     * @param oldIds lis id of old user
     * @param newIds lis id of new user
     * @return list of available users for campaign
     */ 
    @AuraEnabled
    public static void insertUsers(Id campaignId, String recordTp, List<Id> oldIds, List<Id> newIds){
        Set<User> oldUsers = new Set<User>([SELECT Id, Name FROM User WHERE Id IN :oldIds]);
        Set<User> newUsers = new Set<User>([SELECT Id, Name FROM User WHERE Id IN :newIds]);
        Set<User> allUsers = oldUsers.clone();
        allUsers.addAll(newUsers);
        Set<User> usersToDelete = allUsers.clone();
        usersToDelete.removeAll(newUsers);
        Set<User> usersToAdd = allUsers.clone();
        usersToAdd.removeAll(oldUsers);

        List<Role_of_Campaing__c> usersToAddRoles = new List<Role_of_Campaing__c>();
        for(User user: usersToAdd){
            Role_of_Campaing__c role = new Role_of_Campaing__c();
            role.RecordTypeId = Schema.SObjectType.Role_of_Campaing__c.getRecordTypeInfosByName().get(recordTp).getRecordTypeId();
            role.User_of_Role__c = user.Id;
            role.Campaing__c = campaignId;
            usersToAddRoles.add(role);
        }
        insert usersToAddRoles;
        Set<Id> usersToDeleteIds = (new Map<Id, User>(new List<User>(usersToDelete))).keyset();
        delete [SELECT Id, User_of_Role__c, Campaing__c FROM Role_of_Campaing__c WHERE Campaing__c = :campaignId AND User_of_Role__c IN :usersToDeleteIds];
    }
}
