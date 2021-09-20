import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import "../../../../shared"
import "../../../../shared/status"
import "../../../../shared/status/core"

StatusModal {
    id: shareModal

    QtObject {
        id: internal
        property var selectedAccount: walletV2Model.accountsView.currentAccount
    }

    anchors.centerIn: parent
    implicitWidth: 454
    implicitHeight: 568

    // To-do Icon in header needs to be updated once emoji picker is ready
    header.title: internal.selectedAccount.name
    header.subTitle: qsTr("Basic address")
    header.popupMenu: StatusPopupMenu {
        id: accountPickerPopUp
        Repeater {
            id: repeaster
            model: walletV2Model.accountsView.accounts
            delegate: Loader {
                sourceComponent: accountPickerPopUp.delegate
                onLoaded: {
                    item.action.text = model.name
                    // To-do this and Icon in header needs to be updated once emoji picker is ready
                    item.action.iconSettings.name = "filled-account"
                }
                Connections {
                    enabled: !!item.action
                    target: item.action
                    onTriggered: {
                        internal.selectedAccount = { address, name, iconColor, fiatBalance }
                        accountPickerPopUp.dismiss()
                    }
                }
            }
        }
    }

    Image {
        id: qrCodeImage
        width: 273
        height: 270
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter

        asynchronous: true
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: false
        source: profileModel.qrCode(internal.selectedAccount.address)
        StatusIcon {
            width: 66
            height: 66
            anchors.centerIn: parent
            icon: "snt"
        }
    }

    Column {
        id: addressColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: qrCodeImage.bottom
        anchors.topMargin: 25

        spacing: 8
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Your wallet address")
            color: Theme.palette.directColor4
            font.pixelSize: 13
            font.weight: Font.Medium
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: internal.selectedAccount.address
            color: Theme.palette.directColor1
            font.pixelSize: 13
            font.weight: Font.Medium
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
        }
    }

    Row  {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: addressColumn.bottom
        anchors.topMargin: 25

        spacing: 20

        Repeater {
            model: 2
            Column {
                spacing: 5
                StatusRoundButton {
                    anchors.horizontalCenter: parent.horizontalCenter

                    icon.name: index === 0 ? "copy" : "link"
                    onClicked: {
                        if (index === 0) {
                            if (internal.selectedAccount.address) {
                                chatsModel.copyToClipboard(internal.selectedAccount.address)
                            }
                            else {
                                // To-do Get link functionality
                            }
                        }
                    }
                }
                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: index === 0 ? qsTr("Copy") : qsTr("Get link")
                    color: Theme.palette.primaryColor1
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    lineHeight: 18
                    lineHeightMode: Text.FixedHeight
                }
            }
        }
    }
}
