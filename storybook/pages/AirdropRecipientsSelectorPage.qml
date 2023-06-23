import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.controls 1.0

import Models 1.0
import Storybook 1.0

import utils 1.0


SplitView {
    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "compressed_" + publicKey
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({ ensVerified: true })
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        AddressesModel {
            id: addresses
        }

        ListModel {
            id: members

            property int counter: 0

            function addMember() {
                const i = counter++
                const key = `pub_key_${i}`

                append({
                    alias: "",
                    colorId: "1",
                    displayName: `contact ${i}`,
                    ensName: "",
                    icon: "",
                    isContact: true,
                    localNickname: "",
                    onlineStatus: 1,
                    pubKey: key,
                    isVerified: true,
                    isUntrustworthy: false
                })
            }

            Component.onCompleted: {
                for (let i = 0; i < 4; i++)
                    addMember()
            }
        }

        Loader {
            id: loader

            anchors.centerIn: parent
            active: globalUtilsReady && mainModuleReady

            sourceComponent: AirdropRecipientsSelector {
                id: selector

                addressesModel: addresses
                loadingAddresses: timer.running
                membersModel: members
                showAddressesInputWhenEmpty:
                    showAddressesInputWhenEmptyCheckBox.checked

                infiniteMaxNumberOfRecipients:
                    infiniteMaxNumberOfRecipientsCheckBox.checked

                maxNumberOfRecipients: maxNumberOfRecipientsSpinBox.value

                onAddAddressesRequested: timer.start()
                onRemoveAddressRequested: addresses.remove(index)
                onRemoveMemberRequested: members.remove(index)

                Timer {
                    id: timer

                    interval: 1000

                    onTriggered: {
                        addresses.addAddressesFromString(
                                    selector.addressesInputText)
                        selector.clearAddressesInput()
                        selector.positionAddressesListAtEnd()
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            RowLayout {
                Button {
                    text: "Clear addresses list"
                    onClicked: addresses.clear()
                }

                Button {
                    text: "Clear members list"
                    onClicked: members.clear()
                }

                CheckBox {
                    id: showAddressesInputWhenEmptyCheckBox

                    text: "Show addresses input when empty"
                }

                CheckBox {
                    id: infiniteMaxNumberOfRecipientsCheckBox

                    text: "Infinite number of expected recipients"
                }
            }

            RowLayout {
                Label {
                    text: "Expected number of recipients:"
                }

                SpinBox {
                    id: maxNumberOfRecipientsSpinBox

                    value: 2
                    from: 1
                    to: 100
                }
            }

            Button {
                text: "Add member"
                onClicked: {
                    members.addMember()
                    loader.item.positionMembersListAtEnd()
                }
            }

            MenuSeparator {}

            TextEdit {
                readOnly: true
                selectByMouse: true
                text: "valid address: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4"
            }
        }
    }
}
