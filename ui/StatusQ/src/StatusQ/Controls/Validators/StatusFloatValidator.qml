import QtQuick 2.14

import StatusQ.Controls 0.1

/*!
   \qmltype StatusFloatValidator
   \inherits StatusValidator
   \inqmlmodule StatusQ.Controls.Validators
   \since StatusQ.Controls.Validators 0.1
   \brief The StatusFloatValidator.qml type provides a validator for float values.

   The \c StatusFloatValidator type provides a validator for float values.

   Example of how to use it:

   \qml
        StatusFloatValidator {
            bottom: 0
            top: 1.25
            errorMessage: qsTr("This is an invalid numeric value")
        }
   \endqml

   For a list of components available see StatusQ.
*/
StatusValidator {
    id: root

    /*!
       \qmlproperty real StatusFloatValidator::bottom
       This property holds the validator's lowest acceptable value. By default, this property's value is derived from the lowest signed float available.
    */
    property real bottom: qmlDoubleValidator.bottom

    /*!
       \qmlproperty var StatusFloatValidator::locale
       This property holds the locale used to interpret the number.
    */
    property var locale: Qt.locale()

    /*!
       \qmlproperty real StatusFloatValidator::top
       This property holds the validator's highest acceptable value. By default, this property's value is derived from the highest float available.
    */
    property real top: qmlDoubleValidator.top

    /*!
       \qmlproperty DoubleValidator StatusFloatValidator::qmlDoubleValidator
       This property holds a default qml double validator instance.
    */
    readonly property DoubleValidator qmlDoubleValidator: DoubleValidator {}

    name: "floatValidator"
    errorMessage: qsTr("Please enter a valid numeric value.")

    validate: function (t) {
        return !isNaN(t) && t >= bottom && t <= top  ? true : {
                                             bottom: bottom,
                                             top: top,
                                             actual: t
                                         }
    }
}
