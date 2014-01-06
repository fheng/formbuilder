Formbuilder.registerField 'text',
  icon: 'icon-font'
  repeatable: true
  view: """
    <% var size = rf.get(Formbuilder.options.mappings.SIZE) || 'large'; %>
    <input type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' class='rf-size-<%= size %>' />
  """

  edit: """
    <%= Formbuilder.templates['edit/size']() %>
    <%= Formbuilder.templates['edit/min_max_length']() %>
    <div class='fb-edit-section-header'>Field Format</div>
    <div class="inline-labels">

    <label>Type</label>
    <select data-rv-value="model.<%= Formbuilder.options.mappings.FIELD_FORMAT_MODE %>" class="fieldFormatMode" style="width: auto;">
      <option value="simple">Simple</option>
      <option value="regex">Advanced (Regex)</option>
    </select><br />
    <label>Format</label>
    <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.FIELD_FORMAT_STRING %>" class="fieldFormatString" style="width: 150px;" /><br />
    </div>
    <div class="simpleFormat">
      <strong>c</strong> = alphanumeric character<br />
      <strong>n</strong> = number<br />
      <strong>e.g.</strong> ccnn-nnnn matches ab12-5432, but not 0000-0000
    </div>
    <div class="advancedFormat">
    Use javascript-friendly regular expressions to validate - no need to include surrounding / characters <br />
    <strong>e.g.</strong> .+ but not /.+/

    </div>

  """

  addButton: """
    <span class='symbol'><span class='icon-font'></span></span> Text
  """

  defaultAttributes: (attrs) ->
    attrs
