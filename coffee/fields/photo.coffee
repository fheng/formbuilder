Formbuilder.registerField 'photo',
  icon: 'icon-camera'
  repeatable: true
  valueField: false
  view: """
    <h1><span class='icon-camera'></span></h1>
  """
  edit: """
          <div class='fb-edit-section-header'>Photo Settings</div>
          <div class="inline-labels">
          <label>Max Height</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_HEIGHT %>" style="width: 60px" /> px<br />
          <label>Max Width</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_WIDTH %>" style="width: 60px" /> px<br />
          <label>Quality</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_QUALITY %>" style="width: 60px" /> %<br />
          </div>
        """

  addButton: """
    <span class='symbol'><span class='icon-camera'></span></span> Photo Capture
  """

  defaultAttributes: (attrs) ->
    attrs
