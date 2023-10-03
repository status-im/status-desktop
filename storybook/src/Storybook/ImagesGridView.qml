import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

GridView {
    id: root

    cellWidth: 400
    cellHeight: 300

    signal clicked(int index)

    delegate: Item {
        width: root.cellWidth
        height: root.cellHeight

        Frame {
            anchors.fill: parent
            anchors.margins: padding / 2

            Image {
                id: image

                anchors.fill: parent
                mipmap: true

                source: model.imageLink
                fillMode: Image.PreserveAspectFit
            }

            BusyIndicator {
                anchors.centerIn: parent
                running: image.status !== Image.Ready
            }

            MouseArea {
                anchors.fill: parent

                onClicked: root.clicked(model.index)
            }

            RoundButton {
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                text: "🔗"

                onClicked: Qt.openUrlExternally(model.rawLink)

                ToolTip.delay: 1500
                ToolTip.visible: hovered
                ToolTip.text: model.rawLink
            }
        }
    }
}
