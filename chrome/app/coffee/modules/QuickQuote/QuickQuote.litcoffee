QuickQuote quotes quickly.

    class QuickQuote extends Module
        version: '1.0'
        name: 'QuickQuote'
        description: 'Enables a Quick Reply-like drop box for quoting.'
        pages: Pages.Thread
        run: ->
            postID = document.URL.match /\/t\.(\d+)(_.*?)?\//
            if postID?
                postURL = "http://www.gaiaonline.com/forum/compose" +
                           "/ajaxentry/new/#{postID[1]}/"
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
                        if $(e.target).parent().children('.qq-box').length == 0
                            p = $(e.target).parent()
                            t = $(e.target).height()
                            p.css 'position', 'relative'
                            p.append """
                                     <div class="qq-box">
                                         <img src="http://s.cdn.gaiaonline.com/images/loader.gif">
                                     </div>
                                     """
                            $ ".qq-box", p
                                .css
                                    position: "absolute"
                                    top: t+"px"
                                    left: "0"
                                    width: "321px"
                                    height: "211px"
                                    padding: "10px"
                                    background: "white"
                                    border: "1px solid #98aeb7"
                                    zIndex: "192"
                                .click (e) ->
                                    e.stopImmediatePropagation()
                            $.get $(e.target).attr('href'), GES.util.cb p, (data, context) ->
                                if $("#captcha", data).children().length is 0
                                    quoted = $ "#message", data
                                        .val()
                                        .match /quote="([^"]+)"/
                                    $ ".qq-box", context
                                        .css
                                            background: "#CDD9DD url(http://s.cdn.gaiaonline.com/images/forum/quick_reply_bg.png) no-repeat"
                                        .html """
                                              <h2>Quick Quote</h2>
                                              <span class="qq-close-span">
                                                  &nbsp;
                                                  <span class="qq-quoting">
                                                      (Quoting #{quoted[1]})
                                                  </span>
                                                  <a href="#" class="qq-close"></a>
                                              </span>
                                              <textarea class="qq-text" tabindex="4"></textarea>
                                              <a href="#" class="qq-submit cta-button-sm" tabindex="5">
                                                  <span>Submit</span>
                                              </a>
                                              """
                                    if quoted[1] is not $(context).parents('.post').find('.user_name').text()
                                        $ ".qq-quoting", context
                                            .css "color", "red"

                                    $ ".qq-close", context
                                        .css
                                            cssFloat: "right"
                                            width: "14px"
                                            height: "14px"
                                            marginTop: "3px"
                                            background: "url(http://s.cdn.gaiaonline.com/images/forum/quick_reply_closeButton.png) no-repeat"

                                    $ "h2", context
                                        .css
                                            cssFloat: "left"
                                            marginTop: "0px"

                                    $ ".qq-close", context
                                        .click (e) ->
                                            e.preventDefault()
                                            $(e.target).parent().parent().css "display", "none"

                                    $ ".qq-text", context
                                        .css
                                            width: "320px"
                                            height: "150px"

                                    $ ".qq-submit", context
                                        .css
                                            cssFloat: "right"
                                            marginTop: "7px"

                                    $ ".qq-submit", context
                                        .click GES.util.cb data, (f, t) ->
                                            f.preventDefault()
                                            GES.util.events.fire "post",
                                                text: $(f.target).parents("div").find(".qq-text")
                                            GES.util.quickpost postURL,
                                                               $("#message", t).val() + $(f.target).parents("div").find(".qq-text").val(),
                                                               $("#compose_entry input[name='nonce']", t).val()
                                else
                                    $(".qq-box", context).html "Sorry, you've been captcha'd.  You will need to slow-quote."
                                    $(".qq-box", context).append "<br/><button>Close</button>"
                                    $("button", context).click ->
                                        $(".qq-box", context).remove()
                        else
                            $ e.target
                                .parent()
                                .children '.qq-box'
                                .toggle()
    new QuickQuote()
