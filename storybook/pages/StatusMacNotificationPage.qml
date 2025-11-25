import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Platform

Item {
    StatusMacNotification {
        anchors.centerIn: parent
        name: "Some name"
        message: "Some message here"

        width: widthSlider.value || undefined
    }

    RowLayout {

        Slider {
            id: widthSlider

            from: 0
            to: 400
        }
    }
}

// category: Platform
// status: good
