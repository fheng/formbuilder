class Formbuilder
  @helpers:
    defaultFieldAttrs: (field_type) ->
      if Formbuilder.options.mappings.TYPE_ALIASES && Formbuilder.options.mappings.TYPE_ALIASES[field_type]
        field_type = Formbuilder.options.mappings.TYPE_ALIASES[field_type]

      attrs = {}
      attrs[Formbuilder.options.mappings.FIELD_OPTIONS] = {}
      attrs[Formbuilder.options.mappings.REQUIRED] = true
      attrs[Formbuilder.options.mappings.REPEATING] = false
      attrs[Formbuilder.options.mappings.FIELD_TYPE] = field_type
      attrs[Formbuilder.options.mappings.LABEL] = "Untitled"
      attrs[Formbuilder.options.mappings.VALIDATE_IMMEDIATELY] = true
      Formbuilder.fields[field_type].defaultAttributes?(attrs) || attrs

    simple_format: (x) ->
      x?.replace(/\n/g, '<br />')

  @options:
    BUTTON_CLASS: 'fb-button'
    HTTP_ENDPOINT: ''
    HTTP_METHOD: 'POST'

    mappings:
      SIZE: 'field_options.size'
      UNITS: 'field_options.units'
      LABEL: 'label'
      VALUE: 'value'
      HASH: 'hash'
      FIELD_TYPE: 'field_type'
      REQUIRED: 'required'
      REPEATING: 'repeating'
      VALIDATE_IMMEDIATELY: 'validate_immediately'
      ADMIN_ONLY: 'admin_only'
      FIELD_OPTIONS : 'field_options'
      OPTIONS: 'field_options.options'
      DESCRIPTION: 'field_options.description'
      DESCRIPTION_PLACEHOLDER: 'Add a longer description to this field'
      DESCRIPTION_TITLE: 'Description'
      INCLUDE_OTHER: 'field_options.include_other_option'
      INCLUDE_BLANK: 'field_options.include_blank_option'
      INTEGER_ONLY: 'field_options.integer_only'
      LOCATION_UNIT: 'field_options.location_unit'
      DATETIME_UNIT: 'field_options.datetime_unit'
      MIN: 'field_options.min'
      MAX: 'field_options.max'
      MINLENGTH: 'field_options.minlength'
      MAXLENGTH: 'field_options.maxlength'
      MINREPITIONS: 'field_options.minRepeat'
      MAXREPITIONS: 'field_options.maxRepeat'
      LENGTH_UNITS: 'field_options.min_max_length_units'
      FILE_SIZE : 'field_options.file_size'
      FIELD_FORMAT_MODE : 'field_options.field_format_mode'
      FIELD_FORMAT_STRING : 'field_options.field_format_string'
      PHOTO_HEIGHT: 'field_options.photo_height'
      PHOTO_WIDTH: 'field_options.photo_width'
      PHOTO_QUALITY: 'field_options.photo_quality'
      SINGLE_CHECKED: 'field_options.checked'
      TIME_AUTOPOPULATE: 'field_options.time_autopopulate'
      VALUE_HEADER : 'Value'
      TYPE_ALIASES: false
      FIELD_ERROR : 'field_error'
    unAliasType: (type) ->
      if Formbuilder.options.mappings.TYPE_ALIASES
        $idx = _.values(Formbuilder.options.mappings.TYPE_ALIASES).indexOf(type)
        if $idx>-1
          type = _.keys(Formbuilder.options.mappings.TYPE_ALIASES)[$idx]
      type
    dict:
      ALL_CHANGES_SAVED: 'All changes saved'
      SAVE_FORM: 'Save form'
      UNSAVED_CHANGES: 'You have unsaved changes. If you leave this page, you will lose those changes!'

  @fields: {}
  @inputFields: {}
  @nonInputFields: {}

  @model: Backbone.DeepModel.extend
    sync: -> # noop
    indexInDOM: ->
      $wrapper = $(".fb-field-wrapper").filter ( (_, el) => $(el).data('cid') == @cid  )
      $(".fb-field-wrapper").index $wrapper
    is_input: ->
      $type = @get(Formbuilder.options.mappings.FIELD_TYPE)
      $type = Formbuilder.options.unAliasType($type)
      Formbuilder.inputFields[$type]?

  @collection: Backbone.Collection.extend
    initialize: ->
      @on 'add', @copyCidToModel

    model: Formbuilder.model

    comparator: (model) ->
      model.indexInDOM()

    copyCidToModel: (model) ->
      model.attributes.cid = model.cid

  @registerField: (name, opts) ->
    for x in ['view', 'edit']
      opts[x] = _.template(opts[x])

    Formbuilder.fields[name] = opts

    if opts.type == 'non_input'
      Formbuilder.nonInputFields[name] = opts
    else
      Formbuilder.inputFields[name] = opts

  @views:
    view_field: Backbone.View.extend
      className: "fb-field-wrapper"

      events:
        'click .subtemplate-wrapper': 'focusEditView'
        'click .js-duplicate': 'duplicate'
        'click .js-clear': 'clear'
        'keyup input' : 'forceEditRender'
        'keyup textarea' : 'forceEditRender'
        'change input[type=file]' : 'forceEditRender'


      initialize: ->
        @parentView = @options.parentView
        @listenTo @model, "change", @render
        @listenTo @model, "destroy", @remove

      render: ->
        # If this is from the .trigger event of a model, avoid it
        # allows us to update form field values on the LHS also
        if @.editing
          delete @.editing
          return

        editStructure = if @parentView.options.hasOwnProperty('editStructure') then @parentView.options.editStructure else true

        $type = @model.get(Formbuilder.options.mappings.FIELD_TYPE)
        if Formbuilder.options.mappings.TYPE_ALISES
          $type = Formbuilder.options.mappings.TYPE_ALISES[$type]
        @$el.addClass('response-field-'+$type)
            .data('cid', @model.cid)
            .html(Formbuilder.templates["view/base#{if !@model.is_input() then '_non_input' else ''}"]({ editStructure : editStructure, rf: @model}))

        return @

      focusEditView: (e) ->
        @parentView.createAndShowEditView(@model)

      forceEditRender: (e) ->
        # Allow inputting text in the input field to update the model value, but dont allow
        # this section to re-render, as it kills our focus
        val = e.target.value
        @.editing = true
        @.model.set(Formbuilder.options.mappings.VALUE, val)
        return
      clear: ->
        @parentView.handleFormUpdate()
        @model.destroy()

      duplicate: ->
        attrs = _.clone(@model.attributes)
        delete attrs['id']
        attrs[Formbuilder.options.mappings.LABEL] += ' Copy'
        @parentView.createField attrs, { position: @model.indexInDOM() + 1 }
    edit_field: Backbone.View.extend
      className: "edit-response-field"

      events:
        'click .js-add-option': 'addOption'
        'click .js-remove-option': 'removeOption'
        'click .js-default-updated': 'defaultUpdated'
        'input .option-label-input': 'forceRender'
        'change .fb-repeating input[type=checkbox]' : 'toggleRepititionsInputs'
        'change .fieldFormatMode' : 'changeFieldFormatHelpText'
        'change .fb-required input[type=checkbox]' : 'requiredChanged'

      initialize: ->
        @listenTo @model, "destroy", @remove
        @parentView = @options.parentView

      render: ->
        commonCheckboxes = if @parentView.options.hasOwnProperty('commonCheckboxes') then @parentView.options.commonCheckboxes else true
        $repeatable = false
        $type = @model.get(Formbuilder.options.mappings.FIELD_TYPE)
        $type = Formbuilder.options.unAliasType($type)

        if Formbuilder.inputFields[$type] && Formbuilder.inputFields[$type].repeatable && Formbuilder.inputFields[$type].repeatable == true
          $repeatable = true

        @$el.html(Formbuilder.templates["edit/base#{if !@model.is_input() then '_non_input' else ''}"]({rf: @model, editStructure : @parentView.options.editStructure, commonCheckboxes : commonCheckboxes, repeatable : $repeatable, repeating: @model.get(Formbuilder.options.mappings.REPEATING) }))
        rivets.bind @$el, { model: @model }
        return @

      remove: ->
        @options.parentView.editView = undefined
        @options.parentView.$el.find("[href=\"#addField\"]").click()
        Backbone.View.prototype.remove.call(@)

      # @todo this should really be on the model, not the view
      addOption: (e) ->
        $el = $(e.currentTarget)
        i = @$el.find('.option').index($el.closest('.option'))
        options = @model.get(Formbuilder.options.mappings.OPTIONS) || []
        newOption = {checked: false}
        newOption[Formbuilder.options.mappings.LABEL] = ""

        if i > -1
          options.splice(i + 1, 0, newOption)
        else
          options.push newOption

        @model.set Formbuilder.options.mappings.OPTIONS, options
        @model.trigger "change:#{Formbuilder.options.mappings.OPTIONS}"
        @forceRender()

      removeOption: (e) ->
        $el = $(e.currentTarget)
        index = @$el.find(".js-remove-option").index($el)
        options = @model.get Formbuilder.options.mappings.OPTIONS
        options.splice index, 1
        @model.set Formbuilder.options.mappings.OPTIONS, options
        @model.trigger "change:#{Formbuilder.options.mappings.OPTIONS}"
        @forceRender()

      defaultUpdated: (e) ->
        $el = $(e.currentTarget)
        $checkboxType = 'checkboxes'
        if Formbuilder.options.mappings.TYPE_ALIASES && Formbuilder.options.mappings.TYPE_ALIASES['checkboxes']
          $checkboxType = Formbuilder.options.mappings.TYPE_ALIASES['checkboxes']
        unless @model.get(Formbuilder.options.mappings.FIELD_TYPE) == $checkboxType # checkboxes can have multiple options selected
          @$el.find(".js-default-updated").not($el).attr('checked', false).trigger('change')

        @forceRender()

      forceRender: ->
        @model.trigger('change', @model)
      toggleRepititionsInputs: (e) ->
        $el = $(e.target)
        if $el.prop('checked')==true
          @$el.find('.fb-repititions input').prop('disabled', false)
          $min = @$el.find('.fb-repititions input.minReps')
          $max = @$el.find('.fb-repititions input.maxReps')
          if ($min.val()=="")
            @model.set(Formbuilder.options.mappings.MINREPITIONS, 1)
          if ($max.val()=="")
            @model.set(Formbuilder.options.mappings.MAXREPITIONS, 5)
          # Repeating fields must be required
          @model.set(Formbuilder.options.mappings.REQUIRED, true)
        else
          @$el.find('.fb-repititions input').prop('disabled', true)
      changeFieldFormatHelpText: (e) ->
        $value = $(e.target).val();
        if ($value == "regex")
          @$el.find('.simpleFormat').hide()
          @$el.find('.advancedFormat').show();
        else
          @$el.find('.simpleFormat').show();
          @$el.find('.advancedFormat').hide();
      requiredChanged: (e) ->
        $el = $(e.target)
        $checkboxType = 'checkboxes'
        if Formbuilder.options.mappings.TYPE_ALIASES && Formbuilder.options.mappings.TYPE_ALIASES[$checkboxType]
          $checkboxType = Formbuilder.options.mappings.TYPE_ALIASES['checkboxes']
        if (@model.get(Formbuilder.options.mappings.FIELD_TYPE) == $checkboxType)
          @render()
          if $el.prop('checked')==false
            @model.unset(Formbuilder.options.mappings.MIN)
            @model.unset(Formbuilder.options.mappings.MAX)
    main: Backbone.View.extend
      SUBVIEWS: []

      events:
        'click .js-save-form': 'saveForm'
        'click .fb-add-field-types a': 'addField'
        'blur input.minReps' : 'checkReps'
        'blur input.maxReps' : 'checkReps'

      initialize: ->
        if !@options.eventFix
          @events['click .fb-tabs a'] = 'showTab'

        @$el = $(@options.selector)
        @formBuilder = @options.formBuilder

        # Create the collection, and bind the appropriate events
        @collection = new Formbuilder.collection
        @collection.bind 'add', @addOne, @
        @collection.bind 'reset', @reset, @
        @collection.bind 'change', @handleFormUpdate, @
        @collection.bind 'destroy add reset', @hideShowNoResponseFields, @
        @collection.bind 'destroy', @ensureEditViewScrolled, @

        @render()
        @collection.reset(@options.bootstrapData)
        @initAutosave()

      initAutosave: ->
        @formSaved = true
        @saveFormButton = @$el.find(".js-save-form")
        @saveFormButton.attr('disabled', true).text(Formbuilder.options.dict.ALL_CHANGES_SAVED)

        setInterval =>
          @saveForm.call(@)
        , 5000

        $(window).bind 'beforeunload', =>
          if @formSaved then undefined else Formbuilder.options.dict.UNSAVED_CHANGES

      reset: ->
        @$responseFields.html('')
        @addAll()

      render: ->
        @options.editStructure = if @options.hasOwnProperty('editStructure') then @options.editStructure else true
        @options.addAt = if @options.hasOwnProperty('addAt') then @options.addAt else 'last';

        if Formbuilder.options.mappings.TYPE_ALIASES
          for orig,alias of Formbuilder.options.mappings.TYPE_ALIASES
            Formbuilder.fields[alias] = Formbuilder.fields[orig]

        $fields = {};
        $fieldsNonInput = {};

        if @options.hasOwnProperty('fields')
          for fieldName in @options.fields
            field = Formbuilder.inputFields[fieldName] || Formbuilder.nonInputFields[fieldName];
            if !field
              throw new Error("No field found with name" + fieldName)

            if field.type == "non_input" then $fieldsNonInput[fieldName] = field else $fields[fieldName] = field
        else
          $fields = Formbuilder.inputFields;
          $fieldsNonInput = Formbuilder.nonInputFields;


        @$el.html Formbuilder.templates['page']({ editStructure : @options.editStructure, fieldsEnabled : $fields, fieldsEnabledNonInput : $fieldsNonInput })

        # Save jQuery objects for easy use
        @$fbLeft = @$el.find('.fb-left') || @$el.find('.span6.middle')
        @$fbRight = @$el.find('.fb-right') || @$el.find('.span4.right')
        @$responseFields = @$el.find('.fb-response-fields')

        @bindWindowScrollEvent()
        @hideShowNoResponseFields()

        # Render any subviews (this is an easy way of extending the Formbuilder)
        new subview({parentView: @}).render() for subview in @SUBVIEWS

        if @options.eventFix
          @.$el.find('.fb-tabs a').unbind().click(@.showTab)

        return @

      bindWindowScrollEvent: ->
        $(window).on 'scroll', =>
          return if @$fbLeft.data('locked') == true
          newMargin = Math.max(0, $(window).scrollTop())
          maxMargin = @$responseFields.height()

          @$fbLeft.css
            'margin-top': Math.min(maxMargin, newMargin)

      showTab: (e) ->
        $el = $(e.currentTarget)
        target = $el.data('target')
        $el.closest('li').addClass('active').siblings('li').removeClass('active')
        this.$el.find(target).addClass('active').siblings('.fb-tab-pane').removeClass('active')

        @unlockLeftWrapper() unless target == '#editField'

        if target == '#editField' && !@editView && (first_model = @collection.models[0])
          @createAndShowEditView(first_model)

      addOne: (responseField, _, options) ->
        view = new Formbuilder.views.view_field
          model: responseField
          parentView: @

        #####
        # Calculates where to place this new field.
        #
        # Are we replacing a temporarily drag placeholder?
        if options.$replaceEl?
          options.$replaceEl.replaceWith(view.render().el)

        # Are we adding to the bottom?
        else if !options.position? || options.position == -1
          @$responseFields.append view.render().el

        # Are we adding to the top?
        else if options.position == 0
          @$responseFields.prepend view.render().el

        # Are we adding below an existing field?
        else if ($replacePosition = @$responseFields.find(".fb-field-wrapper").eq(options.position))[0]
          $replacePosition.before view.render().el

        # Catch-all: add to bottom
        else
          @$responseFields.append view.render().el

      setSortable: ->
        @$responseFields.sortable('destroy') if @$responseFields.hasClass('ui-sortable')
        @$responseFields.sortable
          forcePlaceholderSize: true
          placeholder: 'sortable-placeholder'
          cancel: '.fb-field-wrapper.response-field-page_break'
          stop: (e, ui) =>
            if ui.item.data('field-type')
              rf = @collection.create Formbuilder.helpers.defaultFieldAttrs(ui.item.data('field-type')), {$replaceEl: ui.item}
              @createAndShowEditView(rf)
            if ui.item.is('div:first-of-type')
              # Dragged below the first page break - can't drag stuff to be first. prevent.
              @$responseFields.sortable('cancel')
            @handleFormUpdate()
            @trigger('reorder');
            return true
          update: (e, ui) =>
            # ensureEditViewScrolled, unless we're updating from the draggable
            @ensureEditViewScrolled() unless ui.item.data('field-type')

        @setDraggable()

      setDraggable: ->
        $addFieldButtons = @$el.find("[data-field-type]")

        $addFieldButtons.draggable
          connectToSortable: @$responseFields
          start: =>
            @$responseFields.sortable("refresh")
          helper: =>
            $helper = $("<div class='response-field-draggable-helper' />")
            $helper.css
              width: @$responseFields.width() # hacky, won't get set without inline style
              height: '80px'

            $helper

      addAll: ->
        @collection.each @addOne, @
        @setSortable() unless (@options.editStructure == false)

      hideShowNoResponseFields: ->
        @$el.find(".fb-no-response-fields")[if @collection.length > 0 then 'hide' else 'show']()

      addField: (e) ->
        field_type = $(e.currentTarget).data('field-type')
        @createField Formbuilder.helpers.defaultFieldAttrs(field_type)

      createField: (attrs, options) ->
        options = options || {}
        options.at = if @options.addAt=="last" then @collection.length else 0
        rf = @collection.create attrs, options
        @createAndShowEditView(rf)
        @handleFormUpdate()

      createAndShowEditView: (model) ->
        $responseFieldEl = @$el.find(".fb-field-wrapper").filter( -> $(@).data('cid') == model.cid )
        $responseFieldEl.addClass('editing').siblings('.fb-field-wrapper').removeClass('editing')

        if @editView
          if @editView.model.cid is model.cid
            @$el.find(".fb-tabs a[data-target=\"#editField\"]").click()
            @scrollLeftWrapper $responseFieldEl, (oldPadding? && oldPadding)
            return

          oldPadding = @$fbLeft.css('padding-top')
          @editView.remove()

        @editView = new Formbuilder.views.edit_field
          model: model
          parentView: @

        $newEditEl = @editView.render().$el
        @$el.find(".fb-edit-field-wrapper").html $newEditEl
        @$el.find(".fb-tabs a[data-target=\"#editField\"]").click() unless @options.noEditOnDrop
        @scrollLeftWrapper($responseFieldEl)
        return @

      checkReps : (e) ->
        $target = $(e.target);
        $active = if $target.hasClass('maxReps')==true then 'max' else 'min'
        $parent = $target.parent();
        $maxRep = $target.parent().find('input.maxReps');
        $minRep = $target.parent().find('input.minReps');
        $minVal = Number($minRep.val());
        $maxVal = Number($maxRep.val());

        if ($active == 'min')
          if $minVal and $minVal < 0 or $minVal > $maxVal
            $minRep.addClass('error');
          else
            $minRep.removeClass('error');
          $minRep.val(parseInt($minVal)); # ensure numeric type, not string
        else
          if $maxVal and $maxVal < 0 or $minVal > $maxVal
            $maxRep.addClass('error');
          else
            $maxRep.removeClass('error');
          $maxRep.val(parseInt($maxVal)); # ensure numeric type, not string

      ensureEditViewScrolled: ->
        return unless @editView
        @scrollLeftWrapper $(".fb-field-wrapper.editing")

      scrollLeftWrapper: ($responseFieldEl) ->
        return if @options.noScroll
        @unlockLeftWrapper()
        $.scrollWindowTo ($responseFieldEl.offset().top - @$responseFields.offset().top), 200, =>
          @lockLeftWrapper()

      lockLeftWrapper: ->
        @$fbLeft.data('locked', true)

      unlockLeftWrapper: ->
        @$fbLeft.data('locked', false)

      handleFormUpdate: ->
        return if @updatingBatch
        @formSaved = false
        @saveFormButton.removeAttr('disabled').text(Formbuilder.options.dict.SAVE_FORM)

      saveForm: (e) ->
        return if @formSaved
        @formSaved = true
        @saveFormButton.attr('disabled', true).text(Formbuilder.options.dict.ALL_CHANGES_SAVED)
        @collection.sort()
        payload = JSON.stringify fields: @collection.toJSON()

        if Formbuilder.options.HTTP_ENDPOINT then @doAjaxSave(payload)
        @formBuilder.trigger 'save', payload

      doAjaxSave: (payload) ->
        $.ajax
          url: Formbuilder.options.HTTP_ENDPOINT
          type: Formbuilder.options.HTTP_METHOD
          data: payload
          contentType: "application/json"
          success: (data) =>
            @updatingBatch = true

            for datum in data
              # set the IDs of new response fields, returned from the server
              @collection.get(datum.cid)?.set({id: datum.id})
              @collection.trigger 'sync'

            @updatingBatch = undefined

  constructor: (selector, opts = {}) ->
    _.extend @, Backbone.Events
    @mainView = new Formbuilder.views.main _.extend({ selector: selector }, opts, { formBuilder: @ })
    @collection = @mainView.collection

window.Formbuilder = Formbuilder

if module?
  module.exports = Formbuilder
else
  window.Formbuilder = Formbuilder
