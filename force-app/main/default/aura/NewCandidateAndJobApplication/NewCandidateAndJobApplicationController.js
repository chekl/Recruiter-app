({
  init: function (component, event, helper) {
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
      }
    });
    $A.enqueueAction(getJAFieldsAction);
  },
  createCandidate: function (component, event, helper) {}
});
