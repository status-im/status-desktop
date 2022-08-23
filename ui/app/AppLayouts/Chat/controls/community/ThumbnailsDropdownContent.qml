import QtQuick 2.0
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1

StatusScrollView {
    id: root

    property string title: ""
    property url titleImage: ""
    property string subtitle: ""
    property ListModel model
    property int maxHeight: 381 // default by design

    signal itemClicked(var key, string name, url iconSource)

    QtObject {
        id: d
        readonly property int imageSize: 133
        readonly property int columns: 2
    }

    implicitHeight: Math.min(column.implicitHeight, root.maxHeight)
    implicitWidth: d.imageSize * d.columns + grid.columnSpacing * (d.columns - 1)
    clip: true
    flickDeceleration: Flickable.VerticalFlick

    ColumnLayout {
        id: column
        spacing: 4
        Item {
            Layout.fillWidth: true
            height: 45 // by design
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                spacing: 8
                StatusRoundedImage {
                    Layout.alignment: Qt.AlignVCenter
                    image.source: root.titleImage
                    visible: root.titleImage.toString() !== ""
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0
                    StatusBaseText {
                        Layout.fillWidth: true
                        text: root.title
                        color: Theme.palette.directColor1
                        font.pixelSize: 13
                        clip: true
                        elide: Text.ElideRight
                    }
                    StatusBaseText {
                        visible: root.subtitle
                        Layout.fillWidth: true
                        text: root.subtitle
                        color: Theme.palette.baseColor1
                        font.pixelSize: 12
                        clip: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
        GridLayout {
            id: grid
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            columnSpacing: 8
            rowSpacing: 12
            columns: d.columns
            Repeater {
                model: root.model
                delegate: ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 133
                        Layout.preferredHeight: 133
                        color: "transparent"
                        Image {
                            source: model.imageSource
                            anchors.fill: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: { root.itemClicked(model.key, model.name, model.iconSource) }
                        }
                    }
                    StatusBaseText {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 8
                        text: model.name
                        color: Theme.palette.directColor1
                        font.pixelSize: 13
                        clip: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
