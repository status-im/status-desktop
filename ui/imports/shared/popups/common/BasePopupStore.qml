import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    // store properties
    required property bool isAddAccountPopup
    property bool enteredPrivateKeyIsValid: false
    property bool enteredPrivateKeyMatchTheKeypair: true
    property bool enteredSeedPhraseIsValid: false

    // backend properties
    required property var privateKeyAccAddress

    // functions
    property var changePrivateKeyPostponed: function(){}
    property var cleanPrivateKey: function(){}
    property var submitPopup: function(){}
    property var changeSeedPhrase: function(){}
    property var validSeedPhrase: function(){}

    function getFromClipboard() {
       return globalUtils.getFromClipboard()
    }
}
