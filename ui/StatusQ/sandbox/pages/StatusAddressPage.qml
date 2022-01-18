import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusAddress {
        text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
    }

    Item {
        width: 200
        height: childrenRect.height
        StatusAddress {
            text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
            expandable: true
            width: parent.width
        }
    }
}
