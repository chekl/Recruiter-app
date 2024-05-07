import { LightningElement, wire } from "lwc";
import getAllQualifiedApiNamesForRelatedCandidate from "@salesforce/apex/PageSettingsRelatedCandidatesController.getAllQualifiedApiNamesForRelatedCandidate";
import getCustomMetadataForRelatedCandidate from "@salesforce/apex/PageSettingsRelatedCandidatesController.getCustomMetadataForRelatedCandidate";
import Select_Metadata_Record from "@salesforce/label/c.Select_Metadata_Record";
import Custom_Metadata_Type_Record from "@salesforce/label/c.Custom_Metadata_Type_Record";
import Field_Set_For_Candidate_Tile from "@salesforce/label/c.Field_Set_For_Candidate_Tile";
import Field_Set_For_Candidate_Modal from "@salesforce/label/c.Field_Set_For_Candidate_Modal";
import Field_Set_For_Job_Application from "@salesforce/label/c.Field_Set_For_Job_Application";
import Candidate_Per_Page from "@salesforce/label/c.Candidate_Per_Page";
import Is_Avatars_Shown from "@salesforce/label/c.Is_Avatars_Shown";
import Is_Unaccessable_Shown from "@salesforce/label/c.Is_Unaccessable_Shown";
import Msg_Record_Update from "@salesforce/label/c.Msg_Record_Update";
import Fields from "@salesforce/label/c.Fields";
import Save_Label from "@salesforce/label/c.Save";
import updateCustomMetadataRecord from "@salesforce/apex/PageSettingsRelatedCandidatesController.updateCustomMetadataRecord";
import { showErrorToast, showSuccessToast } from "c/utils";
import { refreshApex } from "@salesforce/apex";

export default class PageSettingsForRelatedCandidatesBlock extends LightningElement {
  qualifiedApiNames;
  selectedApiName;
  isAvatarsShowed;
  isUnaccessableShowed;
  fieldSetForCandidateTile;
  fieldSetForCandidateModal;
  fieldSetForCandidateJobApplications;
  candidatePerPage;
  wiredActivities;
  labels = {
    Select_Metadata_Record,
    Custom_Metadata_Type_Record,
    Field_Set_For_Candidate_Tile,
    Field_Set_For_Candidate_Modal,
    Field_Set_For_Job_Application,
    Fields,
    Save_Label,
    Candidate_Per_Page,
    Is_Avatars_Shown,
    Is_Unaccessable_Shown,
    Msg_Record_Update
  };
  typeRecordOptions;
  recordId;
  objectApiNames = {
    CANDIDATE__C: "Candidate__c",
    JOB_APPLICATION__C: "Job_Application__c"
  };

  @wire(getAllQualifiedApiNamesForRelatedCandidate) QualifiedApiNames({
    data,
    error
  }) {
    if (data) {
      this.typeRecordOptions = data.map((val) => {
        return { label: val, value: val };
      });
    } else if (error) {
      showErrorToast(error);
    }
  }

  @wire(getCustomMetadataForRelatedCandidate, {
    qualifiedApiName: "$selectedApiName"
  })
  getPrevSettings(value) {
    this.wiredActivities = value;
    const { data, error } = value;
    if (data) {
      this.recordId = data.id;
      this.candidatePerPage = data.Candidates_Per_Page__c;
      this.isAvatarsShowed = data.Is_Avatars_Shown__c;
      this.isUnaccessableShowed = data.Is_Unaccessable_Shown__c;
      this.fieldSetForCandidateTile = data.Field_Set_For_Candidate_Tile__c;
      this.fieldSetForCandidateModal = data.Field_Set_For_Candidate_Modal__c;
      this.fieldSetForCandidateJobApplications =
        data.Field_Set_For_Related_Job_Application__c;
    } else if (error) {
      showErrorToast(error);
    }
  }

  handleTypeRecordChange(event) {
    this.selectedApiName = event.detail.value;
  }

  handleFieldSetJobApplicationChange(event) {
    this.fieldSetForCandidateJobApplications = event.detail.value;
  }
  handleFieldSetCandidateTileChange(event) {
    this.fieldSetForCandidateTile = event.detail.value;
  }
  handleFieldSetCandidateModalChange(event) {
    this.fieldSetForCandidateModal = event.detail.value;
  }
  handleIsAvatarShownChange(event) {
    this.isAvatarsShowed = event.detail.checked;
  }
  handleIsUnaccessableShowedChange(event) {
    this.isUnaccessableShowed = event.detail.checked;
  }
  handleCandidatePerPageChange(event) {
    this.candidatePerPage = event.detail.value;
  }

  updateRecord(event) {
    event.preventDefault();
    const fieldWithValuesMap = {
      Candidates_Per_Page__c: this.candidatePerPage,
      Is_Avatars_Shown__c: this.isAvatarsShowed,
      Is_Unaccessable_Shown__c: this.isUnaccessableShowed,
      Field_Set_For_Candidate_Tile__c: this.fieldSetForCandidateTile,
      Field_Set_For_Candidate_Modal__c: this.fieldSetForCandidateModal,
      Field_Set_For_Related_Job_Application__c:
        this.fieldSetForCandidateJobApplications
    };
    updateCustomMetadataRecord({
      qualifiedApiName: this.selectedApiName,
      fieldWithValuesMap
    })
      .then(() => {
        showSuccessToast(this.labels.Msg_Record_Update);
        refreshApex(this.wiredActivities);
      })
      .catch((error) => showErrorToast(error));
  }
}
