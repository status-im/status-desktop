import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

Control {
    id: root

    property alias image: imageItem.source
    property alias title: titleItem.text
    property alias subtitle: subtitleItem.text
    property alias checkersModel: checkersItems.model

    property int imageWidth: 256
    property int imageHeigth: root.imageWidth
    property int imageBottomMargin: 0

    padding: Theme.padding
    bottomPadding: Theme.xlPadding

    QtObject {
        id: d

        readonly property int rowChildSpacing: 10
        readonly property color rowIconColor: Theme.palette.primaryColor1
        readonly property string rowIconName: "checkmark-circle"
        readonly property int rowFontSize: 15
        readonly property color rowTextColor: Theme.palette.directColor1
        readonly property double rowTextLineHeight: 1.2
    }

    background: Rectangle {
        color: "transparent"
        radius: 16
        border.color: Theme.palette.baseColor2
    }

    contentItem: ColumnLayout {
        Image {
            id: imageItem

            objectName: "welcomeSettingsImage"

            Layout.preferredWidth: root.imageWidth
            Layout.preferredHeight: root.imageHeigth
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: root.imageBottomMargin
            Layout.fillWidth: true

            fillMode: Image.PreserveAspectFit
            mipmap: true
            cache: false
        }

        StatusBaseText {
            id: titleItem

            objectName: "welcomeSettingsTitle"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.secondaryAdditionalTextSize
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: subtitleItem
            objectName: "welcomeSettingsSubtitle"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.2
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            id: checkersColumn

            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 10

            Repeater {
                id: checkersItems

                objectName: "checkListItem"

                RowLayout {
                    Layout.fillWidth: true

                    spacing: d.rowChildSpacing

                    StatusIcon {
                        icon: d.rowIconName
                        color: d.rowIconColor
                    }

                    StatusBaseText {
                        objectName: "checkListText_" + index

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: modelData
                        lineHeight: d.rowTextLineHeight
                        font.pixelSize: d.rowFontSize
                        color: d.rowTextColor
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
