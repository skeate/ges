Next we declare a module class. All modules should derive from this. Versioning
here is a bit simpler: Major.Minor

* Major for significant changes (new features, change in how a feature works,
  etc.). This also increments the Minor version number of the whole codebase
  (see above).
* Minor is for bug fixes.

We've also got a default constructor that loads data and adds itself to GES.

    class @Module
        constructor: ->
            self = @
            GES.util.data.get @name, {}, (data) ->
                @data = data
                GES.addModule self
        version: '1.0'
        name: 'Uninitialized module'
        description: 'Uninitialized module'
        runOn: [Pages.All]
        options: []
        option: (name) ->
            opt = @options.filter (o) -> o.name == name
            if opt.length > 0 then opt[0] else null
        tab: null
        tabData: -> {}
        run: ->
            console.log 'attempting to run base module'

Modules can have settings, and those settings can be displayed either on a tab
of its own or, if there's only a few simple options, in the module list itself.
The latter should derive from `ModuleOption`.

`ModuleOption` takes a name and an object containing two required properties:
`type` and `label`. `type` is one of `['toggle', 'text', 'action']`. If `toggle`
or `text`, you can also specify `initial` to set a default value.

Also, I don't much like this but right now the names have to be globally unique
(i.e., two different modules can't have options with the same name). Todo: find
a way around this.

    class @ModuleOption
        constructor: (@name, options) ->
            @type = options.type
            @label = options.label
            switch @type

`toggle` is pretty simple; it creates a checkbox. Value is true or false.

                when 'toggle'
                    if !options.initial? then options.initial = false
                    if typeof options.initial != 'boolean'
                        throw 'Default setting for toggle must be boolean'
                    GES.util.data.get @name, options.initial, (data) =>
                        @enabled = data

`text` produces a text box. If you also pass `obscured: true`, it's a password
box. You can also pass a RegExp in `check` if you want a particular format.

                when 'text'
                    if !options.initial? then options.initial = ''
                    if typeof options.initial != 'string'
                        throw 'Default setting for text must be a string'
                    if !options.check? then options.check = /.*/
                    if !options.check instanceof RegExp
                        throw 'Check must be RegExp'
                    if !options.obscured? then options.obscured = false
                    if typeof options.obscured != 'boolean'
                        throw 'Obscured must be a boolean.'
                    @obscured = options.obscured
                    @check = options.check
                    GES.util.data.get @name, options.initial, (data) =>
                        @value = data

`action` will generate a button to execute `options.action`. The action is
asynchronous, so once clicked, the button gets disabled and
`options.waitText` (default 'executing..') is shown until the action
completes.

                when 'action'
                    if !options.action? or typeof options.action != 'function'
                        throw 'Action option requires function to execute.'
                    if !options.waitText? then options.waitText = 'executing..'
                    if typeof options.waitText != 'string'
                        throw 'Wait Text must be string'
                    @waitText = options.waitText
                    @action = options.action

If you prefer to make a tab:

1. Make a template (we use dust.js)
2. Set `Module.tab` to the name of your template
3. Set `Module.tabData` to a function returning the object to pass in
