Formbuilder.registerField 'barcode',
  icon: 'icon-barcode'
  repeatable: true
  valueField: false
  view: """
        """

  edit: """

        """

  addButton: """
             <span class='symbol'><span class='icon-barcode'></span></span> Barcode
             """

  defaultAttributes: (attrs) ->
    attrs
