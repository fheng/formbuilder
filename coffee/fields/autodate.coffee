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
          <input disabled value="YYYY-MM-DD HH:MM">
          <span class='icon icon-calendar'></span><span class='icon icon-time'></span>

        <% } %>
        """
  edit: """
        <div class='fb-edit-section-header'>Time Stamp Options</div>
        <div class="inline-labels">
          <label>Field type:</label>
          <select data-rv-value="model.<%= Formbuilder.options.mappings.DATETIME_UNIT %>" style="width: auto;">
            <option value="datetime">Date &amp; Time</option>
            <option value="time">Time Only</option>
            <option value="date">Date Only</option>
          </select>
          <label>Auto-populate:</label>
          <input type='checkbox' data-rv-checked='model.<%= Formbuilder.options.mappings.TIME_AUTOPOPULATE  %>' />
        </div>
        """

  addButton: """
             <span class='symbol'><span class='icon-calendar'></span></span> Datestamp
             """

  defaultAttributes: (attrs) ->
    attrs[Formbuilder.options.mappings.DATETIME_UNIT] = 'datetime'
    attrs
