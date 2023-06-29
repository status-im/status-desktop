import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

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
            regularExpression: Constants.regularExpressions.alphanumericalExpanded
            errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
        }
    ]
}
