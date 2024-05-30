@IsTest
private class FieldsUsageBatchableTest {
  @TestSetup
  static void makePositions() {
    Test.startTest();
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < 200; i++) {
      Position__c position = TestDataFactory.createPosition('Test');
      positions.add(position);
    }
    insert positions;
    Test.stopTest();
  }

  @isTest
  static void testCloseOldPositionsBatchble() {
    Test.startTest();
    FieldsUsageBatchable fieldsUsageBatchable = new FieldsUsageBatchable(
      'Position__c'
    );
    Id batchID = Database.executeBatch(fieldsUsageBatchable, 200);
    Test.stopTest();

    Assert.areEqual(
      'Completed',
      [
        SELECT Status
        FROM AsyncApexJob
        WHERE Id = :batchID
      ]
      .Status,
      'Batcheble does not completed '
    );
  }
}
