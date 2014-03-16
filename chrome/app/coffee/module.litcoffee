Next we declare a module class. All modules should derive from this. Versioning
here is a bit simpler: Major.Minor

* Major for significant changes (new features, change in how a feature works,
  etc.). This also increments the Minor version number of the whole codebase
  (see above).
* Minor is for bug fixes.

We've also got a default constructor that loads data and adds itself to GES.

    class @Module
        constructor: ->
            GES.util.data.get @name, false, (data) =>
                @enabled = data
                GES.addModule @
        version: '1.0'
        name: 'Uninitialized module'
        description: 'Uninitialized module'
        pages: [Pages.All]

Module options show up in the main module list. There are a few types
available; see below for details.

        options: []

Getter function. Be sure to use ?, since if the option isn't set (for whatever
reason), this will return `null`.

        option: (name) ->
            opt = @options.filter (o) -> o.name == name
            if opt.length > 0 then opt[0] else null

If you prefer to make a tab:

1. Make a template (we use dust.js)
2. Set `Module.tab` to the name of your template
3. Set `Module.loadTabData` to a function, taking a callback, that loads data
   and passes it into the callback.
4. Set `Module.onTabLoad` to a function that runs after the tab is loaded.
   Use it for controller code.

Tabs should be used for more complex settings.

        tab: null
        loadTabData: (cb) -> cb({})
        onTabLoad: ->
        enable: (d) ->
            @enabled = d
            GES.util.data.set @name, d
            if d and GES.runOnPage(@pages) then @run()
        run: ->
            console.log 'attempting to run base module'

Elements in `Module.options` should derive from `ModuleOption`.

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

`textbox` produces a text area (perhaps this name should be changed). 

                when 'textbox'
                    if !options.initial? then options.initial = ''
                    if typeof options.initial != 'string'
                        throw 'Default setting for textbox must be a string'
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
