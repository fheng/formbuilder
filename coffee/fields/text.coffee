Formbuilder.registerField 'text',

  view: """
    <% var size = rf.get(Formbuilder.options.mappings.SIZE) || 'large'; %>
    <input type='text' value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' class='rf-size-<%= size %>' />
  """

  edit: """
    <%= Formbuilder.templates['edit/size']() %>
    <%= Formbuilder.templates['edit/min_max_length']() %>
  """

  addButton: """
    <span class='symbol'><span class='icon-font'></span></span> Text
  """

  defaultAttributes: (attrs) ->
    attrs.field_options.size = 'large'
    attrs
