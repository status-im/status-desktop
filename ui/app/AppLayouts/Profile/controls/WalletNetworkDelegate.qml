import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    property string chainName
    property string iconUrl
    property bool isActive
    property bool isDeactivatable

    signal setNetworkActive(bool active)
    signal editNetwork()

    QtObject {
        id: d

        function toggleActive() {
            if (root.isDeactivatable) {
                root.setNetworkActive(!root.isActive)
            }
        }
    }

    onClicked: d.toggleActive()

    title: chainName
    asset.name: Theme.svg(iconUrl)
    asset.isImage: true
    width: parent.width
    leftPadding: Theme.padding
    rightPadding: Theme.padding
    components: [
        RowLayout {
            spacing: 16
            Item {
                implicitWidth: isActiveSwitch.width
                implicitHeight: isActiveSwitch.height

                StatusSwitch {
                    id: isActiveSwitch
                    objectName: "isActiveSwitch_" + chainName
                    enabled: !root.isActive || root.isDeactivatable
                    checked: root.isActive
                    onToggled:{
                        checked = Qt.binding(() => root.isActive)
                        d.toggleActive()
                    }
                }

                StatusMouseArea {
                    id: inactiveSwitchMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    visible: !isActiveSwitch.enabled
                    hoverEnabled: true
                }

                StatusToolTip {
                    visible: !!inactiveSwitchMouseArea.containsMouse
                    text: qsTr("Required for some Status features")
                }
            }

            StatusFlatButton {
                icon.name: "pencil-outline"
                icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1 
                onClicked: root.editNetwork()
            }
        }
    ]
}
