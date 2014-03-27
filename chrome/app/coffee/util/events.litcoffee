This adds an event infrastructure to GES. This is essentially just the original
version (from v3); probably could use an update. Could likely find an existing
library to do this, even.

    class @GES.util.events
        @listeners: {}
        @fire: (evt, data) ->
            console.log 'firing '+evt+' with '+data
            if @listeners[evt] instanceof Array
                $.each @listeners[evt], (k,v) ->
                    v(data)
        @addListener: (evt, listener) ->
            if typeof evt == 'string'
                if !@listeners[evt]?
                    @listeners[evt] = []
                @listeners[evt].push listener
        @removeListener: (evt, listener) ->
            if @listeners[evt] instanceof Array
                listeners = @listeners[evt]
                for i in [0..listeners.length-1] by 1
                    if listeners[i] == listener
                        listeners.splice i, 1
                        return

Also set up some events: posting from the main post form

    $('body').on 'submit', '#compose_entry', ->
        GES.util.events.fire 'post',
            text: $('#message')

and posting from Quick Reply

    $('body').on 'click', '#qr_submit', ->
        GES.util.events.fire 'post',
            text: $('#qr_text')
