import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import "../controls"

Item {
    id: root

    property alias displayName: displayNameInput
    property alias bio: bioInput

    property var socialLinksModel

    signal socialLinkChanged(string uuid, string text, string url)
    signal addSocialLinksClicked

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    ColumnLayout {
        id: layout
        anchors.fill: parent

        spacing: 19 // by design

        StatusInput {
            id: displayNameInput
            objectName: "displayNameInput"

            Layout.fillWidth: true

            label: qsTr("Display name")
            placeholderText: qsTr("Display Name")
            charLimit: 24
            validators: Constants.validators.displayName
        }


        StatusInput {
            id: bioInput
            objectName: "bioInput"

            Layout.fillWidth: true
            Layout.topMargin: 5 // by design

            label: qsTr("Bio")
            placeholderText: qsTr("Tell us about yourself")
            charLimit: 240
            multiline: true
            minimumHeight: 108
            maximumHeight: 108
            input.verticalAlignment: TextEdit.AlignTop
        }

        Repeater {
            model: root.socialLinksModel
            delegate: StaticSocialLinkInput {
                objectName: model.text + "-socialLinkInput"

                Layout.fillWidth: true
                linkType: model.linkType
                text: model.url

                onTextChanged: root.socialLinkChanged(model.uuid, model.text, text)
            }
        }

        StatusIconTextButton {
            objectName: "addMoreSocialLinksButton"
            Layout.topMargin: -8 // by design
            text: qsTr("Add more social links")
            onClicked: root.addSocialLinksClicked()
        }
    }
}
