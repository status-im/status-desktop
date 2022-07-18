import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

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

    AddAccountModal {
        id: addAccountModal
        anchors.centerIn: parent
        onAfterAddAccount: root.onAfterAddAccount()
        emojiPopup: root.emojiPopup
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
                color: Style.current.textColor
                text: {
                    Utils.toLocaleString(parseFloat(RootStore.totalCurrencyBalance).toFixed(2), localAppSettings.locale, {"currency": true}) + " " + RootStore.currentCurrency.toUpperCase()
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

        ScrollView {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            clip: true

            ListView {
                id: listView

                spacing: Style.current.smallPadding
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                delegate: StatusListItem {
                    width: ListView.view.width
                    highlighted: RootStore.currentAccount.name === model.name
                    title: model.name
                    subTitle: Utils.toLocaleString(model.currencyBalance.toFixed(2), RootStore.locale, {"model.currency": true}) + " " + RootStore.currentCurrency.toUpperCase()
                    icon.emoji: !!model.emoji ? model.emoji: ""
                    icon.color: model.color
                    icon.name: !model.emoji ? "filled-account": ""
                    icon.letterSize: 14
                    icon.isLetterIdenticon: !!model.emoji ? true : false
                    icon.background.color: Theme.palette.primaryColor3
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
        }

        Item { Layout.fillHeight: true }

        StatusButton {
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
