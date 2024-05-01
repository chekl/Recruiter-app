public with sharing class MetadataUtils implements Metadata.DeployCallback {
  public static void updateMetadata(
    String fullName,
    String label,
    Map<String, Object> fieldWithValuesMap
  ) {
    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
    customMetadata.fullName = fullName;
    customMetadata.label = label;

    for (String key : fieldWithValuesMap.keySet()) {
      Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
      customField.field = key;
      customField.value = fieldWithValuesMap.get(key);
      customMetadata.values.add(customField);
    }

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);
    MetadataUtils callback = new MetadataUtils();
    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
  }

  public void handleResult(
    Metadata.DeployResult result,
    Metadata.DeployCallbackContext context
  ) {
    if (result.status == Metadata.DeployStatus.SUCCEEDED) {
      System.debug(' ===>' + result);
    } else {
      System.debug(' ===> fail ' + result);
    }
  }
}
