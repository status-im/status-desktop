import QtQuick 2.13

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string backButtonText: ""
    signal backPressed()

    StatusFlatButton {
        text: root.backButtonText
        icon.name: "previous"
        onClicked: {
            root.backPressed();
        }
    }
}
