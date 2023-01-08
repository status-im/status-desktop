import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

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
    property var showSavedAddresses: function(showSavedAddresses){}
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
        anchors.margins: Style.current.padding
        anchors.bottomMargin: Style.current.smallPadding
        spacing: Style.current.padding

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Wallet")
            font.weight: Font.Bold
            font.pixelSize: 17
        }

        Item {
            height: childrenRect.height
            Layout.fillWidth: true

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

            StyledText {
                id: totalValue
                color: Style.current.secondaryText
                text: qsTr("Total value")
                width: parent.width
                anchors.top: walletAmountValue.bottom
                anchors.topMargin: 4
                font.pixelSize: 12
            }
        }

        StatusListView {
            objectName: "walletAccountsListView"
            spacing: Style.current.smallPadding
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Style.current.halfPadding

            // ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            delegate: StatusListItem {
                objectName: "walletAccountItem"
                width: ListView.view.width
                highlighted: RootStore.currentAccount.name === model.name
                title: model.name
                subTitle: LocaleUtils.currencyAmountToLocaleString(model.currencyBalance)
                asset.emoji: !!model.emoji ? model.emoji: ""
                asset.color: model.color
                asset.name: !model.emoji ? "filled-account": ""
                asset.letterSize: 14
                asset.isLetterIdenticon: !!model.emoji ? true : false
                asset.bgColor: Theme.palette.primaryColor3
                statusListItemTitle.font.weight: Font.Medium
                color: sensor.containsMouse || highlighted ? Theme.palette.baseColor3 : "transparent"
                onClicked: {
                    changeSelectedAccount(index)
                    showSavedAddresses(false)
                }
            }

            footer: Item {
                width: ListView.view.width
                height: addAccountBtn.height + Style.current.xlPadding
                StatusButton {
                    id: addAccountBtn
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: Style.current.bigPadding
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    icon.name: "add"
                    text: qsTr("Add account")
                    onClicked: addAccountModal.open()
                }
            }

            model: RootStore.accounts
            // model: RootStore.exampleWalletModel
        }

        StatusButton {
            objectName: "savedAddressesBtn"
            size: StatusBaseButton.Size.Small
            topPadding: Style.current.halfPadding
            bottomPadding: Style.current.halfPadding
            normalColor: "transparent"
            hoverColor: Theme.palette.primaryColor3
            font.weight: Font.Medium
            text: qsTr("Saved addresses")
            icon.name: "address"
            onClicked: showSavedAddresses(true)
        }
    }
}
