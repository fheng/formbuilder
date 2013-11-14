Formbuilder.registerField 'paragraph',
  icon : 'icon-align-justify'

  repeatable: true
  view: """
    <textarea class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' ><%= rf.get(Formbuilder.options.mappings.VALUE) %></textarea>
  """

  edit: """
    <%= Formbuilder.templates['edit/size']() %>
    <%= Formbuilder.templates['edit/min_max_length']() %>
  """

  addButton: """
    <span class="icon icon-align-justify"></span> Paragraph
  """

  defaultAttributes: (attrs) ->
    attrs
