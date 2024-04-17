public with sharing class PositionsListWithControllerLWC {
  private static List<String> generateStatus(String status) {
    return status == '' ||
      status == null
      ? new List<String>{ 'Open', 'Closed', 'Pending' }
      : new List<String>{ status };
  }

  @AuraEnabled(cacheable=true)
  public static Integer getCountPositions(String status) {
    return [
      SELECT COUNT()
      FROM Position__c
      WHERE Status__c IN :generateStatus(status)
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Position__c> getPositions(
    String status,
    Integer pageSize,
    Integer pageOffset
  ) {
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
      WHERE Status__c IN :generateStatus(status)
      ORDER BY Id
      LIMIT :pageSize
      OFFSET :pageOffset
    ];
  }

  @AuraEnabled
  public static void updatePositions(List<Position__c> updatedData) {
    update updatedData;
  }
}
