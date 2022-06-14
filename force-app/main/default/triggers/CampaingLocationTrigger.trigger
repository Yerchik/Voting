/**
 * @description trigger on Location for Campaing object
 * @param  insert - some tasks after insert
 * @param  update - some tasks after update
 */
trigger CampaingLocationTrigger on Location_for_Campaing__c (after insert, after update) {
    new CustomMDTTriggerHandler().run();
}