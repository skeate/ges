The Account Switcher module make switching accounts easy; it replaces your
username with a dropbox of choices.

    class AccountSwitcher extends Module
        version: '1.0'
        name: 'Account Switcher'
        description: 'Switch accounts quickly.'
        tab: 'accountSwitcher'
        loadTabData: (cb) ->
            GES.util.data.get 'accounts', {}, (accounts)->
                cb accounts
        run: ->


Finally, create an instance.

    new AccountSwitcher()
