import { LightningElement, wire } from "lwc";
import getFormFields from "@salesforce/apex/CandidateAndJobApplicationModal.getFormFields";
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
  isJobApplicationChanged = false;
  jobApplicationInitial;
  candidateId;

  @wire(getFormFields) FormFields({ data, error }) {
    if (data) {
      this.candidateFields = data.candidateFields;
      this.jobApplicationFields = data.jobApplicationFields;
      this.jobApplicationInitial = data.jobApplicationFields.map(
        (fieldName) => {
          return { value: null, fieldName };
        }
      );
    } else if (error) {
      showErrorToast(error);
    }
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
    if (this.isJobApplicationChanged) {
      this.template
        .querySelector("lightning-record-edit-form[data-id=jobApplicationForm]")
        .submit();
    } else {
      this.handleReset();
      this.navigateToCandidate();
    }
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

  checkJobApplicationChanges(event) {
    const field = {
      fieldName: event.target.fieldName,
      value: event.detail.value
    };
    this.jobApplicationInitial.forEach((f) => {
      if (f.fieldName === field.fieldName) {
        this.isJobApplicationChanged = f.value !== field.value;
      }
    });
  }
}
