class QuickBump extends Module
    version: '1.0'
    name: 'QuickBump'
    description: 'Make bumping threads with custom text easy.'
    pages: [Pages.Thread]
    run: ->
        this_id = document.URL.match /\/t\.([0-9]+)(_.*?)?\//

        post_url = "";
        if this_id != null
            post_url = "http://www.gaiaonline.com/forum/compose/ajaxentry/new/"+this_id[1]+"/"

        $ ".thread_options"
            .prepend """
                     <a class="cta-button-md quickbump gray-button" href="#">
                       <span class="button_text">QuickBump</span>
                     </a>
                     """

        $ "#qr_submit"
            .before """
                    <a class="info_button" id="savequickbump" href="#" style="float:left;margin:10px 0px 0px 15px;">
                        <span class="button_cap">&nbsp;</span>
                        <span class="button_text">Save as QuickBump</span>
                    </a>
                    """

        $ "#savequickbump"
            .click (e) ->
                e.preventDefault()
                if $("#qr_text").val() != ""
                    GES.util.data.set "quickbumptext", $("#qr_text").val()
                    $("#savequickbump span:last").text "Saved!"
                    setTimeout \
                        -> $("#savequickbump span:last").text("Save as QuickBump"),
                        2000

        $(".quickbump").click (e) ->
            e.preventDefault()
            GES.util.data.get "quickbumptext", "bump", (data) ->
                GES.util.quickpost post_url,
                           data,
                           $("#qr_container input[name='nonce']").val()

new QuickBump()
