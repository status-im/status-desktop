import QtQuick 2.13
import QtQuick.Controls 2.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../"

StackDetailBase {
    backButtonText: "Assets"

    //graph placeholder
    Rectangle {
        width: 649
        height: 253
        anchors.centerIn: parent
        color: "pink"
        opacity: 0.3
    }
}
