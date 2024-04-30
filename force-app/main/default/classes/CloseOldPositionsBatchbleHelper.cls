public with sharing class CloseOldPositionsBatchbleHelper {
  public static void closeOldPositions(List<Position__c> positions) {
    List<Position__c> closedPositions = new List<Position__c>();
    for (Position__c position : positions) {
      position.Status__c = 'Closed';
      closedPositions.add(position);
    }
    if (!closedPositions.isEmpty()) {
      update closedPositions;
    }
  }
}
