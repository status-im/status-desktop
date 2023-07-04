import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.panels 1.0

import Models 1.0
import Storybook 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        RowLayout {
            spacing: 100
            anchors.centerIn: parent

            PrivilegedTokenArtworkPanel {
                size: PrivilegedTokenArtworkPanel.Size.Small
                artwork: doodles.checked ? ModelsData.collectibles.doodles : ModelsData.collectibles.mana
                color: color1.checked ?  "#FFC4E9" : "#f44336"
                isOwner: ownerMode.checked                
                showTag: showTag.checked
            }

            PrivilegedTokenArtworkPanel {
                size: PrivilegedTokenArtworkPanel.Size.Large
                artwork: doodles.checked ? ModelsData.collectibles.doodles : ModelsData.collectibles.mana
                color: color1.checked ?  "#FFC4E9" : "#f44336"
                isOwner: ownerMode.checked
                showTag: showTag.checked
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.fillWidth: true
        SplitView.preferredHeight: 250

        logsView.logText: logs.logText

        ColumnLayout {

            CheckBox {
                id: showTag

                text: "Show tag"
                checked: false
            }

            RowLayout {
                RadioButton {
                    id: ownerMode
                    text: "Owner"
                    checked: true
                }

                RadioButton {
                    id: masterTokenMode
                    text: "Token Master"
                }
            }

            RowLayout {
                RadioButton {
                    id: color1

                    text: "Light pink"
                    checked: true
                }

                RadioButton {
                    text: "Orange"
                }
            }

            RowLayout {
                RadioButton {
                    id: doodles
                    text: "Doodles"
                    checked: true
                }

                RadioButton {
                    text: "Mana"
                }
            }
        }
    }
}
