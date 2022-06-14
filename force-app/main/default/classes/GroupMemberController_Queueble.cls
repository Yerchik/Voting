public with sharing class GroupMemberController_Queueble implements Queueable {
    private List<GroupMember> members;

    public GroupMemberController_Queueble() {
    }

    public GroupMemberController_Queueble(List<GroupMember> membersToDelete) {
        this.members = membersToDelete;
    }

    public void execute(QueueableContext context){
        List<Id> groupId = new List<Id>();
        List<Id> userOrGroupId = new List<Id>();
        for (GroupMember member : members) {
            groupId.add(member.GroupId);
            userOrGroupId.add(member.UserOrGroupId);
        }
        try {
            delete [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupId AND UserOrGroupId IN :userOrGroupId];
        } catch (Exception e) {
            System.enqueueJob(new ExceptionUtility(e));
        }
    }

    public List<GroupMember> rolesMember(List<Role_of_Campaing__c> roles){
        Set<Id> rolesId = (new Map<Id,Role_of_Campaing__c>(roles)).keySet();
        List<Role_of_Campaing__c> rolesWithName = [SELECT Campaing__r.Name, RecordTypeId, User_of_Role__c FROM Role_of_Campaing__c WHERE Id IN :rolesId];
        Map<String,Id> groupName = new Map<String,Id>();
        for (Role_of_Campaing__c role : rolesWithName) {
            String name = 'CMP-' + role.Campaing__r.Name + '-' + Schema.SObjectType.Role_of_Campaing__c.getRecordTypeInfosById().get(role.RecordTypeId).getName() + 's';
            groupName.put(name, role.User_of_Role__c);
        }
        List<Group> groups = [SELECT Id, Name FROM Group WHERE Name IN :groupName.keySet()];
        List<GroupMember> membersOfRole = new List<GroupMember>();
        for (Group g : groups) {
            GroupMember member = new GroupMember();
            member.GroupId = g.Id;
            member.UserOrGroupId = groupName.get(g.Name);
            membersOfRole.add(member);
        }
        System.debug('1111 ' + membersOfRole);
        return membersOfRole;
    }


}
