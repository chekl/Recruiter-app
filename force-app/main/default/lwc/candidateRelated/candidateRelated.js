import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import selectCandidatesRelatedToPosition from '@salesforce/apex/CandidateRelatedController.selectCandidatesRelatedToPosition';
import selectCountOfRelatedCandidates from '@salesforce/apex/CandidateRelatedController.selectCountOfRelatedCandidates';
import Related_Candidates from '@salesforce/label/c.Related_Candidates';
import Empty_List from '@salesforce/label/c.Empty_List';
import selectJobApplicationsRelatedToCandidate from '@salesforce/apex/CandidateRelatedController.selectJobApplicationsRelatedToCandidate';
import selectCandidateById from '@salesforce/apex/CandidateRelatedController.selectCandidateById';
import CandidateAndJobApplicationModal from 'c/candidateAndJobApplicationModal';

export default class CandidateRelated extends LightningElement {
    labels = {Related_Candidates, Empty_List};
    @wire(CurrentPageReference)
    currentPageReference;
    recordId;
    currentPage = 1;
    @track candidates = [];
    @api pageSize = 1;
    @track candidateCount;

    connectedCallback() {
        this.recordId = this.currentPageReference.attributes.recordId;
    }
    
    @wire(selectCountOfRelatedCandidates, {positionId: "$recordId"} ) CandidateCount({data, error}) {
        if(data) {
            this.candidateCount = data[0].expr0;
        } else if(error) {
            //cnsol
        }
    }

    @wire(selectCandidatesRelatedToPosition, {positionId: "$recordId", pageOffset: '$pageOffset',  pageSize: '$pageSize'}) Candidates({data, error}) {
        if(data) {
            this.candidates = data.map((record) => {
                return {
                    id: record.Candidate__c,
                    email: record.Candidate__r.Email__c,
                    fullName: `${record.Candidate__r.First_Name__c} ${record.Candidate__r.Last_Name__c}`,
                    link: '/' + record.Candidate__c
                }
            });
        }  else if(error) {
            //cnsol
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
        selectJobApplicationsRelatedToCandidate({ candidateId })
    ]).then(([candidate, jobApplications]) => {
        CandidateAndJobApplicationModal.open({
            size: 'large',
            candidate,
            jobApplications : jobApplications.map(record => {
                return {
                    ...record,
                    positionTitle: record.Position__r.Title__c
                }
            })
        });
    }).catch(error => {
        console.error('Error fetching data:', error);
    });
  }
}