import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import Storybook 1.0
import Models 1.0
import utils 1.0

SplitView {
    id: root

    Logs { id: logs }

    QtObject {
        id: d

        property string longText: ModelsData.descriptions.longLoremIpsum.repeat(5)
        readonly property bool isRectangle: contentComboBox.currentValue === "rectangle"
        readonly property bool isImage: contentComboBox.currentValue === "image"
        readonly property bool isText: contentComboBox.currentValue === "text"
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.centerIn: parent
                width: 600
                height: 600

                border.color: "black"
                border.width: 1

                StatusScrollView {
                    id: scrolView1
                    anchors.fill: parent
                    anchors.margins: 1
                    contentWidth: widthFillCheckBox.checked ? availableWidth : widthSpinBox.value

                    visible: d.isRectangle

                    Rectangle {
                        gradient: Gradient.NightFade
                        implicitWidth: widthFillCheckBox.checked ? scrolView1.availableWidth : widthSpinBox.value
                        implicitHeight: heightFillCheckBox.checked ? scrolView1.availableHeight : heightSpinBox.value
                    }
                }

                StatusScrollView {
                    id: scrollView3
                    anchors.fill: parent
                    anchors.margins: 1
                    contentWidth: widthFillCheckBox.checked ? availableWidth : widthSpinBox.value

                    visible: d.isImage

                    Image {
                        width: widthFillCheckBox.checked ? scrollView3.availableWidth : widthSpinBox.value
                        source: "https://placekitten.com/900/900"
                    }
                }

                StatusScrollView {
                    id: scrollView2
                    anchors.fill: parent
                    anchors.margins: 1
                    contentWidth: widthFillCheckBox.checked ? availableWidth : widthSpinBox.value

                    visible: d.isText

                    Text {
                        width: widthFillCheckBox.checked ? scrollView2.availableWidth : widthSpinBox.value
                        wrapMode: Text.WrapAnywhere
                        text: d.longText
                    }
                }
            }
        }

        StatusModal {
            id: modal

            anchors.centerIn: parent
            padding: 0
            destroyOnClose: false

            headerSettings.title: "StatusScrollView"
            showFooter: false

            StatusScrollView {
                id: modalScrollView

                anchors.fill: parent
                contentWidth: availableWidth

                Text {
                    width: modalScrollView.availableWidth
                    wrapMode: Text.WrapAnywhere
                    text: d.longText
                }
            }
        }

        StatusModal {
            id: modal2

            anchors.centerIn: parent
            padding: 16
            destroyOnClose: false

            headerSettings.title: "StatusScrollView (detached scrollbars)"
            showFooter: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                Text {
                    id: textItem
                    Layout.fillWidth: true
                    text: "This header is fixed and not scrollable"
                    font.pixelSize: 18
                }

                Item {
                    id: modal2scrollViewWrapper
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    implicitWidth: modal2scrollView.implicitWidth
                    implicitHeight: modal2scrollView.implicitHeight

                    StatusScrollView {
                        id: modal2scrollView

                        anchors.fill: parent
                        contentWidth: availableWidth

                        padding: 0

                        ScrollBar.vertical: StatusScrollBar {
                            parent: modal2scrollViewWrapper
                            anchors.top: modal2scrollView.top
                            anchors.bottom: modal2scrollView.bottom
                            anchors.left: modal2scrollView.right
                            anchors.leftMargin: 1
                        }

                        Text {
                            width: modal2scrollView.availableWidth
                            wrapMode: Text.WordWrap
                            text: d.longText
                        }
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        Layout.fillHeight: true
                        text: "StatusModal"
                        onClicked: {
                            modal.open()
                        }
                    }
                    Button {
                        Layout.fillHeight: true
                        text: "StatusModal\n(detached bar)"
                        onClicked: {
                            modal2.open()
                        }
                    }
                }

                Label {
                    id: slidesLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    textFormat: Text.MarkdownText
                    text: "Please, read our [contributing guide](https://github.com/status-im/status-desktop/blob/master/ui/StatusQ/src/contributing.md#StatusScrollView) (or checkout a [presenation](https://docs.google.com/presentation/d/1ZZeg9j2fZMV-iHreu_Wsl1u6D9POH7SlUO78ZXNj-AI)) about using `StatusScrollView`"
                    onLinkActivated: (link) => {
                        Qt.openUrlExternally(link)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        visible: !!slidesLabel.hoveredLink
                        acceptedButtons: Qt.NoButton
                    }
                }

            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10

                ComboBox {
                    id: contentComboBox
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.bottomMargin: 20
                    model: ["image", "rectangle", "text"]
                }

                Label {
                    text: "fill width"
                }
                CheckBox {
                    id: widthFillCheckBox
                }

                Label {
                    text: "rectangle width"
                }
                SpinBox {
                    id: widthSpinBox
                    enabled: !widthFillCheckBox.checked
                    editable: true
                    height: 30
                    value: 900
                    stepSize: 100
                    from: 0
                    to: 1000
                }

                Label {
                    text: "fill height"
                }
                CheckBox {
                    id: heightFillCheckBox
                    checked: false
                }

                Label {
                    text: "rectangle height"
                }
                SpinBox {
                    id: heightSpinBox
                    editable: true
                    height: 30
                    value: 800
                    stepSize: 100
                    from: 0
                    to: 1000
                }
            }
        }
    }
}

// category: Components
