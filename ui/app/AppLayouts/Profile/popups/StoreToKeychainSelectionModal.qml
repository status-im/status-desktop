import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0

import "../../Onboarding/shared" as OnboardingComponents

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    property var privacyStore

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

    function offerToStorePassword(password, runStoreToKeychainPopup) {
        if(Qt.platform.os == "osx")
        {
            if(runStoreToKeychainPopup)
                Global.openPopup(storeToKeychainConfirmationPopupComponent, { password: password })
        }
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

        RadioButtonSelector {
            id: storeBtn
            title: qsTr("Store")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueStore
            onCheckedChanged: {
                if (checked && localAccountSettings.storeToKeychainValue !== Constants.storeToKeychainValueStore) {
                    // TODO: REFACTOR TO NEW PASWORD VIEW AND
                    // DELETE StoreToKeychainSelectionModal.qml
                    // AND CreatePasswordModal.qml IF NOT NEEDED
                    var storePassPopup = Global.openPopup(storePasswordModal)
                    if(storePassPopup)
                    {
                        storePassPopup.closed.connect(function(){
                            updateListState()
                        })
                    }
                }
            }
        }

        RadioButtonSelector {
            id: notNowBtn
            title: qsTr("Not now")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNotNow ||
                     localAccountSettings.storeToKeychainValue === ""
            onCheckedChanged: {
                if (checked) {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNotNow
                }
            }
        }

        RadioButtonSelector {
            id: neverBtn
            title: qsTr("Never")
            buttonGroup: openLinksWithGroup
            checked: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueNever
            onCheckedChanged: {
                if (checked) {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever
                }
            }
        }

        Component {
            id: storePasswordModal
            OnboardingComponents.CreatePasswordModal {
                privacyStore: popup.privacyStore
                storingPasswordModal: true
                height: Style.dp(350)

                onOfferToStorePassword: {
                    popup.offerToStorePassword(password, runStoreToKeychainPopup)
                }
            }
        }

        Component {
            id: storeToKeychainConfirmationPopupComponent
            ConfirmationDialog {
                id: storeToKeychainConfirmationPopup
                property string password: ""
                height: Style.dp(200)
                confirmationText: qsTr("Would you like to store password to the Keychain?")
                showRejectButton: true
                showCancelButton: true
                confirmButtonLabel: qsTr("Store")
                rejectButtonLabel: qsTr("Not now")
                cancelButtonLabel: qsTr("Never")

                onClosed: {
                    destroy()
                }

                function finish()
                {
                    password = ""
                    storeToKeychainConfirmationPopup.close()
                }

                onConfirmButtonClicked: {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueStore
                    root.privacyStore.storeToKeyChain(password)
                    finish()
                }

                onRejectButtonClicked: {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNotNow
                    finish()
                }

                onCancelButtonClicked: {
                    localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever
                    finish()
                }
            }
        }
    }
}
