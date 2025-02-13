import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.controls 1.0

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0

SplitView {
    id: root

    Item {
        implicitWidth: delegate.width
        NetworkSelectItemDelegate {
            id: delegate
            title: "Ethereum"
            iconUrl: Theme.svg("network/Network=Ethereum")
            showIndicator: true
            multiSelection: true
            checkState: checkStateSelector.checkState
            nextCheckState: checkState === Qt.Unchecked ? Qt.PartiallyChecked : 
                        checkState === Qt.PartiallyChecked ? Qt.Checked : Qt.Unchecked

            onCheckStateChanged: {
                checkStateSelector.checkState = checkState
            }
        }
    }

    Pane {
        id: pane
        SplitView.fillWidth: true
        ColumnLayout {
            CheckBox {
                text: "showIndicator"
                checked: delegate.showIndicator
                onCheckedChanged: {
                    delegate.showIndicator = checked
                }
            }

            CheckBox {
                text: "multiSelection"
                checked: delegate.multiSelection
                onCheckedChanged: {
                    delegate.multiSelection = checked
                }
            }

            CheckBox {
                text: "showNewIcon"
                checked: delegate.showNewIcon
                onCheckedChanged: {
                    delegate.showNewIcon = checked
                }
            }

            Label {
                text: "title"
            }
            TextField {
                text: delegate.title
                onTextChanged: {
                    delegate.title = text
                }
            }

            Label {
                text: "iconUrl"
            }
            TextField {
                text: delegate.iconUrl
                onTextChanged: {
                    delegate.iconUrl = text
                }
            }

            CheckBox {
                id: checkStateSelector
                text: "checkedState"
                tristate: true
                checked: true
                onCheckStateChanged: {
                    if(delegate.checkState !== checkState) {
                        delegate.checkState = checkState
                    }
                }
            }
        }
    }
}

// category: Controls
