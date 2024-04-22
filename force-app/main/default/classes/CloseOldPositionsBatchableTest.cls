@isTest
private class CloseOldPositionsBatchableTest {
  @TestSetup
  static void makePositions() {
    Test.startTest();
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < 200; i++) {
      Position__c position = TestDataFactory.createPosition('Test');
      position.Open_Date__c = Date.today().addDays(-100);
      position.Status__c = 'Open';
      positions.add(position);
    }
    insert positions;
    Test.stopTest();
  }

  @isTest
  static void testCloseOldPositionsBatchble() {
    Test.startTest();
    CloseOldPositionsBatchble closeOldPositions = new CloseOldPositionsBatchble();
    Id batchID = Database.executeBatch(closeOldPositions, 200);
    Test.stopTest();

    Assert.areEqual(
      200,
      [
        SELECT COUNT()
        FROM Position__c
        WHERE Title__c = 'Test' AND Status__c = 'Closed'
      ],
      'Batcheble does not work'
    );
  }
}
