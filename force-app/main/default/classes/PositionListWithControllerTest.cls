@isTest
private class PositionListWithControllerTest {
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
  static void testGetPositionsList() {
    PositionsListWithController controller = new PositionsListWithController();
    controller.selectedStatus = 'Closed';
    controller.getPositionsList();

    Assert.areNotEqual(null, controller.positions, 'Positions are null for Closed status');
    Assert.areEqual(
      1,
      controller.positions.size(),
      'The expected size of Closed positions is 1, but instead get: ' +
      controller.positions.size()
    );
    Assert.areEqual(
      'Closed',
      controller.positions[0].Status__c,
      'The expected status is Closed, but instead get: ' +
      controller.positions[0].Status__c
    );

    controller.selectedStatus = '';
    controller.getPositionsList();

    Assert.areNotEqual(null, controller.positions, 'Positions are null for all statuses');
    Assert.areEqual(3, controller.positions.size(), 'The expected size of all positions is 3, but instead get: ' +
    controller.positions.size());
  }

  @isTest
  static void testSave() {
    PositionsListWithController controller = new PositionsListWithController();
    controller.getPositionsList();

    controller.positions[0].Status__c = 'Closed';

    PageReference pageRef = controller.save();

    List<Position__c> updatedPositions = [
      SELECT Id
      FROM Position__c
      WHERE Status__c = 'Closed'
    ];
    Assert.areEqual(
      2,
      updatedPositions.size(),
      'The expected size of updatedPositions is 2, but instead get: ' +
      updatedPositions.size()
    );
  }

  @isTest
  static void testGetStatuses() {
    PositionsListWithController controller = new PositionsListWithController();
    List<SelectOption> statuses = controller.getStatuses();

    Assert.areNotEqual(null, statuses, 'Statuses are null');
    Assert.areEqual(
      4,
      statuses.size(),
      'The expected size of statuses is 4, but instead get: ' + statuses.size()
    );
  }
}
