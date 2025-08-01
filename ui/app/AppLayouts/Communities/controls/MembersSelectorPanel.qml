import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls.delegates

import utils


Control {
    id: root

    property alias model: listView.model
    property int maximumListHeight: 188

    readonly property alias count: listView.count

    signal removeMemberRequested(int index)

    function positionListAtEnd() {
        listView.positionViewAtEnd()
    }

    QtObject {
        id: d

        readonly property int delegateHeight: 47
    }

    contentItem: Column {
        spacing: 8

        RowLayout {
            width: root.availableWidth
            spacing: 0

            component Text: StatusBaseText {
                color: Theme.palette.baseColor1
                text: qsTr("Members")
                font.pixelSize: Theme.tertiaryTextFontSize
                elide: Text.ElideRight
            }

            Text {
                text: qsTr("Members")
            }

            Item { Layout.fillWidth: true }

            Text {
                text: qsTr("%n member(s)", "", root.count)
            }
        }

        Rectangle {
            width: root.availableWidth
            height: Math.min(root.maximumListHeight,
                             d.delegateHeight * root.count)

            radius: Theme.radius
            color: Theme.palette.statusListItem.backgroundColor

            StatusListView {
                id: listView

                anchors.fill: parent

                delegate: ContactListItemDelegate {
                    width: ListView.view.width
                    height: d.delegateHeight
                    icon.width: 29
                    icon.height: 29

                    color: "transparent"

                    StatusIcon {
                        id: deleteIcon

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        width: 16
                        height: 16

                        icon: "delete"
                        color: Theme.palette.directColor1

                        StatusMouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.removeMemberRequested(model.index)
                        }
                    }
                }
            }
        }
    }
}
