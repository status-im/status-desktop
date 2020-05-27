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
            id: walletInfoContainer
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
                text: "qwerty"
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

    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:770;width:1152}
}
##^##*/
