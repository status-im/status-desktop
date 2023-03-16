import QtQuick 2.14
import QtGraphicalEffects 1.14

import shared.views 1.0 as SharedViews

import StatusQ.Core.Theme 0.1

Item {
    property alias profileStore: profilePreview.profileStore
    property alias contactsStore: profilePreview.contactsStore
    property alias dirtyValues: profilePreview.dirtyValues
    property alias dirty: profilePreview.dirty

    implicitHeight: profilePreview.implicitHeight 
                        + profilePreview.anchors.topMargin 
                        + profilePreview.anchors.bottomMargin

    implicitWidth: profilePreview.implicitWidth 
                        + profilePreview.anchors.leftMargin 
                        + profilePreview.anchors.rightMargin

    function reload() {
        profilePreview.reload()
    }

    SharedViews.ProfileDialogView {
        id: profilePreview
        anchors.fill: parent
        anchors.margins: 24
        readOnly: true
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
