Formbuilder.registerField 'signature',
  repeatable: true
  valueField: false
  icon: 'icon-pencil'
  view: """
    <h1 style="border: 1px solid #bbb; padding: 10px; border-radius: 6px;"><span class='icon-pencil'></span></h1>
  """
  edit: """"""

  addButton: """
    <span class='symbol'><span class='icon-pencil'></span></span> <span dataa-rv-translate>Signature Capture</span>
  """

  defaultAttributes: (attrs) ->
    attrs
