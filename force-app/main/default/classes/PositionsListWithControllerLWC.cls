public with sharing class PositionsListWithControllerLWC {
  @AuraEnabled(cacheable=true)
  public static Integer getCountPositions(String status) {
    return [
      SELECT COUNT()
      FROM Position__c
      WHERE Status__c IN :PositionListControllerHelper.generateStatus(status)
      WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Position__c> getPositions(
    String status,
    Integer pageSize,
    Integer pageOffset
  ) {
    SObjectAccessDecision stripPositions = Security.stripInaccessible(
      AccessType.READABLE,
      [
        SELECT
          Id,
          Title__c,
          Status__c,
          Open_Date__c,
          Closed_Date__c,
          Min_Pay__c,
          Max_Pay__c
        FROM Position__c
        WHERE Status__c IN :PositionListControllerHelper.generateStatus(status)
        ORDER BY Id
        LIMIT :pageSize
        OFFSET :pageOffset
      ]
    );

    return PositionListControllerHelper.stripRemovedFieldsFromPositions(
      stripPositions
    );
  }

  @AuraEnabled
  public static void updatePositions(List<Position__c> updatedData) {
    if (!Schema.sObjectType.Position__c.fields.Status__c.isUpdateable()) {
      throw new CustomException(Label.Permission_Exception);
    }
    update updatedData;
  }
}
