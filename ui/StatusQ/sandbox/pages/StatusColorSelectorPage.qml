import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Row {
    spacing: 8

    StatusColorSelector {
        model: ["red", "blue", "green"]
    }
}
