Secret Revealer will show white (or light) text in posts and signatures, and
also enlarge small text to make it easier to read.

    class SecretRevealer extends Module
        version: '1.0'
        name: 'Secret Revealer'
        description: 'Shows white/light/small text'
        pages: [Pages.Thread]
        run: ->
            $('.post .content span, .user-sig span').each ->
                $t = $(@)
                c = $t.css 'color'
                cs = /rgb\((\d+), (\d+), (\d+)\)/.exec c

This checks the luma per Rec. 709; basically checking lightness (the
coefficients represent the different effects different colors have on it).

                if c == 'white' or .21*cs[1] + .72*cs[2] + .07*cs[3] >= 230
                    $t.css 'background', 'grey'
                if $t.css('font-size') is '0px'
                    $t.css 'font-size', '10px'
                    $t.css 'background', 'yellow'
    new SecretRevealer()
