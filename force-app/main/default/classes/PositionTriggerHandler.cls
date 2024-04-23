public with sharing class PositionTriggerHandler {
  public static List<Position__c> getPositionsWithChangedStatusToClosed(Map<Id, Position__c> positionsNewMap, Map<Id, Position__c> positionOldMap) {
    List<Position__c> changedPositions = new List<Position__c>();
    for(Id positionId : positionsNewMap.keySet()) {
      Position__c newPosition = positionsNewMap.get(positionId);
      if(newPosition.Status__c != positionOldMap.get(positionId).Status__c && newPosition.Status__c == 'Closed') {
        changedPositions.add(newPosition);
      }
    }
    return changedPositions;
  }

  public static void addClosedDateToPosition(List<Position__c> positions) {
    for (Position__c position : positions) {
      if (position.Status__c == 'Closed') {
        position.Closed_Date__c = Date.today();
      }
    }
  }
}
