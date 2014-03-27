class ThreadHighlighter extends Module
    version: '1.0'
    name: 'Thread Highlighter'
    description: 'Highlights threads meeting certain criteria'
    options: [
        new ModuleOption "highlight-limit-color",
            type: 'text'
            label: 'Limit highlight color (e.g., #FFD700)'
            check: /^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$/
            initial: "#FFD700"
        new ModuleOption "highlight-limit",
            type: "text"
            label: "Highlight threads with fewer posts than (0 = disabled)"
            check: /^[0-9]+$/
            initial: "0"
        new ModuleOption "highlight-friend-color",
            type: "text"
            label: "Friend highlight color (e.g., #78D0CC)"
            check: /^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$/
            initial: "#78D0CC"
        new ModuleOption "highlight-friends",
            type: "toggle"
            label: "Highlight friends' threads"
            initial: false
        new ModuleOption "highlight-self-color",
            type: "text"
            label: "Self highlight color (e.g., #C5B8F5)"
            check: /^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$/
            initial: "#C5B8F5"
        new ModuleOption "highlight-self",
            type: "toggle"
            label: "Highlight own threads"
            initial: false
    ]
    pages: [Pages.Forum]
    run: ->
        color = @option('highlight-limit-color').value
        limit = @option('highlight-limit').value
        fcolor = @option('highlight-friend-color').value
        friends = @option('highlight-friends').enabled
        scolor = @option('highlight-self-color').value
        self = @option('highlight-self').enabled
        $ '.forum-list .replies'
            .filter ->
                parseInt($(@).text()) < parseInt(limit)
            .parent()
            .css 'background', color
        threadCreatorList = $ '.forum-list .creator a'
        if self
            s = $ '.avatarName span'
            if s.length
                username = s.text()
                username = username.substr 0, username.length-1
            else
                username = $('.avatarName select option[selected]').text()
            threadCreatorList.each ->
                if $(@).text() == username
                    $(@).closest('tr').css 'background', scolor
        if friends
            GES.util.friends.get (friendlist) ->
                threadCreatorList.each ->
                    if -1 != $.inArray $(@).text(), friendlist
                        $(@).closest('tr').css 'background', fcolor
new ThreadHighlighter()
