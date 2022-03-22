import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

StatusProgressBar {
    id: control

    property var strength
    property string labelVeryWeak: "Very weak"
    property string labelWeak: "Weak"
    property string labelSoso: "So-so"
    property string labelGood: "Good"
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
