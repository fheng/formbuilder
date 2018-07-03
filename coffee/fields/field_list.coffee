Formbuilder.registerField 'list',
  icon : 'icon-list'
  type: 'non_input'

  view: """
        <div class="btn-group pull-right">
        <a data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" class="btn btn-small btn-listfield-data" href="#"><i class="icon-pencil"></i> <span data-rv-translate>Edit Data</span></a>
        <a data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" class="btn btn-small btn-listfield-structure" href="#"><i class="icon-road"></i> <span data-rv-translate>Edit Structure</span></i></a>
        </div>
        <label class='section-name'><%= rf.escape(Formbuilder.options.mappings.LABEL) %></label>
        <br />
        <br />
        <div class="fieldlist_table" data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>">
        <p class="instructions"><i class="icon-info-sign"></i><span data-rv-translate>Empty list - to add contents:</span> </p><br />
        &nbsp; &nbsp;  <span data-rv-translate>1) Use "Edit Structure" to add fields to the list</span> <br />
        &nbsp;  &nbsp;  <span data-rv-translate>2) Use "Edit Data" to add rows</span>
        </div>
        """

  edit: """
        <div class="btn-group">
        <a data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" class="btn btn-listfield-data" href="#"><i class="icon-pencil"></i> <span data-rv-translate>Edit Data</span></a>
        <a data-name="<%= rf.escape(Formbuilder.options.mappings.LABEL) %>" class="btn btn-listfield-structure" href="#"><i class="icon-road"></i> <span data-rv-translate>Edit Structure</span></i></a>
        </div>

        <div class='fb-edit-section-header' data-rv-translate>List Name</div>
        <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />

        """

  addButton: """
             <span class='symbol'><span class='icon-list'></span></span> <span data-rv-translate>Field List</span>
             """
