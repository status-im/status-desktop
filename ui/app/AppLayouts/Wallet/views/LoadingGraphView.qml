import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

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
            source: Theme.svg("mask/dummyLineGraph")
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            visible: false
            cache: false
        }

        OpacityMask {
            source: loadingComp
            anchors.fill: loadingComp
            maskSource: mask
        }
    }
}
