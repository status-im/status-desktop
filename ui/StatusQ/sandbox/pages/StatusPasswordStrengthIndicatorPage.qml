import QtQuick.Layouts 1.14
import StatusQ.Controls 0.1

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusPasswordStrengthIndicator {
        id: veryweakPw
        strength: StatusPasswordStrengthIndicator.Strength.VeryWeak
        value: 0.75
    }

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

    StatusPasswordStrengthIndicator {
        id: goodPw
        strength: StatusPasswordStrengthIndicator.Strength.Good
        value: 1
    }

    StatusPasswordStrengthIndicator {
        id: greatPw
        strength: StatusPasswordStrengthIndicator.Strength.Great
        value: 0.3
    }
}
