@isTest
public with sharing class PositionTriggerTest {
  @isTest
  static void testAddClosedDateToPosition() {
    Position__c positionInsert = TestDataFactory.createPosition('Test');
    positionInsert.Status__c = 'Closed';
    Test.startTest();
    insert positionInsert;
    Test.stopTest();

    Position__c closedPosition = [
      SELECT Closed_Date__c, Id, Status__c
      FROM Position__c
      WHERE Status__c = 'Closed' AND Title__c = 'Test'
      LIMIT 1
    ];

    Assert.areNotEqual(
      null,
      closedPosition.Closed_Date__c,
      'The expected result is date, but insted get:' +
      closedPosition.Closed_Date__c
    );
  }
}
