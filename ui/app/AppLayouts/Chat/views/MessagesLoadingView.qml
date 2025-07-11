import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

ListView {
    spacing: 20
    interactive: false
    clip: true

    model: ListModel {
        Component.onCompleted: {
            var numElements = 20
            for (var i = 1; i < numElements; ++i) {
                if (i % 5 === 0)
                    append({ "isImage": true, "thirdLine": false })
                else if (i % 3 === 0)
                    append({ "isImage": false, "thirdLine": true })
                else
                    append({ "isImage": false, "thirdLine": false })
            }
        }
    }

    delegate: Item {

        implicitHeight: layoutContent.implicitHeight
        implicitWidth: layoutContent.implicitWidth

        RowLayout {
            id: layoutContent
            anchors.fill: parent
            spacing: 8

            LoadingComponent {
                Layout.alignment: Qt.AlignTop
                radius: width / 2
                height: 44
                width: 44
            }

            ColumnLayout {
                spacing: 4
                LoadingComponent {
                    radius: 4
                    height: 20
                    width: 124
                }
                LoadingComponent {
                    radius: 16
                    height: model.isImage ? 194 : 18
                    width: model.isImage ? 147 : 335
                }
                LoadingComponent {
                    visible: thirdLine
                    radius: 4
                    height: 18
                    width: 215
                }
            }
        }
    }
}

