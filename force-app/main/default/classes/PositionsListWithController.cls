public with sharing class PositionsListWithController {
  public List<Position__c> positions { get; private set; }
  public String selectedStatus { get; set; }
  public List<SelectOption> statuses = new List<SelectOption>{
    new SelectOption('', 'All'),
    new SelectOption('Open', 'Open'),
    new SelectOption('Closed', 'Closed'),
    new SelectOption('Pending', 'Pending')
  };

  public void getPositionsList() {
    List<String> statusFilter = new List<String>();
    if (String.isNotBlank(selectedStatus)) {
      statusFilter.add(selectedStatus);
    } else {
      statusFilter.addAll(new List<String>{ 'Open', 'Closed', 'Pending' });
    }

    positions = [
      SELECT
        Id,
        Title__c,
        Status__c,
        Open_Date__c,
        Closed_Date__c,
        Min_Pay__c,
        Max_Pay__c
      FROM Position__c
      WHERE Status__c IN :statusFilter
    ];
  }
  public PositionsListWithController() {
    getPositionsList();
  }
  public List<SelectOption> getStatuses() {
    return statuses;
  }

  public PageReference save() {
    update positions;
    return null;
  }
}
