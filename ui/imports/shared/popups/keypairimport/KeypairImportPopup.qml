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
        case Constants.keypairImportPopup.state.selectImportMethod:
            return qsTr("Import %1 keypair").arg(root.store.selectedKeypair.name)
        case Constants.keypairImportPopup.state.scanQr:
            return qsTr("Scan encrypted QR")
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
                    case Constants.keypairImportPopup.state.scanQr:
                        return scanQrComponent
                    case Constants.keypairImportPopup.state.importPrivateKey:
                        return keypairImportPrivateKeyComponent
                    case Constants.keypairImportPopup.state.importSeedPhrase:
                        return keypairImportSeedPhraseComponent
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
                id: scanQrComponent
                Item {
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

                case Constants.keypairImportPopup.state.scanQr:
                    return qsTr("Done")
                case Constants.keypairImportPopup.state.importPrivateKey:
                case Constants.keypairImportPopup.state.importSeedPhrase:
                    return qsTr("Import %1 keypair").arg(root.store.selectedKeypair.name)
                }

                return ""
            }
            visible: text !== ""
            enabled: root.store.primaryPopupButtonEnabled

            icon.name: {
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
