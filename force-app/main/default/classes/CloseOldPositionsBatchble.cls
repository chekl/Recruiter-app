public class CloseOldPositionsBatchble implements Database.Batchable<SObject> {
  private static final Date TODAY_MINUS_3_MONTHS = Date.today().addDays(-90);
  private static final String OPEN_STATUS = 'Open';

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Status__c, Open_Date__c FROM Position__c WHERE Status__c = :OPEN_STATUS AND Open_Date__c <= :TODAY_MINUS_3_MONTHS'
    );
  }

  public void execute(Database.BatchableContext bc, List<Position__c> scope) {
    CloseOldPositionsBatchbleHelper.closeOldPositions(scope);
  }

  public void finish(Database.BatchableContext bc) {
  }
}
