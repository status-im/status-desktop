import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1


ColumnLayout {
    property alias domainName: domainNameInput.text
    property alias domainNameValid: domainNameInput.valid

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
}
