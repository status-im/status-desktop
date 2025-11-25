import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

Control {
    id: root

    property string name: "channelName"
    property string message: qsTr("My latest message\n with a return")

    background: Rectangle {
        // TODO: what about dark theme?
        color: "#F7F7F7"
        radius: 8
    }

    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    topPadding: Theme.padding
    bottomPadding: Theme.padding

    contentItem: RowLayout {

        spacing: Theme.halfPadding

        Image {
            id: identicon

            Layout.preferredHeight: root.availableHeight
            Layout.preferredWidth: root.availableHeight

            source: Qt.resolvedUrl("../../assets/png/status-logo-icon.png")

            sourceSize.width: width * 2
            sourceSize.height: height * 2

            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            spacing: Theme.halfPadding / 2

            StatusBaseText {
                id: name

                Layout.fillWidth: true

                elide: Text.ElideRight
                text: root.name
                font.weight: Font.Medium
                font.pixelSize: Theme.primaryTextFontSize
                color: "#4b4b4b"
            }

            StatusBaseText {
                id: messagePreview

                Layout.fillWidth: true

                elide: Text.ElideRight
                font.pixelSize: Theme.secondaryTextFontSize
                color: "#4b4b4b"
                text: root.message
            }
        }
        Rectangle {
            Layout.preferredWidth: 1.2
            Layout.fillHeight: true

            Layout.topMargin: -Theme.padding
            Layout.bottomMargin: -Theme.padding

            color: "#D9D9D9"
        }

        StatusBaseText {
            Layout.fillHeight: true
            Layout.minimumWidth: height + Theme.padding

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            elide: Text.ElideRight
            font.weight: Font.Medium
            font.pixelSize: Theme.secondaryTextFontSize

            text: qsTr("Open")
            color: "black"
        }
    }
}


