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

    property string contactRequestId: ""
    property string fromAddress: ""
    property int clock: 0
    property string text: ""
    property int contactRequestState: 0

    signal accepted()
    signal discarded()

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
                timestamp: root.clock
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: root.text
            }
        }
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Ignore")
            objectName: "ignoreButton"
            onClicked: root.discarded()
        }
        StatusButton {
            text: qsTr("Accept")
            type: StatusBaseButton.Type.Success
            objectName: "acceptButton"
            onClicked: root.accepted()
        }
    }
}
