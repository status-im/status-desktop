import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property alias image: imageItem.source
    property alias title: titleItem.text
    property alias subtitle: subtitleItem.text
    property alias checkersModel: checkersItems.model

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height + mainLayout.anchors.topMargin

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: 24

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: contentColumn.implicitHeight + contentColumn.anchors.topMargin + contentColumn.anchors.bottomMargin
            color: "transparent"
            radius: 16
            border.color: Theme.palette.baseColor5
            clip: true

            ColumnLayout {
                id: contentColumn

                anchors.fill: parent
                anchors.margins: 16
                anchors.bottomMargin: 32
                spacing: 8
                clip: true

                Image {
                    id: imageItem

                    Layout.preferredWidth: 257
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignHCenter
                    mipmap: true
                }

                StatusBaseText {
                    id: titleItem

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter                   
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    id: subtitleItem

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.2
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                    wrapMode: Text.WordWrap
                }

                ColumnLayout {
                    id: checkersColumn

                    readonly property int rowChildSpacing: 10
                    readonly property color rowIconColor: Theme.palette.primaryColor1
                    readonly property string rowIconName: "checkmark-circle"
                    readonly property int rowFontSize: 15
                    readonly property color rowTextColor: Theme.palette.directColor1
                    readonly property double rowTextLineHeight: 1.2

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.topMargin: 8
                    spacing: 10

                    Repeater {
                        id: checkersItems

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: checkersColumn.rowChildSpacing

                            StatusIcon {
                                icon: checkersColumn.rowIconName
                                color: checkersColumn.rowIconColor
                            }

                            StatusBaseText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: modelData
                                lineHeight: checkersColumn.rowTextLineHeight
                                font.pixelSize: checkersColumn.rowFontSize
                                color: checkersColumn.rowTextColor
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
