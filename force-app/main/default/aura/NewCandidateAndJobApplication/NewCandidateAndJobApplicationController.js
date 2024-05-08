({
  init: function (component) {
    component.set("v.isJobApplicationChanged", false);
    var getCandidateFieldsAction = component.get("c.getCandidateForm");

    getCandidateFieldsAction.setCallback(this, function (response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var form = response.getReturnValue();
        component.set("v.candidateFields", form);
      }
    });
    $A.enqueueAction(getCandidateFieldsAction);

    var getJAFieldsAction = component.get("c.getJobApplicationForm");

    getJAFieldsAction.setCallback(this, function (response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var form = response.getReturnValue();
        component.set("v.jobApplicationFields", form);
        component.set(
          "v.jobApplicationInitial",
          form.map(function (field) {
            return { value: null, fieldName: field };
          })
        );
      }
    });
    $A.enqueueAction(getJAFieldsAction);
  },
  createCandidate: function (component) {
    var candidate = component.find("candidateForm");
    candidate.submit();
  },
  handleCancel: function () {
    var event = $A.get("e.force:navigateToList");
    event.setParams({
      scope: "Candidate__c"
    });
    event.fire();
  },
  handleCandidateSuccess: function (component, event) {
    component.set("v.candidateId", event.getParam("response").id);

    var jobApplication = component.find("jobApplicationForm");
    if (component.get("v.isJobApplicationChanged")) {
      jobApplication.submit();
    } else {
      component.find("field").forEach(function (f) {
        f.reset();
      });
      var navigate = $A.get("e.force:navigateToSObject");
      navigate.setParams({
        recordId: component.get("v.candidateId"),
        slideDevName: "related"
      });
      navigate.fire();
    }
  },
  handleJobApplicationSuccess: function (component) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: $A.get("$Label.c.Default_Success_Title"),
      message: $A.get("$Label.c.Job_Application_Saved"),
      type: "success"
    });
    toastEvent.fire();
    component.find("field").forEach(function (f) {
      f.reset();
    });
    var navigate = $A.get("e.force:navigateToSObject");
    navigate.setParams({
      recordId: component.get("v.candidateId"),
      slideDevName: "related"
    });
    navigate.fire();
  },
  checkJobApplicationChanges: function (component, event) {
    var field = {
      fieldName: event.getSource().get("v.fieldName"),
      value: event.getParam("value")
    };
    component.get("v.jobApplicationInitial").forEach(function (f) {
      if (f.fieldName === field.fieldName) {
        component.set("v.isJobApplicationChanged", f.value !== field.value);
      }
    });
  }
});
