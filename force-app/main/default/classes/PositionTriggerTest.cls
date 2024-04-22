@isTest
public with sharing class PositionTriggerTest {
  @isTest
  static void testAddClosedDateToPosition() {
    Test.startTest();
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < 2000; i++) {
      Position__c position = TestDataFactory.createPosition('Test');
      position.Status__c = 'Closed';
      positions.add(position);
    }
    insert positions;
    Test.stopTest();

    List<Position__c> closedPosition = [
      SELECT Closed_Date__c, Id, Status__c
      FROM Position__c
      WHERE Status__c = 'Closed' AND Title__c = 'Test'
    ];

    Assert.areEqual(
      2000,
      closedPosition.size(),
      'The expected result is 2000, but insted get: ' + closedPosition.size()
    );

    Assert.areNotEqual(
      null,
      closedPosition[0].Closed_Date__c,
      'The expected result is date, but insted get:' +
      closedPosition[0].Closed_Date__c
    );
  }
}
