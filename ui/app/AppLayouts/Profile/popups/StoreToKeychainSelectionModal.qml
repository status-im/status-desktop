import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import "../../../../shared/controls"
import "../../../../shared/popups"

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    title: qsTr("Store pass to Keychain")

    onClosed: {
        destroy()
    }

    Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup {
            id: openLinksWithGroup
        }

        RadioButtonSelector {
            title: qsTr("Store")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueStore
            onCheckedChanged: {
                if (checked && accountSettings.storeToKeychain !== Constants.storeToKeychainValueStore) {
                    var storePassPopup = openPopup(storePasswordModal)
                    if(storePassPopup)
                    {
                        storePassPopup.closed.connect(function(){
                            if (accountSettings.storeToKeychain === Constants.storeToKeychainValueStore)
                                popup.close()
                            else if (accountSettings.storeToKeychain === Constants.storeToKeychainValueNotNow)
                                notNowBtn.checked = true
                            else if (accountSettings.storeToKeychain === Constants.storeToKeychainValueNever)
                                neverBtn.checked = true
                        })
                    }
                }
            }
        }

        RadioButtonSelector {
            id: notNowBtn
            title: qsTr("Not now")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueNotNow ||
                     accountSettings.storeToKeychain === ""
            onCheckedChanged: {
                if (checked) {
                    accountSettings.storeToKeychain = Constants.storeToKeychainValueNotNow
                }
            }
        }

        RadioButtonSelector {
            id: neverBtn
            title: qsTr("Never")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueNever
            onCheckedChanged: {
                if (checked) {
                    accountSettings.storeToKeychain = Constants.storeToKeychainValueNever
                }
            }
        }
    }
}
