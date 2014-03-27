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
        @version: '4.0.1-beta'

GES.runOnPage takes a list of pages (defined below), and checks if a module
should run on the current page.

        @runOnPage: (pages) ->
            pages.reduce (p,c) ->
                p or c.test document.URL
            , false

When we add a module, we first want to add it to the Modules tab in GES.

        @modules: {}
        @addModule: (module) ->
            @modules[module.name] = module
            dust.render 'module', module, (err, res) ->

Load order can be random, but I'd like the list to be consistent, so
alphabetize.

                $modNames = $ '#ges-tabs-modules .ges-module h3'
                $modNames.each ->
                    if $(@).text() > module.name
                        $(@).parent().before res
                # if it wasn't added (can happen if it belongs at end of list
                # or list was empty)
                if $('.ges-module').length == $modNames.length
                    $('#ges-tabs-modules').append res

Next we check if it has its own tab, and add it if it does.

            if module.tab?
                module.loadTabData (tabData) ->
                    dust.render module.tab, tabData, (err, res) ->
                        tabs = $('#ges-tabs')
                        tab = '<li><a href="#ges-tabs-'+module.tab+'">'
                        tab += module.name
                        tab += '</a></li>'
                        tabs.find('.ui-tabs-nav').append tab
                        tab = '<div id="ges-tabs-'+module.tab+'">'
                        tab += (err or res)
                        tab += '</div>'
                        tabs.append tab
                        tabs.tabs 'refresh'
                    module.onTabLoad()

Finally, we check if (a) the module is enabled, and (b) the current page is one
the module should run on. If so, run it.

            if module.enabled and @runOnPage module.pages
                module.run()

Initialization consists of setting up the GES window...

        @init: ->
            dust.render 'ges', version: GES.version, (err, res) ->
                $('body').append res
                $('#ges-tabs').tabs()

... and adding a link to access it.

            link = """
                   <li class="hud-item-new">
                       <a href="#" id="ges-link" class="hud-item-value-new">
                           <span>GES</span>
                       </a>
                   </li>
                   """
            $('.hud-stats .hud-item-list-new').append link
            $('#ges-link').on 'click', (e)->
                e.preventDefault()
                $('#ges-box').dialog
                        modal: true
                        resizable: false
                        width: '600px'
                        dialogClass: 'ges-main'

    @GES.init()

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

Since we're generating the list of modules in this file, it seems fair to
include the controller code for the module list here as well.

    $gtm = $('#ges-tabs-modules')
    $gtm.on 'click', '.ges-module > .controls > button', ->
        $(@).parent().siblings('.options').slideToggle()

    $gtm.on 'change', '.ges-module > .controls > label > input', ->
        GES.modules[@name].enable(@checked)
        $(@).parents('.ges-module').toggleClass('enabled',@checked)

    $gtm.on 'click', '.ges-module > .options > .action > button', ->
        m = $(@).parents('.ges-module').find('.controls input').attr('name')
        opt_name = $(@).parents('.option').attr 'data-name'
        option = GES.modules[m].option(opt_name)
        $(@).prop 'disabled', true
        option.action ->
            $(@).prop 'disabled', false
            $(@).text option.label

    $gtm.on 'change', '.ges-module > .options > .text > input', ->
        m = $(@).parents('.ges-module').find('.controls input').attr('name')
        opt_name = $(@).parents('.option').attr 'data-name'
        option = GES.modules[m].option(opt_name)
        if option.check.test $(@).val()
            GES.util.data.set option.name, $(@).val()
        else
            GES.util.notify 'Invalid input.'
            $(@).focus()

    $gtm.on 'change', '.ges-module > .options > .toggle input', ->
        m = $(@).parents('.ges-module').find('.controls input').attr('name')
        opt_name = $(@).parents('.option').attr 'data-name'
        option = GES.modules[m].option(opt_name)
        GES.util.data.set option.name, $(@).prop 'checked'

    $gtm.on 'change', '.ges-module > .options > .textbox > textarea', ->
        m = $(@).parents('.ges-module').find('.controls input').attr('name')
        opt_name = $(@).parents('.option').attr 'data-name'
        option = GES.modules[m].option(opt_name)
        GES.util.data.set option.name, $(@).val()
