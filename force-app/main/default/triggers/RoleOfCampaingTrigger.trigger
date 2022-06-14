/**
 * @description trigger on Role of Campaing object
 * @param  insert - some tasks after insert
 * @param  delete - some tasks before delete
 */
trigger RoleOfCampaingTrigger on Role_of_Campaing__c (after insert, before delete) {
    new CustomMDTTriggerHandler().run();
}