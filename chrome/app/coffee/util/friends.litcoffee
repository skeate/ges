A few modules need to access the friend list, so I made it into a global
utility.

    class GES.util.friends
        @get: (cb) -> GES.util.data.get 'friends', [], cb
        @update: (cb) ->
            GES.util.data.set 'friends', []
            url = "http://www.gaiaonline.com/profile/friendlist.php?start=0"

The lists can be multiple pages, so each one must be processed in turn.

            process = (data, cb) ->
                GES.util.data.get 'friends', [], (list) ->
                    count = /\d+ to \d+ of (\d+)/.exec $('#viewlist',data).text()
                    $('#listdetail .username a', data).each ->
                        list.push $(@).attr 'title'
                    if list.length < count[1]
                        GES.util.data.set 'friends', list
                        url = "http://www.gaiaonline.com/profile/friendlist.php?start=" + list.length
                        $.get url, GES.util.cb cb, process
                    else
                        GES.util.data.set 'friends', list
                        cb()
            $.get url, GES.util.cb cb, process
        @render: ->
            GES.util.friends.get (friends) ->
                dust.render 'friends',
                    friends: friends
                    (err, res) ->
                        $('#ges-tabs-friends').html res
                        $('#ges-tabs-friends button').on 'click', ->
                            $(@).prop 'disabled', true
                            GES.util.friends.update =>
                                $(@).prop 'disabled', false
                                GES.util.friends.render()

Now render the list to the Friends tab.

    GES.util.friends.render()
