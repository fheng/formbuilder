Formbuilder.registerField 'autodate',
  repeatable: true
  valueField: false
  view: """
        <h1><span class='icon-calendar'></span></h1>
        Automatic
        <% if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)==="date"){ %>
        Date
        <% } else if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)==="time"){ %>
        Time
        <% }else{ %>
        Date &amp; Time
        <% } %> stamp
        """
  edit: """
        <div class='fb-edit-section-header'>Time Stamp Options</div>
        <select data-rv-value="model.<%= Formbuilder.options.mappings.DATETIME_UNIT %>" style="width: auto;">
        <option value="time">Time Only</option>
        <option value="date">Date Only</option>
        <option value="datetime">Date &amp; Time</option
        </select>
        """

  addButton: """
             <span class='symbol'><span class='icon-calendar'></span></span> Datestamp
             """

  defaultAttributes: (attrs) ->
    attrs[Formbuilder.options.mappings.DATETIME_UNIT] = 'datetime'
    attrs
