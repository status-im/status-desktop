import QtQuick

import utils

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Controls.Validators

StatusInput {
    id: root

    label: qsTr("Community name")
    charLimit: 30
    placeholderText: qsTr("A catchy name")

    validators: [
        StatusMinLengthValidator {
            minLength: 1
            errorMessage: Utils.getErrorMessage(root.errors,
                                                qsTr("community name"))
        },
        StatusRegularExpressionValidator {
            regularExpression: Constants.regularExpressions.alphanumericalExpanded
            errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
        }
    ]
}
