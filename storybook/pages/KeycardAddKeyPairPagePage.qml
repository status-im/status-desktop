import QtQuick
import QtQuick.Controls

import AppLayouts.Onboarding2.pages

Item {
    id: root

    KeycardAddKeyPairPage {
        id: progressPage

        anchors.fill: parent

        inProgress: inProgressCheckBox.checked
    }

    CheckBox {
        id: inProgressCheckBox

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        text: "In progress"
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48023&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48081&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48102&node-type=frame&m=dev
