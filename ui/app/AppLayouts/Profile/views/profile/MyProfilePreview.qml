import QtQuick 2.13
import QtGraphicalEffects 1.14

import shared.views 1.0 as SharedViews

import StatusQ.Core.Theme 0.1

Item {
    property alias profileStore: profilePreview.profileStore

    implicitHeight: profilePreview.implicitHeight 
                        + profilePreview.anchors.topMargin 
                        + profilePreview.anchors.bottomMargin

    implicitWidth: profilePreview.implicitWidth 
                        + profilePreview.anchors.leftMargin 
                        + profilePreview.anchors.rightMargin

    SharedViews.ProfileView {
        id: profilePreview
        anchors.fill: parent
        anchors.margins: 24
    }

    DropShadow {
        id: shadow
        anchors.fill: profilePreview
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 12
        color: "#40000000"
        source: profilePreview
    }
}