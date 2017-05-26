Formbuilder.registerField 'autodate',
  icon: 'icon-calendar'
  repeatable: true
  valueField: false
  view: """
        <% if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)==="date"){ %>
          <input disabled value="YYYY-MM-DD">
          <span class='icon icon-calendar'></span>
        <% } else if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)==="time"){ %>
          <input disabled value="HH:MM">
          <span class='icon icon-time'></span>
        <% }else{ %>
          <input disabled value="<%= rf.get(Formbuilder.options.mappings.DATETIME_FORMAT) || 'YYYY-MM-DD HH:mm:ss' %>">
          <span class='icon icon-calendar'></span><span class='icon icon-time'></span>

        <% } %>
        """
  edit: """
        <div class='fb-edit-section-header' data-rv-translate>Date Stamp Options</div>
        <div class="inline-labels">
          <label data-rv-translate>Field type:</label>
          <select class="datetype" data-rv-value="model.<%= Formbuilder.options.mappings.DATETIME_UNIT %>">
            <option value="datetime" data-rv-translate>Date &amp; Time</option>
            <option value="time" data-rv-translate>Time Only</option>
            <option value="date" data-rv-translate>Date Only</option>
          </select>
	  <div class="dateformat">
          <label data-rv-translate>Format:</label>
          <input type="text" data-rv-value="model.<%= Formbuilder.options.mappings.DATETIME_FORMAT %>"/>
	  <div>
        </div>
        """

  addButton: """
             <span class='symbol'><span class='icon-calendar'></span></span> <span data-rv-translate>Datestamp</span>
             """

  defaultAttributes: (attrs) ->
    attrs[Formbuilder.options.mappings.DATETIME_UNIT] = 'datetime'
    attrs[Formbuilder.options.mappings.DATETIME_FORMAT] = 'YYYY-MM-DD HH:mm:ss'
    attrs
