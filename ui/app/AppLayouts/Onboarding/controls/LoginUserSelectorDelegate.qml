import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Popups
import StatusQ.Core.Utils as StatusQUtils

import shared.controls.chat
import utils

ItemDelegate {
    id: root

    property string label
    property int colorId
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
            StatusUserImage {
                name:  root.label
                // TODO we should be checking if the user set a custom name
                // but it requires changing the DB which is probably not worth it
                usesDefaultName: !root.image
                image: root.image
                userColor: Utils.colorForColorId(root.colorId)
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
