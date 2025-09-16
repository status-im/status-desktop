import QtQuick

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators

StatusInput {
    id: root

    label: qsTr("Description")
    charLimit: 140

    placeholderText: qsTr("What your community is about")
    input.multiline: true
    maximumHeight: 108
    minimumHeight: 108

    input.verticalAlignment: Qt.AlignTop
    input.placeholder.verticalAlignment: Qt.AlignTop

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community description"))
        },
        StatusRegularExpressionValidator {
            regularExpression: Constants.regularExpressions.alphanumericalExpanded4
            errorMessage: Constants.errorMessages.alphanumericalExpanded3RegExp
        }
    ]
}
