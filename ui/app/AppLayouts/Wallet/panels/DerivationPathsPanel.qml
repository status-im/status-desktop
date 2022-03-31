import QtQuick 2.12

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import "../stores"

StatusSelect {
    id: derivationPathSelect

    property string path: ""

    function reset() {
        derivationPathSelectedItem.title = DerivationPathModel.derivationPaths.get(0).name
        derivationPathSelectedItem.subTitle = DerivationPathModel.derivationPaths.get(0).path
    }

    label: qsTr("Derivation Path")
    selectMenu.width: 351
    menuAlignment: StatusSelect.MenuAlignment.Left
    model: DerivationPathModel.derivationPaths
    selectedItemComponent: StatusListItem {
        id: derivationPathSelectedItem
        implicitWidth: parent.width
        statusListItemTitle.wrapMode: Text.NoWrap
        statusListItemTitle.width: parent.width - Style.current.padding
        statusListItemTitle.elide: Qt.ElideMiddle
        statusListItemTitle.anchors.left: undefined
        statusListItemTitle.anchors.right: undefined
        icon.background.color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        title: DerivationPathModel.derivationPaths.get(0).name
        subTitle: DerivationPathModel.derivationPaths.get(0).path
        Component.onCompleted: {
            derivationPathSelect.path = Qt.binding(function() { return derivationPathSelectedItem.subTitle})
        }
    }
    selectMenu.delegate: StatusListItem {
        implicitWidth: parent.width
        statusListItemTitle.wrapMode: Text.NoWrap
        statusListItemTitle.width: parent.width - Style.current.padding
        statusListItemTitle.elide: Qt.ElideMiddle
        statusListItemTitle.anchors.left: undefined
        statusListItemTitle.anchors.right: undefined
        title: model.name
        subTitle: model.path
        onClicked: {
            derivationPathSelectedItem.title = title
            derivationPathSelectedItem.subTitle = subTitle
            derivationPathSelect.selectMenu.close()
        }
    }
}


