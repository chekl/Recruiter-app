@isTest
private class PositionListWithControllerLWCTest {
  @TestSetup
  static void makeData() {
    Test.startTest();
    List<Position__c> positions = new List<Position__c>();
    List<String> statuses = new List<String>{ 'Open', 'Closed', 'Pending' };
    for (String status : statuses) {
      positions.add(
        new Position__c(
          Title__c = 'Position',
          Status__c = status,
          Location__c = 'Test'
        )
      );
    }
    insert positions;
    Test.stopTest();
  }

  @isTest
  static void testUpdatePositions() {
    Test.startTest();
    List<Position__c> positions = PositionsListWithControllerLWC.getPositions(
      '',
      3,
      0
    );
    positions[0].Title__c = 'New Title';
    PositionsListWithControllerLWC.updatePositions(positions);
    Test.stopTest();

    List<Position__c> updatedPositions = [
      SELECT Id, Title__c
      FROM Position__c
      WHERE Title__c = 'New Title'
    ];

    Assert.areEqual(
      1,
      updatedPositions.size(),
      'The expected size of updated positions is 1, but instead get: ' +
      updatedPositions.size()
    );
  }

  @isTest
  static void testGetCountPositions() {
    Test.startTest();
    Integer positionCount = PositionsListWithControllerLWC.getCountPositions(
      ''
    );
    Integer closedPositionCount = PositionsListWithControllerLWC.getCountPositions(
      'Closed'
    );
    Test.stopTest();

    Assert.areEqual(
      3,
      positionCount,
      'The expected count of all positions is 3, but instead get: ' +
      positionCount
    );

    Assert.areEqual(
      1,
      closedPositionCount,
      'The expected count of closed positions is 1, but instead get: ' +
      closedPositionCount
    );
  }

  @isTest
  static void testGetPositions() {
    Test.startTest();
    List<Position__c> positions = PositionsListWithControllerLWC.getPositions(
      '',
      3,
      0
    );
    List<Position__c> closedPositions = PositionsListWithControllerLWC.getPositions(
      'Closed',
      3,
      0
    );
    Test.stopTest();

    Assert.areEqual(
      3,
      positions.size(),
      'The expected size of all positions is 3, but instead get: ' +
      positions.size()
    );

    Assert.areEqual(
      1,
      closedPositions.size(),
      'The expected size of Closed positions is 1, but instead get: ' +
      closedPositions.size()
    );
    Assert.areEqual(
      'Closed',
      closedPositions[0].Status__c,
      'The expected value of Status__c positions is Closed, but instead get: ' +
      closedPositions[0].Status__c
    );
  }
}
