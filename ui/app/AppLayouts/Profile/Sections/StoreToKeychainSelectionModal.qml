import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

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

        StatusRadioButtonRow {
            text: qsTr("Store")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueStore
            onRadioCheckedChanged: {
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

        StatusRadioButtonRow {
            id: notNowBtn
            text: qsTr("Not now")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueNotNow ||
                     accountSettings.storeToKeychain === ""
            onRadioCheckedChanged: {
                if (checked) {
                    accountSettings.storeToKeychain = Constants.storeToKeychainValueNotNow
                }
            }
        }

        StatusRadioButtonRow {
            id: neverBtn
            text: qsTr("Never")
            buttonGroup: openLinksWithGroup
            checked: accountSettings.storeToKeychain === Constants.storeToKeychainValueNever
            onRadioCheckedChanged: {
                if (checked) {
                    accountSettings.storeToKeychain = Constants.storeToKeychainValueNever
                }
            }
        }
    }
}
