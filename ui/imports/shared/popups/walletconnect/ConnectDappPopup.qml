import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusModal {
    id: root

    width: Constants.dapps.connectDappPopupWidth

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    headerSettings.title: qsTr("Connect a Dapp via WalletConnect")

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
                    // TODO

                    return undefined
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: primaryButton
            height: Constants.dapps.footerButtonsHeight
            text: qsTr("Done")
            visible: text !== ""
            enabled: root.store.primaryPopupButtonEnabled

            onClicked: {
                console.warn("TODO: done...")
            }
        }
    ]
}
