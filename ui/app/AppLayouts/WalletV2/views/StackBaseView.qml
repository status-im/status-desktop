import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Controls 0.1

StackView {
    id: root

    replaceEnter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
    }
    replaceExit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }
}
