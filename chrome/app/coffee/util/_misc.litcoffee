A smattering of small utility functions.

    class @GES.util

Quick function to supply a closure around a callback, so extra data may be passed.

        @cb: (obj, callee) -> (data) -> callee data, obj

"Quickpost" standardizes the post mechanism, including error passing to the
notification utility.

        @quickpost: (post_url, text, nonce)->
            $.post post_url,
                message: text
                action_submit: 'submit'
                nonce: nonce,
                (data) ->
                    if data.status
                        window.location = data.url
                    else
                        GES.util.notify data.message, 'error'
