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
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_HEIGHT %> | number" style="width: 60px" /> px<br />
          <label>Max Width</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_WIDTH %> | number" style="width: 60px" /> px<br />
          <label>Quality</label>
          <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.PHOTO_QUALITY %> | number" style="width: 60px" /> %<br />
          <label>Photo Source</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_SOURCE %>" style="width: auto;">
          <option value="both">Camera &amp; Library</option>
          <option value="camera">Camera Only</option>
          <option value="library">Library Only</option>
          </select> <br />
          <label>Photo Type</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_TYPE %>" style="width: auto;">
          <option value="jpeg">JPEG</option>
          <option value="png">PNG</option>
          </select> <br />
          <label>Save To Photo Album?</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.PHOTO_SAVE %>" style="width: auto;">
          <option value="true">Yes</option>
          <option value="false">No</option>
          </select>
          </div>
        """

  addButton: """
    <span class='symbol'><span class='icon-camera'></span></span> Photo Capture
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.PHOTO_SOURCE, "both");
    attrs.set(Formbuilder.options.mappings.PHOTO_TYPE, "jpeg");
    attrs.set(Formbuilder.options.mappings.PHOTO_SAVE, "true");
    attrs.toJSON()
