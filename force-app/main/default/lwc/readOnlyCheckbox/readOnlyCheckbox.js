import { LightningElement, api } from 'lwc';

export default class ReadOnlyCheckbox extends LightningElement {
    @api label;
    @api checked;
}