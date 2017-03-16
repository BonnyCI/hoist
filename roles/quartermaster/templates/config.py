import logging

# This is a minimal configuration to get you started with the Text mode.
# If you want to connect Errbot to chat services, checkout
# the options in the more complete config-template.py from here:
# https://raw.githubusercontent.com/errbotio/errbot/master/errbot/config-template.py

BACKEND = 'IRC'
# Errbot will start in text mode (console only mode)
# and will answer commands from there.

BOT_DATA_DIR = r'{{ quartermaster_home_dir }}'
BOT_EXTRA_PLUGIN_DIR = '{{ quartermaster_home_dir }}/plugins'

BOT_LOG_FILE = r'{{ quartermaster_log_dir }}/quartermaster.log'
BOT_LOG_LEVEL = logging.DEBUG

BOT_ADMINS = ('{{ secrets.quartermaster.admins }}', )
# !! Don't leave that as "CHANGE ME" if you connect your bot to a chat system!

BOT_IDENTITY = {
    'nickname': '{{ quartermaster_name }}',
    # 'username' : 'err-chatbot',    # opt, defaults to nickname if omitted
    # 'password' : None,             # optional
    'server': 'irc.freenode.net',
    # 'port': 6667,                  # optional
    # 'ssl': False,                  # optional
    # 'ipv6': False,                 # optional
    'nickserv_password': '{{ secrets.quartermaster.nickserv_pass | default('None')}}'

    # Optional: Specify an IP address or hostname (vhost), and a
    # port, to use when making the connection. Leave port at 0
    # if you have no source port preference.
    #    example: 'bind_address': ('my-errbot.io', 0)
    # 'bind_address': ('localhost', 0),
}

CHATROOM_PRESENCE = ('{{ quartermaster_default_channel }}', )

IRC_CHANNEL_RATE = 1
IRC_PRIVATE_RATE = 1

IRC_RECONNECT_ON_DISCONNECT = 5
