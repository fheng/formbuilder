Formbuilder.registerField 'readOnly',
  repeatable: false
  type: 'non_input'
  icon : 'icon-comment'
  view: """
  <label class='section-name'>&nbsp; <%= rf.escape(Formbuilder.options.mappings.LABEL) %></label>
    <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>
      <div>
        <label class='fb-option'>
          <%= _.escape(rf.get(Formbuilder.options.mappings.OPTIONS)[i].label) %>
        </label>
      </div>
      <br/>
    <% } %>

    <% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>
      <div class='other-option'>
        <input type='text' />
      </div>
    <% } %>
  """

  edit: """
  <div class='fb-edit-section-header' data-rv-translate>Label</div>
  <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />
    <%= Formbuilder.templates['edit/readonly']({includeDatasource: true, rf: rf}) %>
  """

  addButton: """
    <span class="symbol"><span class="icon-comment"></span></span> <span data-rv-translate>Read Only</span>
  """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'readOnly');
    attrs.set(Formbuilder.options.mappings.REQUIRED, false);
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: Formbuilder._("Read Only Text Paragraph")
    ])
    attrs.toJSON()
