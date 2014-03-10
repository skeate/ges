Better Ignore's original purpose was to fix some oversights on how ignored
users were handled. Mainly, you could still see their threads in the forum
listing. This has since been fixed, but Better Ignore is still useful for some
things:

* You can "half-ignore" users. Essentially, hide their threads in the forum but
  still see their regular posts.
* Ignoring users is much faster. If you ignore a user, a dialog pops up to
  confirm, and if you click OK it ignores them in the background. No need to
  navigate to separate pages.

It will also hide any trace evidence, such as the "Topics Blocked" at the
bottom of the forum.

    class BetterIgnore extends Module
        version: '2.0'
        name: 'Better Ignore'
        description: 'Improves ignore functionality'
        pages: [Pages.Forum, Pages.Thread]
        tab: 'BetterIgnore'
        loadTabData: (cb) ->
            GES.util.data.get 'ignored', [], (@ignored) =>
                cb ignored: @ignored
        onTabLoad: ->
            $bi = $('#ges-better-ignore')
            $bi.find('a').on 'click', (e) =>
                $e = $ e.target
                user = $e.parent().children('span').text()
                @ignored.splice @ignored.indexOf(user), 1
                GES.util.data.set 'ignored', @ignored
                $e.parent().remove()
            $bi.find('button').on 'click', (e) =>
                user = e.target.parentElement.children[0].value
                @ignored.push user
                GES.util.data.set 'ignored', @ignored
                dust.render @tab, ignored: @ignored, (err, res) =>
                    $bi.replaceWith res
                    @onTabLoad()
        run: ->
            GES.util.data.get 'ignored', [], (@ignored) =>

First, remove the half-ignored from the forum listing.

                $('.forum-list .creator a').each ->
                    if -1 != $.inArray $(@).text(), @ignored
                        $ @
                          .parents 'tr'
                          .remove()

Also remove the "Topics Blocked" addition

                $('.forum-list td.notice').parent().remove()

Since we've (potentially) removed some rows, we ought to redo the row striping.

                $(".forum-list tbody tr").removeClass()
                $(".forum-list tbody tr:even").addClass "rowon"
                $(".forum-list tbody tr:odd").addClass "rowoff"

Next, add the fast ignore feature.

            uid = ''
            $('body').on 'mousedown', '#avatar_menu #ignore a', (e) =>
                uid = e.target.href.match(/hook=(\d+)&/)[1]
                e.target.href = "javascript:"
            $('body').on 'mouseup', '#avatar_menu #ignore a', (e) =>
                box = $ """
                        <div>
                            Are you sure you want to ignore this user?
                        </div>
                        """
                $(box).dialog
                    modal: true
                    resizable: false
                    title: "Ignore User"
                    buttons:
                        "Yes": ->
                            args =
                                "user_ids[]": uid
                                action: "Add Ignored"
                            $.post '/friends/', args, (data)=>
                                $(@).html('<div>User ignored</div>')
                                    .dialog
                                        title: "Success"
                                        buttons:
                                            OK: ->
                                                $(@).dialog 'close'
                            $(@).html('<div>')
                                .spin()
                                .dialog
                                    title: "Ignoring..."
                                    buttons: {}
                        "No": ->
                            $(@).dialog 'close'

    new BetterIgnore()
