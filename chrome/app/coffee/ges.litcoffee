First, we set up the GES object. There will only be one, so
all properties are static. Versioning is similar to semver
(Major.Minor.Patch), with some modifications:

* Major is incremented when there's a significant change
  to the main codebase (i.e., not modules). Unlike semver
  it doesn't necessarily have to be *incompatible*. Example:
  if/when new browser extension builds are added, that will
  increase major version.
* Minor is incremented with new (or significantly changed)
  modules. See below for module versioning details.
* Patch is for bug fixes, in either the main codebase or
  included modules.

This is the same versioning that should be tagged in the repo.

    class @GES # @ so it's global
        @version: '4.0.0a'

When we add a module, we first want to add it to the Modules tab in GES.

        @addModule: (module) ->
            dust.render 'module', module, (err, res) ->
                $('#ges-tabs-modules').append res

Next we check if it has its own tab, and add it if it does.

            ###
            if module.tab?
                dust.render module.tab, module.data, (err, res) ->
                    tabs = $('#ges-tabs')
                    tab = '<li><a href="#ges-tabs-'+module.tab+'">'
                    tab += module.name
                    tab += '</a></li>'
                    tabs.find('.ui-tabs-nav').append tab
                    tabs.append '<div>'+res+'</div>'
                    tabs.tabs 'refresh'
            ###

Finally, we check if (a) the module is enabled, and (b) the current page is one
the module should run on. If so, run it.

            if module.enabled and 
               module.runOn.reduce((prev, cur)-> prev or cur.test document.URL)
                module.run()

Initialization consists of setting up the GES window...

        @init: ->
            dust.render 'ges', version: GES.version, (err, res) ->
                $('body').append res
                $('#ges-tabs').tabs()

... and adding a link to access it.

            link = """
                   <li class="hud-item">
                       <span class="pipe">|</span>
                   </li>
                   <li class="hud-item">
                       <a href="#" id="ges-link">GES</a>
                   </li>
                   """
            $('.hud-account .hud-item-list').append link
            $('#ges-link').on 'click', (e)->
                e.preventDefault()
                $('#ges-box').dialog
                        modal: true
                        resizable: false
                        width: '600px'

    @GES.init()

Include Google CDN jQueryUI theme, to avoid rewriting URLs in embedded CSS.

    $('head').append '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/blitzer/jquery-ui.css">'

Modules might only run on certain kinds of pages. By default, it runs on any
Gaia page, but you can set `Module.runOn` to an array of the pages where it
should be run. `Pages` contains some regular expressions that are intended to
match certain pages' URLs.

    class @Pages
        @All: /.*/
        @Forum: /\/forum\/(.*?\/)?(f\.|list\/)\d+\//
        @Thread: /\/forum\/(.*?\/)+t\.\d+/
        @ThreadReply: /\/forum\/compose\/entry\/new\//
        @NewThread: /\/forum\/compose\/topic\/new\//
        @Marketplace: /\/marketplace\/?$/
        @MarketplaceItem: /\/marketplace\/itemdetail\//
        @UserStore: /\/marketplace\/userstore\//
        @UserStoreBuy: /\/marketplace\/userstore\/\d+\/buy\//
        @Inventory: /\.com\/inventory/

Next we declare a module class. All modules should derive from this. Versioning
here is a bit simpler: Major.Minor

* Major for significant changes (new features, change in how a feature works,
  etc.). This also increments the Minor version number of the whole codebase
  (see above).
* Minor is for bug fixes.

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
        tab: null
        run: ->
            console.log 'attempting to run base module'

Modules can have settings, and those settings can be displayed either on a tab
of its own or, if there's only a few simple options, in the module list itself.
The latter should derive from `ModuleOption`.

    class @ModuleOption
        constructor: (@type, @label, @initial, @check = /.*/, @action, @wait_text) ->
            if @type != 'action' and !@initial?
                throw 'Initial setting required for type '+@type

            if @type == 'action'
                if !@action? or typeof @action != 'function'
                    throw 'Action function required if type is "action"'
                if !@wait_text? or typeof @wait_text != 'string'
                    throw 'Wait text string required if type is "action"'

            if @type == 'text' or @type == 'textbox'
                if typeof @initial != 'string'
                    throw 'Initial setting must be string for type '+@type
                if !@check instanceof RegExp
                    throw 'Check must be a regular expression'
            
            if @type == 'toggle'
                if typeof @initial != 'boolean'
                    throw 'Initial setting must be boolean for type '+@type
                     

If you prefer to make a tab:

1. Make a template (we use dust.js)
2. Set `Module.tab` to the name of your template
3. Set `Module.tabData` to a function returning the object to pass in
