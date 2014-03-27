class Queuer extends Module
    version: '1.0'
    name: 'Queuer'
    description: 'Queues posts/pms to submit after cooldown expires.'
    tab: 'Queuer'
    loadTabData: (cb) ->
        GES.util.data.get 'queues', posts: [], pms: [], cb
    onTabLoad: ->
        $('#ges-tabs-Queuer button.force').on 'click', ->
            #force post submission
        $('#ges-tabs-Queuer button.move-up').on 'click', ->
            # move up in queue
        $('#ges-tabs-Queuer button.move-down').on 'click', ->
            # move down in queue
    run: ->
        setInterval =>
            @loadTabData (queues) ->
                if queues.posts.length
                    a = 1
                    # try to post
                if queues.pms.length
                    # try to pm
                    a = 2
        , 1000

        $ 'body'
            .on 'submit', '#compose_entry', (e) ->
                e.preventDefault()
                debugger
        #watch for PMs / post submissions
        #hijack submission
        #if ok, just go to the page it would go to
        #if error, append to queue
new Queuer()
