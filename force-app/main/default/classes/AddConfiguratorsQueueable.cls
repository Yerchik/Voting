/**
 * queueable class which implements asynchronous jobs for adding group member to group
 */
public with sharing class AddConfiguratorsQueueable implements Queueable {

    private final String CONFIGURATOR = 'Configurator';

    private List<GroupMember> newGroupMembers;
    /**
     * @description constructor 
     */
    public AddConfiguratorsQueueable() {
    }
    /**
     * @description constructor 
     * @param  addedGroups - list of group members to insert
     */ 
    public AddConfiguratorsQueueable(List<GroupMember> addedGroups) {
        this.newGroupMembers = addedGroups;
    }
    /**
     * @description assigns members to group
     * @param  context
     */ 
    public void execute(QueueableContext context){   
        try {
            insert newGroupMembers;          
        } catch (Exception e) {
            System.enqueueJob(new ExceptionUtility(e));
        }   
    }
    /**
     * @description create Role of Campaing objets with of confugurators and campaings
     * @param  campeigns created campaings
     */
    public void createConfiguratorRole(List<Voting_Campaign__c> campeigns){
        List<Role_of_Campaing__c> rolesList = new List<Role_of_Campaing__c>();
        for (Voting_Campaign__c campeign : campeigns) {
            rolesList.add(new Role_of_Campaing__c(RecordTypeId = Schema.SObjectType.Role_of_Campaing__c.getRecordTypeInfosByName().get(CONFIGURATOR).getRecordTypeId(),
            Campaing__c = campeign.Id,
            User_of_Role__c = UserInfo.getUserId()));
        }
        insert rolesList;
    }

}
