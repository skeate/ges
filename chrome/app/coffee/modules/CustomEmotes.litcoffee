Custom Emotes allows the user to easily post pictures repeatedly.

    class CustomEmotes extends Module
        version: '1.0'
        name: 'Custom Emotes'
        description: 'Configure your own emoticons, usable with :keyword:'
        pages: [Pages.Thread, Pages.ThreadReply, Pages.NewThread]
        options: [
            new ModuleOption 'list',
                type: 'textbox'
                label: 'Emoticon list. One per line, format: keyword url'
                initial: ''
            ]
        run: ->
            emotes = @option('list').value.split '\n'
            if emotes
                replaceEmotes = (text) ->
                    for emote in emotes
                        [keyword, url] = emote.split ' '
                        text = text.replace new RegExp(":#{keyword}:", 'gi'),
                            "[img]#{url}[/img]"
                    return text

                GES.util.events.addListener 'post', (data) ->
                    $ data.text
                        .val replaceEmotes $(data.text).val()

                emoticonSet = $ '#emoticon_set'
                emoticonSet.append '<option value="Custom">Custom</option>'
                emoticonSet.on 'change', ->
                    if $(@).val() == 'Custom'
                        for emote in emotes
                            [keyword, url] = emote.split ' '
                            temp = $ '<a href="#">:'+keyword+':</a>'
                            temp.data 'url', url
                            temp.on 'click', ->
                                message = $ '#message'
                                message.val message.val() + $(@).text()
                            img = []
                            temp.on 'mouseenter', (e)->
                                img = $ '<img src="'+$(@).data('url')+'">'
                                img.css
                                    position: 'absolute'
                                    top: e.pageY
                                    left: e.pageX
                                    pointerEvents: 'none'
                                img.appendTo 'body'
                            temp.on 'mouseleave', ->
                                img.remove()
                            $ 'ul#emoticons'
                                .append temp
                                .append ' '

    new CustomEmotes()
