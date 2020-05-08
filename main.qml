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
            currentIndex: 0
            topPadding: 57
            rightPadding: 19
            leftPadding: 19
            transformOrigin: Item.Top
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            anchors.top: parent.top
            anchors.topMargin: 5
            spacing: 5
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.preferredWidth: 80
            Layout.maximumWidth: 80
            Layout.minimumHeight: 0

            TabButton {
                id: firstBtn
                x: 0
                width: 40
                height: 40
                text: ""
                padding: 0
                transformOrigin: Item.Center
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    color: "#ECEFFC"
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/messageActive.svg" : "img/message.svg"
                }
            }

            TabButton {
                id: secondBtn
                width: 40
                height: 40
                text: ""
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: firstBtn.top
                background: Rectangle {
                    color: "#ECEFFC"
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/walletActive.svg" : "img/wallet.svg"
                }
            }

            TabButton {
                id: thirdBtn
                width: 40
                height: 40
                text: ""
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: secondBtn.top
                background: Rectangle {
                    color: "#ECEFFC"
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/profileActive.svg" : "img/profile.svg"
                }
            }
        }

        StackLayout {
            width: parent.width
            Layout.fillWidth: true
            currentIndex: tabBar.currentIndex

            SplitView {
                id: splitView
                x: 9
                y: 0
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
                        anchors.rightMargin: 0
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

                ColumnLayout {
                    anchors.fill: parent

                    RowLayout {
                        Layout.fillHeight: true
                        TextArea { id: accountResult; Layout.fillWidth: true; text: logic.accountResult; readOnly: true }
                    }
                }

            Item {

            }
        }
    }


}


/*##^##
Designer {
    D{i:0;formeditorZoom:1.5}D{i:8;anchors_height:40;anchors_width:40}
}
##^##*/
