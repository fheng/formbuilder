Formbuilder.registerField 'website',
  repeatable: true
  icon : 'icon-link'
  view: """
    <input type='text' class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' placeholder='http://' />
  """

  edit: """

  """

  addButton: """
    <span class="symbol"><span class="icon-link"></span></span> <span data-rv-translate>Website</span>
  """
