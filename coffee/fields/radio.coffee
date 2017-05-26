Formbuilder.registerField 'radio',
  icon: 'icon-circle-blank'
  repeatable: true
  valueField: false
  view: """
    <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
      <div>
        <label class='fb-option'>
          <input type='radio' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick="javascript: return false;" />
          <%= _.escape(rf.get(Formbuilder.options.mappings.OPTIONS)[i].label) %>
        </label>
      </div>
    <% } %>

    <% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>
      <div class='other-option'>
        <label class='fb-option'>
          <input type='radio' />
          <span data-rv-translate>Other</span>
        </label>

        <input type='text' />
      </div>
    <% } %>
  """

  edit: """
    <%= Formbuilder.templates['edit/options']({includeDatasource: true, rf: rf}) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-circle-blank"></span></span> <span data-rv-translate>Radio Buttons</span>
  """

  defaultAttributes: (attrs) ->
    # @todo
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'radio');
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "Option 1",
      checked: false
    ,
      label: "Option 2",
      checked: false
    ])
    attrs.toJSON()
