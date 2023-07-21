import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import AppLayouts.Communities.popups 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    SplitView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        Pane {
            id: mainPane
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: popupComponent.createObject(mainPane)
            }
            Component.onCompleted: popupComponent.createObject(mainPane)
        }
        Pane {
            SplitView.preferredWidth: 300

            contentItem: ColumnLayout {

                Label {
                    text: "Matching private key"
                }
                TextEdit {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                    }

                    id: matchingPrivateKey
                    Layout.fillWidth: true
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    text: "0x0454f2231543ba02583e4c55e513a75092a4f2c86c04d0796b195e964656d6cd"
                }

                Button {
                    text: "Copy"
                    onClicked: {
                        matchingPrivateKey.selectAll()
                        matchingPrivateKey.copy()
                        matchingPrivateKey.deselect()
                    }
                }

                Label {
                    text: "Mismatching private key"
                }
                TextEdit {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                    }

                    id: mismatchingPrivateKey
                    Layout.fillWidth: true
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    text: "0x0454f2231543ba02583e4c55e513a75092a4f2c86c04d0796b195e964656d6ce"
                }

                Button {
                    text: "Copy"
                    onClicked: {
                        mismatchingPrivateKey.selectAll()
                        mismatchingPrivateKey.copy()
                        mismatchingPrivateKey.deselect()
                    }
                }

                Label {
                    text: "Load in progress private key"
                }

                TextEdit {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                    }

                    id: loadInProgressPrivateKey
                    Layout.fillWidth: true
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    text: "0x0454f2231543ba02583e4c55e513a75092a4f2c86c04d0796b195e964656d6ca"
                }

                Button {
                    text: "Copy"
                    onClicked: {
                        loadInProgressPrivateKey.selectAll()
                        loadInProgressPrivateKey.copy()
                        loadInProgressPrivateKey.deselect()
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    QtObject {
        id: d
        readonly property var community: QtObject {
            property string id: "1"
            property string name: "Socks"
            property var members: { "count": 5 }
            property string image: Style.png("tokens/UNI")
            property string color: "orchid"
        }

        readonly property var otherCommunity: QtObject {
            property string id: "2"
            property string name: "Socks"
            property var members: { "count": 5 }
            property string image: Style.png("tokens/UNI")
            property string color: "orchid"
        }

        readonly property Timer timer: Timer {
            //id: _timer
            interval: 1000
            repeat: false
            function callWithDelay(cb) {
                d.timer.triggered.connect(cb);
                d.timer.triggered.connect(function release () {
                    d.timer.triggered.disconnect(cb);
                    d.timer.triggered.disconnect(release);
                });
                d.timer.start();
            }
        }
    }

    Component {
        id: popupComponent
        ImportControlNodePopup {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true

            onRequestCommunityInfo: {
                logs.logEvent("ImportControlNodePopup::onRequestCommunityInfo", ["private key"], [privateKey])
                if(privateKey === matchingPrivateKey.text)
                    d.timer.callWithDelay(() => popup.setCommunityInfo(d.community))
                else if (privateKey === mismatchingPrivateKey.text)
                    d.timer.callWithDelay(() => popup.setCommunityInfo(d.otherCommunity))
            }

            community: d.community
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}
