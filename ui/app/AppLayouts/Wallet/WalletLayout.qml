import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "."

SplitView {
    id: walletView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    LeftTab {
        id: leftTab
    }

    Item {
        id: walletContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: leftTab.right
        anchors.leftMargin: 0

        WalletHeader {
            id: walletHeader
        }

        RowLayout {
            id: assetInfoContainer
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: walletHeader.bottom
            anchors.topMargin: 23
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: assetsTitle
                color: Theme.darkGrey
                text: qsTr("Assets")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                font.pixelSize: 14
            }

            Component {
                id: assetViewDelegate

                Item {
                    id: element6
                    height: 56
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0

                    Image {
                        id: assetInfoContainer
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
                id: listView
                anchors.topMargin: 36
                anchors.fill: parent
                model: assetsModel.assets
                delegate: assetViewDelegate
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.8999999761581421;height:770;width:1152}
D{i:16;anchors_x:0;anchors_y:0}
}
##^##*/

