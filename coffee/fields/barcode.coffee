Formbuilder.registerField 'barcode',
  icon: 'icon-barcode'
  repeatable: true
  valueField: false
  view: """
        <label data-rv-translate>Value: </label><input type='number' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  /><br/>
        <label data-rv-translate>Format: </label><input type='number' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
        """

  edit: """

        """

  addButton: """
             <span class='symbol'><span class='icon-barcode'></span></span> <span data-rv-translate>Barcode</span>
             """

  defaultAttributes: (attrs) ->
    attrs
