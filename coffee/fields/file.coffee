Formbuilder.registerField 'file',
  repeatable: true
  icon: 'icon-cloud-upload'
  valueField: false
  view: """
    <div class="file_container" data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>"></div>
    <input type='file' name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  />
  """

  edit: """
        <div class='fb-edit-section-header'>File Settings</div>
        Max. File Size
        <input type="text" data-rv-input="model.<%= Formbuilder.options.mappings.FILE_SIZE %> | number" style="width: 60px" /> KB
        """

  addButton: """
    <span class="symbol"><span class="icon-cloud-upload"></span></span> File
  """
