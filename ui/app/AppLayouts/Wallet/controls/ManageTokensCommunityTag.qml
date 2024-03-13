import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0
import utils 1.0

Control {
    id: root

    property alias asset: identicon.asset
    property string communityName
    property string communityId
    property var communityImage
    property bool loading
    property bool useLongTextDescription: true

    property Component customBackground: Component {
        Rectangle {
            border.width: 1
            border.color: Theme.palette.baseColor2
            color: enabled ? Theme.palette.baseColor4 : Theme.palette.baseColor3
            radius: 20
        }
    }

    QtObject {
        id: d
        readonly property bool unknownCommunityName: !!root.communityName ? root.communityName.startsWith("0x") && root.communityName === root.communityId : false
        property var loadingComponent: Component { LoadingComponent {} }
    }

    horizontalPadding: 12
    verticalPadding: Style.current.halfPadding
    spacing: 4

    background: Loader {
        sourceComponent: root.loading ? d.loadingComponent : root.customBackground
    }

    contentItem: RowLayout {
        spacing: root.spacing
        visible: !root.loading
        StatusSmartIdenticon {
            id: identicon
            Layout.preferredWidth: visible ? 16 : 0
            Layout.preferredHeight: visible ? 16 : 0
            asset.width: 16
            asset.height: 16
            visible: root.useLongTextDescription && !!asset.source
            asset.name: !!root.communityImage ? root.communityImage : "help"
            asset.isImage: !!root.communityImage
        }

        RowLayout {
            spacing: 2
            Layout.fillWidth: true

            StatusBaseText {
                Layout.fillWidth: true

                font.pixelSize: Style.current.tertiaryTextFontSize
                font.weight: Font.Medium
                text:  {
                    if (d.unknownCommunityName) {
                        if (communityNameToolTip.visible) {
                            if (!root.full) {
                                return StatusQUtils.Utils.elideAndFormatWalletAddress(root.communityName)
                            }
                            return qsTr("Community %1").arg(StatusQUtils.Utils.elideAndFormatWalletAddress(root.communityName))
                        }
                        if (!root.full) {
                            return qsTr("Unknown")
                        }

                        return qsTr("Unknown community")
                    }
                    
                    return root.communityName
                }
                elide: Text.ElideRight
                color: enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1                
            }

            CopyToClipBoardButton {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16

                visible: d.unknownCommunityName && root.hovered
                icon.height: Style.current.tertiaryTextFontSize
                icon.width: Style.current.tertiaryTextFontSize
                icon.color: Theme.palette.directColor1
                color: Style.current.transparent
                textToCopy: root.communityName
                onCopyClicked: {
                    Utils.copyToClipboard(textToCopy)
                }
            }           
        }
    }

    StatusToolTip {
        id: communityNameToolTip
        text: qsTr("Community name could not be fetched")
        visible: d.unknownCommunityName && root.hovered
        orientation: StatusToolTip.Orientation.Top
    }
}
