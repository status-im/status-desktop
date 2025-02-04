import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

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
