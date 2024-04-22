public with sharing class PositionTriggerHandler {
  public static void addClosedDateToPosition(List<Position__c> positions) {
    for (Position__c position : positions) {
      if (position.Status__c == 'Closed' && position.Closed_Date__c == null) {
        position.Closed_Date__c = Date.today();
      }
    }
  }
}
