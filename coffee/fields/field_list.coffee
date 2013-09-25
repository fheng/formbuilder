Formbuilder.registerField 'field_list',

  type: 'non_input'

  view: """
        <div class="btn-group pull-right">
        <a class="btn btn-small btn-listfield-data" href="#"><i class="icon-road"></i> Edit Data</a>
        <a class="btn btn-small btn-listfield-structure" href="#"><i class="icon-pencil"></i> Edit Structure</i></a>
        </div>
        <label class='section-name'><%= rf.get(Formbuilder.options.mappings.LABEL) %></label>
        <br />
        <br />
        <table>
        <thead>
        <tr>

        </tr>
        </thead>
        <tbody>
        <tr>
        <td>
        Loading...
        </td>
        </tr>
        </tbody>
        </table>
        """

  edit: """
        <div class="btn-group">
        <a class="btn btn-listfield-data" href="#"><i class="icon-road"></i> Edit Data</a>
        <a class="btn btn-listfield-structure" href="#"><i class="icon-pencil"></i> Edit Structure</i></a>
        </div>

        <div class='fb-edit-section-header'>List Name</div>
        <input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />

        """

  addButton: """
             <span class='symbol'><span class='icon-list'></span></span> Field List
             """
