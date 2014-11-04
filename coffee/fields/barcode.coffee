Formbuilder.registerField 'barcode',
  icon: 'icon-barcode'
  repeatable: true
  valueField: false
  view: """
        <label>Value: </label><input type='number' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  /><br/>
        <label>Format: </label><input type='number' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
        """

  edit: """

        """

  addButton: """
             <span class='symbol'><span class='icon-barcode'></span></span> Barcode
             """

  defaultAttributes: (attrs) ->
    attrs
