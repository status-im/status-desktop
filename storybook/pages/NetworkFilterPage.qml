import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

import AppLayouts.stores 1.0
import AppLayouts.Wallet.controls 1.0

SplitView {
    id: root
    Logs { id: logs }

    readonly property string ethereumName : "Ethereum Mainnet"
    readonly property string optimismName : "Optimism"
    readonly property string arbitrumName : "Arbitrum"



    // Keep a clone so that the UX can be modified without affecting the original model
    CloneModel {
        id: simulatedNimModel

        sourceModel: SortFilterProxyModel {
            sourceModel: NetworksModel.flatNetworks
            filters: ValueFilter { roleName: "isTest"; value: false }
        }

        roles: ["chainId", "layer", "chainName", "isTest", "isEnabled", "iconUrl", "shortName", "chainColor"]
        rolesOverride: [{ role: "enabledState", transform: (mD) => {
                return simulatedNimModel.areAllEnabled(sourceModel)
                        ? NetworkSelectItemDelegate.UxEnabledState.AllEnabled
                        : mD.isEnabled
                            ? NetworkSelectItemDelegate.UxEnabledState.Enabled
                            : NetworkSelectItemDelegate.UxEnabledState.Disabled
            }
        }]

        /// Simulate the Nim model
        function toggleNetwork(network) {
            const chainId = network.chainId
            let chainIdOnlyEnabled = true
            let chainIdOnlyDisabled = true
            let allEnabled = true
            for (let i = 0; i < simulatedNimModel.count; i++) {
                const item = simulatedNimModel.get(i)
                if(item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Enabled) {
                    if(item.chainId !== chainId) {
                        chainIdOnlyEnabled = false
                    }
                } else if(item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Disabled) {
                    if(item.chainId !== chainId) {
                        chainIdOnlyDisabled = false
                    }
                    allEnabled = false
                } else {
                    if(item.chainId === chainId) {
                        chainIdOnlyDisabled = false
                        chainIdOnlyEnabled = false
                    }
                }
            }
            for (let i = 0; i < simulatedNimModel.count; i++) {
                const item = simulatedNimModel.get(i)
                if(allEnabled) {
                    simulatedNimModel.setProperty(i, "enabledState", item.chainId === chainId ? NetworkSelectItemDelegate.UxEnabledState.Enabled : NetworkSelectItemDelegate.UxEnabledState.Disabled)
                } else if(chainIdOnlyEnabled || chainIdOnlyDisabled) {
                    simulatedNimModel.setProperty(i, "enabledState", NetworkSelectItemDelegate.UxEnabledState.AllEnabled)
                } else if(item.chainId === chainId) {
                    simulatedNimModel.setProperty(i, "enabledState", item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Enabled
                                                  ? NetworkSelectItemDelegate.UxEnabledState.Disabled
                                                  : NetworkSelectItemDelegate.UxEnabledState.Enabled)
                }
                const haveEnabled = item.enabledState !== NetworkSelectItemDelegate.UxEnabledState.Disabled
                if(item.isEnabled !== haveEnabled) {
                    simulatedNimModel.setProperty(i, "isEnabled", haveEnabled)
                }
            }
        }

        function areAllEnabled(modelToCheck) {
            for (let i = 0; i < modelToCheck.count; i++) {
                if(!(modelToCheck.get(i).isEnabled)) {
                    return false
                }
            }
            return true
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            id: container

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            NetworkFilter {
                id: networkFilter

                anchors.centerIn: parent

                flatNetworks: simulatedNimModel

                multiSelection: multiSelectionCheckBox.checked
                showAllSelectedText: ctrlShowAllSelectedText.checked
                showTitle: ctrlShowTitle.checked
                showCheckboxes: ctrlShowCheckBoxes.checked
                showRadioButtons: ctrlShowRadioButtons.checked

                onToggleNetwork: (network) => {
                    logs.logEvent("onToggleNetwork: " + network.chainName)

                    if(multiSelection) {
                        simulatedNimModel.toggleNetwork(network)
                    } else {
                      if(network.chainName === root.ethereumName)
                        ethRadioBtn.checked = true

                      else if(network.chainName === root.optimismName)
                        optRadioBtn.checked = true

                      else if(network.chainName === root.arbitrumName)
                        arbRadioBtn.checked = true
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 16

            CheckBox {
                id: multiSelectionCheckBox
                text: "Multi selection"
                checked: true
                onCheckedChanged: if(!checked) ethRadioBtn.checked = true
            }

            CheckBox {
                id: ctrlShowTitle
                visible: !multiSelectionCheckBox.checked
                text: "Show title text"
                checked: true
            }

            CheckBox {
                id: ctrlShowCheckBoxes
                visible: multiSelectionCheckBox.checked
                text: "Show checkboxes"
                checked: true
            }

            CheckBox {
                id: ctrlShowRadioButtons
                visible: !multiSelectionCheckBox.checked
                text: "Show radio buttons"
                checked: true
            }

            CheckBox {
                id: ctrlShowAllSelectedText
                text: "Show 'All networks' text"
                visible: multiSelectionCheckBox.checked
                checked: true
            }

            ColumnLayout {
                visible: !multiSelectionCheckBox.checked
                Label {
                    Layout.fillWidth: true
                    text: "Chain Id:"
                }

                RadioButton {
                    id: ethRadioBtn

                    text: root.ethereumName
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.ethNet)
                }
                RadioButton {
                    id: optRadioBtn

                    text: root.optimismName
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.optimismNet)
                }
                RadioButton {
                    id: arbRadioBtn

                    text: root.arbitrumName
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.arbitrumNet)
                }
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=13179-346563&mode=design&t=RUkJVqqhgam32C1S-0
