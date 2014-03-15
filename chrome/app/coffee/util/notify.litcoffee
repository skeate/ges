This supplies some basic notifications. First, we need to set up a container
for them.

    $('body').append '<div id="ges-notifications"></div>'

Then we set up a GES.util to provide access. There's a queue, so multiple
notifications can be displayed at the same time.

    class @GES.util.notify
        constructor: (msg, type = 'warning') ->
            if type == 'warning'
                notify.enqueue $('<div>').writeAlert msg
            else
                notify.enqueue $('<div>').writeError msg
        @queue: []
        @timer: 5000
        @enqueue: (div) ->
            $div = $ div
            $notif = $ '#ges-notifications'
            @queue.push div
            $notif.append div
            $div.fadeIn 'fast'
            $notif.height $notif.height() + $div.height() + 10
            setTimeout @dequeue, @timer, @
        @dequeue: (ctx) ->
            $(ctx.queue.shift(),).fadeOut ->
                $notif = $ '#ges-notifications'
                $notif.height $notif.height() - $(@).height() - 10
                $(@).remove()

Not strictly GES-specific: a jquery-ui extension to make alerts a bit nicer.

    jQuery.fn.writeError = (message) ->
        @each ->
            $(@).html """
                      <div class="ui-widget">
                        <div class="ui-state-error ui-corner-all ges-notif-div">
                          <p>
                            <span class="ui-icon ui-icon-alert ges-notif-span"></span>
                            #{ message }
                          </p>
                        </div>
                      </div>
                      """
    jQuery.fn.writeAlert = (message) ->
        @each ->
            $(@).html """
                      <div class="ui-widget">
                        <div class="ui-state-highlight ui-corner-all ges-notif-div">
                          <p>
                            <span class="ui-icon ui-icon-info ges-notif-span"></span>
                            #{ message }
                          </p>
                        </div>
                      </div>
                      """
