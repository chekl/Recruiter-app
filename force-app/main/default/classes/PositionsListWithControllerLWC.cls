public with sharing class PositionsListWithControllerLWC {
  @AuraEnabled(cacheable=true)
  public static List<Position__c> getPositions(String status) {
    String whereClause = status != null &&
    status != ''
    ? 'WHERE Status__c = \'' + status + '\''
    : '';
    
    List<Position__c> positions = Database.query(
      'SELECT Id, Title__c, Status__c, Open_Date__c, Closed_Date__c, Min_Pay__c, Max_Pay__c FROM Position__c ' +
      whereClause
    );

    return positions;
  }

  @AuraEnabled
  public static void updatePositions(List<Position__c> updatedData) {
    update updatedData;
  }
}
