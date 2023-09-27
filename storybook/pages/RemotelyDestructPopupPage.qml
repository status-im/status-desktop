import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    Logs { id: logs }
    ListModel {
        id: accountsModel

        ListElement {
            name: "Test account"
            emoji: "😋"
            address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            color: "red"
        }

        ListElement {
            name: "Another account - generated"
            emoji: "🚗"
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"
            color: "blue"
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Pane {
            id: pane

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            RemotelyDestructPopup {
                id: dialog

                margins: 250
                topMargin: 30

                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false
                destroyOnClose: false
                parent: pane
                anchors.centerIn: pane


                collectibleName: editorCollectible.text
                model: TokenHoldersModel {}
                accounts: accountsModel
                chainName: "Optimism"
                feeText: "0,01 ETH (60,34 USD)"
                onRemotelyDestructClicked: {
                    logs.logEvent("RemoteSelfDestructPopup::onRemotelyDestructClicked",
                                  ["walletsAndAmounts", "accountAddress"], [
                                      JSON.stringify(walletsAndAmounts), accountAddress
                                  ])
                    close()
                }

                Component.onCompleted: {
                    open()
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {

            Label {
                Layout.fillWidth: true
                text: "Collectible name"
            }

            TextField {
                id: editorCollectible
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Anniversary"
            }

        }
    }
}

// category: Popups
