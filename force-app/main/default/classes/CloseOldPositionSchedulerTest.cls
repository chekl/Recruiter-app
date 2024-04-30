@isTest
private class CloseOldPositionSchedulerTest {
  @isTest
  static void testScheduler() {
    Test.startTest();

    Position__c position = TestDataFactory.createPosition('Test');
    insert position;

    Id jobId = System.schedule(
      'testScheduler',
      '0 0 0 * * ?',
      new CloseOldPositionScheduler()
    );

    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    Assert.areEqual(
      '0 0 0 * * ?',
      ct.CronExpression,
      'The CronExpressions are not the same, get: ' + ct.CronExpression
    );

    Assert.areEqual(0, ct.TimesTriggered, 'The job is running!');
    Assert.areEqual(
      '2024-04-23 00:00:00',
      String.valueOf(ct.NextFireTime),
      'The expected next time the job will did not meet, instead get: ' +
      String.valueOf(ct.NextFireTime)
    );
    Test.stopTest();

    Assert.areEqual(
      'Test',
      [SELECT Id, Title__c FROM Position__c WHERE Id = :position.Id].Title__c,
      'The expected result is Test'
    );
  }
}
