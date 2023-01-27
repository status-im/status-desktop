import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

StatusInput {
    id: root

    label: qsTr("Name your community")
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
