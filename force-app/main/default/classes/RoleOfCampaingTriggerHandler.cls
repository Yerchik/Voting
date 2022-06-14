/**
 * handling functionality to call on different actions on Role_of_Campaing__c object 
 */
public with sharing class RoleOfCampaingTriggerHandler extends CustomMDTTriggerHandler{
    public List<Role_of_Campaing__c> newRoles = new List<Role_of_Campaing__c>();
    public List<Role_of_Campaing__c> oldRoles = new List<Role_of_Campaing__c>();
    /**
     * @description constructor with arguments for RoleOfCampaingTriggerHandler object
     * @param  nRoles newRoles list of new(basically Trigger.new) Role of Campaing objects
     * @param  oRoles oldRoles list of old(basically Trigger.old) Role of Campaing objects
     */ 
    public RoleOfCampaingTriggerHandler(List<Role_of_Campaing__c> nRoles, List<Role_of_Campaing__c> oRoles){
        this.newRoles = nRoles;
        this.oldRoles = oRoles;
    }
    /**
     * @description default constructor for VotingCampaignTriggerHandler object 
     */
    public RoleOfCampaingTriggerHandler() {
        this((List<Role_of_Campaing__c>)Trigger.New, (List<Role_of_Campaing__c>)Trigger.old);

    }
    /**
     * @description invoked after Role_of_Campaing__c object(list of objects) is inserted
     * Invokes method to add user for public groups
     */ 
    public override void afterInsert(){  
        System.enqueueJob(new SharingCampaign_Queueable(newRoles));
        System.enqueueJob(new AddConfiguratorsQueueable(new GroupMemberController_Queueble().rolesMember(newRoles)));    
    }
    /**
     * @description invoked after Role_of_Campaing__c object(list of objects) is deleted
     * Invokes method to delete public groups attached to voting campaigns
     */
    public override void beforeDelete(){
        System.enqueueJob(new GroupMemberController_Queueble(new GroupMemberController_Queueble().rolesMember(oldRoles)));
    }

}
