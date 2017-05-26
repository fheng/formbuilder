Formbuilder.registerField 'address',
  repeatable : true
  view: """
    <div class='input-line'>
      <span class='street'>
        <input type='text' />
        <label data-rv-translate>Address</label>
      </span>
    </div>

    <div class='input-line'>
      <span class='city'>
        <input type='text' />
        <label data-rv-translate>City</label>
      </span>

      <span class='state'>
        <input type='text' />
        <label data-rv-translate>State / Province / Region</label>
      </span>
    </div>

    <div class='input-line'>
      <span class='zip'>
        <input type='text' />
        <label data-rv-translate>Zipcode</label>
      </span>

      <span class='country'>
        <select><option data-rv-translate>United States</option></select>
        <label data-rv-translate>Country</label>
      </span>
    </div>
  """

  edit: ""

  addButton: """
    <span class="symbol"><span class="icon-home"></span></span> <span data-rv-translate>Address</span>
  """
