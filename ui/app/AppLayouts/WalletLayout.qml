import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../imports"

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

    ColumnLayout {
        id: walletSendContainer
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:770;width:1152}D{i:4;anchors_x:140;anchors_y:93}
}
##^##*/
