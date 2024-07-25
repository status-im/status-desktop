import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
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
import "../stores"

StatusModal {
    id: root

    property var accounts
    property var selectedAccount

    property bool switchingAccounsEnabled: true
    property bool changingPreferredChainsEnabled: true

    property string qrImageSource: store.getQrCode(d.visibleAddress)
    property var getNetworkShortNames: function(chainIDsString) {
        return store.getNetworkShortNames(chainIDsString)
    }

    property var store: RootStore

    signal updateSelectedAddress(string address)
    signal updatePreferredChains(string address, string preferredChains)

    onSelectedAccountChanged: {
        d.preferredChainIdsArray = root.selectedAccount.preferredSharingChainIds.split(":").filter(Boolean).map(Number)
    }

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
                proxyRoles: [
                    FastExpressionRole {
                        name: "colorizedChainPrefixes"
                        function getChainShortNames(chainIds) {
                            const chainShortNames = root.getNetworkShortNames(chainIds)
                            return WalletUtils.colorizedChainPrefix(chainShortNames)
                        }
                        expression: getChainShortNames(model.preferredSharingChainIds)
                        expectedRoles: ["preferredSharingChainIds"]
                    }
                ]
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
                    Layout.leftMargin: Style.current.bigPadding
                    Layout.preferredWidth: parent.width - copyButton.width
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    textFormat: TextEdit.RichText
                    wrapMode: Text.WrapAnywhere
                    text: WalletUtils.colorizedChainPrefix(d.preferredChainShortNames) + root.selectedAccount.address
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                }

                CopyButtonWithCircle {
                    id: copyButton

                    Layout.rightMargin: Style.current.bigPadding
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    textToCopy: d.visibleAddress
                    successCircleVisible: true
                }
            }
        }
    }

    onOpened: {
        store.addressWasShown(root.selectedAccount.address)
    }

    QtObject {
        id: d

        readonly property bool multiChainView: tabBar.currentIndex === 1
        readonly property int advanceFooterHeight: 88

        property var preferredChainIdsArray: []
        Binding on preferredChainIdsArray {
            value: root.selectedAccount.preferredSharingChainIds.split(":").filter(Boolean).map(Number)
        }
        onPreferredChainIdsArrayChanged: {
            if (preferredChainIdsArray !== selectPopup.selection) {
                selectPopup.selection = preferredChainIdsArray
            }
        }
        property var preferredChainIds: d.preferredChainIdsArray.join(":")

        readonly property string preferredChainShortNames: d.multiChainView? root.getNetworkShortNames(d.preferredChainIds) : ""
        readonly property string visibleAddress: "%1%2".arg(d.preferredChainShortNames).arg(root.selectedAccount.address)
    }

    Column {
        id: content
        width: parent.width
        height: childrenRect.height

        topPadding: Style.current.xlPadding
        bottomPadding: Style.current.xlPadding
        spacing: Style.current.bigPadding

        StatusSwitchTabBar {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: 1

            StatusSwitchTabButton {
                objectName: "legacyButton"
                text: qsTr("Legacy")
            }
            StatusSwitchTabButton {
                objectName: "multichainButton"
                text: qsTr("Multichain")
            }
        }

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
                        radius: Style.current.bigPadding
                        border.width: 1
                        border.color: Style.current.border
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: Style.current.bigPadding
                        height: Style.current.bigPadding
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: Style.current.bigPadding
                        height: Style.current.bigPadding
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

        Item {
            width: parent.width
            height: Math.max(flow.height, editButton.height)
            anchors.horizontalCenter: parent.horizontalCenter
            visible: d.multiChainView && (d.preferredChainIdsArray.length > 0 || root.changingPreferredChainsEnabled)

            Flow {
                id: flow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Repeater {
                    model: root.store.filteredFlatModel
                    delegate: StatusNetworkListItemTag {
                        enabled: false
                        button.visible: false
                        title: model.shortName
                        asset.name: model.isTest ? Style.svg(model.iconUrl + "-test") : Style.svg(model.iconUrl)
                        visible: d.preferredChainIdsArray.includes(model.chainId)
                    }
                }
            }

            StatusRoundButton {
                id: editButton
                width: 32
                height: 32
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "edit_pencil"
                type: StatusRoundButton.Type.Tertiary
                visible: root.changingPreferredChainsEnabled
                highlighted: selectPopup.visible
                onClicked: selectPopup.open()

                NetworkSelectPopup {
                    id: selectPopup

                    x: editButton.width - width
                    y: editButton.height + 2

                    margins: -1 // to allow positioning outside the bounds of the dialog

                    flatNetworks: root.store.filteredFlatModel
                    selection: d.preferredChainIdsArray
                    multiSelection: true

                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    onSelectionChanged: {
                        if (selection !== d.preferredChainIdsArray)
                            d.preferredChainIdsArray = selection
                    }

                    onClosed: {
                        root.updatePreferredChains(root.selectedAccount.address, d.preferredChainIds)
                    }
                }
            }
        }
    }
}

