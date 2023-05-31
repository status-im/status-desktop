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

        property string longText: "facilisis magna etiam tempor orci eu lobortis elementum nibh tellus molestie nunc non blandit massa enim nec dui nunc mattis enim ut tellus elementum sagittis vitae et leo duis ut diam quam nulla porttitor massa id neque aliquam vestibulum morbi blandit cursus risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit eget gravida cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus mauris vitae ultricies leo integer malesuada nunc vel risus commodo viverra maecenas accumsan lacus vel facilisis volutpat est velit egestas dui id ornare arcu odio ut sem nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est ultricies integer quis auctor elit sed vulputate mi sit amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat semper viverra nam libero justo laoreet sit amet cursus sit amet dictum sit amet justo donec enim diam vulputate ut pharetra sit amet aliquam id diam maecenas ultricies mi eget mauris pharetra et ultrices neque ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus urna neque viverra justo nec ultrices dui sapien eget mi proin sed libero enim sed faucibus turpis in eu mi bibendum neque egestas congue quisque egestas diam in arcu cursus euismod quis viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat sed cras ornare arcu dui vivamus arcu felis bibendum ut tristique et egestas quis ipsum suspendisse ultrices gravida dictum fusce ut placerat orci nulla pellentesque dignissim enim sit amet venenatis urna cursus eget nunc scelerisque viverra mauris in aliquam sem fringilla ut morbi tincidunt augue interdum velit euismod in pellentesque massa placerat duis ultricies lacus sed turpis tincidunt id aliquet risus feugiat in ante metus dictum at tempor commodo ullamcorper a lacus vestibulum sed arcu non odio euismod lacinia at quis risus sed vulputate odio ut enim blandit volutpat maecenas volutpat blandit aliquam etiam erat velit scelerisque in dictum non consectetur a erat nam at lectus urna duis convallis convallis tellus id interdum velit laoreet id donec ultrices tincidunt arcu non sodales neque sodales ut etiam sit amet nisl purus in mollis nunc sed id semper risus in hendrerit gravida rutrum quisque non tellus orci ac auctor augue mauris augue neque gravida in fermentum et sollicitudin ac orci phasellus"
        readonly property bool isRectangle: contentComboBox.currentValue === "rectangle"
        readonly property bool isText: contentComboBox.currentValue === "text"
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        StatusScrollView {
            id: scrolView1
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: widthFillCheckBox.checked ? availableWidth : widthSpinBox.value

            visible: d.isRectangle

            Rectangle {
                gradient: Gradient.NightFade
                implicitWidth: widthFillCheckBox.checked ? scrolView1.availableWidth : widthSpinBox.value
                implicitHeight: heightFillCheckBox.checked ? scrolView1.availableHeight : heightSpinBox.value
            }
        }

        StatusScrollView {
            id: scrollView2
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: widthFillCheckBox.checked ? availableWidth : widthSpinBox.value

            visible: d.isText

            Text {
                width: widthFillCheckBox.checked ? scrollView2.availableWidth : widthSpinBox.value
                wrapMode: Text.WrapAnywhere
                text: d.longText
            }
        }

        StatusModal {
            id: modal
            anchors.centerIn: parent

            padding: 0

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

            RowLayout {
                anchors.centerIn: parent

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
                    model: ["rectangle", "text"]
                }

                Label {
                    text: "fill width"
                }
                CheckBox {
                    id: widthFillCheckBox
                    checked: true
                }

                Label {
                    text: "rectangle width"
                }
                SpinBox {
                    id: widthSpinBox
                    enabled: !widthFillCheckBox.checked
                    editable: true
                    height: 30
                    value: 500
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
                    enabled: d.isRectangle
                }

                Label {
                    text: "rectangle height"
                }
                SpinBox {
                    id: heightSpinBox
                    editable: true
                    enabled: d.isRectangle
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
