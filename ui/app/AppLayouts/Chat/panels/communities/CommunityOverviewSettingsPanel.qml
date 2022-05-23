import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "../../layouts"

/*! TODO: very confusing to be refactored

    The "API" properties are just for input purposes and to track the initial state
    used in evaluating the dirty flag. They should not be updated based
    on user input. The final relevant values are accessed through the \c item member of \c edit property
 */
StackLayout {
    id: root

    property string name
    property string description
    property string logoImageData
    property string bannerImageData
    property rect bannerCropRect
    property color color
    property bool editable: false
    property bool owned: false
    property bool isCommunityHistoryArchiveSupportEnabled: false
    property bool historyArchiveSupportToggle: false

    signal edited(Item item) // item containing edited fields (name, description, logoImagePath, bannerPath, bannerCropRect, color)

    clip: true

    SettingsPageLayout {
        title: qsTr("Overview")

        content: ColumnLayout {
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                spacing: 16

                StatusSmartIdenticon {
                    name: root.name

                    icon {
                        width: 80
                        height: 80
                        isLetterIdenticon: !root.logoImageData
                        color: root.color
                        letterSize: width / 2.4
                    }

                    image {
                        width: 80
                        height: 80
                        source: root.logoImageData
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StatusBaseText {
                        id: nameText
                        Layout.fillWidth: true
                        font.pixelSize: 24
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.name
                    }

                    StatusBaseText {
                        id: descriptionText
                        Layout.fillWidth: true
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.description
                    }
                }

                StatusButton {
                    visible: root.editable
                    text: qsTr("Edit Community")
                    onClicked: root.currentIndex = 1
                }
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1
                visible: root.editable
                color: Theme.palette.statusPopupMenu.separatorColor
            }

            RowLayout {
                Layout.fillWidth: true

                visible: root.owned

                StatusIcon {
                    icon: "info"
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("This node is the Community Owner Node. For your Community to function correctly try to keep this computer with Status running and onlinie as much as possible.")
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    wrapMode: Text.WordWrap
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    SettingsPageLayout {
        id: editCommunityPage

        previousPage: qsTr("Overview")
        title: qsTr("Edit Community")

        content: CommunityEditSettingsPanel {
            id: communityEditSettingsPanel

            name: root.name
            description: root.description
            color: root.color
            logoImageData: root.logoImageData
            bannerImageData: root.bannerImageData
            isCommunityHistoryArchiveSupportEnabled: root.isCommunityHistoryArchiveSupportEnabled
            historyArchiveSupportToggle: root.historyArchiveSupportToggle

            Component.onCompleted: {
                editCommunityPage.dirty =
                        Qt.binding(() => {
                                       return root.name !== name ||
                                              root.description !== description ||
                                              logoImagePath.length > 0 ||
                                              root.color !== color ||
                                              bannerPath.length > 0 ||
                                              isValidRect(bannerCropRect) ||
                                              root.historyArchiveSupportToggle !== historyArchiveSupportToggle
                                   })

                function isValidRect(r /*rect*/) { return r.width !== 0 && r.height !== 0 }
            }
        }

        onPreviousPageClicked: {
            if (dirty) {
                notifyDirty()
            } else {
                root.currentIndex = 0
            }
        }

        onSaveChangesClicked: {
            root.currentIndex = 0
            root.edited(contentItem)
            reloadContent()
        }

        onResetChangesClicked: reloadContent()
    }
}
