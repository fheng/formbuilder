Formbuilder.registerField 'checkbox',
  repeatable: true
  icon : 'icon-check'
  valueField: false
  view: """
        <input type='checkbox' <%= rf.get(Formbuilder.options.mappings.SINGLE_CHECKED) && 'checked' %> onclick="javascript: return false;" />
        """

  edit: """
        <div class='fb-edit-section-header' data-rv-translate>Checked</div>
        <input type='checkbox' <%= rf.get(Formbuilder.options.mappings.SINGLE_CHECKED) && 'checked' %> data-rv-checked='model.<%= Formbuilder.options.mappings.SINGLE_CHECKED%>' />
        """

  addButton: """
             <span class="symbol"><span class="icon-check"></span></span> <span data-rv-translate>Checkbox</span>
             """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.SINGLE_CHECKED, true);
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'checkbox');
    attrs.toJSON()
