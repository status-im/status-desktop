import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

/*!
   \qmltype StatusInput
   \inherits Item
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief The StatusInput control provides a generic user text input

   Example of how to use it:

   \qml
        StatusInput {
            label: "Label"
            charLimit: 30
            errorMessage: qsTr("Input doesn't match validator")
            input.clearable: true
            input.placeholderText: qsTr("Placeholder text")
        }
   \endqml

   For a list of components available see StatusQ.
*/
Item {
    id: root

    /*!
        \qmlproperty alias StatusInput::input
        This property holds a reference to the TextEdit component.
    */
    property alias input: statusBaseInput

    /*!
        \qmlproperty string StatusInput::letterIconName
        This property holds a reference to the StatusBaseInput's letterIconName property.
    */
    property alias letterIconName: statusBaseInput.letterIconName

    /*!
        \qmlproperty alias StatusInput::valid
        This property holds a reference to the TextEdit's valid property.
    */
    property alias valid: statusBaseInput.valid
    /*!
        \qmlproperty alias StatusInput::pending
        This property holds a reference to the TextEdit's pending property.
    */
    property alias pending: statusBaseInput.pending
    /*!
        \qmlproperty alias StatusInput::text
        This property holds a reference to the TextEdit's text property.
    */
    property alias text: statusBaseInput.text
    /*!
        \qmlproperty alias StatusInput::font
        This property holds a reference to the TextEdit's font property.
    */
    property alias font: statusBaseInput.font

    /*!
       \qmlproperty errorMessageCmp
        This property represents the errorMessage shown on statusInput in cases one of the validators fails

        This can be used to control the error message's look and position from the outside.

        Examples of usage

        \qml
            StatusInput {
                errorMessageCmp.font.pixelSize: 15
                errorMessageCmp.font.weight: Font.Medium
            }
        \endqml
    */
    property alias errorMessageCmp: errorMessage
    /*!
        \qmlproperty string StatusInput::label
        This property sets the label text.
    */
    property string label: ""
    /*!
        \qmlproperty string StatusInput::secondaryLabel
        This property sets the secondary label text.
    */
    property string secondaryLabel: ""
    /*!
        \qmlproperty int StatusInput::charLimit
        This property sets the character limit of the text input.
    */
    property int charLimit: 0
    /*!
        \qmlproperty string StatusInput::errorMessage
        This property sets the error message text.
    */
    property string errorMessage: ""
    /*!
        \qmlproperty real StatusBaseInput::leftPadding
        This property sets the leftComponentLoader's left padding.
    */
    property real leftPadding: 16
    /*!
        \qmlproperty real StatusBaseInput::rightPadding
        This property sets the right padding.
    */
    property real rightPadding: 16
    /*!
        \qmlproperty list StatusBaseInput::validators
        This property sets the list of validators to be considered.
    */
    property list<StatusValidator> validators
    /*!
        \qmlproperty list StatusBaseInput::validators
        This property sets the list of async validators to be considered.
    */
    property list<StatusAsyncValidator> asyncValidators
    /*!
       \qmlproperty int StatusInput::validationMode
        This property describes the validation mode

        Note that this property should be always strictly compared with one of ValidationMode's value

        Default value: StatusInput.ValidationMode.OnlyWhenDirty

        Examples of usage

        > To ignore invalid input
        \qml
        StatusInput {
            validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
            validators: [
                StatusMinLengthValidator {
                    minLength: 15
                }
            ]
        }
        \endqml
    */
    property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
    /*!
        \qmlproperty string StatusBaseInput::validatedValue
        This property sets the validated value text.
    */
    property string validatedValue
    /*!
        \qmlproperty var StatusBaseInput::pendingValidators
        This property sets the pending validators to be considered.
    */
    property var pendingValidators: []

    /*!
        \qmlsignal
        This signal is emitted when the icon is clicked.
    */
    signal iconClicked()
    /*!
        \qmlsignal
        This signal is emitted when a hard key is pressed passing as parameter the keyboard event.
    */
    signal keyPressed(var event)
    /*!
        \qmlsignal
        This signal is emitted when the text edit is clicked.
    */
    signal editClicked()

    /*!
       \qmltype ValidationMode
       \brief Available validation modes supported by StatusInput

        Values:

        - OnlyWhenDirty validates input only after it has become dirty
        - Always validates input even before it has become dirty
        - IgnoreInvalidInput ignore the new content if it doesn't match validators

       Has no effect without at least a validator

       \note that it represents a QML enumeration and can't be used as a property type, we use int instead

       \see validationMode for a usage example
       \see validators
    */
    enum ValidationMode {
        OnlyWhenDirty, // validates input only after it has become dirty
        Always, // validates input even before it has become dirty
        IgnoreInvalidInput // ignore the new content if it doesn't match
    }

    /*!
        \qmlproperty var StatusBaseInput::errors
        This property holds the validation errors.
    */
    property var errors: ({})
    /*!
        \qmlproperty var StatusBaseInput::errors
        This property holds the validation async errors.
    */
    property var asyncErrors: ({})
    /*!
        \qmlmethod
        This function resets the text input validation and text.
    */
    function reset() {
        statusBaseInput.valid = true
        statusBaseInput.pristine = true
        statusBaseInput.text = ""
        root.errorMessage = ""
    }

    property string _previousText: text
    /*!
        \qmlmethod
        This function validates the text input's text.
    */
    function validate() {

        if (!statusBaseInput.dirty && validationMode === StatusInput.ValidationMode.OnlyWhenDirty) {
            return
        }
        statusBaseInput.valid = true
        if (validators.length) {
            for (let idx in validators) {
                let validator = validators[idx]
                let result = validator.validate(statusBaseInput.text)

                if (typeof result === "boolean" && result) {
                    statusBaseInput.valid = statusBaseInput.valid && true
                    delete errors[validator.name]
                } else {
                    if (!errors) {
                        errors = {}
                    }
                    if (typeof result === "boolean") {
                        result = {
                            valid: result
                        }
                    }
                    result.errorMessage = validator.errorMessage
                    errors[validator.name] = result
                    statusBaseInput.valid = statusBaseInput.valid && false
                }
            }
            if (errors){
                let errs = Object.values(errors)
                if (errs && errs[0]) {
                    if(validationMode === StatusInput.ValidationMode.IgnoreInvalidInput
                            && text.length > _previousText.length) {
                        // Undo the last input
                        const cursor = statusBaseInput.cursorPosition;
                        statusBaseInput.text = _previousText;
                        if (statusBaseInput.cursor > statusBaseInput.text.length) {
                            statusBaseInput.cursorPosition = statusBaseInput.text.length;
                        } else {
                            statusBaseInput.cursorPosition = cursor-1;
                        }
                    }
                    errorMessage.text = errs[0].errorMessage || root.errorMessage;
                } else {
                    errorMessage.text = ""
                }
            }
            _previousText = text
        }

        if (asyncValidators.length && !Object.values(errors).length) {
            for (let idx in asyncValidators) {
                let asyncValidator = asyncValidators[idx]
                asyncValidator.validationComplete.connect(function (value, valid) {
                    updateAsyncValidity(asyncValidator.name, value, valid)
                })
                root.pending = true
                pendingValidators.push(asyncValidator.name)
                asyncValidator.asyncOperationInternal(statusBaseInput.text)
            }
        } else if (!asyncValidators.length && !Object.values(errors).length) {
            root.validatedValue = root.text
        }
    }
    /*!
        \qmlmethod
        This function updates the text input async validation.
    */
    function updateAsyncValidity(validatorName, value, result) {
        if (!asyncErrors) {
            asyncErrors = {}
        }

        if (typeof result === "boolean" && result) {
            if (asyncErrors[validatorName] !== undefined) {
                delete asyncErrors[validatorName]
            }
            errorMessage.text = ""
            root.validatedValue = value
        } else {
            asyncErrors[validatorName] = result
            for (let idx in asyncValidators) {
                errorMessage.text = asyncValidators[idx].errorMessage || root.errorMessage
                break;
            }
        }
        pendingValidators = pendingValidators.filter(v => v !== validatorName)
        root.pending = pendingValidators.length > 0
        root.valid = Object.values(asyncErrors).length == 0
    }

    implicitWidth: inputLayout.implicitWidth
    implicitHeight: inputLayout.implicitHeight
    height: implicitHeight
    width: implicitWidth

    Component.onCompleted: validate()

    ColumnLayout {
        id: inputLayout

        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true

            StatusBaseText {
                id: label
                visible: !!root.label
                elide: Text.ElideRight
                text: root.label
                font.pixelSize: 15
                color: statusBaseInput.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
            }

            StatusBaseText {
                id: secondaryLabel
                visible: !!root.secondaryLabel
                elide: Text.ElideRight
                text: root.secondaryLabel
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }

            Item {
                Layout.fillWidth: true
            }

            StatusBaseText {
                id: charLimitLabel

                visible: root.charLimit > 0

                text: "%1 / %2".arg(statusBaseInput.text.length).arg(root.charLimit)
                font.pixelSize: 12
                color: statusBaseInput.enabled ? Theme.palette.baseColor1 : Theme.palette.directColor6
            }
        }

        StatusBaseInput {
            id: statusBaseInput

            Layout.fillWidth: true
            Layout.fillHeight: true

            leftPadding: root.leftPadding
            rightPadding: root.rightPadding

            maximumLength: root.charLimit
            onTextChanged: root.validate()

            Keys.forwardTo: [root]
            onIconClicked: root.iconClicked()
            onKeyPressed: {
                root.keyPressed(event);
            }
            onEditChanged: {
                root.editClicked();
            }
        }

        StatusBaseText {
            id: errorMessage

            visible: !!text && !statusBaseInput.valid

            font.pixelSize: 12
            color: Theme.palette.dangerColor1

            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
        }
    }
}
