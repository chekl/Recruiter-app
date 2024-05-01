public with sharing class CandidateRelatedController {
  private static List<Schema.FieldSetMember> getJobApplicationFields(
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult jobApplicationDescribe = Job_Application__c.SObjectType.getDescribe();
    Schema.FieldSet jobApplicationFieldSet = jobApplicationDescribe.fieldSets.getMap()
      .get(fieldSetName);
    if (jobApplicationFieldSet != null) {
      return jobApplicationFieldSet.getFields();
    } else {
      return new List<Schema.FieldSetMember>();
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> selectCountOfRelatedCandidates(
    Id positionId
  ) {
    return [
      SELECT COUNT(Candidate__c)
      FROM Job_Application__c
      WHERE Position__c = :positionId
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Job_Application__c> selectCandidatesRelatedToPosition(
    Id positionId,
    Integer pageSize,
    Integer pageOffset
  ) {
    return [
      SELECT
        Candidate__c,
        Candidate__r.Name,
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT :pageSize
      OFFSET :pageOffset
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Job_Application__c selectJobApplicationRelatedToCandidate(
    Id candidateId,
    Id positionId,
    String fieldSetName
  ) {
    String query =
      'SELECT ' +
      CandidateRelatedController.generateFieldsForQueryByFieldSet(
        CandidateRelatedController.getJobApplicationFields(fieldSetName)
      ) +
      'Id FROM Job_Application__c WHERE Candidate__c = :candidateId AND Position__c = :positionId LIMIT 1';
    return Database.query(query);
  }

  private static List<Schema.FieldSetMember> getCandidateFields(
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult candidateDescribe = Candidate__c.SObjectType.getDescribe();
    Schema.FieldSet candidateFieldSet = candidateDescribe.fieldSets.getMap()
      .get(fieldSetName);
    if (candidateFieldSet != null) {
      return candidateFieldSet.getFields();
    } else {
      System.debug(
        'Field set \'' +
          fieldSetName +
          '\' does not exist on Candidate__c object.'
      );
      return new List<Schema.FieldSetMember>();
    }
  }

  private static String generateFieldsForQueryByFieldSet(
    List<Schema.FieldSetMember> fields
  ) {
    String query = '';
    for (Schema.FieldSetMember field : fields) {
      query += field.getFieldPath() + ', ';
    }
    return query;
  }

  @AuraEnabled(cacheable=true)
  public static Candidate__c selectCandidateByIdAndFieldSet(
    Id candidateId,
    String fieldSetName
  ) {
    List<Schema.FieldSetMember> candidateFields = CandidateRelatedController.getCandidateFields(
      fieldSetName
    );
    if (candidateFields.isEmpty()) {
      // Handle the case where the field set is empty or does not exist
      return null;
    }

    System.debug(
      'Fields in field set \'' +
        fieldSetName +
        '\': ' +
        generateFieldsForQueryByFieldSet(candidateFields)
    );

    String query =
      'SELECT ' +
      generateFieldsForQueryByFieldSet(candidateFields) +
      'Id FROM Candidate__c WHERE Id = :candidateId LIMIT 1';
    System.debug('Query generated: ' + query);

    return Database.query(query);
  }

  @AuraEnabled(cacheable=true)
  public static Related_Candidate_Setting__mdt getCustomMetadataDefaultForRelatedCandidate() {
    String qualifiedApiName;

    if (
      CandidateRelatedController.userHasPermissionByName('Recruiter_Access')
    ) {
      qualifiedApiName = 'Recruiter_Settings';
    } else if (
      CandidateRelatedController.userHasPermissionByName('Interviewer_Access')
    ) {
      qualifiedApiName = 'Interviewer_Settings';
    }

    return qualifiedApiName != null
      ? [
          SELECT
            Is_Avatars_Shown__c,
            Is_Unaccessable_Shown__c,
            Candidates_Per_Page__c,
            Field_Set_For_Candidate_Modal__c,
            Field_Set_For_Candidate_Tile__c,
            Field_Set_For_Related_Job_Application__c
          FROM Related_Candidate_Setting__mdt
          WHERE QualifiedApiName = :qualifiedApiName
          LIMIT 1
        ]
      : null;
  }

  private static Boolean userHasPermissionByName(String permissionName) {
    AggregateResult[] results = [
      SELECT COUNT(Id) total
      FROM PermissionSetAssignment
      WHERE
        AssigneeId = :UserInfo.getUserId()
        AND PermissionSet.Name = :permissionName
    ];

    Integer permissionCount = results.isEmpty()
      ? 0
      : (Integer) results[0].get('total');

    return permissionCount > 0;
  }
}
