Formbuilder.registerField 'price',
  repeatable: true
  view: """
    <div class='input-line'>
      <span class='above-line'>$</span>
      <span class='dolars'>
        <input type='text' />
        <label data-rv-translate>Dollars</label>
      </span>
      <span class='above-line'>.</span>
      <span class='cents'>
        <input type='text' />
        <label data-rv-translate>Cents</label>
      </span>
    </div>
  """

  edit: ""

  addButton: """
    <span class="symbol"><span class="icon-dollar"></span></span> <span data-rv-translate>Price</span>
  """
