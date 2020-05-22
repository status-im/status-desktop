import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"

ColumnLayout {
    readonly property int w: 340
    property alias currentTab: walletScreenButtons.currentIndex

    id: walletInfoContainer
    width: w
    spacing: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0

    RowLayout {
        id: walletHeader
        height: 375
        Layout.fillWidth: true
        width: walletInfoContainer.w

        Rectangle {
            id: walletHeaderContent
            color: Theme.blue
            height: 375
            Layout.fillWidth: true

            Item {
                id: walletValueTextContainer
                x: 140
                width: 175
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 110

                Text {
                    id: tild
                    color: Theme.lightBlueText
                    text: qsTr("~")
                    font.weight: Font.Medium
                    font.pixelSize: 30
                }

                TextEdit {
                    id: walletAmountValue
                    color: "#ffffff"
                    text: qsTr("408.30")
                    selectByMouse: true
                    cursorVisible: true
                    readOnly: true
                    anchors.left: tild.right
                    anchors.leftMargin: 1
                    font.weight: Font.Medium
                    font.pixelSize: 30
                }

                Text {
                    id: currencyText
                    color: Theme.lightBlueText
                    text: qsTr("USD")
                    anchors.left: walletAmountValue.right
                    anchors.leftMargin: 5
                    font.weight: Font.Medium
                    font.pixelSize: 30
                }
            }

            TabBar {
                readonly property int btnHeight: 56

                id: walletScreenButtons
                width: walletInfoContainer.w
                height: btnHeight*3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                currentIndex: 0
                spacing: 0
                background: Rectangle {
                    color: "#00000000"
                }

                TabButton {
                    id: sendTabButton
                    width: walletInfoContainer.w
                    height: walletScreenButtons.btnHeight
                    text: ""
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    background: Rectangle {
                        color: parent.checked ? Theme.darkBlue : Theme.transparent
                    }
                    Text {
                        id: element
                        color: "#ffffff"
                        text: qsTr("Send")
                        anchors.left: parent.left
                        anchors.leftMargin: 72
                        anchors.verticalCenter: parent.verticalCenter
                        font.weight: Font.Bold
                        font.pixelSize: 14
                    }


                    RoundedIcon {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        imgPath: "../../img/diagonalArrow.svg"
                        anchors.verticalCenter: parent.verticalCenter
                        size: 36
                        bg: "#19ffffff"
                    }
                }

                TabButton {
                    id: depositTabButton
                    width: walletInfoContainer.w
                    height: walletScreenButtons.btnHeight
                    text: ""
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.top: sendTabButton.bottom
                    background: Rectangle {
                        color: parent.checked ? Theme.darkBlue : Theme.transparent
                    }

                    Text {
                        id: element2
                        color: "#ffffff"
                        text: qsTr("Deposit")
                        anchors.left: parent.left
                        anchors.leftMargin: 72
                        anchors.verticalCenter: parent.verticalCenter
                        font.weight: Font.Bold
                        font.pixelSize: 14
                    }


                    RoundedIcon {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        imgPath: "../../img/diagonalArrowDown.svg"
                        anchors.verticalCenter: parent.verticalCenter
                        size: 36
                        bg: "#19ffffff"
                    }
                }

                TabButton {
                    id: txHistoryTabButton
                    width: walletInfoContainer.w
                    height: walletScreenButtons.btnHeight
                    text: ""
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.top: depositTabButton.bottom
                    background: Rectangle {
                        color: parent.checked ? Theme.darkBlue : Theme.transparent
                    }
                    Text {
                        id: element3
                        color: "#ffffff"
                        text: qsTr("Transaction History")
                        anchors.left: parent.left
                        anchors.leftMargin: 72
                        anchors.verticalCenter: parent.verticalCenter
                        font.weight: Font.Bold
                        font.pixelSize: 14
                    }


                    RoundedIcon {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        imgPath: "../../img/list.svg"
                        anchors.verticalCenter: parent.verticalCenter
                        size: 36
                        bg: "#19ffffff"
                    }
                }
            }
        }
    }

    RowLayout {
        id: assetInfoContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            id: walletSendBg
            color: "#ffffff"
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: assetsTitle
                color: Theme.darkGrey
                text: qsTr("Assets")
                anchors.left: parent.left
                anchors.leftMargin: Theme.padding
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
    D{i:0;formeditorZoom:0.8999999761581421;height:770;width:340}
}
##^##*/
