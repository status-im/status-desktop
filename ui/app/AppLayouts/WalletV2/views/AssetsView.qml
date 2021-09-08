import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../imports"
import "../../../../shared"
import StatusQ.Core 0.1

Item {
    id: root
    signal assetClicked(string name)

    Component {
        id: assetViewDelegate

        Item {
            id: element
            anchors.right: parent.right
            anchors.left: parent.left
            height: 40

            Image {
                id: assetInfoImage
                width: 36
                height: 36
                source: symbol ? "../../../img/tokens/" + symbol + ".png" : ""
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                onStatusChanged: {
                    if (assetInfoImage.status == Image.Error) {
                        assetInfoImage.source = "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                    }
                }
            }
            StatusBaseText {
                id: assetSymbol
                text: symbol
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.top: assetInfoImage.top
                anchors.topMargin: 0
                font.pixelSize: 15
            }
            StatusBaseText {
                id: assetFullTokenName
                text: name
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                color: Style.current.secondaryText
                font.pixelSize: 15
            }
            StatusBaseText {
                id: assetValue
                text: value.toUpperCase() + " " + symbol
                anchors.right: parent.right
                anchors.rightMargin: 0
                font.pixelSize: 15
                font.strikeout: false
            }
            StatusBaseText {
                id: assetFiatValue
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
                    root.assetClicked(name);
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
            image: "../../../img/token-icons/eth.svg"
        }
    }

    ScrollView {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: assetListView.contentHeight > assetListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: assetListView
            spacing: Style.current.padding * 2
            anchors.fill: parent
            //model: exampleModel
            model: walletModel.tokensView.assets
            delegate: assetViewDelegate
            boundsBehavior: Flickable.StopAtBounds
        }
    }
}
