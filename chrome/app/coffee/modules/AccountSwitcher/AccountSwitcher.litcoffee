The Account Switcher module make switching accounts easy; it replaces your
username with a dropbox of choices.

    class AccountSwitcher extends Module
        version: '1.0'
        name: 'Account Switcher'
        description: 'Switch accounts quickly.'
        tab: 'AccountSwitcher'
        loadTabData: (cb) ->
            GES.util.data.get 'accounts', {}, (@accounts) =>
                list = []
                for user, pass of @accounts
                    list.push user: user, pass: pass
                cb accounts: list
        onTabLoad: ->
            $as = $('#ges-account-switcher')
            # Delete button clicked
            $as.find('table tr button').on 'click', (e) =>
                $btn = $(e.target)
                name = $btn.parent().siblings(':first').text()
                delete @accounts[name]
                GES.util.data.set 'accounts', @accounts
                $btn.parent().parent().remove()
            # Password edited
            $as.find('table tr input').on 'change', (e) =>
                $pwd = $(e.target)
                name = $pwd.parent().siblings(':first').text()
                @accounts[name] = $pwd.val()
                GES.util.data.set 'accounts', @accounts
            # Account added
            $as.find('button.add').on 'click', =>
                name = $as.find('div input:text').val()
                pass = $as.find('div input:password').val()
                @accounts[name] = pass
                GES.util.data.set 'accounts', @accounts
                list = []
                for user, pass of @accounts
                    list.push user: user, pass: pass
                # Easier to just rerender panel rather than add in table row
                # manually. call @onTabLoad to re-register events.
                dust.render @tab, accounts: list, (err, res) =>
                    $as.replaceWith res
                    @onTabLoad()
        run: ->
            GES.util.data.get 'accounts', {}, (@accounts) =>
                $hudname = $('.avatarName span')
                signedIn = $hudname.text()
                $hudname.replaceWith '<select>'
                $hudlist = $('.avatarName select')
                for name, pw of @accounts
                    selected = if name+'!' == signedIn then ' selected' else ''
                    opt = "<option value=\"#{name}\""+selected+">#{name}</option>"
                    $hudlist.append opt
                $hudlist.css 'font-size', '8pt'
                $hudlist.on 'change', ->
                    oldloc = window.location
                    logout = $('.hud-item a[href*="/auth/logout"]').attr "href"
                    newLogin = $(@).val()
                    $.get logout, (data) ->
                        $mlf = $ '#memberloginForm', data
                        token = $mlf.children('input:hidden[name="token"]').val()
                        args = 
                            token: token
                            sid: $mlf.children('input:hidden[name="sid"]').val()
                            username: newLogin
                            password: ''
                            autologin: 'on'
                            signInButton: 'Log In'
                            chap: md5(md5(accounts[newLogin])+token)
                        $mlf.children('a').each ->
                            args[@name] = $mlf.children('input:hidden[name="'+@name+'"]').val()
                        $.post '/auth/login/', args, ->
                            window.location = oldloc
    new AccountSwitcher()
