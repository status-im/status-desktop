import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

StatusInput {
    id: root

    label: qsTr("Leaving community message")
    charLimit: 80

    placeholderText: qsTr("The message a member will see when they leave your community")
    input.placeholder.wrapMode: Text.WordWrap

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community intro message"))
        }
    ]
}
