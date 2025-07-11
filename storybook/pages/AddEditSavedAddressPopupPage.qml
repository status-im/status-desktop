import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Utils
import SortFilterProxyModel

import Storybook
import Models
import AppLayouts.stores
import AppLayouts.Wallet.popups
import AppLayouts.Wallet.stores as WalletStores

import utils
import shared.stores as SharedStores

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popupBg.openDialog()
        }

        function openDialog() {
            popupComponent.createObject(popupBg)
        }

        Component.onCompleted: openDialog()

        Component {
            id: popupComponent
            AddEditSavedAddressPopup {
                visible: true
                destroyOnClose: true
                modal: false
                closePolicy: Popup.NoAutoClose               

                store: WalletStores.RootStore
                sharedRootStore: SharedStores.RootStore {}

                // Emulate resolving ENS by simple validation
                QtObject {
                    id: mainModule

                    function resolveENS(name, uuid) {
                        if (Utils.isValidEns(name)) {
                            resolvedENS("", "0x1234567890123456789012345678901234567890", uuid)
                        }
                        else {
                            resolvedENS("", "", uuid)
                        }
                    }

                    signal resolvedENS(string pubkey, string address, string uuid)
                }

                Component.onCompleted: initWithParams({edit: ctrlIsEdit.checked,
                                                          name: ctrlIsEdit.checked ? ctrlName.text : "",
                                                          address: ctrlIsEdit.checked ? (ctrlAddressRadio.checked ? ctrlAddress.text : ctrlEnsAddress.text)
                                                                                      : "",
                                                          colorId : ctrlIsEdit.checked ? "magenta" : ""})
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            Switch {
                id: ctrlIsEdit
                text: "Is edit?"
            }

            RowLayout {
                Layout.leftMargin: 8
                Layout.fillWidth: true
                visible: ctrlIsEdit.checked
                Label { text: "Name:" }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlName
                    text: "cool name"
                }
            }

            Label {
                Layout.leftMargin: 8
                visible: ctrlIsEdit.checked
                text: "Address:"
            }
            ButtonGroup { id: addressButtonGroup }

            RowLayout {
                visible: ctrlIsEdit.checked
                Layout.leftMargin: 8
                Layout.fillWidth: true

                RadioButton {
                    id: ctrlAddressRadio
                    checked: true
                    ButtonGroup.group: addressButtonGroup
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlAddress
                    text: "0x1234567890123456789012345678901234567891"
                    placeholderText: "Regular address"
                }
            }

            RowLayout {
                visible: ctrlIsEdit.checked
                Layout.leftMargin: 8
                Layout.fillWidth: true

                RadioButton {
                    id: ctrlEnsRadio
                    ButtonGroup.group: addressButtonGroup
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlEnsAddress
                    text: "me.eth"
                    placeholderText: "ENS address"
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Popups

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=23256-263282&mode=design&t=0DRwQJKDGYJPHkq1-4
