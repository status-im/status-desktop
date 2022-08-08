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
        placeholderText: "Placeholder"
    }

    StatusInput {
        label: "Label"
        placeholderText: "Disabled"
        input.enabled: false
    }

    StatusInput {
        placeholderText: "Clearable"
        input.clearable: true
    }

    StatusInput {
        placeholderText: "Invalid"
        input.valid: false
    }

    StatusInput {
        label: "Label"

        input.icon.name: "search"
        placeholderText: "Input with icon"
    }

    StatusInput {
        label: "Label"
        placeholderText: "Placeholder"
        input.clearable: true
    }

    StatusInput {
        charLimit: 30
        placeholderText: "Placeholder"
        input.clearable: true
    }

    StatusInput {
        label: "Label"
        charLimit: 30
        placeholderText: "Placeholder"
        input.clearable: true
    }

    Item {
        implicitWidth: 480
        implicitHeight: 82
        z: 100000
        StatusSeedPhraseInput {
            id: statusSeedInput
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height
            textEdit.input.anchors.leftMargin: 16
            textEdit.input.anchors.rightMargin: 16
            textEdit.input.anchors.topMargin: 11
            textEdit.label: "Input with drop down selection list" + (insertedWord ? ` (${insertedWord})` : "")
            leftComponentText: "1"
            inputList: ListModel {
                ListElement {
                    seedWord: "add"
                }
                ListElement {
                    seedWord: "address"
                }
                ListElement {
                    seedWord: "panda"
                }
                ListElement {
                    seedWord: "posible"
                }
                ListElement {
                    seedWord: "win"
                }
                ListElement {
                    seedWord: "wine"
                }
                ListElement {
                    seedWord: "wing"
                }
            }

            property string insertedWord: ""
            onDoneInsertingWord: insertedWord = word
        }
    }

    StatusInput {
        label: "Label"
        charLimit: 30
        errorMessage: "Error message"
        input.clearable: true
        input.valid: false
        placeholderText: "Placeholder"
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
        placeholderText: "Placeholder"
        minimumHeight: 56
        maximumHeight: 56
    }

    StatusInput {
        id: input
        label: "Label"
        charLimit: 30
        placeholderText: "Input with validator"

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
        label: "Input with <i>StatusRegularExpressionValidator</i>"
        charLimit: 30
        placeholderText: `Must match regex(${validators[0].regularExpression.toString()}) and <= 30 chars`
        validationMode: StatusInput.ValidationMode.IgnoreInvalidInput

        validators: [
            StatusRegularExpressionValidator {
                regularExpression: /^[0-9A-Za-z_\$-\s]*$/
                errorMessage: "Bad input!"
            }
        ]
    }

    StatusInput {
        label: "Label"
        placeholderText: "Input width component (right side)"
        input.rightComponent: StatusIcon {
            icon: "cancel"
            height: 16
            color: Theme.palette.dangerColor1
        }
    }


    StatusInput {
        input.multiline: true
        placeholderText: "Multiline"
    }

    StatusInput {
        input.multiline: true
        placeholderText: "Multiline with static height"
        minimumHeight: 100
        maximumHeight: 100
    }

    StatusInput {
        input.multiline: true
        placeholderText: "Multiline with max/min"
        minimumHeight: 80
        maximumHeight: 200
    }

    StatusInput {
        property bool toggled: true
        label: "Input with emoji icon"
        placeholderText: "Enter Name"
        input.icon.emoji: toggled ? "😁" : "🧸"
        input.icon.color: "blue"
        input.isIconSelectable: true
        onIconClicked: {
            toggled = !toggled
        }
    }

    StatusInput {
        property bool toggled: true
        label: "Input with selectable icon which is not an emoji"
        placeholderText: "Enter Name"
        input.icon.emoji: ""
        input.icon.name: toggled ? "filled-account" : "image"
        input.icon.color: "blue"
        input.isIconSelectable: true
        onIconClicked: {
            toggled = !toggled
        }
    }

    StatusInput {
        label: "Input with inline token selector"
        input.leftComponent: StatusTokenInlineSelector {
            tokens: [{amount: 0.1, token: "ETH"},
                     {amount: 10, token: "SNT"},
                     {amount: 15, token: "MANA"}]

            StatusToolTip {
                id: toolTip
                text: "posted"
            }
            onTriggered: toolTip.visible = true
        }
        input.edit.readOnly: true
    }
}
