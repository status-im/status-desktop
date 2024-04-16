import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Controls.Validators 0.1

// StatusInput variation that allows only one decimal point and only numbers
StatusInput {
    id: root

    property var locale: LocaleUtils.userInputLocale
    validationMode: StatusInput.ValidationMode.IgnoreInvalidInput

    input.edit.objectName: "amountInput"

    validators: [
        StatusFloatValidator {
            bottom: 0
            errorMessage: ""
            locale: root.locale
        }
    ]

    onKeyPressed: (event) => {
                      // additionally accept dot (.) and convert it to the correct decimal point char
                      if (event.key === Qt.Key_Period || event.key === Qt.Key_Comma) {
                          // Only one decimal point is allowed
                          if(root.text.indexOf(root.locale.decimalPoint) === -1)
                            root.input.insert(root.input.cursorPosition, root.locale.decimalPoint)
                          event.accepted = true
                      } else if ((event.key > Qt.Key_9 && event.key <= Qt.Key_BraceRight) || event.key === Qt.Key_Space || event.key === Qt.Key_Tab) {
                          event.accepted = true
                      }
                  }
}
