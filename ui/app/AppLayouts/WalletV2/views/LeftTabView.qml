import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

Rectangle {
    id: walletInfoContainer
    color: Style.current.secondaryMenuBackground

    property var store
    signal savedAddressesClicked(bool selected)

    StyledText {
        id: title
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
        text: qsTrId("wallet")
    }

    Item {
        id: walletValueTextContainer
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        height: childrenRect.height

        StyledTextEdit {
            id: walletAmountValue
            color: Style.current.textColor
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            font.weight: Font.Medium
            font.pixelSize: 30
            //TOOD improve this to not use dynamic scoping
            text: Utils.toLocaleString("0.00", globalSettings.locale, {"currency": true}) + " " + "USD"
        }

        StyledText {
            id: totalValue
            color: Style.current.secondaryText
            text: qsTrId("wallet-total-value")
            anchors.left: walletAmountValue.left
            anchors.top: walletAmountValue.bottom
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }


    Component {
        id: walletDelegate

        Rectangle {
            id: rectangle
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            height: 64
            property bool selected: (index === walletInfoContainer.store.selectedAccount)
            property bool hovered
            color: selected ? Style.current.menuBackgroundActive :
                   hovered ? Style.current.backgroundHoverLight
                   : Style.current.transparent
            radius: Style.current.radius

            SVGImage {
                id: walletIcon
                width: 12
                height: 12
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                source: Style.svg("walletIcon")
            }
            ColorOverlay {
                anchors.fill: walletIcon
                source: walletIcon
                color: Utils.getCurrentThemeAccountColor(iconColor) || Style.current.accountColors[0]
            }
            StyledText {
                id: walletName
                elide: Text.ElideRight
                anchors.right: walletBalance.left
                anchors.rightMargin: Style.current.smallPadding
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: walletIcon.right
                anchors.leftMargin: Style.current.smallPadding

                font.pixelSize: 15
                font.weight: Font.Medium
                color: Style.current.textColor
                text: name
            }
            StyledText {
                id: walletAddress
                font.family: Style.current.fontHexRegular.name
                anchors.right: parent.right
                anchors.rightMargin: parent.width/2
                elide: Text.ElideMiddle
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.smallPadding
                anchors.left: walletIcon.left
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Style.current.secondaryText
                opacity: selected ? 0.7 : 1
                text: address
            }
            StyledText {
                id: walletBalance
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Style.current.textColor
                text: isLoading ? "..." : Utils.toLocaleString(fiatBalance, globalSettings.locale, {"currency": true}) + " " + "USD"
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    rectangle.hovered = true;
                }
                onExited: {
                    rectangle.hovered = false;
                }
                onClicked: {
                    walletInfoContainer.store.changeSelectedAccount(index);
                }
            }
        }
    }

    ScrollView {
        id: accountsList
        anchors.right: parent.right
        anchors.left: parent.left
        height: (listView.count <= 8) ? ((listView.count * 64) + (Style.current.padding * 2)) : 530
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Style.current.padding
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: listView
            clip: true
            anchors.fill: parent
            spacing: 5
            boundsBehavior: Flickable.StopAtBounds
            model: walletInfoContainer.store.walletModelV2Inst.accountsView.accounts
            delegate: walletDelegate
            ListModel {
                id: exampleWalletModel
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }

                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#FA6565"
                }
                ListElement {
                    name: "Status account"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }

                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#FA6565"
                }
                ListElement {
                    name: "Status account"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }

                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#FA6565"
                }
                ListElement {
                    name: "Status account"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }
                ListElement {
                    name: "Status account"
                    address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }

                ListElement {
                    name: "Test account 1"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#FA6565"
                }
                ListElement {
                    name: "Status account 12"
                    address: "0x2Ef1...E0Ba"
                    balance: "12.00 USD"
                    iconColor: "#7CDA00"
                }
            }
        }
    }

    AddAccountView {
        id: addAccountButton
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: accountsList.bottom
        anchors.topMargin: 31
        store: walletInfoContainer.store
    }
    StatusNavigationListItem {
        id: btnSavedAddresses
        title: qsTr("Saved addresses")
        icon.name: "address"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.smallPadding

        onClicked: {
            selected = !selected;
            walletInfoContainer.savedAddressesClicked(selected);
        }
    }
}
