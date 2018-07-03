Formbuilder.registerField 'map',
  repeatable: true
  valueField: false
  icon : 'icon-map-marker'
  view: """
    <h1><span class='icon-map-marker'></span></h1>
  """
  edit: """"""

  addButton: """
    <span class='symbol'><span class='icon-map-marker'></span></span> <span data-rv-translate>Map</span>
  """

  defaultAttributes: (attrs) ->
    attrs
