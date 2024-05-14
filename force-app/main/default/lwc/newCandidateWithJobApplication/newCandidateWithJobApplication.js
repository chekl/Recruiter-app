import { LightningElement } from "lwc";
import getFormFieldsByObjectType from "@salesforce/apex/CandidateAndJobApplicationModal.getFormFieldsByObjectType";
import { NavigationMixin } from "lightning/navigation";
import { showErrorToast, showSuccessToast } from "c/utils";
import Create_Candidate from "@salesforce/label/c.Create_Candidate";
import Candidate from "@salesforce/label/c.Candidate";
import Job_Application from "@salesforce/label/c.Job_Application";
import Cancel_Label from "@salesforce/label/c.Cancel";
import Save_Label from "@salesforce/label/c.Save";
import Job_Application_Saved from "@salesforce/label/c.Job_Application_Saved";

export default class NewCandidateWithJobApplication extends NavigationMixin(
  LightningElement
) {
  labels = {
    Create_Candidate,
    Candidate,
    Job_Application,
    Cancel_Label,
    Save_Label,
    Job_Application_Saved
  };
  objectApiNames = {
    candidate: "Candidate__c",
    jobApplication: "Job_Application__c"
  };
  candidateFields = [];
  jobApplicationFields = [];
  candidateId;

  connectedCallback() {
    getFormFieldsByObjectType({ sObjectType: "Candidate__c" })
      .then((fields) => (this.candidateFields = fields))
      .catch((error) => showErrorToast(error));
    getFormFieldsByObjectType({
      sObjectType: "Job_Application__c"
    })
      .then((fields) => (this.jobApplicationFields = fields))
      .catch((error) => showErrorToast(error));
  }

  handleReset() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
  }

  navigateToCandidate() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: this.objectApiNames.candidate,
        recordId: this.candidateId,
        actionName: "view"
      }
    });
  }

  createCandidate() {
    this.template
      .querySelector("lightning-record-edit-form[data-id=candidateForm]")
      .submit();
  }

  handleCandidateSuccess(event) {
    this.candidateId = event.detail.id;
    const form = this.template.querySelector(
      "lightning-record-edit-form[data-id=jobApplicationForm]"
    );
    let isApplicationChanged = false;
    const fields = [...form.querySelectorAll("lightning-input-field")].reduce(
      (acc, field) => {
        if (field.value) {
          isApplicationChanged = true;
        }
        acc[field.fieldName] = field.value;
        return acc;
      },
      {}
    );
    fields.Candidate__c = event.detail.id;
    if (isApplicationChanged) {
      form.submit(fields);
    } else {
      this.handleReset();
      this.navigateToCandidate();
    }
  }

  handleFormError(event) {
    showErrorToast(event);
  }

  handleJobApplicationSuccess() {
    showSuccessToast(this.labels.Job_Application_Saved);
    this.handleReset();
    this.navigateToCandidate();
  }

  handleCancel() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectApiNames.candidate,
        actionName: "home"
      }
    });
  }
}
