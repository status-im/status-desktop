import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.controls 1.0
import shared.popups 1.0
import shared.popups.send.controls 1.0

import AppLayouts.stores 1.0
import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0

import ".."
import AppLayouts.Wallet.stores 1.0 as WalletStores

StatusModal {
    id: root

    property var accounts
    property var selectedAccount

    property bool switchingAccounsEnabled: true

    property string qrImageSource: root.store.getQrCode(root.selectedAccount.mixedcaseAddress)

    property WalletStores.RootStore store: WalletStores.RootStore

    signal updateSelectedAddress(string address)

    width: 556
    contentHeight: content.implicitHeight + d.advanceFooterHeight

    hasFloatingButtons: true

    showHeader: false
    showAdvancedHeader: hasFloatingButtons
    advancedHeaderComponent: Item {
        implicitWidth: accountSelector.implicitWidth
        implicitHeight: accountSelector.implicitHeight
        AccountSelectorHeader {
            id: accountSelector
            control.enabled: root.switchingAccounsEnabled && model.count > 1
            width: implicitWidth
            model: SortFilterProxyModel {
                sourceModel: root.accounts
                sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
            }

            selectedAddress: !!root.selectedAccount ? root.selectedAccount.address : ""
            onCurrentAccountAddressChanged: {
                root.updateSelectedAddress(currentAccountAddress)
            }
        }
    }

    showFooter: false
    showAdvancedFooter: true
    advancedFooterComponent: Rectangle {
        width: parent.width
        height: rowLayout.height + 56 // Makes it totally 88 for one liner text as per design
        color: Theme.palette.baseColor4
        radius: 8

        // Hide round corners of the upper part
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.radius
            color: parent.color
        }

        // Divider
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Theme.palette.baseColor2
        }

        Item { // Needed to avoid binding loop warnings
            anchors.centerIn: parent
            height: childrenRect.height
            width: parent.width

            RowLayout {
                id: rowLayout

                width: parent.width

                StatusBaseText {
                    Layout.leftMargin: Theme.bigPadding
                    Layout.preferredWidth: parent.width - copyButton.width
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    textFormat: TextEdit.RichText
                    wrapMode: Text.WrapAnywhere
                    text: root.selectedAccount.mixedcaseAddress
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                }

                CopyButtonWithCircle {
                    id: copyButton

                    Layout.rightMargin: Theme.bigPadding
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    textToCopy: root.selectedAccount.mixedcaseAddress
                    successCircleVisible: true
                }
            }
        }
    }

    onOpened: {
        root.store.addressWasShown(root.selectedAccount.address)
    }

    QtObject {
        id: d

        readonly property int advanceFooterHeight: 88
    }

    Column {
        id: content
        width: parent.width
        height: childrenRect.height

        topPadding: Theme.xlPadding
        bottomPadding: Theme.xlPadding
        spacing: Theme.bigPadding

        Item {
            id: qrCode
            height: 320
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: qrCode.width
                    height: qrCode.height
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: qrCode.width
                        height: qrCode.height
                        radius: Theme.bigPadding
                        border.width: 1
                        border.color: Theme.palette.border
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: Theme.bigPadding
                        height: Theme.bigPadding
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: Theme.bigPadding
                        height: Theme.bigPadding
                    }
                }
            }

            Image {
                id: qrCodeImage
                objectName: "qrCodeImage"
                anchors.centerIn: parent
                height: parent.height
                width: parent.width
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: false
                source: root.qrImageSource
            }

            Rectangle {
                anchors.centerIn: qrCodeImage
                width: 88
                height: 88
                color: "white"
                radius: width / 2
                StatusSmartIdenticon {
                    anchors.centerIn: parent
                    name: root.selectedAccount.name
                    asset {
                        width: 72
                        height: 72
                        name: !root.selectedAccount.name && !root.selectedAccount.emoji? "status-logo-icon" : ""
                        color: !root.selectedAccount.name && !root.selectedAccount.emoji? "transparent" : Utils.getColorForId(root.selectedAccount.colorId)
                        emoji: root.selectedAccount.emoji
                        charactersLen: 1
                        isLetterIdenticon: root.selectedAccount.name && !root.selectedAccount.emoji
                        letterIdenticonBgWithAlpha: root.selectedAccount.name && !root.selectedAccount.emoji
                    }
                }
            }
        }
    }
}

