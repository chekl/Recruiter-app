import LightningDatatable from "lightning/datatable";
import picklistPositionStatus from "./picklistPositionStatus";
import picklistPositionStatusEditable from "./picklistPositionStatusEditable";
export default class CustomDtTypeLwc extends LightningDatatable {
  static customTypes = {
    positionStatusPicklist: {
      template: picklistPositionStatus,
      editTemplate: picklistPositionStatusEditable,
      standardCellLayout: true,
      typeAttributes: ["label", "placeholder", "options", "value"]
    }
  };
}
