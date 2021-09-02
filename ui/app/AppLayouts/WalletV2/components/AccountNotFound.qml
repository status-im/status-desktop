import QtQuick 2.13
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root
    spacing: 8
    signal generateAccountClicked()
    signal proceedWithSeedClicked()

    StatusBaseText {
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 15
        text: qsTr("Is your seed phrase secure?")
        color: Theme.palette.dangerColor1
    }

    StatusBaseText {
        Layout.preferredWidth:  345
        Layout.alignment: Qt.AlignHCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 15
        text: qsTr("We found no active accounts with that seed phrase. If it is a new account please ensure that it is secure. Scammers often provide you with a phrase and siphon funds later.\n")
        color: Theme.palette.baseColor1
    }

    StatusButton {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Generate an account using Status")
        onClicked: {
            root.generateAccountClicked();
        }
    }

    StatusButton {
        Layout.alignment: Qt.AlignHCenter
        type: StatusBaseButton.Type.Danger
        text: qsTr("Proceed with seed phrase")
        onClicked: {
            root.proceedWithSeedClicked();
        }
    }
}
