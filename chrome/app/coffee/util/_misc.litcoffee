A smattering of small utility functions.

    class @GES.util

Quick function to supply a closure around a callback, so extra data may be passed.

        @cb: (callee, obj) -> (data) -> callee data, obj

"Quickpost" standardizes the post mechanism, including error passing to the
notification utility.

        @quickpost: (post_url, text, nonce)->
            $.post post_url,
                message: text
                action_submit: 'submit'
                nonce: nonce,
                (data) ->
                    res = JSON.parse data, @args
                    if res.status
                        window.location = res.url
                    else
                        GES.util.notify res.message, 'error'