import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    title: qsTr("Store pass to Keychain")

    onClosed: {
        destroy()
    }

    function updateListState() {
        if (localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueStore)
            storeBtn.checked = true
        else if (localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNotNow ||
                 localAccountSettings.storeToKeychainValue === "")
            notNowBtn.checked = true
        else if (localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNever)
            neverBtn.checked = true
    }

    Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        Connections {
            target: localAccountSettings
            onStoreToKeychainValueChanged: {
                updateListState()
            }
        }

        ButtonGroup {
            id: openLinksWithGroup
        }

        StatusRadioButtonRow {
            id: storeBtn
            text: qsTr("Store")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueStore
            onRadioCheckedChanged: {
                if (checked && localAccountSettings.storeToKeychainValue !== Constants.storeToKeychainValueStore) {
                    var storePassPopup = openPopup(storePasswordModal)
                    if(storePassPopup)
                    {
                        storePassPopup.closed.connect(function(){
                            updateListState()
                        })
                    }
                }
            }
        }

        StatusRadioButtonRow {
            id: notNowBtn
            text: qsTr("Not now")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNotNow ||
                     localAccountSettings.storeToKeychainValue === ""
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNotNow
                }
            }
        }

        StatusRadioButtonRow {
            id: neverBtn
            text: qsTr("Never")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNever
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever
                }
            }
        }
    }
}
