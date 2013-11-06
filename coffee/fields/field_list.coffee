Formbuilder.registerField 'list',

  type: 'non_input'

  view: """
        <div class="btn-group pull-right">
        <a data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" class="btn btn-small btn-listfield-data" href="#"><i class="icon-pencil"></i> Edit Data</a>
        <a data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" class="btn btn-small btn-listfield-structure" href="#"><i class="icon-road"></i> Edit Structure</i></a>
        </div>
        <label class='section-name'><%= rf.get(Formbuilder.options.mappings.LABEL) %></label>
        <br />
        <br />
        <div class="fieldlist_table" data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>">
        <p class="instructions"><i class="icon-info-sign"></i>Empty list - to add contents: </p><br />
        &nbsp; &nbsp;  1) Use "Edit Structure" to add fields to the list <br />
        &nbsp;  &nbsp;  2) Use "Edit Data" to add rows
        </div>
        """

  edit: """
        <div class="btn-group">
        <a data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" class="btn btn-listfield-data" href="#"><i class="icon-pencil"></i> Edit Data</a>
        <a data-name="<%= rf.get(Formbuilder.options.mappings.LABEL) %>" class="btn btn-listfield-structure" href="#"><i class="icon-road"></i> Edit Structure</i></a>
        </div>

        <div class='fb-edit-section-header'>List Name</div>
        <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />

        """

  addButton: """
             <span class='symbol'><span class='icon-list'></span></span> Field List
             """
