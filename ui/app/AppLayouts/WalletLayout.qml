import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../imports"
import "../../shared"

Item {
    id: walletView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true
    // Those anchors show a warning too, but whithout them, there is a gap on the right
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0

    ColumnLayout {
        readonly property int w: 340

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
                            imgPath: "../img/diagonalArrow.svg"
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
                            imgPath: "../img/diagonalArrowDown.svg"
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
                            imgPath: "../img/list.svg"
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
            width: 100
            height: 100

            Rectangle {
                id: walletSendBg
                width: 200
                height: 200
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

                        Rectangle {
                            width: 36
                            height: 36
                            color: Theme.blue
                            radius: 50
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

                // Delete this when we have a real model
                ListModel {
                    id: exampleAssets
                    ListElement {
                        name: "Ethereum"
                        symbol: "ETH"
                        value: "0.4564234124124..."
                        fiatValue: "$268.30"
                        image: ""
                    }
                }

                ListView {
                    id: listView
                    anchors.topMargin: 36
                    anchors.fill: parent
                    // Change this to the real model
                    model: exampleAssets
                    delegate: assetViewDelegate
                }
            }
        }
    }

    StackLayout {
        id: walletContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: walletInfoContainer.right
        anchors.leftMargin: 0
        currentIndex: walletScreenButtons.currentIndex

        Item {
            id: sendContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element1
                text: qsTr("Send")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: depositContainer
            width: 200
            height: 200
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                id: element4
                text: qsTr("Deposit")
                font.weight: Font.Bold
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pixelSize: 20
                anchors.left: parent.left
                anchors.top: parent.top
            }
        }

        Item {
            id: txHistoryContainer
            width: 200
            height: 200
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                id: element5
                text: qsTr("Transaction History")
                font.weight: Font.Bold
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pixelSize: 20
                anchors.left: parent.left
                anchors.top: parent.top
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:770;width:1152}D{i:10;anchors_width:340}
}
##^##*/
