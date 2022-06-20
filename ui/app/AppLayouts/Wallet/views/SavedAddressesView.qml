import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import "../popups"
import "../controls"
import "../stores"

Item {
    id: root
    anchors.leftMargin: Style.dp(80)
    anchors.rightMargin: Style.dp(80)
    anchors.topMargin: Style.dp(62)

    property var contactsStore

    QtObject {
        id: _internal
        property bool loading: false
        property string error: ""
    }

    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: btnAdd.height

        Row {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: btnAdd.left
            spacing: Style.dp(10)

            StatusIcon {
                icon: "address"
                color: Theme.palette.primaryColor1
                width: undefined
                height: Style.dp(35)
                anchors.verticalCenter: parent.verticalCenter
            }
            StatusBaseText {
                id: title
                text: qsTr("Saved addresses")
                font.weight: Font.Medium
                font.pixelSize: Style.dp(28)
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.palette.directColor1
            }
        }
        StatusButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.top: parent.top
            text: "Add new   +"
            leftPadding: Style.current.halfPadding
            rightPadding: Style.dp(11)
            visible: !_internal.loading
            onClicked: {
                Global.openPopup(addEditSavedAddress)
            }
        }
        StatusLoadingIndicator {
            anchors.centerIn: parent
            visible: _internal.loading
            color: Theme.palette.directColor4
        }
    }

    Component {
        id: delegateSavedAddress
        StatusListItem {
            id: savedAddress
            title: name
            subTitle: address
            icon.name: "wallet"
            implicitWidth: parent.width
            property bool showButtons: sensor.containsMouse
            components: [
                StatusRoundButton {
                    color: hovered ? Theme.palette.dangerColor2 : Theme.palette.dangerColor3
                    icon.color: Theme.palette.dangerColor1
                    visible: showButtons
                    icon.name: "delete"
                    onClicked: {
                        deleteAddressConfirm.name = name
                        deleteAddressConfirm.address = address
                        deleteAddressConfirm.open()
                    }
                },
                StatusRoundButton {
                    icon.name: "pencil"
                    visible: showButtons
                    onClicked: Global.openPopup(addEditSavedAddress,
                                                {
                                                    edit: true,
                                                    address: address,
                                                    name: name
                                                })
                },
                StatusRoundButton {
                    icon.name: "send"
                    visible: showButtons
                },
                StatusRoundButton {
                    color: hovered ? Theme.palette.pinColor2 : Theme.palette.pinColor3
                    icon.color: Theme.palette.pinColor1
                    icon.name: "favourite"
                    visible: showButtons
                }
            ]
        }
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            onSave: {
                _internal.loading = true
                _internal.error = RootStore.createOrUpdateSavedAddress(name, address)
                _internal.loading = false
                close()
            }
        }
    }

    StatusModal {
        id: deleteAddressConfirm
        property string address
        property string name
        // NOTE: the `text` property was created as a workaround because
        // setting StatusBaseText.text to `qsTr("...").arg("...")`
        // caused no text to render
        property string text: qsTr("Are you sure you want to remove '%1' from your saved addresses?").arg(name)
        anchors.centerIn: parent
        header.title: "Are you sure?"
        header.subTitle: name
        contentItem: StatusBaseText {
            anchors.centerIn: parent
            height: contentHeight + topPadding + bottomPadding
            text: deleteAddressConfirm.text
            font.pixelSize: 15
            color: Theme.palette.directColor1
            wrapMode: Text.Wrap
            topPadding: Style.current.padding
            rightPadding: Style.current.padding
            bottomPadding: Style.current.padding
            leftPadding: Style.current.padding
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: deleteAddressConfirm.close()
            },
            StatusButton {
                type: StatusBaseButton.Type.Danger
                text: qsTr("Delete")
                onClicked: {
                    _internal.loading = true
                    _internal.error = RootStore.deleteSavedAddress(deleteAddressConfirm.address)
                    deleteAddressConfirm.close()
                    _internal.loading = false
                }
            }
        ]
    }

    SavedAddressesError {
        id: errorMessage
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        visible: _internal.error !== ""
        text: _internal.error
        height: visible ? Style.dp(36) : 0
    }

    StatusBaseText {
        anchors.top: errorMessage.bottom
        anchors.topMargin: Style.current.padding
        anchors.centerIn: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: listView.count === 0
        color: Theme.palette.baseColor1
        text: qsTr("No saved addresses")
    }

    ScrollView {
        anchors.top: errorMessage.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.right: parent.right
        anchors.left: parent.left
        visible: listView.count > 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: listView
            model: RootStore.savedAddresses
            clip: true
            spacing: Style.dp(5)
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            delegate: delegateSavedAddress
        }
    }
}
