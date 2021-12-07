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

Item {
    id: root
    property bool loading: false
    property int error: SavedAddressesView.Error.None
    anchors.leftMargin: 80
    anchors.rightMargin: 80
    anchors.topMargin: 62
    property var store

    enum Error {
        CreateSavedAddressError,
        DeleteSavedAddressError,
        ParseAddressError,
        ReadSavedAddressesError,
        UpdateSavedAddressError,
        None
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
            spacing: 10

            StatusIcon {
                icon: "address"
                color: Theme.palette.primaryColor1
                width: undefined
                height: 35
                anchors.verticalCenter: parent.verticalCenter
            }
            StatusBaseText {
                id: title
                text: qsTr("Saved addresses")
                font.weight: Font.Medium
                font.pixelSize: 28
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.palette.directColor1
            }
        }
        Component {
            id: addEditSavedAddress
            AddEditSavedAddressPopup {
                id: addEditModal
                anchors.centerIn: parent
                store: root.store
                onClosed: {
                    destroy();
                }
                onBeforeSave: {
                    root.loading = true;
                }
            }
        }
        StatusButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.top: parent.top
            text: "Add new   +"
            leftPadding: 8
            rightPadding: 11
            visible: !root.loading
            onClicked: {
                Global.openPopup(addEditSavedAddress)
            }
        }
        StatusLoadingIndicator {
            anchors.centerIn: parent
            visible: root.loading
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
                    root.loading = true
                    root.store.walletModelV2Inst.savedAddressesView.deleteSavedAddress(
                        deleteAddressConfirm.address)
                    deleteAddressConfirm.close()
                }
            }
        ]

    }
    Connections {
        target: root.store.walletModelV2Inst.savedAddressesView
        onAddEditResultChanged: {
            root.loading = false
            let resultRaw = root.store.walletModelV2Inst.savedAddressesView.addEditResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddressesView.Error.None
                root.store.walletModelV2Inst.savedAddressesView.loadSavedAddresses();
            } else {
                root.error = parseInt(result.e)
            }
        }
    }
    Connections {
        target: root.store.walletModelV2Inst.savedAddressesView
        onDeleteResultChanged: {
            root.loading = false
            let resultRaw = root.store.walletModelV2Inst.savedAddressesView.deleteResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddressesView.Error.None
                root.store.walletModelV2Inst.savedAddressesView.loadSavedAddresses();
                deleteAddressConfirm.close();
            } else {
                root.error = parseInt(result.e)
            }
        }
    }
    Connections {
        target: root.store.walletModelV2Inst.savedAddressesView
        onLoadResultChanged: {
            root.loading = false
            let resultRaw = root.store.walletModelV2Inst.savedAddressesView.loadResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddressesView.Error.None
            } else {
                root.error = parseInt(result.e)
            }
        }
    }

    SavedAddressesError {
        id: errorMessage
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        visible: root.error !== SavedAddressesView.Error.None
        text: root.store.getSavedAddressErrorText(SavedAddressesView, root.error)
        height: visible ? 36 : 0
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
            //model: root.store.exampleWalletModel
            model: root.store.walletModelV2Inst.savedAddressesView.savedAddresses
            clip: true
            spacing: 5
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            delegate: delegateSavedAddress
        }
    }
}
