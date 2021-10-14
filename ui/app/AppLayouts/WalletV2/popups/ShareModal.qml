import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import "../../../../shared"
import "../../../../shared/panels"

StatusModal {
    id: shareModal
    implicitWidth: 454
    implicitHeight: 568
    property var selectedAccount
    property var accountsModel
    property var qrCode
    signal copy(string text)

    // To-do Icon in header needs to be updated once emoji picker is ready
    header.title: shareModal.selectedAccount.name
    header.subTitle: qsTr("Basic address")
    header.popupMenu: StatusPopupMenu {
        id: accountPickerPopUp
        Repeater {
            id: repeater
            model: shareModal.accountsModel
            delegate: Loader {
                sourceComponent: accountPickerPopUp.delegate
                onLoaded: {
                    item.action.text = model.name
                    // To-do this and Icon in header needs to be updated once emoji picker is ready
                    item.action.iconSettings.name = "filled-account"
                }
                Connections {
                    enabled: (!!item && !!item.action)
                    target: enabled ? item.action : null
                    onTriggered: {
                        shareModal.selectedAccount = { address, name, iconColor, fiatBalance }
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
        source: shareModal.qrCode
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
            text: shareModal.selectedAccount.address
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
                            if (shareModal.selectedAccount.address) {
                                shareModal.copy(shareModal.selectedAccount.address);
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
