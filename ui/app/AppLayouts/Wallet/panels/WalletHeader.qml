import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import "../popups"
import "../controls"
import "../stores"

Item {
    id: walletHeader

    property string locale: ""
    property string currency: ""
    property var currentAccount
    property var changeSelectedAccount
    property var store
    property var walletStore
    property var emojiPopup

    height: walletAddress.y + walletAddress.height

    StyledText {
        id: title
        text: currentAccount.name
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.left: parent.left
        anchors.leftMargin: 24
        font.weight: Font.Medium
        font.pixelSize: 28
    }

    Rectangle {
        id: separatorDot
        width: 8
        height: 8
        color: Style.current.primary
        anchors.top: title.verticalCenter
        anchors.topMargin: -3
        anchors.left: title.right
        anchors.leftMargin: 8
        radius: 50
    }

    StyledText {
        id: walletBalance
        text: {
            Utils.toLocaleString(currentAccount.currencyBalance.toFixed(2), locale, {"currency": true}) + " " + walletHeader.currency.toUpperCase()
        }
        anchors.left: separatorDot.right
        anchors.leftMargin: 8
        anchors.verticalCenter: title.verticalCenter
        font.pixelSize: 22
    }

    StatusExpandableAddress {
        id: walletAddress
        address: currentAccount.address
        anchors.top: title.bottom
        anchors.left: title.left
        addressWidth: 180
        anchors.leftMargin: 0
        anchors.topMargin: 0
        store: walletHeader.store
    }

    NetworkFilter {
        id: networkFilter
        visible: walletHeader.walletStore.isMultiNetworkEnabled 
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.right: parent.right
        anchors.rightMargin: 63
        store: walletHeader.walletStore
    }

    Component {
        id: setCurrencyModalComponent
        SetCurrencyModal {
            onClosed: {
                destroy();
            }
        }
    }

    RowLayout {
        id: walletMenu

        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding

        spacing:  Style.current.bigPadding

        HeaderButton {
            id: settingsBtn
            imageSource: Style.svg("settings")
            flipImage: true
            text: ""
            onClicked: function () {
                if (newSettingsMenu.opened) {
                    newSettingsMenu.close()
                } else {
                    let x = settingsBtn.x + settingsBtn.width / 2 - newSettingsMenu.width / 2
                    newSettingsMenu.popup(x, settingsBtn.height)
                }
            }

            // TODO: replace with StatusPopupMenu
            PopupMenu {
                id: newSettingsMenu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                width: 176
                Action {
                    //% "Set Currency"
                    text: qsTrId("set-currency")
                    icon.source: Style.svg("currency")
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        Global.openPopup(setCurrencyModalComponent)
                    }
                }
            }
        }
    }
}
