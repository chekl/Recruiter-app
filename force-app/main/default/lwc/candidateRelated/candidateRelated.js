import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import selectCandidatesRelatedToPosition from "@salesforce/apex/CandidateRelatedController.selectCandidatesRelatedToPosition";
import selectCountOfRelatedCandidates from "@salesforce/apex/CandidateRelatedController.selectCountOfRelatedCandidates";
import Related_Candidates from "@salesforce/label/c.Related_Candidates";
import Empty_List from "@salesforce/label/c.Empty_List";
import selectJobApplicationRelatedToCandidate from "@salesforce/apex/CandidateRelatedController.selectJobApplicationRelatedToCandidate";
import selectCandidateByIdAndFieldSet from "@salesforce/apex/CandidateRelatedController.selectCandidateByIdAndFieldSet";
import getCustomMetadataForRelatedCandidate from "@salesforce/apex/CandidateRelatedController.getCustomMetadataForRelatedCandidate";
import CandidateAndJobApplicationModal from "c/candidateAndJobApplicationModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CandidateRelated extends LightningElement {
  labels = { Related_Candidates, Empty_List };
  @wire(CurrentPageReference)
  currentPageReference;
  recordId;
  currentPage = 1;
  @track candidates = [];
  pageSize;
  @track candidateCount;
  isAvatarsShowed;
  isUnaccessableShowed;
  fieldSetForCandidateTile;
  fieldSetForCandidateModal;
  fieldSetForCandidateJobApplications;
  isBlockAccessed = false;

  connectedCallback() {
    this.recordId = this.currentPageReference.attributes.recordId;
  }

  @wire(getCustomMetadataForRelatedCandidate)
  Metadatarecord({ data, error }) {
    if (data) {
      this.pageSize = data.Candidates_Per_Page__c;
      this.isAvatarsShowed = data.Is_Avatars_Shown__c;
      this.isUnaccessableShowed = data.Is_Unaccessable_Shown__c;
      this.fieldSetForCandidateTile = data.Field_Set_For_Candidate_Tile__c;
      this.fieldSetForCandidateModal = data.Field_Set_For_Candidate_Modal__c;
      this.fieldSetForCandidateJobApplications =
        data.Field_Set_For_Related_Job_Application__c;
      this.isBlockAccessed = true;
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  @wire(selectCountOfRelatedCandidates, { positionId: "$recordId" })
  CandidateCount({ data, error }) {
    if (data) {
      this.candidateCount = data[0].expr0;
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  @wire(selectCandidatesRelatedToPosition, {
    positionId: "$recordId",
    pageOffset: "$pageOffset",
    pageSize: "$pageSize",
    fieldSetName: "$fieldSetForCandidateTile"
  })
  Candidates({ data, error }) {
    if (data) {
      this.candidates = data.map((record) => {
        return {
          id: record.Candidate__c,
          email: record.Candidate__r.Email__c,
          fullName: `${record.Candidate__r.First_Name__c} ${record.Candidate__r.Last_Name__c}`,
          link: "/" + record.Candidate__c
        };
      });
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  get pageOffset() {
    return (this.currentPage - 1) * this.pageSize;
  }

  handleNextPage() {
    this.currentPage = this.currentPage + 1;
  }

  handlePreviousPage() {
    this.currentPage = this.currentPage - 1;
  }

  handleSetCurrentPage(event) {
    this.currentPage = event.detail;
  }

  openCandidateDetails(event) {
    const candidateId = event.target.dataset.candidate;
    Promise.all([
      selectCandidateByIdAndFieldSet({
        candidateId,
        fieldSetName: this.fieldSetForCandidateModal
      }),
      selectJobApplicationRelatedToCandidate({
        candidateId,
        positionId: this.recordId,
        fieldSetName: this.fieldSetForCandidateJobApplications
      })
    ])
      .then(([candidate, jobApplication]) => {
        CandidateAndJobApplicationModal.open({
          size: "large",
          candidate: {
            ...candidate,
            link: "/" + candidate.Id,
            fullName: `${candidate.First_Name__c} ${candidate.Last_Name__c}`,
            ownerLink: "/" + candidate.CreatedById,
            ownerPhotoUrl: candidate.CreatedBy.SmallPhotoUrl,
            ownerUsername: candidate.CreatedBy.Username
          },
          jobApplication: { ...jobApplication, link: "/" + jobApplication.Id },
          isAvatarsShowed: this.isAvatarsShowed,
          isUnaccessableShowed: this.isUnaccessableShowed
        });
      })
      .catch((error) => {
        this.showErrorToast(this.generateErrorMessage(error));
      });
  }

  showErrorToast(error) {
    const event = new ShowToastEvent({
      title: this.labels.Default_Error_Title,
      variant: "Error",
      message: error
    });
    this.dispatchEvent(event);
  }

  generateErrorMessage(error) {
    let errorMessage;
    if (Array.isArray(error.body)) {
      errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      errorMessage = error.body.message;
    }

    return errorMessage;
  }
}
