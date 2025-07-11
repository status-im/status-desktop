import QtQuick

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators

StatusInput {
    id: root

    label: qsTr("Leaving community message (you can edit this later)")
    charLimit: 80

    placeholderText: qsTr("The message a member will see when they leave your community")
    input.placeholder.wrapMode: Text.WordWrap

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community outro message"))
        }
    ]
}
