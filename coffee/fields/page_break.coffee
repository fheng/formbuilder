Formbuilder.registerField 'page_break',
  icon: 'icon-file'
  type: 'non_input'
  view: """
        <label class='section-name'>&nbsp; <%= rf.escape(Formbuilder.options.mappings.LABEL) %></label>
        <p><%= rf.escape(Formbuilder.options.mappings.DESCRIPTION) %></p>
        <hr style="border-bottom: 2px solid #bbb">
        """

  edit: """
        <div class='fb-edit-section-header'>Label</div>
        <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />
        <textarea data-rv-input='model.<%= Formbuilder.options.mappings.DESCRIPTION %>'
        placeholder='Add a longer description to this field'></textarea>
        """

  addButton: """
             <span class='symbol'><span class='icon-file'></span></span> Page Break
             """
