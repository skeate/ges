QuickQuote quotes quickly.

    class QuickQuote extends Module
        version: '1.0'
        name: 'QuickQuote'
        description: 'Enables a Quick Reply-like drop box for quoting.'
        pages: [ Pages.Thread ]
        run: ->
            postID = document.URL.match /\/t\.(\d+)(_.*?)?\//
            if postID?
                postURL = "http://www.gaiaonline.com/forum/compose/ajaxentry/new/#{postID[1]}/"
                $('.post-options > ul li:first-child').each ->
                    $t = $(@)
                    $t.children 'a'
                        .removeClass 'cta-button-sm'
                        .addClass 'cta-dropdown-sm-label'
                    href = $t.children('a:first').attr 'href'
                    $t.append "<a href=\"#{href}\" " +
                        "class=\"cta-dropdown-sm-arrow\" " +
                        "title=\"Quick Quote this post\"></a>"
                    $t.children('.cta-dropdown-sm-arrow').on 'click', (e)->
                        e.preventDefault()
                        if $(e.target).parent().children('.qq-box').length
                            $ e.target
                                .parent()
                                .children '.qq-box'
                                .toggle()
                        else
                            p = $(e.target).parent()
                            t = $(e.target).height()
                            p.css 'position', 'relative'
                            p.append '<div class="qq-box">'
                            p.find('.qq-box').spin()
                            $ ".qq-box", p
                                .css top: t+"px"
                                .click (e) ->
                                    e.stopImmediatePropagation()
                            $.get $(e.target).attr('href'), GES.util.cb p, (data, context) ->
                                if $("#captcha", data).children().length
                                    $(".qq-box", context).html "Sorry, you've been captcha'd.  You will need to slow-quote."
                                    $(".qq-box", context).append "<br/><button>Close</button>"
                                    $("button", context).click ->
                                        $(".qq-box", context).remove()
                                else
                                    quoted = $ "#message", data
                                        .val()
                                        .match /quote="([^"]+)"/
                                    dust.render 'QuickQuote', quoting: quoted[1], (err, res) ->
                                        $ ".qq-box", context
                                            .html res
                                        if quoted[1] is not $(context).parents('.post').find('.user_name').text()
                                            $ ".qq-quoting", context
                                                .css "color", "red"
                                        $ ".qq-close", context
                                            .click (e) ->
                                                e.preventDefault()
                                                $(e.target).parent().parent().css "display", "none"
                                        $ ".qq-submit", context
                                            .click GES.util.cb data, (f, t) ->
                                                f.preventDefault()
                                                GES.util.events.fire "post",
                                                    text: $(f.target).parents("div").find(".qq-text")
                                                GES.util.quickpost postURL,
                                                                   $("#message", t).val() + $(f.target).parents("div").find(".qq-text").val(),
                                                                   $("#compose_entry input[name='nonce']", t).val()
    new QuickQuote()
