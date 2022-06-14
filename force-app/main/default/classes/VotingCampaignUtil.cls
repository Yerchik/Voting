/**
 * contains methods with Voting Campaign object
 */ 
public with sharing class VotingCampaignUtil {
    private final String CONFIGURATOR = 'Configurator';
    //array of roles
    private final List<String> ROLES = new List<String>{'-Moderators', '-Analysts', '-Voters', '-Configurators'};
    /**
     * @description creates public groups for any voting campaign inserted
     * @param  newCampeigns list of inserted campaigns
     * @return list of created public groups
     */ 
    public List<GroupMember> createGroupsAfterCreateCampaign(List<Voting_Campaign__c> newCampeigns){
        List<Group> groups = new List<Group>(); 
        new AddConfiguratorsQueueable().createConfiguratorRole(newCampeigns);   
        for(String name:namesOfGroups(newCampeigns)){            
            groups.add(new Group(Name = name));            
        }
        insert groups;
        return addConfigurator(groups);
    }  
    /**
     * @description deletes public groups for any campaign deleted
     * @param  oldCampeigns list of deleted campaigns
     */ 
    public void deleteGroupsAfterDeleteCampaign(List<Voting_Campaign__c> oldCampeigns){
        List<String> names = namesOfGroups(oldCampeigns);
        delete [SELECT Name FROM Group WHERE Name IN :names ];
    }
    /**
     * @description creates list of names for public groups
     * @param  campeigns list of campaigns
     * @return list of names for public groups
     */
    public List<String> namesOfGroups(List<Voting_Campaign__c> campeigns){
        List<String> names = new List<String>();
        for(String role:ROLES){
            for (Voting_Campaign__c campeign : campeigns) {
                names.add('CMP-'+campeign.name+role);
            }    
        }
        return names;
    }

    public List<GroupMember> addConfigurator(List<Group> newGroups){
        List<GroupMember> members = new List<GroupMember>();
        Id userId = UserInfo.getUserId();
        for (Group g : newGroups) {
            GroupMember member = new GroupMember();
            if(g?.name?.contains(CONFIGURATOR)){              
                member.GroupId = g.Id;
                member.UserOrGroupId = userId;
                members.add(member);
            }            
        }
        return members;
    }    
}
