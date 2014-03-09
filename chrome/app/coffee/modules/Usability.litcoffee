Usability supplies some small tweaks that make navigating the site a little bit
easier.

    class Usability extends Module
        version: '2.0'
        name: 'Usability Tweaks'
        description: 'Fixes miscellaneous poor design issues around the site.'
        options: [
            new ModuleOption 'shiftpms',
                type: 'toggle'
                label: 'Shift-Click PMs'
                initial: true,
            #new ModuleOption 'captchaidx',
            #    type: 'toggle'
            #    label: 'Fix Captcha tab index'
            #    initial: true,
            new ModuleOption 'stopDynamicPages',
                type: 'toggle'
                label: 'Prevent dynamic thread page loading'
                initial: true
        ]
        run: ->
            if @option('shiftpms')?.enabled
                lastSelected = null
                # wut @ selector
                checks = $('#pm_content table table table tr:gt(0) :checkbox')
                checks.each ->
                    $(@).click (ev) ->
                        if ev.shiftKey
                            last = checks.index lastSelected
                            first = checks.index @
                            start = Math.min first, last
                            end = Math.max first, last
                            checks.slice(start, end).attr 'checked', 'checked'
                        else
                            lastSelected = @
            if @option('captchaidx')?.enabled
                console.log 'usability tweak needs reworking'
            if @option('stopDynamicPages')?.enabled
                $('.forum_detail_pagination a').click (e)->
                    e.stopImmediatePropagation()

    new Usability()
