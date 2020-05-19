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

            TextField {
                id: txtValue
                x: 19
                y: 41
                placeholderText: qsTr("Enter ETH")
                anchors.leftMargin: 24
                anchors.topMargin: 32
                width: 239
                height: 40
            }

            TextField {
                id: txtFrom
                x: 340
                y: 41
                width: 239
                height: 40
                text: assetsModel.getDefaultAccount()
                placeholderText: qsTr("Send from (account)")
                anchors.topMargin: 32
                anchors.leftMargin: 24
            }

            TextField {
                id: txtTo
                x: 340
                y: 99
                width: 239
                height: 40
                text: assetsModel.getDefaultAccount()
                placeholderText: qsTr("Send to")
                anchors.topMargin: 32
                anchors.leftMargin: 24
            }

            TextField {
                id: txtPassword
                x: 19
                y: 99
                width: 239
                height: 40
                text: "0x2cd9bf92c5e20b1b410f5ace94d963a96e89156fbe65b70365e8596b37f1f165"
                placeholderText: "Enter Password"
                anchors.topMargin: 32
                anchors.leftMargin: 24
            }

            Button {
                x: 19
                y: 159
                text: "Send"
                onClicked: {
                    let result = assetsModel.onSendTransaction(
                            txtFrom.text,
                            txtTo.text,
                            txtValue.text,
                            txtPassword.text
                            );
                    console.log(result);
                }
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
