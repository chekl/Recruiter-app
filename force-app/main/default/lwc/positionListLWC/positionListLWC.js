import { LightningElement, wire, track, api } from "lwc";
import getPositions from "@salesforce/apex/PositionsListWithControllerLWC.getPositions";
import updatePositions from "@salesforce/apex/PositionsListWithControllerLWC.updatePositions";

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import POSITION__C_OBJECT from "@salesforce/schema/Position__c";
import STATUS__C_FIELD from "@salesforce/schema/Position__c.Status__c";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import Positions from "@salesforce/label/c.Positions";
import Title from "@salesforce/label/c.Title";
import Status from "@salesforce/label/c.Status";
import Open_Date from "@salesforce/label/c.Open_Date";
import Closed_Date from "@salesforce/label/c.Closed_Date";
import Min_Pay from "@salesforce/label/c.Min_Pay";
import Max_Pay from "@salesforce/label/c.Max_Pay";
import Status_Open from "@salesforce/label/c.Status_Open";
import Status_Closed from "@salesforce/label/c.Status_Closed";
import Status_Pending from "@salesforce/label/c.Status_Pending";
import All from "@salesforce/label/c.All";
import Empty_List from "@salesforce/label/c.Empty_List";
import Save from "@salesforce/label/c.Save";
import Save_Positions_Title from "@salesforce/label/c.Save_Positions_Title";
import Default_Error_Title from "@salesforce/label/c.Default_Error_Title";
import getCountPositions from "@salesforce/apex/PositionsListWithControllerLWC.getCountPositions";

const columns = [
  {
    label: Title,
    fieldName: "recordLink",
    type: "url",
    typeAttributes: { label: { fieldName: "Title__c" }, target: "_blank" }
  },
  {
    label: Status,
    fieldName: "Status__c",
    type: "positionStatusPicklist",
    editable: "true",
    typeAttributes: {
      placeholder: "Choose Status",
      options: { fieldName: "picklistOptions" },
      value: { fieldName: "Status__c" },
      label: Status
    }
  },
  { label: Open_Date, fieldName: "Open_Date__c", type: "date" },
  { label: Closed_Date, fieldName: "Closed_Date__c", type: "date" },
  { label: Min_Pay, fieldName: "Min_Pay__c", type: "currency" },
  { label: Max_Pay, fieldName: "Max_Pay__c", type: "currency" }
];

export default class PositionsList extends LightningElement {
  labels = {
    Positions,
    Empty_List,
    Status,
    Save,
    Save_Positions_Title,
    Default_Error_Title
  };
  columns = columns;

  positions = [];
  positionStatus = [];
  @track selectedStatus = "";

  @api pageSize = 200;
  currentPage = 1;
  wiredActivities;
  @track positionCount;
  @track positionObjectMetadata;

  @wire(getObjectInfo, { objectApiName: POSITION__C_OBJECT })
  PositionObjectMetadata({ data, error }) {
    if (data) {
      this.positionObjectMetadata = data;
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$positionObjectMetadata.defaultRecordTypeId",
    fieldApiName: STATUS__C_FIELD
  })
  PositionStatusPicklist({ data, error }) {
    if (data) {
      this.positionStatus = data.values;
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  get pageOffset() {
    return (this.currentPage - 1) * this.pageSize;
  }

  @wire(getPositions, {
    status: "$selectedStatus",
    pageSize: "$pageSize",
    pageOffset: "$pageOffset",
    allStatuses: "$positionStatus"
  })
  Positions(value) {
    this.wiredActivities = value;
    const { data, error } = value;
    if (data) {
      const options = this.positionStatus.map((picklistValue) => ({
        label: picklistValue.label,
        value: picklistValue.value
      }));
      this.positions = data.map((record) => {
        return {
          ...record,
          recordLink: "/" + record.Id,
          picklistOptions: options
        };
      });
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  @wire(getCountPositions, {
    status: "$selectedStatus"
  })
  PositionCount({ data, error }) {
    if (data) {
      this.positionCount = data;
    } else if (error) {
      this.showErrorToast(this.generateErrorMessage(error));
    }
  }

  handleSave() {
    updatePositions({
      updatedData: this.template.querySelector("c-custom-dt-type-lwc")
        .draftValues
    })
      .then(() => {
        this.template.querySelector("c-custom-dt-type-lwc").draftValues = [];
        refreshApex(this.wiredActivities);
      })
      .catch((error) => this.showErrorToast(error.body.message));
  }

  handleStatusChange(event) {
    this.selectedStatus = event.target.value;
    this.currentPage = 1;
  }

  handleCellChange(event) {
    const updatedValues = event.detail.draftValues;
    updatedValues.forEach((updatedValue) => {
      const index = this.positions.findIndex(
        (pos) => pos.Id === updatedValue.Id
      );
      if (index !== -1) {
        this.positions[index].Status__c = updatedValue.Status__c;
      }
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

  get options() {
    return [
      { label: All, value: "" },
      { label: Status_Open, value: Status_Open },
      { label: Status_Closed, value: Status_Closed },
      { label: Status_Pending, value: Status_Pending }
    ];
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
