public with sharing class PositionListControllerHelper {
    public static List<String> generateStatus(String status) {
        return status == '' ||
          status == null
          ? new List<String>{ 'Open', 'Closed', 'Pending' }
          : new List<String>{ status };
    }

    public static List<Position__c> stripRemovedFieldsFromPositions(SObjectAccessDecision stripPositions) {
        List<Position__c> positions = stripPositions.getRecords();
        Set<String> removedFields = stripPositions.getRemovedFields().get('Position__c');
        if(removedFields != null && !removedFields.isEmpty()) {
          for(Position__c position : positions) {
            for(String fieldName : removedFields) {
              position.put(fieldName, null);
            }
          }      
        }
    
        return positions;
    }
}