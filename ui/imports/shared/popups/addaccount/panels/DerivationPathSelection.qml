import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusMenu {
    id: root

    implicitWidth: 285
    padding: 0

    property string selectedRootPath
    property var roots: []
    property var translation: (key, isTitle) => console.error("Must provide implementation")

    signal selected(string rootPath)

    contentItem: StatusListView {
        model: root.roots.length
        implicitHeight: contentHeight
        delegate: StatusListItem {
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
