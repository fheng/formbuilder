Formbuilder.registerField 'section_break',
  type: 'non_input'
  icon: 'icon-minus'
  repeatable: true
  view: """
    <label class='section-name'><%= rf.escape(Formbuilder.options.mappings.LABEL) %></label>
    <p><%= rf.escape(Formbuilder.options.mappings.DESCRIPTION) %></p>
    <hr style="border-bottom: 2px dashed #bbb">
  """

  edit: """
    <div class='fb-edit-section-header' data-rv-translate>Label</div>
    <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />
    <textarea data-rv-input='model.<%= Formbuilder.options.mappings.DESCRIPTION %>'
      placeholder='<%= Formbuilder._("Add a longer description to this field") %>'></textarea>
    <%= Formbuilder.templates['edit/repeating']({rf: rf}) %>
  """

  addButton: """
    <span class='symbol'><span class='icon-minus'></span></span> <span data-rv-translate>Section Break</span>
  """

  defaultAttributes: (attrs) ->
    attrs
