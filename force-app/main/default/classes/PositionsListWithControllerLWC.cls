public with sharing class PositionsListWithControllerLWC {
  @AuraEnabled(cacheable=true)
  public static List<Position__c> getPositions(String status) {
    List<String> selectedStatuses = status == '' ||
      status == null
      ? new List<String>{ 'Open', 'Closed', 'Pending' }
      : new List<String>{ status };
    return [
      SELECT
        Id,
        Title__c,
        Status__c,
        Open_Date__c,
        Closed_Date__c,
        Min_Pay__c,
        Max_Pay__c
      FROM Position__c
      WHERE Status__c IN :selectedStatuses
    ];
  }

  @AuraEnabled
  public static void updatePositions(List<Position__c> updatedData) {
    update updatedData;
  }
}
