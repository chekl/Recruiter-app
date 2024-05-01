import { api, wire, LightningElement } from "lwc";
import getPicklistValues from "@salesforce/apex/PageSettingsRelatedCandidatesController.getPicklistValues";
import getObjectFields from "@salesforce/apex/PageSettingsRelatedCandidatesController.getObjectFields";
import Select_Value from "@salesforce/label/c.Select_Value";
import Fields from "@salesforce/label/c.Fields";
import { showErrorToast } from "c/utils";

export default class PicklistForMetadata extends LightningElement {
  @api fieldapiname;
  @api selected;
  @api label;
  @api objectapiname;
  labels = { Select_Value, Fields };
  options;
  wiredActivities;
  fieldsList = [];

  @wire(getPicklistValues, { picklistField: "$fieldapiname" }) PicklistValues({
    data,
    error
  }) {
    if (data) {
      this.options = data.map((val) => {
        return { value: val, label: val };
      });
    } else if (error) {
      showErrorToast(error);
    }
  }

  @wire(getObjectFields, {
    objectApiName: "$objectapiname",
    fieldSetName: "$selected"
  })
  Fields({ data, error }) {
    if (data) {
      this.fieldsList = data;
    } else if (error) {
      showErrorToast(error);
    }
  }

  handleChange(event) {
    this.dispatchEvent(
      new CustomEvent("onchange", {
        detail: event.detail.value
      })
    );
  }
}
