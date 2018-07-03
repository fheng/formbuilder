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
    <div class='fb-edit-section-header' data-rv-translate>Field Format</div>
    <div class="inline-labels">

    <label data-rv-translate>Type</label>
    <select data-rv-value="model.<%= Formbuilder.options.mappings.FIELD_FORMAT_MODE %>" class="fieldFormatMode" style="width: auto;">
      <option value="simple" data-rv-translate>Simple</option>
      <option value="regex" data-rv-translate>Advanced (Regex)</option>
    </select><br />
    <label data-rv-translate>Format</label>
    <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.FIELD_FORMAT_STRING %>" class="fieldFormatString" style="width: 150px;" /><br />
    </div>
    <div class="simpleFormat">
      <strong>c</strong> = <span data-rv-translate>alphanumeric character</span><br />
      <strong>n</strong> = <span data-rv-translate>number</span><br />
      <span data-rv-translate><strong>e.g.</strong> ccnn-nnnn matches ab12-5432, but not 0000-0000</span>
    </div>
    <div class="advancedFormat" data-rv-translate>
    Use javascript-friendly regular expressions to validate - no need to include surrounding / characters <br />
    <strong>e.g.</strong> .+ but not /.+/

    </div>

  """

  addButton: """
    <span class='symbol'><span class='icon-font'></span></span> <span data-rv-translate>Text</span>
  """

  defaultAttributes: (attrs) ->
    attrs
