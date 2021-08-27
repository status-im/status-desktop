var PROFILE = 0
var CONTACTS = 1
var ENS = 2
var PRIVACY_AND_SECURITY = 3
var APPEARANCE = 4
var SOUND = 5
var LANGUAGE = 6
var NOTIFICATIONS = 7
var SYNC_SETTINGS = 8
var DEVICES_SETTINGS = 9
var BROWSER_SETTINGS = 10
var ADVANCED = 11
var NEED_HELP = 12
var ABOUT = 13
var SIGNOUT = 14

var mainMenuButtons = [{
                       "id": PROFILE,
                       "text": qsTr("My Profile"),
                       "icon": "profile"
                   }, {
                       "id": CONTACTS,
                       "text": qsTr("Contacts"),
                       "icon": "contact"
                   }, {
                       "id": ENS,
                       "text": qsTr("ENS usernames"),
                       "icon": "username"
                   }]

var settingsMenuButtons = [{
                       "id": PRIVACY_AND_SECURITY,
                       "text": qsTr("Privacy and security"),
                       "icon": "security"
                   }, {
                       "id": APPEARANCE,
                       "text": qsTr("Appearance"),
                       "icon": "appearance"
                   }, {
                       "id": SOUND,
                       "text": qsTr("Sound"),
                       "icon": "sound"
                   }, {
                       "id": LANGUAGE,
                       "text": qsTr("Language"),
                       "icon": "language"
                   }, {
                       "id": NOTIFICATIONS,
                       "text": qsTr("Notifications"),
                       "icon": "notification"
                   }, {
                       "id": SYNC_SETTINGS,
                       "text": qsTr("Sync settings"),
                       "icon": "mobile"
                   }, {
                       "id": DEVICES_SETTINGS,
                       "text": qsTr("Devices settings"),
                       "icon": "mobile"
                   },  {
                        "id": BROWSER_SETTINGS,
                        "text": qsTr("Browser settings"),
                        "icon": "browser",
                        "ifEnabled": "browser"
                    }, {
                       "id": ADVANCED,
                       "text": qsTr("Advanced"),
                       "icon": "settings"
                   }]

var extraMenuButtons = [{
                       "id": NEED_HELP,
                       "text": qsTr("Need help?"),
                       "icon": "help"
                   }, {
                       "id": ABOUT,
                       "text": qsTr("About"),
                       "icon": "info"
                   }, {
                       "id": SIGNOUT,
                       "function": "exit",
                       "text": qsTr("Sign out & Quit"),
                       "icon": "logout"
                   }]
