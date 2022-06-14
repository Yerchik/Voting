/**
 * handling functionality to call on different actions on Location for Campaing object 
 */ 
public with sharing class CampaingLocationTriggerHandler extends CustomMDTTriggerHandler{
    public List<Location_for_Campaing__c> newLocations = new List<Location_for_Campaing__c>();
    public List<Location_for_Campaing__c> oldLocations = new List<Location_for_Campaing__c>();
    /**
     * @description constructor with arguments for VotingCampaignTriggerHandler object
     * @param  nLocations newLocations list of new(basically Trigger.new) Location for Campaing objects
     * @param  oLocations oldLocations list of old(basically Trigger.old) Location for Campaing objects
     */ 
    public CampaingLocationTriggerHandler(List<Location_for_Campaing__c> nLocations, List<Location_for_Campaing__c> oLocations) {
        this.newLocations = nLocations;
        this.oldLocations = oLocations;
    }
    /**
     * @description default constructor for VotingCampaignTriggerHandler object 
     */
    public CampaingLocationTriggerHandler() {
        this((List<Location_for_Campaing__c>)Trigger.New, (List<Location_for_Campaing__c>)Trigger.Old);
    }
    /**
     * @description invoked after Location_for_Campaing__c object(list of objects) is inserted
     * Invokes method to fill Latitude__c and Longitude__c fields in Location_for_Campaing__c
     */ 
    public override void afterInsert(){    
        System.enqueueJob(new LocationUtil_Queueble(newLocations));
    }
    /**
     * @description invoked after Location_for_Campaing__c object(list of objects) is updated
     * Invokes method to update Latitude__c and Longitude__c fields in Location_for_Campaing__c
     */
    public override void afterUpdate(){    
        System.enqueueJob(new LocationUtil_Queueble(new LocationUtil_Queueble().locationToUpdate(oldLocations, newLocations)));
    } 
}
