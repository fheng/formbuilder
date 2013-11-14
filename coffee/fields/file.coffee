Formbuilder.registerField 'file',
  repeatable: true
  valueField: false
  view: """
    <div class="file_container" data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>"></div>
    <input type='file' name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  />
  """

  edit: ""

  addButton: """
    <span class="symbol"><span class="icon-cloud-upload"></span></span> File
  """
