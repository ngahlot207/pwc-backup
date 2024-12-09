import { LightningElement, track, api } from 'lwc';

export default class MultiSelectPickList extends LightningElement {

  @track _options;
  @api selectedValue;
  @api label;
  @api disabled = false;
  @api multiSelect = false;
  @track value;
  @track values = [];
  @track optionData;
  @track searchString;
  @track noResultMessage;
  @track showDropdown = false;
  @track _selectedValues;
  @track _required
  @api get isrequired() {
    return this._required;
  }
  set isrequired(value) {
    this._required = value
  }
  @api get selectedValues() {

    return this._selectedValues;
  }
  set selectedValues(value) {
    this._selectedValues = value;
    this.setAttribute("selectedValues", value);

    this.initialize();
  }

  @api get options() {

    return this._options;
  }
  set options(value) {
    this._options = value;
    this.setAttribute("options", value);

    this.initialize();
  }

  connectedCallback() {
    console.log('required', this._required);
    this.initialize();

  }

  initialize() {
    //console.log('options prop owners',options);
    this.showDropdown = false;
    var tempoptionDataList = [];
    var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
    var values = this._selectedValues ? (JSON.parse(JSON.stringify(this._selectedValues))) : null;
    console.log('selected Values print coming from api', values);
    if (value || values) {
      var searchString;
      var count = 0;
      let tempOptionData = {}
      for (var i = 0; i < this._options.length; i++) {
        if (this.multiSelect) {
          if (values.includes(this._options[i].value)) {
            tempOptionData = { ...this._options[i] };

            tempOptionData.selected = true;
            tempoptionDataList.push(tempOptionData);
            count++;
            console.log('values includes', values);
            console.log('options list', tempoptionDataList);
          } else {
            tempOptionData = { ...this._options[i] };
            tempOptionData.selected = false;
            tempoptionDataList.push(tempOptionData);

          }
        } else {
          if (this._options[i].value == value) {
            searchString = this._options[i].label;
            console.log('searchString', searchString);
          }
        }
      }
      if (this.multiSelect) {
        this.searchString = count + ' Option(s) Selected';
        console.log('options selected', this.searchString);
      } else {
        this.searchString = searchString;
      }

    }
    this.value = value;
    this.values = values;
    this.optionData = [...tempoptionDataList];
    console.log('option data print', this.optionData);
    this.checkValidityMultiPick();
  }

  selectItem(event) {
    try {
      var selectedVal = event.currentTarget.dataset.id;
      if (selectedVal) {
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
          if (options[i].value === selectedVal) {
            if (this.multiSelect) {
              if (this.values.includes(options[i].value)) {
                this.values.splice(this.values.indexOf(options[i].value), 1);
              } else {
                this.values.push(options[i].value);
              }
              options[i].selected = options[i].selected ? false : true;
            } else {
              this.value = options[i].value;
              this.searchString = options[i].label;
            }
          }
          if (options[i].selected) {
            count++;
          }
        }
        this.optionData = options;
        console.log('option data1 ', this.optionData);
        if (this.multiSelect) {
          this.searchString = count + ' Option(s) Selected';

          let ev = new CustomEvent('selectoption', { detail: this.values });
          this.dispatchEvent(ev);
        }
        if (!this.multiSelect) {
          let ev = new CustomEvent('selectoption', { detail: this.value });
          this.dispatchEvent(ev);
        }
        if (this.multiSelect)
          event.preventDefault();
        else
          this.showDropdown = false;
      }
    } catch (error) {
      console.log(error);
    }

  }

  @api checkValidityMultiPick() {
    let isInputCorrect;
    if (this.multiSelect) {
      isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
        if (this._selectedValues.length === 0 && this._required) {
          inputField.setCustomValidity("Please Enter Valid Input");
        } else {
          console.log('print else in multi select');
          inputField.setCustomValidity("");
        }
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    } else {
      isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
        inputField.setCustomValidity("");
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    }

    return isInputCorrect;
  }

  showOptions() {
    try {
      if (this.disabled == false && this._options) {
        this.noResultMessage = '';
        this.searchString = '';
        console.log('option data 2 ', this.optionData);
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
          options[i].isVisible = true;
        }
        if (options.length > 0) {
          this.showDropdown = true;
        }
        this.optionData = [...options];
        console.log('onclick of input', this.optionData);
        this.checkValidityMultiPick();

      }
    } catch (error) {
      console.log('error ==== ', error);
    }

  }

  @api clearAll() {
    this.values = [];
    var optionData = this._options ? (JSON.parse(JSON.stringify(this._options))) : null;
    for (var i = 0; i < optionData.length; i++) {
      if (this.multiSelect) {
        optionData[i].selected = false;
      }
    }
    this.searchString = 0 + ' Option(s) Selected';
    this.selectedValues = [];
    this.optionData = optionData;
  }

  @track selectPillValue
  closePill(event) {
    if (this.disabled == false) {
      var value = event.currentTarget.name;
      this.selectPillValue = event.currentTarget.name;
      console.log('close options of picklist', value);
      var count = 0;
      var options = JSON.parse(JSON.stringify(this.optionData));
      for (var i = 0; i < options.length; i++) {
        if (options[i].value === value) {
          options[i].selected = false;
          this.values.splice(this.values.indexOf(options[i].value), 1);
        }
        if (options[i].selected) {
          count++;
        }
      }
      this.optionData = [...options];
      if (this.multiSelect) {
        this.searchString = count + ' Option(s) Selected';
        console.log('select option for close pill', this.searchString);
        let ev = new CustomEvent('selectoption', { detail: this.values });
        this.dispatchEvent(ev);
      }
      let deletedPillValue = new CustomEvent('deleteoption', { detail: this.selectPillValue });
      this.dispatchEvent(deletedPillValue);
    }
  }

  handleBlur() {
    var previousLabel;
    var count = 0;
    for (var i = 0; i < this.optionData.length; i++) {
      if (this.optionData[i].value === this.value) {
        previousLabel = this.optionData[i].label;
      }
      if (this.optionData[i].selected) {
        count++;
      }
    }

    if (this.multiSelect) {
      this.searchString = count + ' Option(s) Selected';
    } else {
      this.searchString = previousLabel;
    }

    this.showDropdown = false;
  }

  handleMouseOut() {
    this.showDropdown = false;
  }

  handleMouseIn() {
    this.showDropdown = true;
  }
}