import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property alias primaryText: collectibleName.text
    property alias secondaryText: collectibleId.text
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 40
        height: 40
        isImage: true
    }

    RowLayout {
        spacing: 8
        StatusSmartIdenticon {
            id: identiconLoader
            Layout.alignment: Qt.AlignVCenter
            asset: root.asset
        }
        StatusBaseText {
            id: collectibleName
            Layout.preferredWidth: Math.min(root.width - identiconLoader.width - collectibleId.width - 24, implicitWidth)
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 28
            lineHeight: 38
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            id: collectibleId
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 28
            lineHeight: 38
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.baseColor1
        }
    }
}
