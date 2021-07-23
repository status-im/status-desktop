import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusBaseInput {
        placeholderText: "Placeholder"
    }

    StatusBaseInput {
        placeholderText: "Disabled"
        enabled: false
    }

    StatusBaseInput {
        multiline: true
        placeholderText: "Multiline"
    }

    StatusBaseInput {
        multiline: true
        placeholderText: "Multiline with static height"
        implicitHeight: 100
    }

    StatusBaseInput {
        multiline: true
        placeholderText: "Multiline with max/min"
        minimumHeight: 80
        maximumHeight: 200
    }
}
