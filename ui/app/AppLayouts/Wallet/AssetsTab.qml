import QtQuick 2.0

Item {
    Component {
        id: assetViewDelegate

        Item {
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Image {
                id: assetInfoImage
                width: 36
                height: 36
                source: image
                anchors.left: parent.left
                anchors.leftMargin: Theme.padding
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: assetValue
                text: value
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                font.strikeout: false
                anchors.left: parent.left
                anchors.leftMargin: 72
            }
            Text {
                id: assetSymbol
                text: symbol
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.darkGrey
                font.pixelSize: 14
                anchors.right: assetFiatValue.left
                anchors.rightMargin: 10
            }
            Text {
                id: assetFiatValue
                color: Theme.darkGrey
                text: fiatValue
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                anchors.right: parent.right
                anchors.rightMargin: Theme.padding
            }
        }
    }


    ListView {
        id: assetListView
        anchors.topMargin: 0
        anchors.fill: parent
        model: assetsModel.assets
        delegate: assetViewDelegate
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
