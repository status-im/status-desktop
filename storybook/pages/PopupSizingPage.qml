import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15


Item {
    id: root

    readonly property string bugLink:
        "https://bugreports.qt.io/browse/QTBUG-87804"

    Popup {
        id: popup

        visible: true

        width: 200

        x: draggableRectangle.width / 2
        y: draggableRectangle.height / 2

        parent: {
            anchors.centerIn = undefined
            Qt.callLater(() => anchors.centerIn = Qt.binding(
                             () => centerInParentCheckBox.checked ? parent
                                                                  : undefined))
            if (pageRootRadioButton.checked)
                return root

            if (overlayRadioButton.checked)
                return Overlay.overlay

            return draggableRectangle
        }

        closePolicy: Popup.NoAutoClose

        margins: marginsSlider.value

        background: Rectangle {
            border.color: "black"
        }

        Binding on margins{
            id: workaroundBinding

            when: false
        }

        onImplicitContentHeightChanged: {
            if (!workAroundCheckBox.checked)
                return

            workaroundBinding.value = popup.margins + 1
            workaroundBinding.when = true
            workaroundBinding.when = false
        }

        ColumnLayout {
            Button {
                text: "Some button 1"

                Layout.fillWidth: true
            }
            Button {
                text: "Some button 2"

                 Layout.fillWidth: true
            }

            anchors.fill: parent

            ListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: contentHeight

                model: itemsCountSlider.value
                spacing: 2
                clip: true

                delegate: Rectangle {
                    width: popup.availableWidth
                    color: "lightblue"
                    border.color: "black"
                    height: 20

                    Label {
                        text: index
                        anchors.centerIn: parent
                    }
                }
            }

            Button {
                text: "Some button 3"

                 Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        id: draggableRectangle

        visible: draggableRadioButton.checked

        border.color: "green"
        color: "lightgreen"
        border.width: 3

        width: 50
        height: width
        x: 100
        y: 100
        radius: width / 2

        Drag.active: dragArea.drag.active

        MouseArea {
            id: dragArea

            anchors.fill: parent
            drag.target: parent
        }
    }

    Pane {
        anchors.bottom: parent.bottom

        ColumnLayout {
            RowLayout {
                Label {
                    text: "items count:"
                }

                Slider {
                    id: itemsCountSlider

                    from: 5
                    to: 100
                    stepSize: 1

                    value: 10
                }

                Label {
                    text: `(${itemsCountSlider.value})`
                }
            }

            RowLayout {
                Label {
                    text: "margins:"
                }

                Slider {
                    id: marginsSlider

                    from: -1
                    to: 100
                    stepSize: 1

                    value: 10
                }

                Label {
                    text: `(${marginsSlider.value})`
                }
            }

            CheckBox {
                id: centerInParentCheckBox

                checked: true
                text: "Center in parent"
            }

            CheckBox {
                id: workAroundCheckBox

                checked: true
                text: "Use workaround for " +
                      `<a href="${bugLink}">${bugLink}</a>` +
                      " (not needed in Qt 6)"

                contentItem: Label {
                     text: parent.text
                     font: parent.font
                     verticalAlignment: Text.AlignVCenter
                     leftPadding: parent.indicator.width + parent.spacing

                     onLinkActivated: Qt.openUrlExternally(link)
                 }
            }

            RowLayout {
                Label {
                    text: "parent:"
                }

                RadioButton {
                    id: pageRootRadioButton

                    text: "page root"
                    checked: true
                }

                RadioButton {
                    id: overlayRadioButton

                    text: "overlay"
                }

                RadioButton {
                    id: draggableRadioButton

                    text: "draggable item"
                }
            }
        }
    }

    Pane {
        anchors.left: parent.left
        anchors.right: parent.right

        z: -1

        Label {
            anchors.fill: parent

            wrapMode: Text.Wrap

            textFormat: Text.MarkdownText
            text: `Conclusions:

* When component size depends on both content and screen position, it is
  important to set both **Layout.fillHeight: true** and
  **Layout.preferredHeight** for a variable height component.
* There is a bug in Qt causing the default height calculation mechanism doesn't
  work properly in Qt 5.15 (it's ok in Qt 6). The proposed solution works
  transparently and does not change other aspects of behavior.
* The value **margins: -1** has a special meaning and changes the behavior of
  the popup when **anchors.centerIn** is not used. Causes the popup to never be
  positioned higher than the given position, regardless of the amount of space
  available (probably undesirable behavior in most cases).
`
        }
    }
}

// category: Research / Examples
