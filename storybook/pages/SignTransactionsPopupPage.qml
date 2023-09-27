import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    Logs { id: logs }

    FeesModel {
        id: feesModel
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Pane {
            id: pane

            SplitView.fillWidth: true
            SplitView.fillHeight: true
            padding: 0

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            SignTransactionsPopup {
                id: dialog

                model: LimitProxyModel {
                    id: filteredModel

                    sourceModel: feesModel
                    limit: countSlider.value
                }

                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false
                destroyOnClose: false
                parent: pane
                anchors.centerIn: parent

                title: `Sign transaction`

                accountName: accountTextField.text
                errorText: errorTextField.text
                totalFeeText: totalCheckBox.checked ? totalFeeTextField.text : ""

                onSignTransactionClicked: logs.logEvent("SignTransactionsPopup::onSignTransactionClicked")
                onCancelClicked: logs.logEvent("SignTransactionsPopup::onCancelClicked")
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
            anchors.fill: parent

            Label {
                Layout.fillWidth: true

                text: "Error text"
            }

            TextField {
                id: errorTextField

                Layout.fillWidth: true

                text: ""
            }

            Label {
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                text: "Account"
            }

            TextField {
                id: accountTextField

                Layout.fillWidth: true

                text: "My Account"
            }

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        Layout.fillWidth: true

                        text: "Number of items in the model"
                    }

                    RowLayout {
                        Slider {
                            id: countSlider

                            from: 1
                            to: feesModel.count
                            value: to
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                        }

                        Label {
                            text: countSlider.value
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    CheckBox {
                        id: totalCheckBox

                        checked: true
                        text: "Total fee"
                    }

                    TextField {
                        id: totalFeeTextField

                        Layout.fillWidth: true

                        text: "0.01 ETH ($265.43)"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Popups
