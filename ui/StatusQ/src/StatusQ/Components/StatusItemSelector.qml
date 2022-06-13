import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property string icon
    property int iconSize: 18
    property string title
    property string defaultItemText

    signal addItem()

    color: Theme.palette.baseColor4
    height: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    radius: 16
    ColumnLayout {
        id: column
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.bottomMargin: anchors.topMargin
        anchors.left: parent.left
        anchors.leftMargin: 16
        spacing: 12
        RowLayout {
            spacing: 8
            Image {
                sourceSize.width: width || undefined
                sourceSize.height: height || undefined
                fillMode: Image.PreserveAspectFit
                mipmap: true
                antialiasing: true
                width: root.iconSize
                height: width
                source: root.icon
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: root.title
                color: Theme.palette.directColor1
                font.pixelSize: 17
            }
        }
        // TODO: Next component iteration - model and selector
        GridLayout {
            rowSpacing: 6
            columnSpacing: 12
            Repeater {
                model: 1
                StatusListItemTag {
                    title: root.defaultItemText
                    color: Theme.palette.baseColor2
                    closeButtonVisible: false
                    titleText.color: Theme.palette.baseColor1
                    titleText.font.pixelSize: 15
                }
            }
            StatusRoundButton {
                implicitHeight: 32
                implicitWidth: implicitHeight
                height: width
                type: StatusRoundButton.Type.Secondary
                icon.name: "add"
                onClicked: root.addItem()
            }
        }
    }
}
