import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    id: root

    property bool checked: true
    property bool allChecked : false
    property int type
    property ButtonGroup buttonGroup
    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 24
        height: 24
        bgWidth: 0
        bgHeight: 0
        bgRadius: 0
        bgColor: Theme.palette.primaryColor3
        color: Theme.palette.primaryColor1
    }

    signal actionTriggered()

    height: 44
    radius: 0
    leftPadding: 21
    rightPadding: 21
    asset: root.assetSettings
    statusListItemTitle.font.pixelSize: 13
    components: [
        StatusCheckBox {
            id: checkBox
            tristate: true
            checkable: true
            spacing: 0
            leftPadding: 0
            rightPadding: 0
            checkState: root.allChecked ? Qt.PartiallyChecked : root.checked ? Qt.Checked : Qt.Unchecked
            nextCheckState: () => {
                                root.actionTriggered()
                                return checkState
                            }
            ButtonGroup.group: buttonGroup
        }
    ]
    onClicked: checkBox.nextCheckState()
}
