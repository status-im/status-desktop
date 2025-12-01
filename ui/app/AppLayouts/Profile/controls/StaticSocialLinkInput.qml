import QtQuick

import utils

import StatusQ.Core.Theme
import StatusQ.Controls

StatusInput {
    id: root

    property int linkType
    property string icon

    leftPadding: Theme.padding
    input.clearable: true

    placeholderText: ProfileUtils.linkTypeToDescription(linkType)
    input.asset {
        name: root.icon
        color: ProfileUtils.linkTypeColor(root.linkType, root.Theme.palette)
        width: 20
        height: 20
    }
}
