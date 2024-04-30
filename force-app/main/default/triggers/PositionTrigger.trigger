trigger PositionTrigger on Position__c(before update, before insert) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        PositionTriggerHandler.addClosedDateToPosition(Trigger.new);
      } 
      if(Trigger.isUpdate) {
        List<Position__c> positions = PositionTriggerHandler.getPositionsWithChangedStatusToClosed(Trigger.newMap, Trigger.oldMap);
        if(!positions.isEmpty()) {
          PositionTriggerHandler.addClosedDateToPosition(positions);
        }
      }
    }
  }
  