import QtQuick
import QtQuick.Layouts
import QtQml
import QtQuick.Controls

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import utils
import shared.controls

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
