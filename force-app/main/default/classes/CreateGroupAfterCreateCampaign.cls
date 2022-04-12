public with sharing class CreateGroupAfterCreateCampaign implements Queueable {
    private List<String> names;

    public CreateGroupAfterCreateCampaign(List<Voting_Campaign__c> newCampeigns){
        List<String> n = new List<String>();
        for (Voting_Campaign__c cam : newCampeigns) {
            n.add('CMP-'+cam.name+'-Configurators');
        }
        this.names = n;
    }

    public void execute(QueueableContext context){
        List<GroupMember> members = new List<GroupMember>();
        for (String name : names) {
            GroupMember member = new GroupMember();
            member.GroupId = [SELECT Name FROM Group WHERE Name LIKE :name ].Id;
            member.UserOrGroupId = UserInfo.getUserId();
            members.add(member);
        }        
        insert members;
    }

    public static void createGroup(List<Voting_Campaign__c> newCampeigns){
        String[] roles = new String[]{'-Moderators', '-Analysts', '-Voters', '-Configurators'};
        List<Group> groups = new List<Group>();      
        for(String role:roles){
            for (Voting_Campaign__c newCampaign : newCampeigns) {
                groups.add(new Group(Name = 'CMP-' + newCampaign.Name + role));
            }
        }
        insert groups;
	}

}
