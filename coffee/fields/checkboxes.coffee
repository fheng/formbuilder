Formbuilder.registerField 'checkboxes',
  repeatable: false
  valueField: false
  icon : 'icon-check'
  view: """
    <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
      <div>
        <label class='fb-option'>
          <input type='checkbox' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick="javascript: return false;" />
          <%= _.escape(rf.get(Formbuilder.options.mappings.OPTIONS)[i].label) %>
        </label>
      </div>
    <% } %>

    <% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>
      <div class='other-option'>
        <label class='fb-option'>
          <input type='checkbox' />
          <span data-rv-translate>Other</span>
        </label>

        <input type='text' />
      </div>
    <% } %>
  """

  edit: """
    <%= Formbuilder.templates['edit/min_max_options']({ rf : rf }) %>
    <%= Formbuilder.templates['edit/options']({includeDatasource: true, rf: rf}) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-check"></span></span> <span data-rv-translate>Checkboxes</span>
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'checkboxes');
    attrs.set(Formbuilder.options.mappings.MIN, 1);
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "Option 1",
      checked: false
    ,
      label: "Option 2",
      checked: false
    ])
    attrs.toJSON()
