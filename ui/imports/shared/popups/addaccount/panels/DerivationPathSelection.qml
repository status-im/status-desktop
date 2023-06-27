import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusMenu {
    id: root

    implicitWidth: 285

    property string selectedRootPath
    property var roots: []
    property var translation: function (key, isTitle) {}

    signal selected(string rootPath)

    contentItem: Column {
        width: root.width

        Repeater {
            model: root.roots.length

            StatusListItem {
                objectName: "AddAccountPopup-PreDefinedDerivationPath-%1".arg(title)
                width: parent.width
                title: root.translation(root.roots[index], true)
                subTitle: root.translation(root.roots[index], false)

                components: [
                    StatusIcon {
                        visible: root.selectedRootPath === root.roots[index]
                        icon: "checkmark"
                        color: Theme.palette.primaryColor1
                    }
                ]

                onClicked: {
                    root.selected(root.roots[index])
                    root.close()
                }
            }
        }
    }
}
