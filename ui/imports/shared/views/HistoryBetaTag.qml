import QtQuick
import QtQml
import QtQuick.Controls

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

    QtObject {
        id: d

        readonly property int networksCount: root.flatNetworks.ModelCount.count

        // Return pairs
        function getExplorerLinks(model, hoveredLink) {
            let links = []
            SQUtils.ModelUtils.forEach(model, function(network) {
                links.push(Utils.getStyledLink(Utils.getChainExplorerName(network["shortName"]), network["blockExplorerURL"], hoveredLink))
            })
            return Utils.getEnumerationString(links, qsTr("or"))
        }
    }

    implicitHeight: 56

    spacing: Theme.halfPadding
    backgroundColor: Theme.palette.primaryColor3
    bgRadius: Theme.radius
    bgBorderColor: Theme.palette.primaryColor2
    tagPrimaryLabel.textFormat: Text.RichText
    tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
    tagPrimaryLabel.text: d.networksCount, qsTr("Activity is in beta. If transactions are missing, check %1.")
        .arg(d.getExplorerLinks(root.flatNetworks, tagPrimaryLabel.hoveredLink))
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
