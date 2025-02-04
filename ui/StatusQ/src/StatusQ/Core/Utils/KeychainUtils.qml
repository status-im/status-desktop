pragma Singleton

import QtQml 2.15

import StatusQ 0.1

QObject {

    /*!
        \qmlmethod void KeychainUtils::getSecret(Keychain keychain, string reason, string profileId, var callback)

        Allows to use Keychain object via a function with a callback.

        keychain is the Keychain object used for handling the biometrics popup,
        reason and profileId are passed to the keychain object to invoke the popup.
        When the request is completed the callback function of the following signature is called:

        function (bool aborted, string error, string password/pin)

        See also Keychain::requestGetCredential
    */
    function getSecret(keychain, reason, profileId, callback) {
        const params = {
            target: keychain,
            callback, reason, profileId
        }

        connector.createObject(this, params)
    }

    Component {
        id: connector

        Connections {
            required property var callback
            required property string reason
            required property string profileId

            function onGetCredentialRequestCompleted(status, password) {
                if (status === Keychain.StatusSuccess)
                    callback(false, "", "")
                else if (status === Keychain.StatusCancelled)
                    callback(true, "", "")
                else
                    callback(false, qsTr("Fetching credentials failed."), "")

                destroy()
            }

            Component.onCompleted: keychain.requestGetCredential(reason, profileId)
        }
    }
}
