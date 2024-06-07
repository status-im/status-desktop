import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

AccountSelector {
    id: root
    
    control.padding: 0
    control.rightInset: -6 //broken indicator positioning
    control.spacing: 4

    indicator.color: Theme.palette.indirectColor1

    control.background: Rectangle {
        objectName: "headerBackground"
        radius: 8
        color: d.headerStyleBackgroundColor
    }

    contentItem: RowLayout {
        id: contentItemRow

        spacing: 0

        StatusSmartIdenticon {
            id: assetContent
            objectName: "assetContent"
            asset.emoji: currentAccount.emoji ?? ""
            asset.color: d.headerStyleBackgroundColor
            asset.width: 32
            asset.height: asset.width
            asset.isLetterIdenticon: !!currentAccount.emoji
            asset.bgColor: Theme.palette.primaryColor3
            visible: !!currentAccount.emoji
        }

        StatusBaseText {
            id: textContent
            objectName: "textContent"
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: currentAccount.name ?? ""
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: 15
            color: Theme.palette.indirectColor1
        }
    }

    QtObject {
        id: d
        readonly property color headerStyleBackgroundColor: !!currentAccount ? root.control.hovered ?
                                        Utils.getHoveredColor(currentAccount.colorId) :
                                        Utils.getColorForId(currentAccount.colorId) : "transparent"
    }
}
