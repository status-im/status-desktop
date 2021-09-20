import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "./components"

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

Item {
    id: root
    property bool loading: false
    property int error: SavedAddresses.Error.None
    anchors.leftMargin: 80
    anchors.rightMargin: 80
    anchors.topMargin: 62


    enum Error {
        CreateSavedAddressError,
        DeleteSavedAddressError,
        ParseAddressError,
        ReadSavedAddressesError,
        UpdateSavedAddressError,
        None
    }

    function getErrorText(error) {
        switch (error) {
            case SavedAddresses.Error.CreateSavedAddressError:
                return qsTr("Error creating new saved address, please try again later.");
            case SavedAddresses.Error.DeleteSavedAddressError:
                return qsTr("Error deleting saved address, please try again later.");
            case SavedAddresses.Error.ReadSavedAddressesError:
                return qsTr("Error getting saved addresses, please try again later.");
            case SavedAddresses.Error.UpdateSavedAddressError:
                return qsTr("Error updating saved address, please try again later.");
            default: return "";
        }
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
            AddEditSavedAddress {
                id: addEditModal
                anchors.centerIn: parent
                onClosed: {
                    destroy()
                }
                onBeforeSave: function() {
                    root.loading = true
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
                appMain.openPopup(addEditSavedAddress)
            }
        }
        StatusLoadingIndicator {
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
                    onClicked: appMain.openPopup(addEditSavedAddress,
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
                    walletV2Model.savedAddressesView.deleteSavedAddress(
                        deleteAddressConfirm.address)
                    deleteAddressConfirm.close()
                }
            }
        ]

    }
    Connections {
        target: walletV2Model.savedAddressesView
        onAddEditResultChanged: {
            root.loading = false
            let resultRaw = walletV2Model.savedAddressesView.addEditResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddresses.Error.None
                walletV2Model.savedAddressesView.loadSavedAddresses();
            } else {
                root.error = parseInt(result.e)
            }
        }
    }
    Connections {
        target: walletV2Model.savedAddressesView
        onDeleteResultChanged: {
            root.loading = false
            let resultRaw = walletV2Model.savedAddressesView.deleteResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddresses.Error.None
                walletV2Model.savedAddressesView.loadSavedAddresses();
                deleteAddressConfirm.close();
            } else {
                root.error = parseInt(result.e)
            }
        }
    }
    Connections {
        target: walletV2Model.savedAddressesView
        onLoadResultChanged: {
            root.loading = false
            let resultRaw = walletV2Model.savedAddressesView.loadResult
            let result = JSON.parse(resultRaw)
            if (result.o) {
                root.error = SavedAddresses.Error.None
            } else {
                root.error = parseInt(result.e)
            }
        }
    }

    SavedAddressesError {
        id: errorMessage
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        visible: root.error !== SavedAddresses.Error.None
        text: getErrorText(root.error)
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

            clip: true
            spacing: 5
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds

            delegate: delegateSavedAddress

            ListModel {
                id: exampleWalletModel
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    isFavorite: false
                }
                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: false
                }
                ListElement {
                    name: "Status account 2"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: true
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    isFavorite: false
                }
                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: false
                }
                ListElement {
                    name: "Status account 2"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: true
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    isFavorite: false
                }
                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: false
                }
                ListElement {
                    name: "Status account 2"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: true
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    isFavorite: false
                }
                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: false
                }
                ListElement {
                    name: "Status account 2"
                    address: "0x2Ef1...E0Ba"
                    isFavorite: true
                }
            }

            model: walletV2Model.savedAddressesView.savedAddresses //exampleWalletModel
        }
    }

}