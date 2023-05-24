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
    property var model
    property var checkedKeys: []

    signal itemClicked(var key, string name, url iconSource)

    QtObject {
        id: d
        readonly property int imageSize: 133
        readonly property int columns: 2
    }

    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ColumnLayout {
        width: root.availableWidth

        StatusBaseText {
            Layout.leftMargin: 8
            Layout.topMargin: 8

            visible: repeater.count === 0

            Layout.fillWidth: true

            text: qsTr("No results")
            color: Theme.palette.baseColor1
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }

        GridLayout {
            id: grid
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            columnSpacing: 8
            rowSpacing: 12
            columns: d.columns

            Repeater {
                id: repeater

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

                            Rectangle {
                                width: 32
                                height: 32

                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.margins: 8

                                radius: width / 2
                                visible: root.checkedKeys.includes(model.key)
                                // TODO: use color from theme when defined properly in the design
                                color: "#F5F6F8"

                                StatusIcon {
                                    anchors.centerIn: parent
                                    icon: "checkmark"

                                    color: Theme.palette.baseColor1
                                    width: 16
                                    height: 16
                                }
                            }
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
}
