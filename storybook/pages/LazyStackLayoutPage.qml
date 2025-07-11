import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Utils

ColumnLayout {
    anchors.fill: parent

    LazyStackLayout {
        id: lazyStackLayout

        currentIndex: indicator.currentIndex

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 100

        Component {
            Rectangle {
                color: "green"

                Component.onCompleted: console.log("GREEN LOADED")
            }
        }

        Component {
            Rectangle {
                color: "red"

                Component.onCompleted: console.log("RED LOADED")
            }
        }

        Component {
            Rectangle {
                color: "yellow"

                Component.onCompleted: console.log("YELLOW LOADED")
            }
        }
    }

    PageIndicator {
        id: indicator

        Layout.alignment: Qt.AlignHCenter

        count: lazyStackLayout.count
        interactive: true

        delegate: Rectangle {
            width: 40
            height: 40
            radius: 20
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: index
            }
        }
    }
}

// category: Controls
