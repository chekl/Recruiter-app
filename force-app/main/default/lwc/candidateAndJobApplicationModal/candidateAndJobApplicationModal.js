import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import Status from '@salesforce/label/c.Status';
import Average_Rating from '@salesforce/label/c.Average_Rating'
import Job_Application from '@salesforce/label/c.Job_Application';
import Candidate from '@salesforce/label/c.Candidate';
import Location from '@salesforce/label/c.Location';
import Email from '@salesforce/label/c.Email';
import Phone from '@salesforce/label/c.Phone';
import Resume from '@salesforce/label/c.Resume';
import Ready_To_Relocate from '@salesforce/label/c.Ready_To_Relocate';
import Created_By from '@salesforce/label/c.Created_By';

export default class CandidateAndJobApplicationModal extends LightningModal {
    @api candidate;
    @api jobApplication;
    @api isAvatarsShowed;
    labels = { Job_Application, Candidate, Email, Phone, Resume, Ready_To_Relocate, Location, Average_Rating, Status, Created_By };
}