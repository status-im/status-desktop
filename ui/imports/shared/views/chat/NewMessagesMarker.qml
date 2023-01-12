import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Item {
    id: root

    property double timestamp
    property int count

    implicitHeight: 28

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 16
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }

        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.palette.primaryColor1
        }

        StatusBaseText {
            text: qsTr("%n missed message(s) since %1", "", count).arg(LocaleUtils.formatDate(timestamp))
            color: Theme.palette.primaryColor1
            font.weight: Font.Bold
            font.pixelSize: 13
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.palette.primaryColor1
                }

                Rectangle {
                    implicitHeight: 16
                    implicitWidth: newLabel.width + 2*4

                    radius: 4
                    color: Theme.palette.primaryColor1

                    StatusBaseText {
                        id: newLabel
                        anchors.centerIn: parent
                        text: qsTr("NEW", "new message(s)")
                        color: Theme.palette.indirectColor1
                        font.weight: Font.DemiBold
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
