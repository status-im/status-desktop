import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../imports"
import "../../shared"

SplitView {
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
        id: walletInfoContainer
        width: 340
        spacing: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        RowLayout {
            id: walletHeader
            height: 300
            Layout.fillWidth: true

            Rectangle {
                id: walletHeaderContent
                width: 200
                height: 200
                color: Theme.blue
                Layout.fillHeight: true
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
                    id: walletScreenButtons
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    currentIndex: 0
                    background: Rectangle {
                        color: "#00000000"
                    }

                    TabButton {
                        id: sendTabButton
                        height: 56
                        text: ""
                        anchors.bottom: depositTabButton.top
                        Layout.fillWidth: true
                        anchors.bottomMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
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
                        height: 56
                        text: ""
                        anchors.bottom: txHistoryTabButton.top
                        anchors.bottomMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
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
                        height: 56
                        text: ""
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
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
            }
        }
    }

    StackLayout {
        id: walletContainer
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
    D{i:0;autoSize:true;formeditorZoom:0.75;height:770;width:1152}D{i:4;anchors_x:140;anchors_y:93}
D{i:8;anchors_width:240}
}
##^##*/
