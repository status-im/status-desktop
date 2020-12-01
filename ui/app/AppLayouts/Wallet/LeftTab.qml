import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"
import "./components"

Item {
    property int selectedAccount: 0
    property var changeSelectedAccount: function(newIndex) {
        if (newIndex > walletModel.accounts) {
            return
        }
        selectedAccount = newIndex
        walletModel.setCurrentAccountByIndex(newIndex)
        walletTabBar.currentIndex = 0;
    }
    id: walletInfoContainer



    StyledText {
        id: title
        //% "Wallet"
        text: qsTrId("wallet")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
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
            text: Utils.toLocaleString(walletModel.totalFiatBalance, appSettings.locale) + " " + walletModel.defaultCurrency.toUpperCase()
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        StyledText {
            id: totalValue
            color: Style.current.darkGrey
            //% "Total value"
            text: qsTrId("wallet-total-value")
            anchors.left: walletAmountValue.left
            anchors.top: walletAmountValue.bottom
            font.weight: Font.Medium
            font.pixelSize: 13
        }

        AddAccount {
            anchors.top: parent.top
            anchors.right: parent.right
        }
    }


    Component {
        id: walletDelegate

        Rectangle {
            property bool selected: index == selectedAccount

            id: rectangle
            height: 64
            color: selected ? iconColor : Style.current.transparent
            radius: Style.current.radius
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding

            SVGImage {
                id: walletIcon
                width: 12
                height: 12
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                source: "../../img/walletIcon.svg"
            }
            ColorOverlay {
                anchors.fill: walletIcon
                source: walletIcon
                color: selected || !iconColor ? Style.current.white : iconColor  // change image color
            }
            StyledText {
                id: walletName
                text: name
                elide: Text.ElideRight
                anchors.right: walletBalance.left
                anchors.rightMargin: Style.current.smallPadding
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: walletIcon.right
                anchors.leftMargin: Style.current.smallPadding

                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Style.current.white : Style.current.textColor
            }
            StyledText {
                id: walletAddress
                font.family: Style.current.fontHexRegular.name
                text: address
                anchors.right: parent.right
                anchors.rightMargin: parent.width/2
                elide: Text.ElideMiddle
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.smallPadding
                anchors.left: walletName.left
                anchors.leftMargin: 0
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Style.current.white : Style.current.darkGrey
                opacity: selected ? 0.7 : 1
            }
            StyledText {
                id: walletBalance
                text: Utils.toLocaleString(fiatBalance, appSettings.locale) + " " + walletModel.defaultCurrency.toUpperCase()
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Style.current.white : Style.current.textColor
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    changeSelectedAccount(index)
                }
            }
        }
    }

    ScrollView {
        anchors.bottom: parent.bottom
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.left: parent.left
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: listView

            spacing: 5
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds

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
            }

            model: walletModel.accounts
            //        model: exampleWalletModel
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:0.75;height:770;width:340}
}
##^##*/
