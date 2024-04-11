public with sharing class PositionsListWithController {
  @TestVisible private List<Position__c> positions { get; set; }
  public String selectedStatus { get; set; }
  public List<SelectOption> statuses = new List<SelectOption>();
  public String whereClause { get; set; }

  public PositionsListWithController() {
    populateStatusOptions();
  }

  private void populateStatusOptions() {
    statuses.add(new SelectOption('', 'All'));
    statuses.add(new SelectOption('Open', 'Open'));
    statuses.add(new SelectOption('Closed', 'Closed'));
    statuses.add(new SelectOption('Pending', 'Pending'));
  }

  private void buildWhereClause() {
    whereClause = selectedStatus != null &&
      selectedStatus != ''
      ? 'WHERE Status__c = \'' + selectedStatus + '\''
      : '';
  }

  public List<Position__c> getPositions() {
    buildWhereClause();
    positions = Database.query(
      'SELECT Id, Title__c, Status__c, Open_Date__c, Closed_Date__c, Min_Pay__c, Max_Pay__c FROM Position__c ' +
      whereClause
    );

    return positions;
  }

  public void getPositionsList() {
    getPositions();
  }

  public List<SelectOption> getStatuses() {
    return statuses;
  }

  public PageReference save() {
    update positions;
    return null;
  }
}
