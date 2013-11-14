Formbuilder.registerField 'location',
  repeatable: true
  valueField: false
  icon : 'icon-location-arrow'
  view: """
    <% if (rf.get(Formbuilder.options.mappings.LOCATION_UNIT)==="latlong"){ %>
    Latitude/Longitude
    <% } else { %>
    Eastings/Northings
    <% } %>
    <br />
    <input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
    <input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
  """
  edit: """
        <div class='fb-edit-section-header'>Location Unit</div>
        <select data-rv-value="model.<%= Formbuilder.options.mappings.LOCATION_UNIT %>" style="width: auto;">
          <option value="latlong">Latitude / Longitude</option>
          <option value="eastnorth">Eastings / Northings</option>
        </select>
  """

  addButton: """
    <span class='symbol'><span class='icon-location-arrow'></span></span> Location
  """

  defaultAttributes: (attrs) ->
    attrs[Formbuilder.options.mappings.LOCATION_UNIT] = 'latlong';
    attrs
