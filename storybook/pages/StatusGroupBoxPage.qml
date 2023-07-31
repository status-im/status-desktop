import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import utils 1.0


SplitView {
    orientation: Qt.Vertical

    component LabeledSlider: Row {
        property alias text: label.text
        property alias value: slider.value
        property alias from: slider.from
        property alias to: slider.to

        Label {
            id: label

            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            id: slider

            value: (from + to) / 2
            from: 10
            to: 500
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        clip: true

        StatusGroupBox {
            id: group

            anchors.centerIn: parent

            title: titleTextEdit.text
            icon: Style.png("tokens/SNT")
            iconSize: iconSizeSlider.value

            label.enabled: labelEnabledCheckBox.checked

            width: undefinedSizeCheckBox.checked ? undefined
                                                 : widthSlider.value
            height: undefinedSizeCheckBox.checked ? undefined
                                                  : heightSlider.value

            Button {
                width: group.availableWidth
                height: group.availableHeight

                text: "Content button with some text"

                implicitWidth: contentImplicitWidthSlider.value
                implicitHeight: contentImplicitHeightSlider.value
            }
        }
    }

    ScrollView {
        clip: true

        Pane {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            ColumnLayout {
                LabeledSlider {
                    id: widthSlider

                    enabled: !undefinedSizeCheckBox.checked
                    text: "width:"
                }

                LabeledSlider {
                    id: heightSlider

                    enabled: !undefinedSizeCheckBox.checked
                    text: "height:"
                }

                CheckBox {
                    id: undefinedSizeCheckBox
                    text: "Undefined size"
                    checked: true
                }

                LabeledSlider {
                    id: contentImplicitWidthSlider

                    text: "content implicit width:"
                }

                LabeledSlider {
                    id: contentImplicitHeightSlider

                    text: "content implicit height:"
                }

                LabeledSlider {
                    id: iconSizeSlider

                    from: 10
                    to: 40
                    value: 18
                    text: "iconSize:"
                }

                RowLayout {
                    TextField {
                        id: titleTextEdit

                        text: "Some title goes here"
                    }

                    CheckBox {
                        id: labelEnabledCheckBox

                        checked: true
                        text: "label enabled"
                    }
                }
            }
        }
    }
}

// category: Components
