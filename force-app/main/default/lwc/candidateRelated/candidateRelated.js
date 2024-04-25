import { LightningElement, wire, api, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import selectCandidatesRelatedToPosition from "@salesforce/apex/CandidateRelatedController.selectCandidatesRelatedToPosition";
import selectCountOfRelatedCandidates from "@salesforce/apex/CandidateRelatedController.selectCountOfRelatedCandidates";
import Related_Candidates from "@salesforce/label/c.Related_Candidates";
import Empty_List from "@salesforce/label/c.Empty_List";
import selectJobApplicationRelatedToCandidate from "@salesforce/apex/CandidateRelatedController.selectJobApplicationRelatedToCandidate";
import selectCandidateById from "@salesforce/apex/CandidateRelatedController.selectCandidateById";
import CandidateAndJobApplicationModal from "c/candidateAndJobApplicationModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CandidateRelated extends LightningElement {
  labels = { Related_Candidates, Empty_List };
  @wire(CurrentPageReference)
  currentPageReference;
  recordId;
  currentPage = 1;
  @track candidates = [];
  @api pageSize = 1;
  @track candidateCount;
  @api isAvatarsShowed = false;

  connectedCallback() {
    this.recordId = this.currentPageReference.attributes.recordId;
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
    pageSize: "$pageSize"
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
      selectCandidateById({ candidateId }),
      selectJobApplicationRelatedToCandidate({
        candidateId,
        positionId: this.recordId
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
          isAvatarsShowed: this.isAvatarsShowed
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
    let message;

    if (Array.isArray(error.body)) {
      message = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    }

    return message;
  }
}
