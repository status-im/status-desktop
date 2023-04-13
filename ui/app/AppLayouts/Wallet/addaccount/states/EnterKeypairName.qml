import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Style.current.padding
        spacing: Style.current.halfPadding

        StatusInput {
            objectName: "AddAccountPopup-GeneratedSeedPhraseKeyName"
            Layout.preferredWidth: parent.width
            Layout.topMargin: Style.current.padding
            label: qsTr("Key name")
            charLimit: Constants.addAccountPopup.keyPairNameMaxLength
            placeholderText: qsTr("Enter a name")
            text: root.store.addAccountModule.newKeyPairName

            onTextChanged: {
                if (text.trim() == "") {
                    root.store.addAccountModule.newKeyPairName = ""
                    return
                }
                root.store.addAccountModule.newKeyPairName = text
            }

            onKeyPressed: {
                root.store.submitAddAccount(event)
            }
        }

        StatusBaseText {
            text: qsTr("For your future reference. This is only visible to you.")
            font.pixelSize: Constants.addAccountPopup.labelFontSize2
            color: Theme.palette.baseColor1
        }
    }
}
