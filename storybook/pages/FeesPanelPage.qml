import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.panels 1.0

import Storybook 1.0
import Models 1.0


SplitView {
    FeesModel {
        id: feesModel
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: feesPanel
            anchors.margins: -15
            border.color: "lightgray"
            color: "transparent"
        }

        FeesPanel {
            id: feesPanel

            anchors.centerIn: parent

            width: 500

            model: LimitProxyModel {
                sourceModel: feesModel
                limit: countSlider.value
            }

            placeholderText: placeholderTextField.text

            footer: Rectangle {
                id: footer

                visible: showFooterSwitch.checked

                height: 100

                border.color: "lightgray"
                color: "transparent"

                Label {
                    anchors.centerIn: parent
                    text: "footer"
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true

                text: "Placeholder text"
            }

            TextField {
                id: placeholderTextField

                Layout.fillWidth: true
                text: "Add valid “What” and “To” values to see fees"
            }

            Switch {
                id: showFooterSwitch

                text: "Show footer"
                checked: true
            }

            Label {
                Layout.fillWidth: true

                text: "Number of items in the model"
            }

            RowLayout {
                Slider {
                    id: countSlider

                    from: 0
                    to: feesModel.count
                    value: to

                    stepSize: 1
                    snapMode: Slider.SnapAlways
                }

                Label {
                    text: countSlider.value
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
