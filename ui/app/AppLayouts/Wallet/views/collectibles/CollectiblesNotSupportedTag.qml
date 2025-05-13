import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import shared.controls 1.0

InformationTag {
    id: root

    // list of ints
    required property var unsupportedChainIds

    QtObject {
        id: d

        readonly property string formattedUnsupportedNetworks: {
            let networkNames = root.unsupportedChainIds.map(chainId => Utils.getNetworkName(chainId))
            return Utils.getEnumerationString(networkNames, qsTr("and"))
        }
    }

    implicitHeight: 56

    spacing: Theme.halfPadding
    backgroundColor: Theme.palette.primaryColor3
    bgRadius: Theme.radius
    bgBorderColor: Theme.palette.primaryColor2
    tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
    tagPrimaryLabel.text: qsTr("Displaying collectibles on %1 is not currently supported by Status.")
        .arg(d.formattedUnsupportedNetworks)
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
}