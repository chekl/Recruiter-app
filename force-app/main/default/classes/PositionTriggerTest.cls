@isTest
public with sharing class PositionTriggerTest {
  @isTest
  static void testAddClosedDateToPosition() {
    Test.startTest();
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < 2000; i++) {
      Position__c position = TestDataFactory.createPosition('Test');
      position.Status__c = 'Open';
      positions.add(position);
    }
    insert positions;

    List<Position__c> positionsToUpdate = [SELECT Id, Status__c FROM Position__c WHERE Status__c = 'Open'];
    Integer halfSize = positionsToUpdate.size() / 2;
    
    for(Integer i = 0; i < halfSize; i++) {
      positionsToUpdate.get(i).Status__c = 'Closed';
    }
    
    for(Integer i = halfSize; i < positionsToUpdate.size(); i++) {
      positionsToUpdate.get(i).Title__c = 'New';
    }
    
    update positionsToUpdate;
    Test.stopTest();

    List<Position__c> closedPosition = [
      SELECT Closed_Date__c, Id, Status__c
      FROM Position__c
      WHERE Status__c = 'Closed' AND Closed_Date__c != null
    ];

    Assert.areEqual(
      halfSize,
      closedPosition.size(),
      'The expected result is ' + halfSize + ' but insted get: ' + closedPosition.size()
    );
  }
}
