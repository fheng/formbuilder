(function() {
  rivets.binders.input = {
    publishes: true,
    routine: rivets.binders.value.routine,
    bind: function(el) {
      return el.addEventListener('input', this.publish);
    },
    unbind: function(el) {
      return el.removeEventListener('input', this.publish);
    }
  };

  rivets.configure({
    prefix: "rv",
    adapter: {
      subscribe: function(obj, keypath, callback) {
        callback.wrapped = function(m, v) {
          return callback(v);
        };
        return obj.on('change:' + keypath, callback.wrapped);
      },
      unsubscribe: function(obj, keypath, callback) {
        return obj.off('change:' + keypath, callback.wrapped);
      },
      read: function(obj, keypath) {
        if (keypath === "cid") {
          return obj.cid;
        }
        return obj.get(keypath);
      },
      publish: function(obj, keypath, value) {
        if (obj.cid) {
          return obj.set(keypath, value);
        } else {
          return obj[keypath] = value;
        }
      }
    }
  });

}).call(this);

(function() {
  var Formbuilder;

  Formbuilder = (function() {
    Formbuilder.helpers = {
      defaultFieldAttrs: function(field_type) {
        var attrs, _base;
        if (Formbuilder.options.mappings.TYPE_ALIASES && Formbuilder.options.mappings.TYPE_ALIASES[field_type]) {
          field_type = Formbuilder.options.mappings.TYPE_ALIASES[field_type];
        }
        attrs = {};
        attrs[Formbuilder.options.mappings.FIELD_OPTIONS] = {};
        attrs[Formbuilder.options.mappings.REQUIRED] = true;
        attrs[Formbuilder.options.mappings.REPEATING] = false;
        attrs[Formbuilder.options.mappings.FIELD_TYPE] = field_type;
        attrs[Formbuilder.options.mappings.LABEL] = "Untitled";
        return (typeof (_base = Formbuilder.fields[field_type]).defaultAttributes === "function" ? _base.defaultAttributes(attrs) : void 0) || attrs;
      },
      simple_format: function(x) {
        return x != null ? x.replace(/\n/g, '<br />') : void 0;
      }
    };

    Formbuilder.options = {
      BUTTON_CLASS: 'fb-button',
      HTTP_ENDPOINT: '',
      HTTP_METHOD: 'POST',
      mappings: {
        SIZE: 'field_options.size',
        UNITS: 'field_options.units',
        LABEL: 'label',
        VALUE: 'value',
        HASH: 'hash',
        FIELD_TYPE: 'field_type',
        REQUIRED: 'required',
        REPEATING: 'repeating',
        ADMIN_ONLY: 'admin_only',
        FIELD_OPTIONS: 'field_options',
        OPTIONS: 'field_options.options',
        DESCRIPTION: 'field_options.description',
        DESCRIPTION_PLACEHOLDER: 'Add a longer description to this field',
        DESCRIPTION_TITLE: 'Description',
        INCLUDE_OTHER: 'field_options.include_other_option',
        INCLUDE_BLANK: 'field_options.include_blank_option',
        INTEGER_ONLY: 'field_options.integer_only',
        LOCATION_UNIT: 'field_options.location_unit',
        DATETIME_UNIT: 'field_options.datetime_unit',
        MIN: 'field_options.min',
        MAX: 'field_options.max',
        MINLENGTH: 'field_options.minlength',
        MAXLENGTH: 'field_options.maxlength',
        MINREPITIONS: 'field_options.minRepeat',
        MAXREPITIONS: 'field_options.maxRepeat',
        LENGTH_UNITS: 'field_options.min_max_length_units',
        FILE_SIZE: 'field_options.file_size',
        PHOTO_HEIGHT: 'field_options.photo_height',
        PHOTO_WIDTH: 'field_options.photo_width',
        PHOTO_QUALITY: 'field_options.photo_quality',
        SINGLE_CHECKED: 'field_options.checked',
        TIME_AUTOPOPULATE: 'field_options.time_autopopulate',
        VALUE_HEADER: 'Value',
        TYPE_ALIASES: false
      },
      unAliasType: function(type) {
        var $idx;
        if (Formbuilder.options.mappings.TYPE_ALIASES) {
          $idx = _.values(Formbuilder.options.mappings.TYPE_ALIASES).indexOf(type);
          if ($idx > -1) {
            type = _.keys(Formbuilder.options.mappings.TYPE_ALIASES)[$idx];
          }
        }
        return type;
      },
      dict: {
        ALL_CHANGES_SAVED: 'All changes saved',
        SAVE_FORM: 'Save form',
        UNSAVED_CHANGES: 'You have unsaved changes. If you leave this page, you will lose those changes!'
      }
    };

    Formbuilder.fields = {};

    Formbuilder.inputFields = {};

    Formbuilder.nonInputFields = {};

    Formbuilder.model = Backbone.DeepModel.extend({
      sync: function() {},
      indexInDOM: function() {
        var $wrapper,
          _this = this;
        $wrapper = $(".fb-field-wrapper").filter((function(_, el) {
          return $(el).data('cid') === _this.cid;
        }));
        return $(".fb-field-wrapper").index($wrapper);
      },
      is_input: function() {
        var $type;
        $type = this.get(Formbuilder.options.mappings.FIELD_TYPE);
        $type = Formbuilder.options.unAliasType($type);
        return Formbuilder.inputFields[$type] != null;
      }
    });

    Formbuilder.collection = Backbone.Collection.extend({
      initialize: function() {
        return this.on('add', this.copyCidToModel);
      },
      model: Formbuilder.model,
      comparator: function(model) {
        return model.indexInDOM();
      },
      copyCidToModel: function(model) {
        return model.attributes.cid = model.cid;
      }
    });

    Formbuilder.registerField = function(name, opts) {
      var x, _i, _len, _ref;
      _ref = ['view', 'edit'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        opts[x] = _.template(opts[x]);
      }
      Formbuilder.fields[name] = opts;
      if (opts.type === 'non_input') {
        return Formbuilder.nonInputFields[name] = opts;
      } else {
        return Formbuilder.inputFields[name] = opts;
      }
    };

    Formbuilder.views = {
      view_field: Backbone.View.extend({
        className: "fb-field-wrapper",
        events: {
          'click .subtemplate-wrapper': 'focusEditView',
          'click .js-duplicate': 'duplicate',
          'click .js-clear': 'clear',
          'keyup input': 'forceEditRender',
          'keyup textarea': 'forceEditRender',
          'change input[type=file]': 'forceEditRender'
        },
        initialize: function() {
          this.parentView = this.options.parentView;
          this.listenTo(this.model, "change", this.render);
          return this.listenTo(this.model, "destroy", this.remove);
        },
        render: function() {
          var $type, editStructure;
          if (this.editing) {
            delete this.editing;
            return;
          }
          editStructure = this.parentView.options.hasOwnProperty('editStructure') ? this.parentView.options.editStructure : true;
          $type = this.model.get(Formbuilder.options.mappings.FIELD_TYPE);
          if (Formbuilder.options.mappings.TYPE_ALISES) {
            $type = Formbuilder.options.mappings.TYPE_ALISES[$type];
          }
          this.$el.addClass('response-field-' + $type).data('cid', this.model.cid).html(Formbuilder.templates["view/base" + (!this.model.is_input() ? '_non_input' : '')]({
            editStructure: editStructure,
            rf: this.model
          }));
          return this;
        },
        focusEditView: function(e) {
          return this.parentView.createAndShowEditView(this.model);
        },
        forceEditRender: function(e) {
          var val;
          val = e.target.value;
          this.editing = true;
          this.model.set(Formbuilder.options.mappings.VALUE, val);
        },
        clear: function() {
          this.parentView.handleFormUpdate();
          return this.model.destroy();
        },
        duplicate: function() {
          var attrs;
          attrs = _.clone(this.model.attributes);
          delete attrs['id'];
          attrs[Formbuilder.options.mappings.LABEL] += ' Copy';
          return this.parentView.createField(attrs, {
            position: this.model.indexInDOM() + 1
          });
        }
      }),
      edit_field: Backbone.View.extend({
        className: "edit-response-field",
        events: {
          'click .js-add-option': 'addOption',
          'click .js-remove-option': 'removeOption',
          'click .js-default-updated': 'defaultUpdated',
          'input .option-label-input': 'forceRender',
          'change .fb-repeating input[type=checkbox]': 'toggleRepititionsInputs'
        },
        initialize: function() {
          this.listenTo(this.model, "destroy", this.remove);
          return this.parentView = this.options.parentView;
        },
        render: function() {
          var $repeatable, $type, commonCheckboxes;
          commonCheckboxes = this.parentView.options.hasOwnProperty('commonCheckboxes') ? this.parentView.options.commonCheckboxes : true;
          $repeatable = false;
          $type = this.model.get(Formbuilder.options.mappings.FIELD_TYPE);
          $type = Formbuilder.options.unAliasType($type);
          if (Formbuilder.inputFields[$type] && Formbuilder.inputFields[$type].repeatable && Formbuilder.inputFields[$type].repeatable === true) {
            $repeatable = true;
          }
          this.$el.html(Formbuilder.templates["edit/base" + (!this.model.is_input() ? '_non_input' : '')]({
            rf: this.model,
            editStructure: this.parentView.options.editStructure,
            commonCheckboxes: commonCheckboxes,
            repeatable: $repeatable,
            repeating: this.model.get(Formbuilder.options.mappings.REPEATING)
          }));
          rivets.bind(this.$el, {
            model: this.model
          });
          return this;
        },
        remove: function() {
          this.options.parentView.editView = void 0;
          this.options.parentView.$el.find("[href=\"#addField\"]").click();
          return Backbone.View.prototype.remove.call(this);
        },
        addOption: function(e) {
          var $el, i, newOption, options;
          $el = $(e.currentTarget);
          i = this.$el.find('.option').index($el.closest('.option'));
          options = this.model.get(Formbuilder.options.mappings.OPTIONS) || [];
          newOption = {
            checked: false
          };
          newOption[Formbuilder.options.mappings.LABEL] = "";
          if (i > -1) {
            options.splice(i + 1, 0, newOption);
          } else {
            options.push(newOption);
          }
          this.model.set(Formbuilder.options.mappings.OPTIONS, options);
          this.model.trigger("change:" + Formbuilder.options.mappings.OPTIONS);
          return this.forceRender();
        },
        removeOption: function(e) {
          var $el, index, options;
          $el = $(e.currentTarget);
          index = this.$el.find(".js-remove-option").index($el);
          options = this.model.get(Formbuilder.options.mappings.OPTIONS);
          options.splice(index, 1);
          this.model.set(Formbuilder.options.mappings.OPTIONS, options);
          this.model.trigger("change:" + Formbuilder.options.mappings.OPTIONS);
          return this.forceRender();
        },
        defaultUpdated: function(e) {
          var $checkboxType, $el;
          $el = $(e.currentTarget);
          $checkboxType = 'checkboxes';
          if (Formbuilder.options.mappings.TYPE_ALIASES && Formbuilder.options.mappings.TYPE_ALIASES['checkboxes']) {
            $checkboxType = Formbuilder.options.mappings.TYPE_ALIASES['checkboxes'];
          }
          if (this.model.get(Formbuilder.options.mappings.FIELD_TYPE) !== $checkboxType) {
            this.$el.find(".js-default-updated").not($el).attr('checked', false).trigger('change');
          }
          return this.forceRender();
        },
        forceRender: function() {
          return this.model.trigger('change');
        },
        toggleRepititionsInputs: function(e) {
          var $el;
          $el = $(e.target);
          if ($el.prop('checked') === true) {
            return this.$el.find('.fb-repititions input').prop('disabled', false);
          } else {
            return this.$el.find('.fb-repititions input').prop('disabled', true);
          }
        }
      }),
      main: Backbone.View.extend({
        SUBVIEWS: [],
        events: {
          'click .js-save-form': 'saveForm',
          'click .fb-add-field-types a': 'addField'
        },
        initialize: function() {
          if (!this.options.eventFix) {
            this.events['click .fb-tabs a'] = 'showTab';
          }
          this.$el = $(this.options.selector);
          this.formBuilder = this.options.formBuilder;
          this.collection = new Formbuilder.collection;
          this.collection.bind('add', this.addOne, this);
          this.collection.bind('reset', this.reset, this);
          this.collection.bind('change', this.handleFormUpdate, this);
          this.collection.bind('destroy add reset', this.hideShowNoResponseFields, this);
          this.collection.bind('destroy', this.ensureEditViewScrolled, this);
          this.render();
          this.collection.reset(this.options.bootstrapData);
          return this.initAutosave();
        },
        initAutosave: function() {
          var _this = this;
          this.formSaved = true;
          this.saveFormButton = this.$el.find(".js-save-form");
          this.saveFormButton.attr('disabled', true).text(Formbuilder.options.dict.ALL_CHANGES_SAVED);
          setInterval(function() {
            return _this.saveForm.call(_this);
          }, 5000);
          return $(window).bind('beforeunload', function() {
            if (_this.formSaved) {
              return void 0;
            } else {
              return Formbuilder.options.dict.UNSAVED_CHANGES;
            }
          });
        },
        reset: function() {
          this.$responseFields.html('');
          return this.addAll();
        },
        render: function() {
          var $fields, $fieldsNonInput, alias, field, fieldName, orig, subview, _i, _j, _len, _len1, _ref, _ref1, _ref2;
          this.options.editStructure = this.options.hasOwnProperty('editStructure') ? this.options.editStructure : true;
          this.options.addAt = this.options.hasOwnProperty('addAt') ? this.options.addAt : 'last';
          if (Formbuilder.options.mappings.TYPE_ALIASES) {
            _ref = Formbuilder.options.mappings.TYPE_ALIASES;
            for (orig in _ref) {
              alias = _ref[orig];
              Formbuilder.fields[alias] = Formbuilder.fields[orig];
            }
          }
          $fields = {};
          $fieldsNonInput = {};
          if (this.options.hasOwnProperty('fields')) {
            _ref1 = this.options.fields;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              fieldName = _ref1[_i];
              field = Formbuilder.inputFields[fieldName] || Formbuilder.nonInputFields[fieldName];
              if (!field) {
                throw new Error("No field found with name" + fieldName);
              }
              if (field.type === "non_input") {
                $fieldsNonInput[fieldName] = field;
              } else {
                $fields[fieldName] = field;
              }
            }
          } else {
            $fields = Formbuilder.inputFields;
            $fieldsNonInput = Formbuilder.nonInputFields;
          }
          this.$el.html(Formbuilder.templates['page']({
            editStructure: this.options.editStructure,
            fieldsEnabled: $fields,
            fieldsEnabledNonInput: $fieldsNonInput
          }));
          this.$fbLeft = this.$el.find('.fb-left') || this.$el.find('.span6.middle');
          this.$fbRight = this.$el.find('.fb-right') || this.$el.find('.span4.right');
          this.$responseFields = this.$el.find('.fb-response-fields');
          this.bindWindowScrollEvent();
          this.hideShowNoResponseFields();
          _ref2 = this.SUBVIEWS;
          for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
            subview = _ref2[_j];
            new subview({
              parentView: this
            }).render();
          }
          if (this.options.eventFix) {
            this.$el.find('.fb-tabs a').unbind().click(this.showTab);
          }
          return this;
        },
        bindWindowScrollEvent: function() {
          var _this = this;
          return $(window).on('scroll', function() {
            var maxMargin, newMargin;
            if (_this.$fbLeft.data('locked') === true) {
              return;
            }
            newMargin = Math.max(0, $(window).scrollTop());
            maxMargin = _this.$responseFields.height();
            return _this.$fbLeft.css({
              'margin-top': Math.min(maxMargin, newMargin)
            });
          });
        },
        showTab: function(e) {
          var $el, first_model, target;
          $el = $(e.currentTarget);
          target = $el.data('target');
          $el.closest('li').addClass('active').siblings('li').removeClass('active');
          this.$el.find(target).addClass('active').siblings('.fb-tab-pane').removeClass('active');
          if (target !== '#editField') {
            this.unlockLeftWrapper();
          }
          if (target === '#editField' && !this.editView && (first_model = this.collection.models[0])) {
            return this.createAndShowEditView(first_model);
          }
        },
        addOne: function(responseField, _, options) {
          var $replacePosition, view;
          view = new Formbuilder.views.view_field({
            model: responseField,
            parentView: this
          });
          if (options.$replaceEl != null) {
            return options.$replaceEl.replaceWith(view.render().el);
          } else if ((options.position == null) || options.position === -1) {
            return this.$responseFields.append(view.render().el);
          } else if (options.position === 0) {
            return this.$responseFields.prepend(view.render().el);
          } else if (($replacePosition = this.$responseFields.find(".fb-field-wrapper").eq(options.position))[0]) {
            return $replacePosition.before(view.render().el);
          } else {
            return this.$responseFields.append(view.render().el);
          }
        },
        setSortable: function() {
          var _this = this;
          if (this.$responseFields.hasClass('ui-sortable')) {
            this.$responseFields.sortable('destroy');
          }
          this.$responseFields.sortable({
            forcePlaceholderSize: true,
            placeholder: 'sortable-placeholder',
            stop: function(e, ui) {
              var rf;
              if (ui.item.data('field-type')) {
                rf = _this.collection.create(Formbuilder.helpers.defaultFieldAttrs(ui.item.data('field-type')), {
                  $replaceEl: ui.item
                });
                _this.createAndShowEditView(rf);
              }
              _this.handleFormUpdate();
              return true;
            },
            update: function(e, ui) {
              if (!ui.item.data('field-type')) {
                return _this.ensureEditViewScrolled();
              }
            }
          });
          return this.setDraggable();
        },
        setDraggable: function() {
          var $addFieldButtons,
            _this = this;
          $addFieldButtons = this.$el.find("[data-field-type]");
          return $addFieldButtons.draggable({
            connectToSortable: this.$responseFields,
            helper: function() {
              var $helper;
              $helper = $("<div class='response-field-draggable-helper' />");
              $helper.css({
                width: _this.$responseFields.width(),
                height: '80px'
              });
              return $helper;
            }
          });
        },
        addAll: function() {
          this.collection.each(this.addOne, this);
          if (!(this.options.editStructure === false)) {
            return this.setSortable();
          }
        },
        hideShowNoResponseFields: function() {
          return this.$el.find(".fb-no-response-fields")[this.collection.length > 0 ? 'hide' : 'show']();
        },
        addField: function(e) {
          var field_type;
          field_type = $(e.currentTarget).data('field-type');
          return this.createField(Formbuilder.helpers.defaultFieldAttrs(field_type));
        },
        createField: function(attrs, options) {
          var rf;
          options = options || {};
          options.at = this.options.addAt === "last" ? this.collection.length : 0;
          rf = this.collection.create(attrs, options);
          this.createAndShowEditView(rf);
          return this.handleFormUpdate();
        },
        createAndShowEditView: function(model) {
          var $newEditEl, $responseFieldEl, oldPadding;
          $responseFieldEl = this.$el.find(".fb-field-wrapper").filter(function() {
            return $(this).data('cid') === model.cid;
          });
          $responseFieldEl.addClass('editing').siblings('.fb-field-wrapper').removeClass('editing');
          if (this.editView) {
            if (this.editView.model.cid === model.cid) {
              this.$el.find(".fb-tabs a[data-target=\"#editField\"]").click();
              this.scrollLeftWrapper($responseFieldEl, (typeof oldPadding !== "undefined" && oldPadding !== null) && oldPadding);
              return;
            }
            oldPadding = this.$fbLeft.css('padding-top');
            this.editView.remove();
          }
          this.editView = new Formbuilder.views.edit_field({
            model: model,
            parentView: this
          });
          $newEditEl = this.editView.render().$el;
          this.$el.find(".fb-edit-field-wrapper").html($newEditEl);
          if (!this.options.noEditOnDrop) {
            this.$el.find(".fb-tabs a[data-target=\"#editField\"]").click();
          }
          this.scrollLeftWrapper($responseFieldEl);
          return this;
        },
        ensureEditViewScrolled: function() {
          if (!this.editView) {
            return;
          }
          return this.scrollLeftWrapper($(".fb-field-wrapper.editing"));
        },
        scrollLeftWrapper: function($responseFieldEl) {
          var _this = this;
          if (this.options.noScroll) {
            return;
          }
          this.unlockLeftWrapper();
          return $.scrollWindowTo($responseFieldEl.offset().top - this.$responseFields.offset().top, 200, function() {
            return _this.lockLeftWrapper();
          });
        },
        lockLeftWrapper: function() {
          return this.$fbLeft.data('locked', true);
        },
        unlockLeftWrapper: function() {
          return this.$fbLeft.data('locked', false);
        },
        handleFormUpdate: function() {
          if (this.updatingBatch) {
            return;
          }
          this.formSaved = false;
          return this.saveFormButton.removeAttr('disabled').text(Formbuilder.options.dict.SAVE_FORM);
        },
        saveForm: function(e) {
          var payload;
          if (this.formSaved) {
            return;
          }
          this.formSaved = true;
          this.saveFormButton.attr('disabled', true).text(Formbuilder.options.dict.ALL_CHANGES_SAVED);
          this.collection.sort();
          payload = JSON.stringify({
            fields: this.collection.toJSON()
          });
          if (Formbuilder.options.HTTP_ENDPOINT) {
            this.doAjaxSave(payload);
          }
          return this.formBuilder.trigger('save', payload);
        },
        doAjaxSave: function(payload) {
          var _this = this;
          return $.ajax({
            url: Formbuilder.options.HTTP_ENDPOINT,
            type: Formbuilder.options.HTTP_METHOD,
            data: payload,
            contentType: "application/json",
            success: function(data) {
              var datum, _i, _len, _ref;
              _this.updatingBatch = true;
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                datum = data[_i];
                if ((_ref = _this.collection.get(datum.cid)) != null) {
                  _ref.set({
                    id: datum.id
                  });
                }
                _this.collection.trigger('sync');
              }
              return _this.updatingBatch = void 0;
            }
          });
        }
      })
    };

    function Formbuilder(selector, opts) {
      if (opts == null) {
        opts = {};
      }
      _.extend(this, Backbone.Events);
      this.mainView = new Formbuilder.views.main(_.extend({
        selector: selector
      }, opts, {
        formBuilder: this
      }));
      this.collection = this.mainView.collection;
    }

    return Formbuilder;

  })();

  window.Formbuilder = Formbuilder;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Formbuilder;
  } else {
    window.Formbuilder = Formbuilder;
  }

}).call(this);

(function() {
  Formbuilder.registerField('address', {
    repeatable: true,
    view: "<div class='input-line'>\n  <span class='street'>\n    <input type='text' />\n    <label>Address</label>\n  </span>\n</div>\n\n<div class='input-line'>\n  <span class='city'>\n    <input type='text' />\n    <label>City</label>\n  </span>\n\n  <span class='state'>\n    <input type='text' />\n    <label>State / Province / Region</label>\n  </span>\n</div>\n\n<div class='input-line'>\n  <span class='zip'>\n    <input type='text' />\n    <label>Zipcode</label>\n  </span>\n\n  <span class='country'>\n    <select><option>United States</option></select>\n    <label>Country</label>\n  </span>\n</div>",
    edit: "",
    addButton: "<span class=\"symbol\"><span class=\"icon-home\"></span></span> Address"
  });

}).call(this);

(function() {
  Formbuilder.registerField('autodate', {
    icon: 'icon-calendar',
    repeatable: true,
    valueField: false,
    view: "<% if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)===\"date\"){ %>\n  <input disabled value=\"YYYY-MM-DD\">\n  <span class='icon icon-calendar'></span>\n<% } else if (rf.get(Formbuilder.options.mappings.DATETIME_UNIT)===\"time\"){ %>\n  <input disabled value=\"HH:MM\">\n  <span class='icon icon-time'></span>\n<% }else{ %>\n  <input disabled value=\"YYYY-MM-DD HH:MM\">\n  <span class='icon icon-calendar'></span><span class='icon icon-time'></span>\n\n<% } %>",
    edit: "<div class='fb-edit-section-header'>Time Stamp Options</div>\n<div class=\"inline-labels\">\n  <label>Field type:</label>\n  <select data-rv-value=\"model.<%= Formbuilder.options.mappings.DATETIME_UNIT %>\" style=\"width: auto;\">\n    <option value=\"datetime\">Date &amp; Time</option>\n    <option value=\"time\">Time Only</option>\n    <option value=\"date\">Date Only</option>\n  </select>\n  <label>Auto-populate:</label>\n  <input type='checkbox' data-rv-checked='model.<%= Formbuilder.options.mappings.TIME_AUTOPOPULATE  %>' />\n</div>",
    addButton: "<span class='symbol'><span class='icon-calendar'></span></span> Datestamp",
    defaultAttributes: function(attrs) {
      attrs[Formbuilder.options.mappings.DATETIME_UNIT] = 'datetime';
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('checkbox', {
    repeatable: true,
    icon: 'icon-check',
    valueField: false,
    view: "<input type='checkbox' <%= rf.get(Formbuilder.options.mappings.SINGLE_CHECKED) && 'checked' %> onclick=\"javascript: return false;\" />",
    edit: "<div class='fb-edit-section-header'>Checked</div>\n<input type='checkbox' <%= rf.get(Formbuilder.options.mappings.SINGLE_CHECKED) && 'checked' %> data-rv-checked='model.<%= Formbuilder.options.mappings.SINGLE_CHECKED%>' />",
    addButton: "<span class=\"symbol\"><span class=\"icon-check\"></span></span> Checkbox",
    defaultAttributes: function(attrs) {
      attrs = new Backbone.Model(attrs);
      attrs.set(Formbuilder.options.mappings.SINGLE_CHECKED, true);
      attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'checkbox');
      return attrs.toJSON();
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('checkboxes', {
    repeatable: false,
    view: "<% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>\n  <div>\n    <label class='fb-option'>\n      <input type='checkbox' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick=\"javascript: return false;\" />\n      <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>\n    </label>\n  </div>\n<% } %>\n\n<% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>\n  <div class='other-option'>\n    <label class='fb-option'>\n      <input type='checkbox' />\n      Other\n    </label>\n\n    <input type='text' />\n  </div>\n<% } %>",
    edit: "<%= Formbuilder.templates['edit/options']({ includeOther: true }) %>",
    addButton: "<span class=\"symbol\"><span class=\"icon-check-empty\"></span></span> Checkboxes",
    defaultAttributes: function(attrs) {
      attrs.field_options.options = [
        {
          label: "",
          checked: false
        }, {
          label: "",
          checked: false
        }
      ];
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('date', {
    repeatable: true,
    view: "<div class='input-line'>\n  <span class='month'>\n    <input type=\"text\" />\n    <label>MM</label>\n  </span>\n\n  <span class='above-line'>/</span>\n\n  <span class='day'>\n    <input type=\"text\" />\n    <label>DD</label>\n  </span>\n\n  <span class='above-line'>/</span>\n\n  <span class='year'>\n    <input type=\"text\" />\n    <label>YYYY</label>\n  </span>\n</div>",
    edit: "",
    addButton: "<span class=\"symbol\"><span class=\"icon-calendar\"></span></span> Date"
  });

}).call(this);

(function() {
  Formbuilder.registerField('dropdown', {
    repeatable: false,
    valueField: false,
    icon: 'icon-caret-down',
    view: "<select>\n  <% if (rf.get(Formbuilder.options.mappings.INCLUDE_BLANK)) { %>\n    <option value=''></option>\n  <% } %>\n\n  <% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>\n    <option <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'selected' %>>\n      <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>\n    </option>\n  <% } %>\n</select>",
    edit: "<%= Formbuilder.templates['edit/options']({ includeBlank: true }) %>",
    addButton: "<span class=\"symbol\"><span class=\"icon-caret-down\"></span></span> Dropdown",
    defaultAttributes: function(attrs) {
      attrs = new Backbone.Model(attrs);
      attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'dropdown');
      attrs.set(Formbuilder.options.mappings.OPTIONS, [
        {
          label: "",
          checked: false
        }, {
          label: "",
          checked: false
        }
      ]);
      attrs.set(Formbuilder.options.mappings.OPTIONS, [
        {
          label: "",
          checked: false
        }, {
          label: "",
          checked: false
        }
      ]);
      attrs.set(Formbuilder.options.mappings.INCLUDE_BLANK, false);
      return attrs.toJSON();
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('email', {
    repeatable: true,
    icon: 'icon-envelope-alt',
    view: "<input type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' placeholder=\"email@example.com\" class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' />",
    edit: "",
    addButton: "<span class=\"symbol\"><span class=\"icon-envelope-alt\"></span></span> Email"
  });

}).call(this);

(function() {
  Formbuilder.registerField('list', {
    icon: 'icon-list',
    type: 'non_input',
    view: "<div class=\"btn-group pull-right\">\n<a data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" class=\"btn btn-small btn-listfield-data\" href=\"#\"><i class=\"icon-pencil\"></i> Edit Data</a>\n<a data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" class=\"btn btn-small btn-listfield-structure\" href=\"#\"><i class=\"icon-road\"></i> Edit Structure</i></a>\n</div>\n<label class='section-name'><%= rf.get(Formbuilder.options.mappings.LABEL) %></label>\n<br />\n<br />\n<div class=\"fieldlist_table\" data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\">\n<p class=\"instructions\"><i class=\"icon-info-sign\"></i>Empty list - to add contents: </p><br />\n&nbsp; &nbsp;  1) Use \"Edit Structure\" to add fields to the list <br />\n&nbsp;  &nbsp;  2) Use \"Edit Data\" to add rows\n</div>",
    edit: "<div class=\"btn-group\">\n<a data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" class=\"btn btn-listfield-data\" href=\"#\"><i class=\"icon-pencil\"></i> Edit Data</a>\n<a data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" class=\"btn btn-listfield-structure\" href=\"#\"><i class=\"icon-road\"></i> Edit Structure</i></a>\n</div>\n\n<div class='fb-edit-section-header'>List Name</div>\n<input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />\n",
    addButton: "<span class='symbol'><span class='icon-list'></span></span> Field List"
  });

}).call(this);

(function() {
  Formbuilder.registerField('file', {
    repeatable: true,
    icon: 'icon-cloud-upload',
    valueField: false,
    view: "<div class=\"file_container\" data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\"></div>\n<input type='file' name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" data-name=\"<%= rf.get(Formbuilder.options.mappings.LABEL) %>\" data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  />",
    edit: "Max. File Size\n<input type=\"text\" data-rv-input=\"model.<%= Formbuilder.options.mappings.FILE_SIZE %>\" style=\"width: 60px\" /> KB",
    addButton: "<span class=\"symbol\"><span class=\"icon-cloud-upload\"></span></span> File"
  });

}).call(this);

(function() {
  Formbuilder.registerField('location', {
    repeatable: true,
    valueField: false,
    icon: 'icon-location-arrow',
    view: "<% if (rf.get(Formbuilder.options.mappings.LOCATION_UNIT)===\"latlong\"){ %>\nLatitude/Longitude\n<% } else { %>\nEastings/Northings\n<% } %>\n<br />\n<input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />\n<input disabled class='rf-size-small' type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' />",
    edit: "<div class='fb-edit-section-header'>Location Unit</div>\n<select data-rv-value=\"model.<%= Formbuilder.options.mappings.LOCATION_UNIT %>\" style=\"width: auto;\">\n  <option value=\"latlong\">Latitude / Longitude</option>\n  <option value=\"eastnorth\">Eastings / Northings</option>\n</select>",
    addButton: "<span class='symbol'><span class='icon-location-arrow'></span></span> Location",
    defaultAttributes: function(attrs) {
      attrs[Formbuilder.options.mappings.LOCATION_UNIT] = 'latlong';
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('map', {
    repeatable: true,
    valueField: false,
    icon: 'icon-map-marker',
    view: "<h1><span class='icon-map-marker'></span></h1>",
    edit: "",
    addButton: "<span class='symbol'><span class='icon-map-marker'></span></span> Map",
    defaultAttributes: function(attrs) {
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('number', {
    repeatable: true,
    icon: 'icon-number',
    iconText: '123',
    view: "<input type='number' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' />\n<% if (units = rf.get(Formbuilder.options.mappings.UNITS)) { %>\n  <%= units %>\n<% } %>",
    edit: "<%= Formbuilder.templates['edit/min_max']() %>\n<%= Formbuilder.templates['edit/units']() %>\n<%= Formbuilder.templates['edit/integer_only']() %>",
    addButton: "<span class=\"symbol\"><span class=\"icon-number\">123</span></span> Number"
  });

}).call(this);

(function() {
  Formbuilder.registerField('page_break', {
    icon: 'icon-file',
    type: 'non_input',
    view: "<label class='section-name'>&nbsp; <%= rf.get(Formbuilder.options.mappings.LABEL) %></label>\n<p><%= rf.get(Formbuilder.options.mappings.DESCRIPTION) %></p>\n<hr style=\"border-bottom: 2px solid #bbb\">",
    edit: "<div class='fb-edit-section-header'>Label</div>\n<input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />\n<textarea data-rv-input='model.<%= Formbuilder.options.mappings.DESCRIPTION %>'\nplaceholder='Add a longer description to this field'></textarea>",
    addButton: "<span class='symbol'><span class='icon-file'></span></span> Page Break"
  });

}).call(this);

(function() {
  Formbuilder.registerField('paragraph', {
    icon: 'icon-align-justify',
    repeatable: true,
    view: "<textarea class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>' ><%= rf.get(Formbuilder.options.mappings.VALUE) %></textarea>",
    edit: "<%= Formbuilder.templates['edit/size']() %>\n<%= Formbuilder.templates['edit/min_max_length']() %>",
    addButton: "<span class=\"icon icon-align-justify\"></span> Paragraph",
    defaultAttributes: function(attrs) {
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('photo', {
    icon: 'icon-camera',
    repeatable: true,
    valueField: false,
    view: "<h1><span class='icon-camera'></span></h1>",
    edit: "<div class=\"inline-labels\">\n<label>Max Height</label>\n<input type=\"text\" data-rv-input=\"model.<%= Formbuilder.options.mappings.PHOTO_HEIGHT %>\" style=\"width: 60px\" /> px<br />\n<label>Max Width</label>\n<input type=\"text\" data-rv-input=\"model.<%= Formbuilder.options.mappings.PHOTO_WIDTH %>\" style=\"width: 60px\" /> px<br />\n<label>Quality</label>\n<input type=\"text\" data-rv-input=\"model.<%= Formbuilder.options.mappings.PHOTO_QUALITY %>\" style=\"width: 60px\" /> %<br />\n</div>",
    addButton: "<span class='symbol'><span class='icon-camera'></span></span> Photo Capture",
    defaultAttributes: function(attrs) {
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('price', {
    repeatable: true,
    view: "<div class='input-line'>\n  <span class='above-line'>$</span>\n  <span class='dolars'>\n    <input type='text' />\n    <label>Dollars</label>\n  </span>\n  <span class='above-line'>.</span>\n  <span class='cents'>\n    <input type='text' />\n    <label>Cents</label>\n  </span>\n</div>",
    edit: "",
    addButton: "<span class=\"symbol\"><span class=\"icon-dollar\"></span></span> Price"
  });

}).call(this);

(function() {
  Formbuilder.registerField('radio', {
    icon: 'icon-circle-blank',
    repeatable: true,
    valueField: false,
    view: "<% for (i in (rf.get(Formbuilder.options.mappings.OPTIONS) || [])) { %>\n  <div>\n    <label class='fb-option'>\n      <input type='radio' <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].checked && 'checked' %> onclick=\"javascript: return false;\" />\n      <%= rf.get(Formbuilder.options.mappings.OPTIONS)[i].label %>\n    </label>\n  </div>\n<% } %>\n\n<% if (rf.get(Formbuilder.options.mappings.INCLUDE_OTHER)) { %>\n  <div class='other-option'>\n    <label class='fb-option'>\n      <input type='radio' />\n      Other\n    </label>\n\n    <input type='text' />\n  </div>\n<% } %>",
    edit: "<%= Formbuilder.templates['edit/options']({ includeOther: true }) %>",
    addButton: "<span class=\"symbol\"><span class=\"icon-circle-blank\"></span></span> Radio Buttons",
    defaultAttributes: function(attrs) {
      attrs = new Backbone.Model(attrs);
      attrs.set(Formbuilder.options.mappings.FIELD_TYPE, 'radio');
      attrs.set(Formbuilder.options.mappings.OPTIONS, [
        {
          label: "",
          checked: false
        }, {
          label: "",
          checked: false
        }
      ]);
      return attrs.toJSON();
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('section_break', {
    type: 'non_input',
    icon: 'icon-minus',
    view: "<label class='section-name'><%= rf.get(Formbuilder.options.mappings.LABEL) %></label>\n<p><%= rf.get(Formbuilder.options.mappings.DESCRIPTION) %></p>\n<hr style=\"border-bottom: 2px dashed #bbb\">",
    edit: "<div class='fb-edit-section-header'>Label</div>\n<input type='text' data-rv-input='model.<%= Formbuilder.options.mappings.LABEL %>' />\n<textarea data-rv-input='model.<%= Formbuilder.options.mappings.DESCRIPTION %>'\n  placeholder='Add a longer description to this field'></textarea>",
    addButton: "<span class='symbol'><span class='icon-minus'></span></span> Section Break"
  });

}).call(this);

(function() {
  Formbuilder.registerField('signature', {
    repeatable: true,
    valueField: false,
    icon: 'icon-pencil',
    view: "<h1 style=\"border: 1px solid #bbb; padding: 10px; border-radius: 6px;\"><span class='icon-pencil'></span></h1>",
    edit: "",
    addButton: "<span class='symbol'><span class='icon-pencil'></span></span> Signature Capture",
    defaultAttributes: function(attrs) {
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('text', {
    icon: 'icon-font',
    repeatable: true,
    view: "<% var size = rf.get(Formbuilder.options.mappings.SIZE) || 'large'; %>\n<input type='text' data-cid='<%= rf.cid %>' data-_id='<%= rf.get('_id') %>'  value='<%= rf.get(Formbuilder.options.mappings.VALUE) %>' class='rf-size-<%= size %>' />",
    edit: "<%= Formbuilder.templates['edit/size']() %>\n<%= Formbuilder.templates['edit/min_max_length']() %>",
    addButton: "<span class='symbol'><span class='icon-font'></span></span> Text",
    defaultAttributes: function(attrs) {
      return attrs;
    }
  });

}).call(this);

(function() {
  Formbuilder.registerField('time', {
    repeatable: true,
    view: "<div class='input-line'>\n  <span class='hours'>\n    <input type=\"text\" />\n    <label>HH</label>\n  </span>\n\n  <span class='above-line'>:</span>\n\n  <span class='minutes'>\n    <input type=\"text\" />\n    <label>MM</label>\n  </span>\n\n  <span class='above-line'>:</span>\n\n  <span class='seconds'>\n    <input type=\"text\" />\n    <label>SS</label>\n  </span>\n\n  <span class='am_pm'>\n    <select>\n      <option>AM</option>\n      <option>PM</option>\n    </select>\n  </span>\n</div>",
    edit: "",
    addButton: "<span class=\"symbol\"><span class=\"icon-time\"></span></span> Time"
  });

}).call(this);

(function() {
  Formbuilder.registerField('website', {
    repeatable: true,
    icon: 'icon-link',
    view: "<input type='text' class='rf-size-<%= rf.get(Formbuilder.options.mappings.SIZE) %>' placeholder='http://' />",
    edit: "<%= Formbuilder.templates['edit/size']() %>",
    addButton: "<span class=\"symbol\"><span class=\"icon-link\"></span></span> Website"
  });

}).call(this);

this["Formbuilder"] = this["Formbuilder"] || {};
this["Formbuilder"]["templates"] = this["Formbuilder"]["templates"] || {};

this["Formbuilder"]["templates"]["edit/base"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p +=
((__t = ( Formbuilder.templates['edit/base_header']() )) == null ? '' : __t) +
'\n<div class="well">\n  ' +
((__t = ( Formbuilder.templates['edit/common']({ rf : rf, editStructure : editStructure, commonCheckboxes : commonCheckboxes, repeatable : repeatable, repeating : repeating }) )) == null ? '' : __t) +
'\n</div>\n';
 if (Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].edit({rf: rf})){ ;
__p += '\n  <div class="well">\n    ' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].edit({rf: rf}) )) == null ? '' : __t) +
'\n  </div>\n';
 } ;
__p += '\n\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/base_header"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-field-label\'>\n  <span data-rv-text="model.' +
((__t = ( Formbuilder.options.mappings.LABEL )) == null ? '' : __t) +
'"></span>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["edit/base_non_input"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p +=
((__t = ( Formbuilder.templates['edit/base_header']() )) == null ? '' : __t) +
'\n' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].edit({rf: rf}) )) == null ? '' : __t) +
'\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/checkboxes"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<label class="fb-required">\n  <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.REQUIRED )) == null ? '' : __t) +
'\' />\n  Required\n</label>\n\n';
 if (repeatable){ ;
__p += '\n  <label class="fb-repeating">\n    <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.REPEATING )) == null ? '' : __t) +
'\' />\n    Repeating\n  </label>\n  <label class="fb-repititions">\n    Min. Repititions\n    ';
 var disabled = (repeating===true) ? "" : "disabled"; ;
__p += '\n    <input type="text" ' +
((__t = ( disabled )) == null ? '' : __t) +
' data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MINREPITIONS )) == null ? '' : __t) +
'" style="width: 30px" />\n    Max. Repititions\n    <input type="text" ' +
((__t = ( disabled )) == null ? '' : __t) +
' data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MAXREPITIONS)) == null ? '' : __t) +
'" style="width: 30px" />\n  </label>\n';
 } ;
__p += '\n<label class="fb-adminonly">\n  <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.ADMIN_ONLY )) == null ? '' : __t) +
'\' />\n  Admin only\n</label>';

}
return __p
};

this["Formbuilder"]["templates"]["edit/common"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class=\'fb-common-wrapper\'>\n  <div class=\'fb-label-description\'>\n    ' +
((__t = ( Formbuilder.templates['edit/label_description']({ rf : rf, editStructure : editStructure }) )) == null ? '' : __t) +
'\n  </div>\n  ';
 if (commonCheckboxes){ ;
__p += '\n  <div class=\'fb-common-checkboxes\'>\n    ' +
((__t = ( Formbuilder.templates['edit/checkboxes']({repeatable : repeatable, repeating : repeating}) )) == null ? '' : __t) +
'\n  </div>\n  ';
 } ;
__p += '\n  <div class=\'fb-clear\'></div>\n</div>\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/integer_only"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-edit-section-header\'>Integer only</div>\n<label>\n  <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.INTEGER_ONLY )) == null ? '' : __t) +
'\' />\n  Only accept integers\n</label>\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/label_description"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if (editStructure) { ;
__p += '\n  <div class=\'fb-edit-section-header\'>Name</div>\n  <input type=\'text\' data-rv-input=\'model.' +
((__t = ( Formbuilder.options.mappings.LABEL )) == null ? '' : __t) +
'\' />\n';
 } ;
__p += '\n';
 if (Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].valueField !== false) { ;
__p += '\n  <div class=\'fb-edit-section-header\'>' +
((__t = ( Formbuilder.options.mappings.VALUE_HEADER )) == null ? '' : __t) +
'</div>\n  <input type=\'text\' data-rv-input=\'model.' +
((__t = ( Formbuilder.options.mappings.VALUE )) == null ? '' : __t) +
'\' />\n';
 } ;
__p += '\n<div class="fb-field-description">\n  <div class=\'fb-edit-section-header\'>' +
((__t = ( Formbuilder.options.mappings.DESCRIPTION_TITLE )) == null ? '' : __t) +
'</div>\n  <textarea data-rv-input=\'model.' +
((__t = ( Formbuilder.options.mappings.DESCRIPTION )) == null ? '' : __t) +
'\'\n    placeholder=\'' +
((__t = ( Formbuilder.options.mappings.DESCRIPTION_PLACEHOLDER )) == null ? '' : __t) +
'\'></textarea>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["edit/min_max"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-edit-section-header\'>Minimum / Maximum</div>\n\nAbove\n<input type="text" data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MIN )) == null ? '' : __t) +
'" style="width: 30px" />\n\n&nbsp;&nbsp;\n\nBelow\n<input type="text" data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MAX )) == null ? '' : __t) +
'" style="width: 30px" />\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/min_max_length"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="fb-configure-length">\n  <div class=\'fb-edit-section-header\'>Length Limit</div>\n\n  Min\n  <input type="text" data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MINLENGTH )) == null ? '' : __t) +
'" style="width: 30px" />\n\n  &nbsp;&nbsp;\n\n  Max\n  <input type="text" data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.MAXLENGTH )) == null ? '' : __t) +
'" style="width: 30px" />\n\n  &nbsp;&nbsp;\n\n  <select data-rv-value="model.' +
((__t = ( Formbuilder.options.mappings.LENGTH_UNITS )) == null ? '' : __t) +
'" style="width: auto;">\n    <option value="characters">characters</option>\n    <option value="words">words</option>\n  </select>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["edit/options"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class=\'fb-edit-section-header\'>Options</div>\n\n';
 if (typeof includeBlank !== 'undefined'){ ;
__p += '\n  <label>\n    <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.INCLUDE_BLANK )) == null ? '' : __t) +
'\' />\n    Include blank\n  </label>\n';
 } ;
__p += '\n\n<div class=\'option\' data-rv-each-option=\'model.' +
((__t = ( Formbuilder.options.mappings.OPTIONS )) == null ? '' : __t) +
'\'>\n  <input type="checkbox" class=\'js-default-updated\' data-rv-checked="option:checked" />\n  <input type="text" data-rv-input="option:label" class=\'option-label-input\' />\n  <a class="js-add-option ' +
((__t = ( Formbuilder.options.BUTTON_CLASS )) == null ? '' : __t) +
'" title="Add Option"><i class=\'icon-plus-sign\'></i></a>\n  <a class="js-remove-option ' +
((__t = ( Formbuilder.options.BUTTON_CLASS )) == null ? '' : __t) +
'" title="Remove Option"><i class=\'icon-minus-sign\'></i></a>\n</div>\n\n';
 if (typeof includeOther !== 'undefined'){ ;
__p += '\n  <label>\n    <input type=\'checkbox\' data-rv-checked=\'model.' +
((__t = ( Formbuilder.options.mappings.INCLUDE_OTHER )) == null ? '' : __t) +
'\' />\n    Include "other"\n  </label>\n';
 } ;
__p += '\n\n<div class=\'fb-bottom-add\'>\n  <a class="js-add-option ' +
((__t = ( Formbuilder.options.BUTTON_CLASS )) == null ? '' : __t) +
'">Add option</a>\n</div>\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/size"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<!--<div class=\'fb-edit-section-header\'>Size</div>-->\n<!--<select data-rv-value="model.' +
((__t = ( Formbuilder.options.mappings.SIZE )) == null ? '' : __t) +
'">-->\n  <!--<option value="small">Small</option>-->\n  <!--<option value="medium">Medium</option>-->\n  <!--<option value="large">Large</option>-->\n<!--</select>-->\n';

}
return __p
};

this["Formbuilder"]["templates"]["edit/units"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-edit-section-header\'>Units</div>\n<input type="text" data-rv-input="model.' +
((__t = ( Formbuilder.options.mappings.UNITS )) == null ? '' : __t) +
'" />\n';

}
return __p
};

this["Formbuilder"]["templates"]["page"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p +=
((__t = ( Formbuilder.templates['partials/save_button']() )) == null ? '' : __t) +
'\n' +
((__t = ( Formbuilder.templates['partials/left_side']({ editStructure : editStructure }) )) == null ? '' : __t) +
'\n' +
((__t = ( Formbuilder.templates['partials/right_side']({ editStructure : editStructure, fieldsEnabled : fieldsEnabled, fieldsEnabledNonInput : fieldsEnabledNonInput}) )) == null ? '' : __t) +
'\n<div class=\'fb-clear\'></div>';

}
return __p
};

this["Formbuilder"]["templates"]["partials/add_field"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class=\'fb-tab-pane active\' id=\'addField\'>\n  <div class=\'fb-add-field-types\'>\n    <div class=\'section\'>\n      ';
 for (i in fieldsEnabled) { ;
__p += '\n        <a data-field-type="' +
((__t = ( i )) == null ? '' : __t) +
'" class="btn btn-primary btn-' +
((__t = ( i )) == null ? '' : __t) +
'">\n          ' +
((__t = ( fieldsEnabled[i].addButton )) == null ? '' : __t) +
'\n        </a>\n      ';
 } ;
__p += '\n    </div>\n\n    <div class=\'section\'>\n      ';
 for (i in fieldsEnabledNonInput) { ;
__p += '\n        <a data-field-type="' +
((__t = ( i )) == null ? '' : __t) +
'" class="btn btn-primary btn-' +
((__t = ( i )) == null ? '' : __t) +
'">\n          ' +
((__t = ( fieldsEnabledNonInput[i].addButton )) == null ? '' : __t) +
'\n        </a>\n      ';
 } ;
__p += '\n    </div>\n  </div>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["partials/edit_field"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-tab-pane\' id=\'editField\'>\n  <div class=\'fb-edit-field-wrapper\'></div>\n</div>\n';

}
return __p
};

this["Formbuilder"]["templates"]["partials/left_side"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'span6 middle\'>\n  <div class=\'fb-no-response-fields\'>No response fields</div>\n  <div class=\'fb-response-fields\'></div>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["partials/right_side"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class=\'span4 right\'>\n  <ul class=\'fb-tabs nav nav-tabs compact \'>\n    ';
 if(editStructure){ ;
__p += '\n      <li class=\'active addfield\'><a data-target=\'#addField\'><i class="icon-plus"></i> Field</a></li>\n      <li class="configurefield"><a data-target=\'#editField\'><i class="icon-cog"></i> Field</a></li>\n    ';
 }else{ ;
__p += '\n      <li class="active configurefield"><a data-target=\'#editField\'><i class="icon-cog"></i> Field</a></li>\n    ';
 } ;
__p += '\n  </ul>\n\n  <div class=\'fb-tab-content\'>\n    ';
 if(editStructure){ ;
__p += '\n      ' +
((__t = ( Formbuilder.templates['partials/add_field']( { fieldsEnabledNonInput : fieldsEnabledNonInput, fieldsEnabled : fieldsEnabled } ) )) == null ? '' : __t) +
'\n    ';
 } ;
__p += '\n    ' +
((__t = ( Formbuilder.templates['partials/edit_field']() )) == null ? '' : __t) +
'\n  </div>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["partials/save_button"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'fb-save-wrapper\'>\n  <button class=\'js-save-form ' +
((__t = ( Formbuilder.options.BUTTON_CLASS )) == null ? '' : __t) +
'\'></button>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["view/base"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class=\'subtemplate-wrapper\'>\n  <div class=\'cover\'></div>\n  ';
 if(editStructure){  ;
__p += '\n  ' +
((__t = ( Formbuilder.templates['view/duplicate_remove']({rf: rf}) )) == null ? '' : __t) +
'\n  ';
 } ;
__p += '\n  <span class="icon icon-inline ' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].icon )) == null ? '' : __t) +
'">' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].iconText )) == null ? '' : __t) +
'</span>\n  ' +
((__t = ( Formbuilder.templates['view/label']({rf: rf}) )) == null ? '' : __t) +
'\n\n  ' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].view({rf: rf}) )) == null ? '' : __t) +
'\n\n  ' +
((__t = ( Formbuilder.templates['view/description']({rf: rf}) )) == null ? '' : __t) +
'\n\n</div>\n';

}
return __p
};

this["Formbuilder"]["templates"]["view/base_non_input"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'subtemplate-wrapper\'>\n  <div class=\'cover\'></div>\n  ' +
((__t = ( Formbuilder.templates['view/duplicate_remove']({rf: rf}) )) == null ? '' : __t) +
'\n  <span class="icon icon-inline ' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].icon )) == null ? '' : __t) +
'"></span>' +
((__t = ( Formbuilder.fields[rf.get(Formbuilder.options.mappings.FIELD_TYPE)].view({rf: rf}) )) == null ? '' : __t) +
'\n</div>\n';

}
return __p
};

this["Formbuilder"]["templates"]["view/description"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<span class=\'help-block\'>\n  ' +
((__t = ( Formbuilder.helpers.simple_format(rf.get(Formbuilder.options.mappings.DESCRIPTION)) )) == null ? '' : __t) +
'\n</span>\n';

}
return __p
};

this["Formbuilder"]["templates"]["view/duplicate_remove"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class=\'actions-wrapper btn-group\'>\n  <a class="js-duplicate btn btn-small btn-success" title="Duplicate Field"><i class=\'icon-plus-sign\'></i></a>\n  <a class="js-clear btn btn-small btn-danger" title="Remove Field"><i class=\'icon-minus-sign\'></i></a>\n</div>';

}
return __p
};

this["Formbuilder"]["templates"]["view/label"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<label>\n  <span>' +
((__t = ( Formbuilder.helpers.simple_format(rf.get(Formbuilder.options.mappings.LABEL)) )) == null ? '' : __t) +
'\n  ';
 if (rf.get(Formbuilder.options.mappings.REQUIRED)) { ;
__p += '\n    <abbr title=\'required\'>*</abbr>\n  ';
 } ;
__p += '\n</label>\n';

}
return __p
};