import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import Title from '@salesforce/label/c.Title';
import Status from '@salesforce/label/c.Status';
import Average_Rating from '@salesforce/label/c.Average_Rating'

const COLUMNS = [
    {
    label: Title,
    fieldName: "positionTitle",
    type: "Text"  },
  {
    label: Status,
    fieldName: "Status__c",
    type: "Text",
  },
  { label: Average_Rating, 
    fieldName: 'Avg_Rating__c',
    type: "Number"
}
];

export default class CandidateAndJobApplicationModal extends LightningModal {
    @api candidate;
    @api jobApplications;
    columns = COLUMNS;
}