import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores/NetworkSelectPopup"

StatusListItem {
    id: root

    property var networkModel: null
    property var singleSelection
    property var radioButtonGroup
    property bool useEnabledRole: true

    signal toggleNetwork(var network, var model, int index)

    /// Mirrors Nim's UxEnabledState enum from networks/item.nim
    enum UxEnabledState {
        Enabled,
        AllEnabled,
        Disabled
    }

    QtObject {
        id: d
        property SingleSelectionInfo tmpObject: SingleSelectionInfo { enabled: true }
    }

    objectName: model.chainName
    title: model.chainName
    asset.height: 24
    asset.width: 24
    asset.isImage: true
    asset.name: Style.svg(model.iconUrl)
    onClicked: {
        if(!root.singleSelection.enabled) {
            checkBox.nextCheckState()
        } else if(!radioButton.checked) {   // Don't allow uncheck
            radioButton.toggle()
        }
    }

    components: [
        StatusCheckBox {
            id: checkBox
            objectName: "networkSelectionCheckbox_" + model.chainName
            tristate: true
            visible: !root.singleSelection.enabled

            checkState: {
                if(root.useEnabledRole) {
                    return model.isEnabled ? Qt.Checked : Qt.Unchecked
                } else if(model.enabledState === NetworkSelectItemDelegate.Enabled) {
                    return Qt.Checked
                } else {
                    if( model.enabledState === NetworkSelectItemDelegate.AllEnabled) {
                        return Qt.PartiallyChecked
                    } else {
                        return Qt.Unchecked
                    }
                }
            }

            nextCheckState: () => {
                                Qt.callLater(root.toggleNetwork, model, root.networkModel, model.index)
                                return Qt.PartiallyChecked
                            }
        },
        StatusRadioButton {
            id: radioButton
            visible: root.singleSelection.enabled
            size: StatusRadioButton.Size.Large
            ButtonGroup.group: root.radioButtonGroup
            checked: root.singleSelection.currentModel === root.networkModel && root.singleSelection.currentIndex === model.index

            property SingleSelectionInfo exchangeObject: null
            function setNewInfo(networkModel, index) {
                d.tmpObject.currentModel = networkModel
                d.tmpObject.currentIndex = index
                exchangeObject = d.tmpObject
                d.tmpObject = root.singleSelection
                root.singleSelection = exchangeObject
                exchangeObject = null
            }

            onCheckedChanged: {
                if(checked && (root.singleSelection.currentModel !== root.networkModel || root.singleSelection.currentIndex !== model.index)) {
                    setNewInfo(root.networkModel, model.index)
                    root.toggleNetwork(({chainId: model.chainId, chainName: model.chainName, iconUrl: model.iconUrl}), root.networkModel, model.index)
                }
            }
        }
    ]
}
