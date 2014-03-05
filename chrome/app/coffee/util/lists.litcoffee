A few modules need to access either the friend or the ignored list, so I made
it into a global utility.

    class GES.util.lists
        @friends: -> GES.util.data.get 'friends', []
        @ignored: -> GES.util.data.get 'ignored', []
        @update: (type, cb) ->
            GES.util.data.set 'friends', []
            GES.util.data.set 'friends_page', 1
            url = "http://www.gaiaonline.com/profile/friendlist.php?start=0"
            if type == 'ignored'
                url += '&list=ignored'

The lists can be multiple pages, so each one must be processed in turn.

            process = (data, obj) ->
                type = obj.type
                cb = obj.cb
                list = GES.util.data.get type, []
                count = /\d+ to \d+ of (\d+)/.exec $('#viewlist',data).text()

                $('#listdetail .username a', data).each ->
                    list.push $(@).attr 'title'

                if list.length < count
                    GES.util.data.set type, list
                    url = "http://www.gaiaonline.com/profile/friendlist.php?start=" + list.length
                    if type == 'ignored'
                        url += '&list=ignored'
                    $.get url, GES.util.cb process, type: type, cb: cb
                else
                    GES.util.data.set type, list
                    cb()
            $.get url, GES.util.cb process, type: type, cb: cb
