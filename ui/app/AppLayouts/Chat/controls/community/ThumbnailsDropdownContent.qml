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

    implicitHeight: Math.min(grid.implicitHeight, root.maxHeight)
    implicitWidth: d.imageSize * d.columns + grid.columnSpacing * (d.columns - 1)
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

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
                        source: model.imageSource ?  model.imageSource :  ""
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
                    elide: Text.ElideRight
                }
            }
        }
    }
}
