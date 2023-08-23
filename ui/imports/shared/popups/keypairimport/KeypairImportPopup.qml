import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "./stores"
import "./states"
import "../common"

StatusModal {
    id: root

    property KeypairImportStore store: KeypairImportStore { }

    width: Constants.keypairImportPopup.popupWidth

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    headerSettings.title: {
        switch (root.store.currentState.stateType) {
        case Constants.keypairImportPopup.state.selectKeypair:
            return qsTr("Import missing keypairs")
        case Constants.keypairImportPopup.state.exportKeypair:
            if (!!root.store.selectedKeypair.name) {
                return qsTr("Encrypted QR for %1 keypair").arg(root.store.selectedKeypair.name)
            }
            return qsTr("Encrypted QR for keypairs on this device")
        case Constants.keypairImportPopup.state.importQr:
            return qsTr("Scan encrypted keypair QR code")
        case Constants.keypairImportPopup.state.displayInstructions:
            if (root.store.syncViaQr) {
                return Constants.keypairImportPopup.instructionsLabelForQr
            }
            return Constants.keypairImportPopup.instructionsLabelForEncryptedKey
        }

        return qsTr("Import %1 keypair").arg(root.store.selectedKeypair.name)
    }

    onClosed: {
        root.store.currentState.doCancelAction()
    }

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        padding: 0
        contentWidth: availableWidth

        Item {
            id: content

            implicitWidth: loader.implicitWidth
            implicitHeight: loader.implicitHeight
            width: scrollView.availableWidth

            Loader {
                id: loader
                width: parent.width
                sourceComponent: {
                    switch (root.store.currentState.stateType) {
                    case Constants.keypairImportPopup.state.selectKeypair:
                        return selectKeypairComponent
                    case Constants.keypairImportPopup.state.selectImportMethod:
                        return selectImportMethodComponent
                    case Constants.keypairImportPopup.state.exportKeypair:
                        return exportKeypairComponent
                    case Constants.keypairImportPopup.state.importQr:
                        return keypairImportQrComponent
                    case Constants.keypairImportPopup.state.importPrivateKey:
                        return keypairImportPrivateKeyComponent
                    case Constants.keypairImportPopup.state.importSeedPhrase:
                        return keypairImportSeedPhraseComponent
                    case Constants.keypairImportPopup.state.displayInstructions:
                        return displayInstructionsComponent
                    }

                    return undefined
                }

                onLoaded: {
                    content.height = Qt.binding(function(){return item.height})
                }
            }

            Component {
                id: selectKeypairComponent
                SelectKeypair {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: selectImportMethodComponent
                SelectImportMethod {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: exportKeypairComponent
                ExportKeypair {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: keypairImportQrComponent
                ScanOrEnterQrCode {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: keypairImportPrivateKeyComponent
                EnterPrivateKey {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: keypairImportSeedPhraseComponent
                EnterSeedPhrase {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }

            Component {
                id: displayInstructionsComponent
                DisplayInstructions {
                    height: Constants.keypairImportPopup.contentHeight
                    store: root.store
                }
            }
        }
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.store.currentState.displayBackButton
            height: Constants.keypairImportPopup.footerButtonsHeight
            width: height
            onClicked: {
                root.store.currentState.doBackAction()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: primaryButton
            height: Constants.keypairImportPopup.footerButtonsHeight
            text: {
                switch (root.store.currentState.stateType) {

                case Constants.keypairImportPopup.state.exportKeypair:
                    return qsTr("Done")
                case Constants.keypairImportPopup.state.importQr:
                    if (root.store.syncViaQr) {
                        return qsTr("Done")
                    }
                    return qsTr("Import keypair")
                case Constants.keypairImportPopup.state.importPrivateKey:
                case Constants.keypairImportPopup.state.importSeedPhrase:
                    return qsTr("Import keypair")
                }

                return ""
            }
            visible: text !== ""
            enabled: root.store.primaryPopupButtonEnabled

            icon.name: {
                if (root.store.currentState.stateType === Constants.keypairImportPopup.state.exportKeypair ||
                        root.store.currentState.stateType === Constants.keypairImportPopup.state.importQr && root.store.syncViaQr) {
                    return ""
                }

                if (root.store.userProfileUsingBiometricLogin) {
                    return "touch-id"
                }

                if (root.store.userProfileIsKeycardUser) {
                    return "keycard"
                }

                return "password"
            }

            onClicked: {
                root.store.submitPopup(null)
            }
        }
    ]
}
