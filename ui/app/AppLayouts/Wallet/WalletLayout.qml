import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "."

Item {
    id: walletView
    x: 0
    y: 0
    property alias walletContainerCurrentIndex: walletContainer.currentIndex
    Layout.fillHeight: true
    Layout.fillWidth: true
    // Those anchors show a warning too, but whithout them, there is a gap on the right
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0

    LeftTab {
        id: leftTab
    }

    StackLayout {
        id: walletContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: leftTab.right
        anchors.leftMargin: 0
        currentIndex: leftTab.currentTab

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
    D{i:0;autoSize:true;formeditorZoom:0.75;height:770;width:1152}
}
##^##*/
