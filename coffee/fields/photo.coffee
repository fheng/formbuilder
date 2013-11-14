Formbuilder.registerField 'photo',
  repeatable: true
  valueField: false
  view: """
    <h1 style="border: 1px solid #bbb; padding: 10px; border-radius: 6px;"><span class='icon-camera'></span></h1>
  """
  edit: """"""

  addButton: """
    <span class='symbol'><span class='icon-camera'></span></span> Photo Capture
  """

  defaultAttributes: (attrs) ->
    attrs
