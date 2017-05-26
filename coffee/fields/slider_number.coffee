Formbuilder.registerField 'sliderNumber',
  repeatable: true
  icon : 'icon-number'
  iconText : '123'
  view: """
        <h1 style="border: 1px solid #bbb; padding: 10px; border-radius: 6px;"><span class='icon-exchange'></span></h1>
        """

  edit: """
        <%= Formbuilder.templates['edit/min_max_step']() %>
        """

  addButton: """
             <span class="symbol"><span class="icon-number">123</span></span> <span data-rv-translate>Slider (Number)</span>
             """
  defaultAttributes: (attrs) ->
    attrs = new Backbone.Model(attrs)
    attrs.set(Formbuilder.options.mappings.MIN, 1);
    attrs.set(Formbuilder.options.mappings.MAX, 10);
    attrs.set(Formbuilder.options.mappings.STEP_SIZE, 1);
    attrs.toJSON()