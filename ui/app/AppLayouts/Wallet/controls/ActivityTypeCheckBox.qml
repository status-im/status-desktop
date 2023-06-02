import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

StatusListItem {
    id: root

    property bool checked: true
    property bool allChecked : false
    property ButtonGroup buttonGroup

    signal actionTriggered(bool checked)

    height: 44
    radius: 0
    leftPadding: 21
    rightPadding: 21
    asset.width: 24
    asset.height: 24
    asset.bgWidth: 0
    asset.bgHeight: 0
    statusListItemTitle.font.pixelSize: 13
    ButtonGroup.group: buttonGroup
    onClicked: checkBox.nextCheckState()
    components: [
        StatusCheckBox {
            id: checkBox
            tristate: true
            spacing: 0
            leftPadding: 0
            rightPadding: 0
            checkState: allChecked ? Qt.PartiallyChecked : root.checked ? Qt.Checked : Qt.Unchecked
            nextCheckState: function() {
                root.actionTriggered(checkBox.checked)
                return Qt.PartiallyChecked
            }
        }
    ]
}
