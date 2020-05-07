import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: applicationWindow
    width: 1024
    height: 768
    title: "JSON RPC Caller"
    visible: true

    RowLayout {
        id: rowLayout
        width: parent.width
        height: parent.height
        anchors.fill: parent
//        spacing: 50

        TabBar {
            id: tabBar
            width: 50
            height: width *2 + spacing
            transformOrigin: Item.Top
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            anchors.top: parent.top
            anchors.topMargin: 5
            spacing: 5
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.preferredWidth: 50
            Layout.maximumWidth: 50
            Layout.minimumHeight: 0

            TabButton {
                id: firstBtn
                width: 50
                height: 50
                text: ""
                transformOrigin: Item.Center
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: image
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: "message.png"
                }
            }

            TabButton {
                id: secondBtn
                width: 50
                height: 50
                text: ""
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: firstBtn.bottom
                anchors.topMargin: parent.spacing

                Image {
                    id: image1
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: "wallet.png"
                }
            }

            TabButton {
                id: thirdBtn
                width: 50
                height: 50
                text: ""
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: secondBtn.bottom

                Image {
                    id: image2
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: "profile.png"
                }
            }
        }

        SplitView {
            Layout.fillHeight: true
//            anchors.fill: parent
//            width: parent.width
            Layout.leftMargin: 0
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.preferredWidth: 200
//            Layout.preferredHeight: 100

            Item {
                width: 300
                height: parent.height
                Layout.minimumWidth: 200

                Button {
                    id: button
                    text: qsTr("TEST BUTTON")
                }
            }

            Item {
                width: parent.width/2
                height: parent.height

                ColumnLayout {
                    anchors.fill: parent

                    RowLayout {
                        Layout.fillHeight: true
                        TextArea { id: callResult; Layout.fillWidth: true; text: logic.callResult; readOnly: true }
                    }

                    RowLayout {
                        Layout.bottomMargin: 20
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        transformOrigin: Item.Bottom
                        Label { text: "data2" }
                        TextField { id: txtData; Layout.fillWidth: true; text: "" }
                        Button {
                            text: "Send"
                            onClicked: logic.onSend(txtData.text)
                            enabled: txtData.text !== ""
                        }
                    }
                }

            }

        }
    }


}


/*##^##
Designer {
    D{i:4;anchors_height:40;anchors_width:40}D{i:6;anchors_height:40;anchors_width:40}
}
##^##*/
