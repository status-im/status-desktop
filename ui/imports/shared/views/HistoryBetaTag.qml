import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts // for the "Layout.fillWidth" Binding

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import utils
import shared.controls

import QtModelsToolkit

InformationTag {
    id: root

    signal linkActivated(string link)

    required property var flatNetworks

    implicitHeight: 56

    spacing: Theme.halfPadding
    backgroundColor: Theme.palette.primaryColor3
    bgRadius: Theme.radius
    bgBorderColor: Theme.palette.primaryColor2
    tagPrimaryLabel.textFormat: Text.RichText
    tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
    tagPrimaryLabel.text: qsTr("Activity is in beta. For any issues, go to Settings → Advanced → Refetch transaction history.")
    tagPrimaryLabel.wrapMode: Text.WordWrap
    tagPrimaryLabel.onLinkActivated: root.linkActivated(link)
    // NB: regular binding won't work as `tagPrimaryLabel` is an alias
    Binding {
        target: tagPrimaryLabel
        property: "Layout.fillWidth"
        value: true
    }
    asset {
        name: "warning"
        width: 20
        height: 20
        color: Theme.palette.primaryColor1
    }
    HoverHandler {
        cursorShape: hovered && !!parent.tagPrimaryLabel.hoveredLink ? Qt.PointingHandCursor : undefined
    }
}
