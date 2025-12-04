import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Utils as StatusQUtils

import shared.controls
import utils

Control {
    id: root

    property alias asset: identicon.asset
    property string communityName
    property string communityId
    property string communityImage
    property bool loading

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
    verticalPadding: Theme.halfPadding
    spacing: 4

    background: Loader {
        sourceComponent: root.loading ? d.loadingComponent : root.customBackground
    }

    contentItem: RowLayout {
        spacing: root.spacing
        visible: !root.loading
        StatusSmartIdenticon {
            id: identicon
            Layout.preferredWidth: visible ? asset.width : 0
            Layout.preferredHeight: visible ? asset.width : 0
            asset.width: 16
            asset.height: 16
            visible: !d.unknownCommunityName && !!asset.source

            Component.onCompleted: {
                updateCommunityImage()
            }
            Connections {
                target: root
                function onCommunityImageChanged() {
                    identicon.updateCommunityImage()
                }
            }

            function updateCommunityImage() {
                if (!root.communityId) // in a grouped (non-community) delegate don't overwrite the group icon
                    return
                // Ensure we keep the flag in sync with the type of asset otherwise we generate warnings
                identicon.asset.name = ""
                identicon.asset.isImage = !!root.communityImage
                identicon.asset.name = !!root.communityImage ? root.communityImage : "help"
            }
        }

        RowLayout {
            spacing: 2
            Layout.fillWidth: true

            StatusBaseText {
                Layout.fillWidth: true
                visible: (!!root.communityName || d.unknownCommunityName)
                font.pixelSize: Theme.tertiaryTextFontSize
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
                icon.height: Theme.tertiaryTextFontSize
                icon.width: Theme.tertiaryTextFontSize
                icon.color: Theme.palette.directColor1
                color: StatusColors.transparent
                textToCopy: root.communityName
                onCopyClicked: (textToCopy) => ClipboardUtils.setText(textToCopy)
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
