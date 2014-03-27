Formbuilder.registerField 'checkboxes',
  repeatable: false
  valueField: false
  icon : 'icon-check'
  view: """
    <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
      <div>
        <label class='fb-option'>
          <input type='checkbox' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick="javascript: return false;" />
          <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>
        </label>
      </div>
    <% } %>

    <% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>
      <div class='other-option'>
        <label class='fb-option'>
          <input type='checkbox' />
          Other
        </label>

        <input type='text' />
      </div>
    <% } %>
  """

  edit: """
    <%= Formbuilder.templates['edit/options']({}) %>
    <%= Formbuilder.templates['edit/min_max_options']({ rf : rf }) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-check"></span></span> Checkboxes
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'checkboxes');
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "",
      checked: false
    ,
      label: "",
      checked: false
    ])
    attrs.toJSON()
