import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.popups.keycard 1.0

import "../controls"
import "../popups"
import "../stores"

Rectangle {
    id: root

    property var changeSelectedAccount: function(){}
    property bool showSavedAddresses: false
    onShowSavedAddressesChanged: {
        walletAccountsListView.footerItem.button.highlighted = showSavedAddresses
    }

    property var emojiPopup: null

    function onAfterAddAccount () {
        root.changeSelectedAccount(RootStore.accounts.rowCount() - 1)
    }

    color: Style.current.secondaryMenuBackground

    Loader {
        id: addAccountModal
        active: false
        asynchronous: true

        function open() {
            if (!active) {
                RootStore.createSharedKeycardModule()
                active = true
            }
            item.open()
        }

        function close() {
            if (item) {
                RootStore.destroySharedKeycarModule()
                item.close()
            }
            active = false
        }

        sourceComponent: AddAccountModal {
            anchors.centerIn: parent
            onAfterAddAccount: root.onAfterAddAccount()
            emojiPopup: root.emojiPopup
            onClosed: addAccountModal.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: walletTitleText.height
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.topMargin: Style.current.padding

            StatusBaseText {
                id: walletTitleText
                text: qsTr("Wallet")
                font.weight: Font.Bold
                font.pixelSize: 17
                color: Theme.palette.directColor1
            }

            StatusRoundButton {
                objectName: "addAccountButton"
                icon.name: "add-circle"
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 2
                color: hovered || highlighted ? Theme.palette.primaryColor3
                                              : "transparent"
                onClicked: addAccountModal.open()
            }
        }

        Item {
            height: childrenRect.height
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding

            StyledTextEdit {
                id: walletAmountValue
                objectName: "walletLeftListAmountValue"
                color: Style.current.textColor
                text: {
                    LocaleUtils.currencyAmountToLocaleString(RootStore.totalCurrencyBalance)
                }
                selectByMouse: true
                cursorVisible: true
                readOnly: true
                width: parent.width
                font.weight: Font.Medium
                font.pixelSize: 22
            }

            StatusBaseText {
                id: totalValue
                color: Theme.palette.baseColor1
                text: qsTr("Total value")
                width: parent.width
                anchors.top: walletAmountValue.bottom
                anchors.topMargin: 4
                font.pixelSize: 12
            }
        }

        StatusListView {
            id: walletAccountsListView

            objectName: "walletAccountsListView"
            spacing: Style.current.smallPadding
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Style.current.halfPadding

            // ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            readonly property Item firstItem: count > 0 ? itemAtIndex(0) : null

            delegate: StatusListItem {
                objectName: "walletAccountItem"
                width: ListView.view.width - Style.current.padding * 2
                highlighted: !ListView.view.footerItem.button.highlighted &&
                             RootStore.currentAccount.name === model.name
                anchors.horizontalCenter: parent.horizontalCenter
                title: model.name
                subTitle: LocaleUtils.currencyAmountToLocaleString(model.currencyBalance)
                asset.emoji: !!model.emoji ? model.emoji: ""
                asset.color: model.color
                asset.name: !model.emoji ? "filled-account": ""
                asset.width: 40
                asset.height: 40
                asset.letterSize: 14
                asset.isLetterIdenticon: !!model.emoji ? true : false
                asset.bgColor: Theme.palette.primaryColor3
                statusListItemTitle.font.weight: Font.Medium
                color: sensor.containsMouse || highlighted ? Theme.palette.baseColor3 : "transparent"
                onClicked: {
                    changeSelectedAccount(index)
                    showSavedAddresses = false
                }
                components: [
                    StatusIcon {
                        icon: {
                            if (model.walletType == "watch")
                                return "show"
                            else if (model.walletType == "key")
                                return "keycard"

                            return ""
                        }
                        color: Theme.palette.directColor1
                        width: 15
                        height: 15
                    }
                ]
            }

            readonly property bool footerOverlayed: contentHeight > availableHeight

            footerPositioning: footerOverlayed ? ListView.OverlayFooter : ListView.InlineFooter
            footer: Control {
                id: footer

                z: 2 // to be on top of delegates when in ListView.OverlayFooter
                horizontalPadding: Style.current.padding
                verticalPadding: Style.current.padding

                property alias button: savedAddressesBtn

                background: Rectangle {
                    color: root.color
                    implicitWidth: root.width
                    implicitHeight: parent.ListView.view.firstItem.height + Style.current.xlPadding

                    layer.enabled: parent.ListView.view.footerOverlayed
                    layer.effect: DropShadow {
                        verticalOffset: -10
                        radius: 20
                        samples: 41
                        fast: true
                        cached: true
                        color: Theme.palette.dropShadow2
                    }

                    StatusMenuSeparator {
                        id: footerSeparator

                        width: parent.width
                        visible: !footer.ListView.view.footerOverlayed
                    }
                }

                contentItem: StatusButton {
                    id: savedAddressesBtn

                    objectName: "savedAddressesBtn"
                    size: StatusBaseButton.Size.Large
                    normalColor: "transparent"
                    hoverColor: Theme.palette.primaryColor3
                    asset.color: Theme.palette.primaryColor1
                    asset.bgColor: Theme.palette.primaryColor3
                    font.weight: Font.Medium
                    text: qsTr("Saved addresses")
                    icon.name: "address"
                    icon.width: 40
                    icon.height: 40
                    isRoundIcon: true
                    textColor: Theme.palette.directColor1
                    textAlignment: Qt.AlignVCenter | Qt.AlignLeft
                    textFillWidth: true
                    spacing: parent.ListView.view.firstItem.statusListItemTitleArea.anchors.leftMargin
                    onClicked: {
                        showSavedAddresses = true
                    }
                }
            }

            model: RootStore.accounts
            // model: RootStore.exampleWalletModel
        }
    }
}
