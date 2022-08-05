import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    signal confirmationUpdated(bool value)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.padding

        Image {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.shared.imageHeight
            Layout.preferredWidth: Constants.keycard.shared.imageWidth
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            mipmap: true
            source: Style.png("keycard/popup_card_red_sprayed@2x")
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: qsTr("A factory reset will delete the key on this Keycard.\nAre you sure you want to do this?")
            font.pixelSize: Constants.keycard.general.fontSize3
            color: Theme.palette.dangerColor1
        }

        StatusCheckBox {
            id: confirmation
            Layout.alignment: Qt.AlignHCenter
            leftSide: false
            spacing: Style.current.smallPadding
            font.pixelSize: Constants.keycard.general.fontSize3
            text: qsTr("I understand the key pair on this Keycard will be deleted")

            onCheckedChanged: {
                root.confirmationUpdated(checked)
            }
        }
    }
}
