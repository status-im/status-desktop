import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0
import shared.controls 1.0

import "../stores"

Loader {
    id: root
    active: false
    sourceComponent: Item {
        LoadingComponent {
            id: loadingComp
            anchors.fill: parent
            visible: false
        }

        Image {
            id: mask
            source: Style.svg("mask/dummyLineGraph")
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            visible: false
        }

        OpacityMask {
            source: loadingComp
            anchors.fill: loadingComp
            maskSource: mask
        }
    }
}
