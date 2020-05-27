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

        Item {
            id: walletHeader
            height: walletAddress.y + walletAddress.height
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: title
                // TODO this should be the name of the wallet
                text: qsTr("Status account")
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
                color: Theme.blue
                anchors.top: title.verticalCenter
                anchors.topMargin: -3
                anchors.left: title.right
                anchors.leftMargin: 8
                radius: 50
            }

            Text {
                id: walletBalance
                // TODO this should be the balance
                text: qsTr("12.00 USD")
                anchors.left: separatorDot.right
                anchors.leftMargin: 8
                anchors.verticalCenter: title.verticalCenter
                font.pixelSize: 22
            }

            Text {
                id: walletAddress
                // TODO this should be the address and an actual Address component that can shrink and expend
                text: qsTr("0X2Ef1...E0Ba")
                anchors.top: title.bottom
                anchors.topMargin: 0
                anchors.left: title.left
                anchors.leftMargin: 0
                font.pixelSize: 13
                color: Theme.darkGrey
            }

            Item {
                property int btnMargin: 8
                property int btnOuterMargin: 32
                id: walletMenu
                // TODO unhardcode this
                width: sendBtn.width + receiveBtn.width + settingsBtn.width
                       + walletMenu.btnOuterMargin * 2
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16

                Item {
                    id: sendBtn
                    width: sendImg.width + sendText.width + walletMenu.btnMargin

                    Image {
                        id: sendImg
                        width: 12
                        height: 12
                        fillMode: Image.PreserveAspectFit
                        source: "../../img/diagonalArrow.svg"
                    }

                    Text {
                        id: sendText
                        text: "Send"
                        anchors.left: sendImg.right
                        anchors.leftMargin: walletMenu.btnMargin
                        font.pixelSize: 13
                        color: Theme.blue
                    }
                }
                Item {
                    id: receiveBtn
                    width: receiveImg.width + receiveText.width + walletMenu.btnMargin
                    anchors.left: sendBtn.right
                    anchors.leftMargin: walletMenu.btnOuterMargin

                    Image {
                        id: receiveImg
                        width: 12
                        height: 12
                        fillMode: Image.PreserveAspectFit
                        source: "../../img/diagonalArrow.svg"
                    }

                    Text {
                        id: receiveText
                        text: "Receive"
                        anchors.left: receiveImg.right
                        anchors.leftMargin: walletMenu.btnMargin
                        font.pixelSize: 13
                        color: Theme.blue
                    }
                }
                Image {
                    id: settingsBtn
                    anchors.left: receiveBtn.right
                    anchors.leftMargin: walletMenu.btnOuterMargin
                    width: 18
                    height: 18
                    fillMode: Image.PreserveAspectFit
                    source: "../../img/settings.svg"
                }
            }
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

