import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

import "../stores/NetworkSelectPopup"
import "../controls"
import "../views"

StatusDialog {
    id: root

    modal: false
    standardButtons: Dialog.NoButton

    anchors.centerIn: undefined

    padding: 4
    width: 360
    implicitHeight: Math.min(432, scrollView.contentHeight + root.padding * 2)

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    required property var layer1Networks
    required property var layer2Networks
    property var testNetworks: null

    /// Grouped properties for single selection state. \c singleSelection.enabled is \c false by default
    /// \see SingleSelectionInfo
    property alias singleSelection: d.singleSelection

    property bool useEnabledRole: true

    /// \c network is a network.model.nim entry. \c model and \c index for the current selection
    /// It is called for every toggled network if \c singleSelection.enabled is \c false
    /// If \c singleSelection.enabled is \c true, it is called only for the selected network when the selection changes
    /// \see SingleSelectionInfo
    signal toggleNetwork(var network, var model, int index)

    QtObject {
        id: d

        property SingleSelectionInfo singleSelection: SingleSelectionInfo {}
    }

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    NetworkSelectionView {
        id: scrollView
        anchors.fill: parent
        layer1Networks: root.layer1Networks
        layer2Networks: root.layer2Networks
        testNetworks: root.testNetworks
        useEnabledRole: root.useEnabledRole
        singleSelection: d.singleSelection
        onToggleNetwork: {
            root.toggleNetwork(network, model, index)
            if(d.singleSelection.enabled)
                close()
        }
    }
}
