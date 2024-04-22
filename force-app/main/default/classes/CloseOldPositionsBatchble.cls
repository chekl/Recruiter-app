public class CloseOldPositionsBatchble implements Database.Batchable<SObject> {
  private static final Date TODAY_MINUS_3_MOUNTH = Date.today().addDays(-90);

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Status__c, Open_Date__c FROM Position__c WHERE Status__c = \'Open\' AND Open_Date__c <= :TODAY_MINUS_3_MOUNTH'
    );
  }

  public void execute(Database.BatchableContext bc, List<Position__c> scope) {
    CloseOldPositionsBatchbleHelper.closeOldPositions(scope);
  }

  public void finish(Database.BatchableContext bc) {
  }
}
