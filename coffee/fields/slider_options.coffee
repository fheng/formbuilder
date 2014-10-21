Formbuilder.registerField 'sliderOptions',
  icon: 'icon-circle-blank'
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
        <%= Formbuilder.templates['edit/options']({}) %>
        """

  addButton: """
             <span class="symbol"><span class="icon-circle-blank"></span></span> Slider (Options)
             """

  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'sliderOptions');
    attrs.set(Formbuilder.options.mappings.OPTIONS, [
      label: "Option 1",
      checked: false
    ,
      label: "Option 2",
      checked: false
    ])
    attrs.toJSON()