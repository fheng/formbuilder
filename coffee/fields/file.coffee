Formbuilder.registerField 'file',

  view: """
    <div class="file_container" data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>"></div>
    <input type='file' />
  """

  edit: """
        <div class='fb-edit-section-header'>Field Name</div>
        <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />
        """

  addButton: """
    <span class="symbol"><span class="icon-cloud-upload"></span></span> File
  """
