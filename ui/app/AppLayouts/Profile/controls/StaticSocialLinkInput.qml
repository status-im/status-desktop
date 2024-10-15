import QtQuick 2.15

import utils 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: root

    property int linkType
    property string icon

    leftPadding: Theme.padding
    input.clearable: true

    placeholderText: ProfileUtils.linkTypeToDescription(linkType)
    input.asset {
        name: root.icon
        color: ProfileUtils.linkTypeColor(root.linkType)
        width: 20
        height: 20
    }
}
