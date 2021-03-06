Formbuilder.js
============

## FH Modifications:
Follow development instructions below.
Overridden CSS is inline in example/index.html
Overridden JS is in coffee/main.coffee, compiled, and checked into formbuilder.js
Overridden HTML so far is templates/partials/left_side.html & right_side.html

DO NOT modify formbuilder.js - it's alas compiled from the coffeescript files. :-(

We've generated some custom properties for use on init:

    noScroll : disable scrolling of the tabbed section to the position of the field we click on
    noEditOnDrop :  Disable opening the edit screen after dropping a field
    editStructure : Set to false to disable editing of structure -disables DnD, only shows the value field  & allows editing the field inline
    fields: An array of enabled fields - defaults to all fields enabled...
    commonCheckboxes: this disables 'required' and 'admin only' checkbox
    addAt: where in the backbone collection to add new items - now defaults to 'last', but can be 'first'

Also, ability to alias field by updating the mappings like this:

    Formbuilder.options.mappings.TYPE_ALIASES = {
      'text' : 'string'
    };

Formbuilder is a graphical interface for letting users build their own webforms. Think Wufoo or Google Forms, but a lightweight component that can be integrated into your application.

*As of right now, Formbuilder only handles the client-side logic of creating a form. It will output a structured JSON representation of your form, but saving the form, rendering it on the server, and storing users' responses is all up to you. I'm planning on releasing a Rails gem to handle this logic, but the ETA on that is pretty up in the air. If you'd like to help, feel free to reach out.*

## Demo
[Click here](http://dobtco.github.io/formbuilder/) to see Formbuilder in action.

## Basic usage
```
<div id='formbuilder'></div>

<script>
var formbuilder = new Formbuilder('#formbuilder');
</script>
```

See more usage examples in the [wiki](https://github.com/dobtco/formbuilder/wiki).

## Design &amp; Dependencies

Formbuilder itself is a pretty small codebase (6kb gzip'd javascript) but it *does* rely on some external libraries, namely Backbone &amp; Rivets. We use bower to manage our dependencies, which can be seen [here](https://github.com/dobtco/formbuilder/blob/master/bower.json). I'd like to reduce some of these in the future, (especially font-awesome, because that's just silly,) but for now that's what you'll have to include.

Formbuilder consists of a few different components that all live in the `Formbuilder` namespace:

- `Formbuilder.templates` are compiled Underscore.js templates that are used to render the Formbuilder interface. You can see these individual files in the `./templates` directory, but if you're including `formbuilder.js`, you don't need to worry about them.

- `Formbuilder.fields` are the different kinds of inputs that users can add to their forms. We expose a simple API, `Formbuilder.registerField()`, that allows you to add more kinds of inputs.

- `Formbuilder.views`

Because of its modular nature, Formbuilder is easy to customize. Most of the configuration lives in class variables, which means you can simply override a template or method. If you have questions, feel free to open an issue -- we've tried to bridge the gap between convention and configuration, but there's no guarantee that we were successful.

## Data format

Keeping with the customizable nature of Formbuilder, you are also able to modify how Formbuilder structures its JSON output. The [default keypaths](https://github.com/dobtco/formbuilder/blob/master/coffee/main.coffee#L20) are:

```coffeescript
SIZE: 'field_options.size'
UNITS: 'field_options.units'
LABEL: 'label'
FIELD_TYPE: 'field_type'
REQUIRED: 'required'
ADMIN_ONLY: 'admin_only'
OPTIONS: 'field_options.options'
DESCRIPTION: 'field_options.description'
INCLUDE_OTHER: 'field_options.include_other_option'
INCLUDE_BLANK: 'field_options.include_blank_option'
INTEGER_ONLY: 'field_options.integer_only'
MIN: 'field_options.min'
MAX: 'field_options.max'
MINLENGTH: 'field_options.minlength'
MAXLENGTH: 'field_options.maxlength'
LENGTH_UNITS: 'field_options.min_max_length_units'
```

Which outputs JSON that looks something like:

```javascript
[{
    "label": "Please enter your clearance number",
    "field_type": "text",
    "required": true,
    "field_options": {},
    "cid": "c6"
}, {
    "label": "Security personnel #82?",
    "field_type": "radio",
    "required": true,
    "field_options": {
        "options": [{
            "label": "Yes",
            "checked": false
        }, {
            "label": "No",
            "checked": false
        }],
        "include_other_option": true
    },
    "cid": "c10"
}, {
    "label": "Medical history",
    "field_type": "file",
    "required": true,
    "field_options": {},
    "cid": "c14"
}]
```

## Events
More coming soon...

#### `save`
```
var builder = new Formbuilder('#formbuilder');

builder.on('save', function(payload){
  ...
});
```

## Developing

1. `npm install`
2. `bower install`
3. `grunt watch`
4. open `example/index.html` and you're all set! 

#### Applying the changes in RHMAP studio

1. `rm -rf node_modules && npm install`
2. `bower install`
3. `Add the formbuilder.js content in fh-ngui (public/javascript/lib/formbuilder/formbuilder.js)`

#### Updating its bundles translations in RHMAP studio

Execute the grunt tasks as described in the [fh-ngui Readme](https://github.com/fheng/fh-ngui#internationalization)

PS.: In RHMAP studio this project is used in the Build Forms feature

## License

MIT
