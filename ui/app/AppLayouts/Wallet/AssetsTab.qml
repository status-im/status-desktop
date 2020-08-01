import QtQuick 2.13
import "../../../imports"
import "../../../shared"

Item {
    Component {
        id: assetViewDelegate

        Item {
            id: element
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            height: 40

            Image {
                id: assetInfoImage
                width: 36
                height: 36
                source: symbol ? "../../img/tokens/" + symbol + ".png" : ""
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                onStatusChanged: {
                    if (assetInfoImage.status == Image.Error) {
                        assetInfoImage.source = "../../img/tokens/0-native.png"
                    }
                }
            }
            StyledText {
                id: assetSymbol
                text: symbol
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.top: assetInfoImage.top
                anchors.topMargin: 0
                font.pixelSize: 15
            }
            StyledText {
                id: assetFullTokenName
                text: name
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                color: Style.current.grey
                font.pixelSize: 15
            }
            StyledText {
                id: assetValue
                text: value.toUpperCase()
                anchors.right: parent.right
                anchors.rightMargin: 0
                font.pixelSize: 15
                font.strikeout: false
            }
            StyledText {
                id: assetFiatValue
                color: Style.current.grey
                text: fiatValue.toUpperCase()
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                font.pixelSize: 15
            }
        }
    }

    ListModel {
        id: exampleModel

        ListElement {
            value: "123 USD"
            symbol: "ETH"
            fullTokenName: "Ethereum"
            fiatValue: "3423 ETH"
            image: "../../img/token-icons/eth.svg"
        }
    }

    ListView {
        id: assetListView
        anchors.topMargin: 20
        anchors.fill: parent
//        model: exampleModel
        model: walletModel.assets
        delegate: assetViewDelegate
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
