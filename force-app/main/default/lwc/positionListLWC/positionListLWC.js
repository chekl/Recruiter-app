import { LightningElement, wire, track } from "lwc";
import getPositions from "@salesforce/apex/PositionsListWithControllerLWC.getPositions";
import updatePositions from "@salesforce/apex/PositionsListWithControllerLWC.updatePositions";

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import POSITION__C_OBJECT from "@salesforce/schema/Position__c.Status__c";
import STATUS__C_FIELD from "@salesforce/schema/Position__c.Status__c";
import { refreshApex } from "@salesforce/apex";

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

const columns = [
  { label: Title, fieldName: "Title__c", type: "text" },
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
  pageTitleLabel = Positions;
  emptyListLabel = Empty_List;
  statusLabel = Status;
  saveLabel = Save;
  saveTitleLabel = Save_Positions_Title;
  columns = columns;

  positions = [];
  positionStatus = [];
  @track selectedStatus = "";

  wiredActivities;
  error;

  @wire(getObjectInfo, { objectApiName: POSITION__C_OBJECT })
  positionObjectMetadata;

  @wire(getPicklistValues, {
    recordTypeId: "$positionObjectMetadata.data.defaultRecordTypeId",
    fieldApiName: STATUS__C_FIELD
  })
  PositionStatusPicklist({ data, error }) {
    if (data) {
      this.positionStatus = data.values;
      this.error = undefined;
    } else if (error) {
      this.error = JSON.stringify(error);
    }
  }

  @wire(getPositions, {
    status: "$selectedStatus",
    allStatuses: "$positionStatus"
  })
  Positions(value) {
    this.wiredActivities = value;
    const { data, error } = value;
    if (data) {
      let options = this.positionStatus.map((picklistValue) => ({
        label: picklistValue.label,
        value: picklistValue.value
      }));
      this.positions = data.map((record) => {
        return {
          ...record,
          picklistOptions: options
        };
      });
      this.error = undefined;
    } else if (error) {
      this.error = JSON.stringify(error);
    }
  }

  handleSave() {
    updatePositions({
      updatedData: this.template.querySelector("c-custom-dt-type-lwc")
        .draftValues
    }).then(() => {
      this.template.querySelector("c-custom-dt-type-lwc").draftValues = [];
      refreshApex(this.wiredActivities);
    });
  }

  handleStatusChange(event) {
    this.selectedStatus = event.target.value;
  }

  handleCellChange(event) {
    let updatedValues = event.detail.draftValues;
    updatedValues.forEach((updatedValue) => {
      let index = this.positions.findIndex((pos) => pos.Id === updatedValue.Id);
      if (index !== -1) {
        this.positions[index].Status__c = updatedValue.Status__c;
      }
    });
  }

  get options() {
    return [
      { label: All, value: "" },
      { label: Status_Open, value: Status_Open },
      { label: Status_Closed, value:  Status_Closed },
      { label: Status_Pending, value: Status_Pending }
    ];
  }
}
