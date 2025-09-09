import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Platform

Column {
    spacing: 8

    StatusMacNotification {
        anchors.centerIn: parent
        name: "Some name"
        message: "Some message here"
    }
}

// category: Platform
// status: good
