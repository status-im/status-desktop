import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0
import "../../../../shared"
import StatusQ.Core 0.1

Item {
    id: root
    property var tokensModel
    signal tokenClicked(string name)

    Component {
        id: tokenViewDelegate

        Item {
            id: element
            anchors.right: parent.right
            anchors.left: parent.left
            height: 40

            Image {
                id: tokenInfoImage
                width: 36
                height: 36
                source: symbol ? Style.png("tokens/" + symbol) : ""
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                onStatusChanged: {
                    if (assetInfoImage.status == Image.Error) {
                        assetInfoImage.source = Style.png("tokens/DEFAULT-TOKEN@3x")
                    }
                }
            }
            StatusBaseText {
                id: tokenSymbol
                text: symbol
                anchors.left: tokenInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.top: tokenInfoImage.top
                anchors.topMargin: 0
                font.pixelSize: 15
            }
            StatusBaseText {
                id: tokenFullTokenName
                text: name
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: tokenInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                color: Style.current.secondaryText
                font.pixelSize: 15
            }
            StatusBaseText {
                id: tokenValue
                text: value.toUpperCase() + " " + symbol
                anchors.right: parent.right
                anchors.rightMargin: 0
                font.pixelSize: 15
                font.strikeout: false
            }
            StatusBaseText {
                id: tokenFiatValue
                color: Style.current.secondaryText
                text: Utils.toLocaleString(fiatBalance, globalSettings.locale) + " " + walletModel.balanceView.defaultCurrency.toUpperCase()
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                font.pixelSize: 15
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.tokenClicked(name);
                }
            }
        }
    }

    ListModel {
        id: exampleModel
        ListElement {
            name: "test"
            fiatBalance: "2000 USD"
            value: "123 USD"
            symbol: "ETH"
            fullTokenName: "Ethereum"
            fiatBalanceDisplay: "3423 ETH"
            image: "token-icons/eth"
        }
    }

    ScrollView {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: tokenListView.contentHeight > tokenListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: tokenListView
            spacing: Style.current.padding * 2
            anchors.fill: parent
            //model: exampleModel
            model: root.tokensModel
            delegate: tokenViewDelegate
            boundsBehavior: Flickable.StopAtBounds
        }
    }
}
