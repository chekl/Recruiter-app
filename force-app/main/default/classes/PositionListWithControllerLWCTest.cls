@isTest
private class PositionListWithControllerLWCTest {
  @TestSetup
  static void makeData() {
    Test.startTest();
    List<Position__c> pos = new List<Position__c>();
    List<String> statuses = new List<String>{ 'Open', 'Closed', 'Pending' };
    for (String status : statuses) {
      pos.add(
        new Position__c(
          Title__c = 'Position',
          Status__c = status,
          Location__c = 'Test'
        )
      );
    }
    insert pos;
    Test.stopTest();
  }

  @isTest
  static void testUpdatePositions() {
    List<Position__c> pos = PositionsListWithControllerLWC.getPositions('');
    pos[0].Title__c = 'New Title';
    PositionsListWithControllerLWC.updatePositions(pos);

    List<Position__c> updatedPos = [
      SELECT Id, Title__c
      FROM Position__c
      WHERE Title__c = 'New Title'
    ];

    Assert.areEqual(
      1,
      updatedPos.size(),
      'The expected size of updated positions is 1, but instead get: ' +
      updatedPos.size()
    );
  }

  @isTest
  static void testGetPositions() {
    List<Position__c> pos = PositionsListWithControllerLWC.getPositions('');
    Assert.areEqual(
      3,
      pos.size(),
      'The expected size of all positions is 3, but instead get: ' + pos.size()
    );

    pos = PositionsListWithControllerLWC.getPositions('Closed');
    Assert.areEqual(
      1,
      pos.size(),
      'The expected size of Closed positions is 1, but instead get: ' +
      pos.size()
    );
    Assert.areEqual(
      'Closed',
      pos[0].Status__c,
      'The expected value of Status__c positions is Closed, but instead get: ' +
      pos[0].Status__c
    );
  }
}
