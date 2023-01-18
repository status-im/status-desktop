import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

ColumnLayout {
    id: root

    property int mode: HoldingTypes.Mode.Add
    property alias domainName: domainNameInput.text
    property alias domainNameValid: domainNameInput.valid
    property alias addButtonEnabled: addOrUpdateButton.enabled

    signal addClicked
    signal updateClicked
    signal removeClicked

    spacing: 0

    StatusInput {
        id: domainNameInput

        Layout.fillWidth: true
        Layout.topMargin: 23

        minimumHeight: 36
        maximumHeight: 36
        topPadding: 0
        bottomPadding: 0
        font.pixelSize: 13
        input.placeholderText: "name.eth"

        validators: StatusRegularExpressionValidator {
            // TODO: check ens domain validator
            regularExpression: /^(\*\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?$/i
            errorMessage: qsTr("Subdomain not recognized")

            validate: function (value) {
                return value === "*.eth" || regularExpression.test(value)
            }
        }

        Component.onCompleted: {
            if (text) {
                input.dirty = true
                validate()
            }
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: 17

        text: qsTr("Put *. before ENS name to include all subdomains in permission")

        wrapMode: Text.Wrap
        color: Theme.palette.baseColor1
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
    }

    StatusButton {
        id: addOrUpdateButton

        text: (root.mode === HoldingTypes.Mode.Add) ? qsTr("Add") : qsTr("Update")
        Layout.topMargin: 40
        Layout.preferredHeight: 44 // by design
        Layout.fillWidth: true
        onClicked: root.mode === HoldingTypes.Mode.Add
                   ? root.addClicked() : root.updateClicked()
    }

    StatusFlatButton {
        text: qsTr("Remove")
        Layout.topMargin: 16 // by design
        Layout.preferredHeight: 44 // by design
        Layout.fillWidth: true
        visible: root.mode === HoldingTypes.Mode.Update
        type: StatusBaseButton.Type.Danger

        onClicked: root.removeClicked()
    }
}
