import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusInput {
        input.placeholderText: "Placeholder"
    }

    StatusInput {
        label: "Label"
        input.placeholderText: "Disabled"
        input.enabled: false
    }

    StatusInput {
        input.placeholderText: "Clearable"
        input.clearable: true
    }

    StatusInput {
        input.placeholderText: "Invalid"
        input.valid: false
    }

    StatusInput {
        label: "Label"

        input.icon.name: "search"
        input.placeholderText: "Input with icon"
    }

    StatusInput {
        label: "Label"
        input.placeholderText: "Placeholder"
        input.clearable: true
    }

    StatusInput {
        charLimit: 30
        input.placeholderText: "Placeholder"
        input.clearable: true
    }

    StatusInput {
        label: "Label"
        charLimit: 30
        input.placeholderText: "Placeholder"
        input.clearable: true
    }

    StatusInput {
        label: "Label"
        charLimit: 30
        errorMessage: "Error message"

        input.clearable: true
        input.valid: false
        input.placeholderText: "Placeholder"
    }

    StatusInput {
        label: "StatusInput"
        secondaryLabel: "with right icon"
        input.icon.width: 15
        input.icon.height: 11
        input.icon.name: text !== "" ? "checkmark" : ""
        input.leftIcon: false
    }

    StatusInput {
        label: "Label"
        secondaryLabel: "secondary label"
        input.placeholderText: "Placeholder"
        input.implicitHeight: 56
    }

    StatusInput {
        id: input
        label: "Label"
        charLimit: 30
        input.placeholderText: "Input with validator"

        validators: [
            StatusMinLengthValidator {
                minLength: 10
                errorMessage: {
                    if (input.errors && input.errors.minLength) {
                        return `Value can't be shorter than ${input.errors.minLength.min} but got ${input.errors.minLength.actual}`
                    }
                    return ""
                }
            }
        ]
    }

    StatusInput {
        input.multiline: true
        input.placeholderText: "Multiline"
    }

    StatusInput {
        input.multiline: true
        input.placeholderText: "Multiline with static height"
        input.implicitHeight: 100
    }

    StatusInput {
        input.multiline: true
        input.placeholderText: "Multiline with max/min"
        input.minimumHeight: 80
        input.maximumHeight: 200
    }
}
