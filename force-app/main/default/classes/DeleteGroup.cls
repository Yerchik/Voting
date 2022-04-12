public with sharing class DeleteGroup {
    public static void deleteGroup(List<Voting_Campaign__c> oldCampeigns){
        List<Group> groupsToDelete = new List<Group>();
        for (Voting_Campaign__c oldCampeign : oldCampeigns) {
            String name = 'CMP-'+oldCampeign.name+'%';
            groupsToDelete.addAll([SELECT Name FROM Group WHERE Name LIKE :name ]);
        }
        delete groupsToDelete;
    }
}
