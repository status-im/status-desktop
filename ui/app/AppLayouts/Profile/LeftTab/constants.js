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
var ADVANCED = 10
var NEED_HELP = 11
var ABOUT = 12

var menuButtons = [{
                       "id": PROFILE,
                       "text": qsTr("My Profile"),
                       "filename": "myProfile.svg"
                   }, {
                       "id": CONTACTS,
                       "text": qsTr("Contacts"),
                       "filename": "profileActive.svg"
                   }, {
                       "id": ENS,
                       "text": qsTr("ENS usernames"),
                       "filename": "atSign.svg"
                   }, {
                       "id": PRIVACY_AND_SECURITY,
                       "text": qsTr("Privacy and security"),
                       "filename": "lock.svg"
                   }, {
                       "id": APPEARANCE,
                       "text": qsTr("Appearance"),
                       "filename": "sun.svg"
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
                       "filename": "bell.svg"
                   }, {
                       "id": SYNC_SETTINGS,
                       "text": qsTr("Sync settings"),
                       "filename": "phone.svg"
                   }, {
                       "id": DEVICES_SETTINGS,
                       "text": qsTr("Devices settings"),
                       "filename": "phone.svg"
                   }, {
                       "id": ADVANCED,
                       "text": qsTr("Advanced"),
                       "filename": "slider.svg"
                   }, {
                       "id": NEED_HELP,
                       "text": qsTr("Need help?"),
                       "filename": "question.svg"
                   }, {
                       "id": ABOUT,
                       "text": qsTr("About"),
                       "filename": "info.svg"
                   }]
