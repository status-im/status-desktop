import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

CommonContactDialog {
    id: root

    // expected roles: id, from, clock, text, contactRequestState
    required property var crDetails

    signal accepted(string contactRequestId)
    signal discarded(string contactRequestId)

    title: qsTr("Review contact request")

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: msgColumn.implicitHeight + msgColumn.anchors.topMargin + msgColumn.anchors.bottomMargin
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: Style.current.radius

        ColumnLayout {
            id: msgColumn
            anchors.fill: parent
            anchors.margins: Style.current.padding

            StatusTimeStampLabel {
                Layout.maximumWidth: parent.width
                timestamp: crDetails.clock
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: crDetails.text
            }
        }
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Ignore")
            objectName: "ignoreButton"
            onClicked: root.discarded(crDetails.id ?? "")
        }
        StatusButton {
            text: qsTr("Accept")
            type: StatusBaseButton.Type.Success
            objectName: "acceptButton"
            onClicked: root.accepted(crDetails.id ?? "")
        }
    }
}
