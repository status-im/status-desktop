import QtQuick

import utils

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Controls.Validators

StatusInput {
    id: root

    label: qsTr("Dialog for new members")
    charLimit: 1400

    multiline: true

    placeholderText: qsTr("What new members will read before joining (eg. community rules, welcome message, etc.). Members will need to tick a check box agreeing to these rules before they are allowed to join your community.")
    input.placeholder.wrapMode: Text.WordWrap

    input.verticalAlignment: TextEdit.AlignTop

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community intro message"))
        }
    ]
}
