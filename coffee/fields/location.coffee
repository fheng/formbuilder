Formbuilder.registerField 'location',
  repeatable: true
  valueField: false
  icon : 'icon-location-arrow'
  view: """
    <% if (rf.get(Formbuilder.options.mappings.LOCATION_UNIT)==="latlong"){ %>
    <span data-rv-translate>Latitude/Longitude</span>
    <% } else { %>
    <span data-rv-translate>Eastings/Northings</span>
    <% } %>
    <br />
    <input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
    <input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />
  """
  edit: """
        <div class='fb-edit-section-header' data-rv-translate>Location Unit</div>
        <select data-rv-value="model.<%= Formbuilder.options.mappings.LOCATION_UNIT %>" style="width: auto;">
          <option value="latlong" data-rv-translate>Latitude / Longitude</option>
          <option value="eastnorth" data-rv-translate>Eastings / Northings</option>
        </select>
  """

  addButton: """
    <span class='symbol'><span class='icon-location-arrow'></span></span> <span data-rv-translate>Location</span>
  """

  defaultAttributes: (attrs) ->
    attrs[Formbuilder.options.mappings.LOCATION_UNIT] = 'latlong';
    attrs
