import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        CreateChannelPopup {
            anchors.centerIn: parent
            modal: false
            closePolicy: Popup.NoAutoClose

            isEdit: isEditCheckBox.checked
            isDeleteable: isDeleteableCheckBox.checked

            emojiPopup: Popup {
                id: emojiPopup

                parent: root

                property var emojiSize

                Button {
                    text: "😃"
                    onClicked: {
                        emojiPopup.emojiSelected(text, false)
                        emojiPopup.close()
                    }
                }

                signal emojiSelected(string emoji, bool atCu)
            }


            onCreateCommunityChannel: function(chName, chDescription, chEmoji, chColor, chCategoryId) {
                logs.logEvent("onCreateCommunityChannel",
                              ["chName", "chDescription", "chEmoji", "chColor", "chCategoryId"], arguments)
            }

            onEditCommunityChannel: function(chName, chDescription, chEmoji, chColor, chCategoryId) {
                logs.logEvent("onEditCommunityChannel",
                              ["chName", "chDescription", "chEmoji", "chColor", "chCategoryId"], arguments)
            }

            onDeleteCommunityChannel: () => {
                logs.logEvent("onDeleteCommunityChannel")
            }

            Component.onCompleted: open()
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        RowLayout {
            CheckBox {
                id: isEditCheckBox

                text: "isEdit"
            }
            CheckBox {
                id: isDeleteableCheckBox

                enabled: isEditCheckBox.checked
                text: "isDeleteable"
            }
        }
    }
}
