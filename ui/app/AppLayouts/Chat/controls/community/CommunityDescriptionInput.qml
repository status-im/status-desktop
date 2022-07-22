import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

StatusInput {
    id: root

    leftPadding: 0
    rightPadding: 0
    label: qsTr("Description")
    charLimit: 140

    placeholderText: qsTr("What your community is about")
    input.multiline: true
    input.implicitHeight: 88

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community description"))
        }
    ]
    validationMode: StatusInput.ValidationMode.Always
}
