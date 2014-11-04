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
             <span class="symbol"><span class="icon-number">123</span></span> Slider (Number)
             """
