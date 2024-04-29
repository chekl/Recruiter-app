public class CloseOldPositionScheduler implements Schedulable {
  public void execute(SchedulableContext ctx) {
    CloseOldPositionsBatchble batch = new CloseOldPositionsBatchble();
    Database.executeBatch(batch);
  }
}
