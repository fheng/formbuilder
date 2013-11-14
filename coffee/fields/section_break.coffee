Formbuilder.registerField 'section_break',

  type: 'non_input'
  icon: 'icon-minus'
  view: """
    <label class='section-name'><%= rf.get(Formbuilder.options.mappings.LABEL) %></label>
    <p><%= rf.get(Formbuilder.options.mappings.DESCRIPTION) %></p>
    <hr style="border-bottom: 2px dashed #bbb">
  """

  edit: """
    <div class='fb-edit-section-header'>Label</div>
    <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />
    <textarea data-rv-input='model.<%= Formbuilder.options.mappings.DESCRIPTION %>'
      placeholder='Add a longer description to this field'></textarea>
  """

  addButton: """
    <span class='symbol'><span class='icon-minus'></span></span> Section Break
  """
