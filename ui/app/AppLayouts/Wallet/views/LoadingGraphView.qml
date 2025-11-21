import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core
import StatusQ.Controls

import utils
import shared.views
import shared.controls

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
            source: Assets.svg("mask/dummyLineGraph")
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
