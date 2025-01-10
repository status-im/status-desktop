import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls.chat 1.0
import utils 1.0

ItemDelegate {
    id: root

    property string label
    property int colorId
    property var colorHash
    property string image
    property bool keycardCreatedAccount
    property bool keycardLocked
    property bool isAction

    verticalPadding: 12
    leftPadding: Theme.padding
    rightPadding: Theme.bigPadding
    spacing: Theme.padding

    background: Rectangle {
        color: root.hovered || root.highlighted ? Theme.palette.statusSelect.menuItemHoverBackgroundColor
                                                : "transparent"
    }

    contentItem: RowLayout {
        spacing: root.spacing
        Loader {
            id: userImageOrIcon
            sourceComponent: root.isAction ? actionIcon : userImage
        }

        Component {
            id: actionIcon
            StatusRoundIcon {
                asset.name: root.image
            }
        }

        Component {
            id: userImage
            UserImage {
                name: root.label
                image: root.image
                colorId: root.colorId
                colorHash: root.colorHash
                imageHeight: Constants.onboarding.userImageHeight
                imageWidth: Constants.onboarding.userImageWidth
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: StatusQUtils.Emoji.parse(root.label)
            color: root.isAction ? Theme.palette.primaryColor1 : Theme.palette.directColor1
            elide: Text.ElideRight
        }

        Loader {
            id: keycardIcon
            active: root.keycardCreatedAccount
            sourceComponent: StatusIcon {
                icon: "keycard"
                color: root.keycardLocked ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
            }
        }
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
    }
}
