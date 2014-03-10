The Thread Filter allows users to filter out threads. Who would've guessed.

    class ThreadFilter extends Module
        version: '1.0'
        name: 'Thread Filter'
        description: "Hides threads with keywords in the title or more than a
                      certain number of replies."
        pages: [Pages.Forum]
        options: [
            new ModuleOption 'forums',
                type: 'text'
                label: 'Forums to filter (blank=all)'
                initial: '23'
                check: /^(\d+, ?)*(\d+)?$/
            new ModuleOption 'limit',
                type: 'text'
                label: 'Reply display limit (0=disable)'
                initial: '0'
                check: /^\d+$/
            new ModuleOption 'allcaps',
                type: 'toggle'
                label: 'Filter threads in ALL CAPS'
                initial: false
            new ModuleOption 'advanced',
                type: 'toggle'
                label: 'Advanced Mode'
                initial: false
            new ModuleOption 'list',
                type: 'textbox'
                label: 'Title filters (one per line)'
                initial: ''
            ]
        run: ->
            forums = @option('forums').value.split ', '
            filters = @option('list').value.split '\n'
            limit = @option('limit').value
            advanced = @option('advanced').enabled
            allcaps = @option('allcaps').enabled

            forumid = document.URL.match(/(\/f\.|list\/)(\d+)(_.*?)?\//)[2]
            if forums.length == 0 or -1 != forums.indexOf forumid
                filters = filters
                    .filter (x) -> x != ''
                    .map (x) =>
                        if advanced
                            new RegExp x, 'i'
                        else
                            new RegExp "\\b#{x}\\b", 'i'
                if allcaps
                    filters.push /^[^a-z]*$/
                if limit != '0'
                    $rep = $ '.forum-list .replies'
                    $rep.filter ->
                            parseInt($(@).text()) > parseInt limit
                        .parent()
                        .remove()
                $ '.forum-list td.title div > a:not(.goto-new-posts)'
                    .each ->
                        for filter in filters
                            if filter.test $(@).text()
                                $(@).parents('tr:first').remove()
                $('.forum-list tbody tr').removeClass()
                $('.forum-list tbody tr:even').addClass 'rowon'
                $('.forum-list tbody tr:odd').addClass 'rowoff'
    new ThreadFilter()
