The Account Switcher module make switching accounts easy; it replaces  ur
username with a dropbox of choices.

    class AccountSwitcher extends Module
        version: '1.0'
        name: 'Account Switcher'
        description: 'Switch accounts quickly.'
        tab: 'account_switcher'
        run: ->
            console.log 'attempting to run account switcher'

Finally, create an instance.

    new AccountSwitcher()