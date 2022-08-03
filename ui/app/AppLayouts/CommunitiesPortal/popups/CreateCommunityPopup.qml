import QtQuick 2.14
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import "../../Chat/controls/community"

import "../controls"
import "../panels"

StatusStackModal {
    id: root

    property var store
    property string finishButtonLabel: qsTr("Create Community")

    stackTitle: qsTr("Create New Community")
    width: 640

    nextButton: StatusButton {
        objectName: "createCommunityNextBtn"
        text: qsTr("Next")
        enabled:  typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof(nextAction) == "function") {
                return nextAction()
            }
            root.currentIndex++
        }
    }

    finishButton: StatusButton {
        objectName: "createCommunityFinalBtn"
        text: finishButtonLabel
        enabled:  typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof (nextAction) == "function") {
                return nextAction()
            }
            root.close()
        }
    }

    onAboutToShow: nameInput.input.edit.forceActiveFocus()

    stackItems: [
        StatusScrollView {
            id: generalView

            readonly property bool canGoNext: nameInput.valid && descriptionTextInput.valid

            ColumnLayout {
                id: generalViewLayout
                width: generalView.availableWidth
                spacing: 16

                CommunityNameInput {
                    id: nameInput
                    input.edit.objectName: "createCommunityNameInput"
                    Layout.fillWidth: true
                    input.tabNavItem: descriptionTextInput.input.edit
                }

                CommunityDescriptionInput {
                    id: descriptionTextInput
                    input.edit.objectName: "createCommunityDescriptionInput"
                    Layout.fillWidth: true
                    input.tabNavItem: nameInput.input.edit
                }

                CommunityLogoPicker {
                    id: logoPicker
                    Layout.fillWidth: true
                }

                CommunityColorPicker {
                    id: colorPicker
                    onPick: root.replace(colorPanel)
                    Layout.fillWidth: true

                    Component {
                        id: colorPanel

                        CommunityColorPanel {
                            Component.onCompleted: color = colorPicker.color
                            onAccepted: {
                                colorPicker.color = color;
                                root.replace(null);
                            }
                        }
                    }
                }

                CommunityTagsPicker {
                    id: communityTagsPicker
                    tags: root.store.communityTags
                    onPick: root.replace(tagsPanel)
                    Layout.fillWidth: true

                    Component {
                        id: tagsPanel

                        CommunityTagsPanel {
                            Component.onCompleted: {
                                tags = communityTagsPicker.tags;
                                selectedTags = communityTagsPicker.selectedTags;
                            }
                            onAccepted: {
                                communityTagsPicker.selectedTags = selectedTags;
                                root.replace(null);
                            }
                        }
                    }
                }

                StatusModalDivider {
                    Layout.fillWidth: true
                }

                CommunityOptions {
                    id: options

                    archiveSupportOptionVisible: root.store.isCommunityHistoryArchiveSupportEnabled
                    archiveSupportEnabled: archiveSupportOptionVisible
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        },
        ColumnLayout {
            id: introOutroMessageView
            spacing: 11
            readonly property bool canGoNext: introMessageInput.valid && outroMessageInput.valid

            CommunityIntroMessageInput {
                id: introMessageInput
                input.edit.objectName: "createCommunityIntroMessageInput"

                Layout.fillWidth: true
                Layout.fillHeight: true

                minimumHeight: height
                maximumHeight: (height - Style.current.xlPadding)
            }

            CommunityOutroMessageInput {
                id: outroMessageInput
                input.edit.objectName: "createCommunityOutroMessageInput"

                Layout.fillWidth: true
            }
        },

        ColumnLayout {
            spacing: 16
            readonly property bool canGoNext: root.store.discordFileList.hasSelectedItems
            property var nextAction: function () {
                if (!root.store.discordFileList.selectedFilesValid) {
                  return root.store.requestExtractChannelsAndCategories()
                }
                root.currentIndex++
            }

            StatusBaseText {
                text: qsTr("Files to import (%1)").arg(root.store.discordFileList.count)
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Theme.palette.directColor1
                visible: root.store.discordFileList.count > 0
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                visible: root.store.discordFileList.count > 0

                Flickable {
                    clip: true
                    anchors.fill: parent
                    contentHeight: selectFilesView.height
                    implicitHeight: selectFilesView.implicitHeight
                    interactive: contentHeight > height
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: selectFilesView
                        spacing: 12
                        width: parent.width

                        Repeater {
                            id: filesList

                            model: root.store.discordFileList

                            ColumnLayout {
                                width: parent.width
                                spacing: 8
                                StatusCheckBox {
                                    Layout.fillWidth: true
                                    text: model.filePath
                                    checked: model.selected
                                    enabled: model.errorMessage == ""
                                    onToggled: {
                                        model.selected = checked
                                    }
                                }
                                StatusBaseText {
                                    Layout.fillWidth: true
                                    visible: model.errorMessage != ""
                                    text: model.errorMessage
                                }
                            }
                        }
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Please select channel message history files from Discord to import into your new Status Community.")
                wrapMode: Text.WordWrap
                visible: root.store.discordFileList.count == 0
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                StatusButton {
                    text: qsTr("Select files")
                    onClicked: fileDialog.open()
                    visible: root.store.discordFileList.count == 0
                }

                StatusFlatButton {
                    text: qsTr("Clear all")
                    type: StatusBaseButton.Type.Danger
                    visible: root.store.discordFileList.count > 0
                    onClicked: root.store.clearFileList()
                }
            }

            FileDialog {
                id: fileDialog

                title: qsTr("Choose files to import")
                selectMultiple: true
                folder: shortcuts.pictures
                nameFilters: [qsTr("JSON files (%1)").arg("*.json")]
                onAccepted: {
                    if (fileDialog.fileUrls.length > 0) {
                        let files = []
                        files.push(...fileDialog.fileUrls)
                        root.store.setFileListItems(files)
                    }
                }
            }
        },

        ColumnLayout {

          id: categoriesAndChannelsView

          readonly property bool canGoNext: root.store.discordChannelsModel.hasSelectedItems
          property var nextAction: function () {
            // TODO: request discord import
          }

          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.store.discordChannelsModel.count == 0
            Loader {
              anchors.centerIn: parent
              active: parent.visible
              sourceComponent: StatusLoadingIndicator {
                width: 50
                height: 50
              }
            }
          }

          ColumnLayout {
              spacing: 12
              visible: root.store.discordChannelsModel.count > 0

              StatusBaseText {
                  Layout.fillWidth: true
                  text: qsTr("Please select the categories and channels to import into your new Status Community.")
                  wrapMode: Text.WordWrap
              }

              StatusCheckBox {
                  id: importAllHistoryCheckbox
                  text: qsTr("Import all history")
                  checked: true
              }

              StatusInput {
                  label: qsTr("Import history from")
                  input.text: new Date(root.store.discordOldestMessageTimestamp * 1000).toString()
                  input.enabled: !importAllHistoryCheckbox.checked
              }

              StatusBaseText {
                  text: qsTr("Selected categories and channels")
                  font.pixelSize: 15
                  font.weight: Font.Medium
                  color: Theme.palette.baseColor1
              }

              Item {
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  Layout.alignment: Qt.AlignHCenter

                  Flickable {
                      clip: true
                      anchors.fill: parent
                      contentHeight: selectCategoriesView.height
                      implicitHeight: selectCategoriesView.implicitHeight
                      interactive: contentHeight > height
                      flickableDirection: Flickable.VerticalFlick

                      ColumnLayout {
                          id: selectCategoriesView
                          spacing: 12
                          width: parent.width

                          Repeater {
                              model: root.store.discordCategoriesModel
                              delegate: ColumnLayout {
                                  spacing: 8
                                  Layout.fillWidth: true

                                  StatusCheckBox {
                                      property string categoryId: model.id
                                      id: categoryCheckbox
                                      checked: model.selected
                                      text: model.name
                                      onToggled: {
                                          model.selected = checked
                                      }
                                  }

                                  ColumnLayout {
                                      id: channels
                                      spacing: 8
                                      Layout.leftMargin: 24
                                      Repeater {
                                          model: root.store.discordChannelsModel
                                          delegate: StatusCheckBox {
                                              Layout.fillWidth: true
                                              text: model.name
                                              checked: model.selected
                                              visible: model.categoryId === categoryCheckbox.categoryId
                                              onClicked: {
                                                  if (checked) {
                                                      root.store.selectDiscordChannel(model.id)
                                                  } else {
                                                      root.store.unselectDiscordChannel(model.id)
                                                  }
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
    ]

    QtObject {
        id: d

        function createCommunity() {
            const error = store.createCommunity({
                    name: Utils.filterXSS(nameInput.input.text),
                    description: Utils.filterXSS(descriptionTextInput.input.text),
                    introMessage: Utils.filterXSS(introMessageInput.input.text),
                    outroMessage: Utils.filterXSS(outroMessageInput.input.text),
                    color: colorPicker.color.toString().toUpperCase(),
                    tags: communityTagsPicker.selectedTags,
                    image: {
                        src: logoPicker.source,
                        AX: logoPicker.cropRect.x,
                        AY: logoPicker.cropRect.y,
                        BX: logoPicker.cropRect.x + logoPicker.cropRect.width,
                        BY: logoPicker.cropRect.y + logoPicker.cropRect.height,
                    },
                    options: {
                        historyArchiveSupportEnabled: options.archiveSupportEnabled,
                        checkedMembership: options.requestToJoinEnabled ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
                        pinMessagesAllowedForMembers: options.pinMessagesEnabled
                    }
            })
            if (error) {
                errorDialog.text = error.error
                errorDialog.open()
            }
            root.close()
        }
    }

    MessageDialog {
        id: errorDialog

        title: qsTr("Error creating the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
