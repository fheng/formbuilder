Formbuilder.registerField 'email',
  repeatable : true
  icon : 'icon-envelope-alt'
  view: """
    <input type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' placeholder="email@example.com" class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' />
  """

  edit: ""

  addButton: """
    <span class="symbol"><span class="icon-envelope-alt"></span></span> <span data-rv-translate>Email</span>
  """
