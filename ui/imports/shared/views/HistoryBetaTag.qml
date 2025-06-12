import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import shared.controls 1.0

import QtModelsToolkit 1.0

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
