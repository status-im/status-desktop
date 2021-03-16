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
                       "filename": "myProfile.svg"
                   }, {
                       "id": CONTACTS,
                       "text": qsTr("Contacts"),
                       "filename": "contacts.svg"
                   }, {
                       "id": ENS,
                       "text": qsTr("ENS usernames"),
                       "filename": "ensUsernames.svg"
                   }]

var settingsMenuButtons = [{
                       "id": PRIVACY_AND_SECURITY,
                       "text": qsTr("Privacy and security"),
                       "filename": "security.svg"
                   }, {
                       "id": APPEARANCE,
                       "text": qsTr("Appearance"),
                       "filename": "appearance.svg"
                   }, {
                       "id": SOUND,
                       "text": qsTr("Sound"),
                       "filename": "sound.svg"
                   }, {
                       "id": LANGUAGE,
                       "text": qsTr("Language"),
                       "filename": "globe.svg"
                   }, {
                       "id": NOTIFICATIONS,
                       "text": qsTr("Notifications"),
                       "filename": "notifications.svg"
                   }, {
                       "id": SYNC_SETTINGS,
                       "text": qsTr("Sync settings"),
                       "filename": "sync.svg"
                   }, {
                       "id": DEVICES_SETTINGS,
                       "text": qsTr("Devices settings"),
                       "filename": "sync.svg"
                   },  {
                        "id": BROWSER_SETTINGS,
                        "text": qsTr("Browser settings"),
                        "filename": "../compassActive.svg"
                    }, {
                       "id": ADVANCED,
                       "text": qsTr("Advanced"),
                       "filename": "advanced.svg"
                   }]

var extraMenuButtons = [{
                       "id": NEED_HELP,
                       "text": qsTr("Need help?"),
                       "filename": "help.svg"
                   }, {
                       "id": ABOUT,
                       "text": qsTr("About"),
                       "filename": "about.svg"
                   }, {
                       "id": SIGNOUT,
                       "function": "exit",
                       "text": qsTr("Sign out"),
                       "filename": "signout.svg"
                   }]
