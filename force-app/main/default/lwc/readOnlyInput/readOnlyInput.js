import { LightningElement, api } from 'lwc';

export default class ReadOnlyInput extends LightningElement {
    @api value;
    @api type = 'text';
    @api label;
    get inputValue() { 
        return this.value !== undefined ? this.value : ''
    }
}