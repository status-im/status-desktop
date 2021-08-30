import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import "../../../imports"
import "../../../shared"
import "./components"

Rectangle {
    id: walletInfoContainer
    color: Style.current.secondaryMenuBackground
    property int selectedAccount: 0
    property var changeSelectedAccount: function(newIndex) {
        if (newIndex > walletV2Model.accountsView.accounts) {
            return
        }
        selectedAccount = newIndex
        walletV2Model.setCurrentAccountByIndex(newIndex)
    }

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
            text: Utils.toLocaleString("0.00", globalSettings.locale, {"currency": true}) + " " + "USD"
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        StyledText {
            id: totalValue
            color: Style.current.secondaryText
            //% "Total value"
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
            property bool selected: index === selectedAccount
            property bool hovered

            id: rectangle
            height: 64
            color: {
              if (selected) {
                  return Style.current.menuBackgroundActive
              }
              if (hovered) {
                  return Style.current.backgroundHoverLight
              }
              return Style.current.transparent
            }
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
                color: Utils.getCurrentThemeAccountColor(iconColor) || Style.current.accountColors[0]
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
                color: Style.current.textColor
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
                anchors.left: walletIcon.left
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Style.current.secondaryText
                opacity: selected ? 0.7 : 1
            }
            StyledText {
                id: walletBalance
                text: isLoading ? "..." : Utils.toLocaleString(fiatBalance, globalSettings.locale, {"currency": true}) + " " + "USD"
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Style.current.textColor
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    rectangle.hovered = true                    
                }
                onExited: {
                    rectangle.hovered = false
                }
                onClicked: {
                    walletInfoContainer.changeSelectedAccount(index)
                }
            }
        }
    }

    ScrollView {
        id: accountsList
        anchors.right: parent.right
        anchors.left: parent.left
        height: (listView.count <= 8) ? (listView.count * 64) : 530
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Style.current.padding
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: listView
            anchors.fill: parent
            spacing: 5
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

            model: walletV2Model.accountsView.accounts
        }
    }

    AddAccount {
        id: addAccountButton
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: accountsList.bottom
        anchors.topMargin: 31
    }

    RowLayout {
        id: savedAdressesLabel
        height: 20
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        StatusIcon {
            color: Theme.palette.baseColor1
            Layout.alignment: Qt.AlignVCenter
            icon: "address"
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Saved addresses")
            color: Theme.palette.baseColor1
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:0.75;height:770;width:340}
}
##^##*/
