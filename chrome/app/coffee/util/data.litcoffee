This is a pretty simple wrapper for data access. As GES expands to other
browsers, this could get adde to.

    class @GES.util.data
        @get: (name, def, cb) ->
            chrome.storage.local.get name, (items)->
                if items[name]?
                    cb items[name]
                cb def
        @set: (name, value) ->
            temp = {}
            temp[name] = value
            chrome.storage.local.set temp