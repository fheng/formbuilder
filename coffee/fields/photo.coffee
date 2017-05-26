Formbuilder.registerField 'photo',
  icon: 'icon-camera'
  repeatable: true
  valueField: false
  view: """
    <h1><span class='icon-camera'></span></h1>
  """
  edit: """
          <div class='fb-edit-section-header' data-rv-translate>Photo Settings</div>
          <div class="inline-labels">
          <label data-rv-translate>Max Height</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_HEIGHT %> | number" style="width: 60px" /> <span data-rv-translate>px</span><br />
          <label data-rv-translate>Max Width</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_WIDTH %> | number" style="width: 60px" /> <span data-rv-translate>px</span><br />
          <label data-rv-translate>Quality</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_QUALITY %> | number" style="width: 60px" /> %<br />
          <label data-rv-translate>Photo Source</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_SOURCE %>" style="width: auto;">
          <option value="both" data-rv-translate>Camera &amp; Library</option>
          <option value="camera" data-rv-translate>Camera Only</option>
          <option value="library" data-rv-translate>Library Only</option>
          </select> <br />
          <label data-rv-translate>Photo Type</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_TYPE %>" style="width: auto;">
          <option value="jpeg" data-rv-translate>JPEG</option>
          <option value="png" data-rv-translate>PNG</option>
          </select> <br />
          <label data-rv-translate>Save To Photo Album?</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_SAVE %>" style="width: auto;">
          <option value="true" data-rv-translate>Yes</option>
          <option value="false" data-rv-translate>No</option>
          </select>
          </div>
        """

  addButton: """
    <span class='symbol'><span class='icon-camera'></span></span> <span data-rv-translate>Photo Capture</span>
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.PHOTO_SOURCE, "both");
    attrs.set(Formbuilder.options.mappings.PHOTO_TYPE, "jpeg");
    attrs.set(Formbuilder.options.mappings.PHOTO_SAVE, "true");
    attrs.toJSON()
