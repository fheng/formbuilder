Formbuilder.registerField 'radio',
  repeatable: true
  valueField: false
  view: """
    <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
      <div>
        <label class='fb-option'>
          <input type='radio' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick="javascript: return false;" />
          <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>
        </label>
      </div>
    <% } %>

    <% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>
      <div class='other-option'>
        <label class='fb-option'>
          <input type='radio' />
          Other
        </label>

        <input type='text' />
      </div>
    <% } %>
  """

  edit: """
    <%= Formbuilder.templates['edit/options']({ includeOther: true }) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-circle-blank"></span></span> Radio Buttons
  """

  defaultAttributes: (attrs) ->
    # @todo
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'radio');
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "",
      checked: false
    ,
      label: "",
      checked: false
    ])
    attrs.toJSON()