Formbuilder.registerField 'dropdown',
  repeatable: false
  valueField: false
  icon : 'icon-caret-down'
  view: """
    <select>
      <% if (rf.get(Formbuilder.options.mappings.INCLUDE_BLANK)) { %>
        <option value=''></option>
      <% } %>

      <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
        <option <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'selected' %>>
          <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>
        </option>
      <% } %>
    </select>
  """

  edit: """
    <%= Formbuilder.templates['edit/options']({ includeBlank: true }) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-caret-down"></span></span> Dropdown
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'dropdown');
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "Option 1",
      checked: false
    ,
      label: "Option 2",
      checked: false
    ])
    attrs.set(Formbuilder.options.mappings.INCLUDE_BLANK, false)
    attrs.toJSON()