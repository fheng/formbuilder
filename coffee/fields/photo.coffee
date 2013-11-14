Formbuilder.registerField 'photo',
  repeatable: true
  valueField: false
  view: """
    <h1><span class='icon-camera'></span></h1>
  """
  edit: """"""

  addButton: """
    <span class='symbol'><span class='icon-camera'></span></span> Photo Capture
  """

  defaultAttributes: (attrs) ->
    attrs
