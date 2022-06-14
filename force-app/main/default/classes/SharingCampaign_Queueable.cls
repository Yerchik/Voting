/**
 * contains method to share campaign to users with role for this campaign
 */ 
public with sharing class SharingCampaign_Queueable implements Queueable {
    
    // list of new role
    private List<Role_of_Campaing__c> newRoles;
    
    /**
     * @description constructor 
     */ 
    public SharingCampaign_Queueable() {
    }
    
    /**
     * @description constructor with roles 
     * @param roles created roles for campaign
     */ 
    public SharingCampaign_Queueable(List<Role_of_Campaing__c> roles) {
        this.newRoles = roles;
    }

    /**
     * @description share campaign to users with role for this campaign
     * @param  context 
     */
    public void execute(QueueableContext context){
        List<Voting_Campaign__Share> campaingsShare = new List<Voting_Campaign__Share>();
        for(Role_of_Campaing__c role: newRoles){
            Voting_Campaign__Share campaingShare = new Voting_Campaign__Share();
            campaingShare.ParentId = role.Campaing__c;
            campaingShare.UserOrGroupId = role.User_of_Role__c;
            campaingShare.AccessLevel = 'Edit';           
            campaingsShare.add(campaingShare);
        }        
        insert campaingsShare;
    }

}
