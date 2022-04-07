import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

/*!
   \qmltype StatusPasswordStrengthIndicator
   \inherits StatusProgressBar
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief It allows visualizing the password strength. Inherits from StatusProgressBar.

   The \c StatusPasswordStrengthIndicator changes its text and color depending on the selected StatusPasswordStrengthIndicator::strength.

   Since it inherits from \c StatusProgressBar, `value` property will change the length of the bar accordingly.

   When `value` property is 0, StatusPasswordStrengthIndicator::strength is automatically set to StatusPasswordStrengthIndicator.Strength.None and no text is displayed.

   Example of how the control looks like:
   \image status_password_strength_indicator.png

   Example of how to use it:

   \qml
        StatusPasswordStrengthIndicator {
            id: weakPw
            strength: StatusPasswordStrengthIndicator.Strength.Weak
            value: 0.5
        }

        StatusPasswordStrengthIndicator {
            id: sosoPw
            strength: StatusPasswordStrengthIndicator.Strength.SoSo
            value: 0.25
        }
   \endqml

   For a list of components available see StatusQ.
*/
StatusProgressBar {
    id: control

    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::strength
       This property holds the password strength value. Possible values are:
       \list
       \li StatusPasswordStrengthIndicator.Strength.None
       \li StatusPasswordStrengthIndicator.Strength.VeryWeak
       \li StatusPasswordStrengthIndicator.Strength.Weak
       \li StatusPasswordStrengthIndicator.Strength.SoSo
       \li StatusPasswordStrengthIndicator.Strength.Good
       \li StatusPasswordStrengthIndicator.Strength.Great
       \endlist
    */
    property var strength
    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::labelVeryWeak
       This property holds the text shown when the strength is StatusPasswordStrengthIndicator.Strength.VeryWeak.

       Default value: "Very weak"
    */
    property string labelVeryWeak: "Very weak"
    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::labelWeak
       This property holds the text shown when the strength is StatusPasswordStrengthIndicator.Strength.Weak.

       Default value: "Weak"
    */
    property string labelWeak: "Weak"
    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::labelSoso
       This property holds the text shown when the strength is StatusPasswordStrengthIndicator.Strength.SoSo.

       Default value: "So-so"
    */
    property string labelSoso: "So-so"
    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::labelGood
       This property holds the text shown when the strength is StatusPasswordStrengthIndicator.Strength.Good.

       Default value: "Good"
    */
    property string labelGood: "Good"
    /*!
       \qmlproperty string StatusPasswordStrengthIndicator::labelGreat
       This property holds the text shown when the strength is StatusPasswordStrengthIndicator.Strength.Great.

       Default value: "Great"
    */
    property string labelGreat: "Great"

    enum Strength {
        None, // 0
        VeryWeak, // 1
        Weak, // 2
        SoSo, // 3
        Good, // 4
        Great // 5
    }

    onValueChanged: if(value === 0) control.strength = StatusPasswordStrengthIndicator.Strength.None

    // Behavior:
    states: [
        // Strength states definition:
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.None
            PropertyChanges { target: control; text: ""}
        },
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.VeryWeak
            PropertyChanges { target: control; fillColor : Theme.palette.dangerColor1}
            PropertyChanges { target: control; text: labelVeryWeak}
        },
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.Weak
            PropertyChanges { target: control; fillColor : Theme.palette.pinColor1}
            PropertyChanges { target: control; text: labelWeak}
        },
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.SoSo
            PropertyChanges { target: control; fillColor : Theme.palette.miscColor7}
            PropertyChanges { target: control; text: labelSoso}
        },
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.Good
            PropertyChanges { target: control; fillColor : Theme.palette.miscColor12}
            PropertyChanges { target: control; text: labelGood}
        },
        State {
            when: control.strength === StatusPasswordStrengthIndicator.Strength.Great
            PropertyChanges { target: control; fillColor : Theme.palette.successColor1}
            PropertyChanges { target: control; text: labelGreat}
        }
    ]
}
