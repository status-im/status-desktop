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
        font.weight: Font.Medium
        text: typeof currentItem.nextButtonText !== "undefined" ? currentItem.nextButtonText : qsTr("Next")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        loading: root.store.discordDataExtractionInProgress
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
        font.weight: Font.Medium
        text: finishButtonLabel
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof (nextAction) == "function") {
                return nextAction()
            }
            root.close()
        }
    }

    readonly property var clearFilesButton: StatusButton {
        font.weight: Font.Medium
        text: qsTr("Clear all")
        type: StatusBaseButton.Type.Danger
        visible: root.currentItem.objectName === "discordFileListView" // no better way to address the current item in the stack :/
        enabled: !fileListView.fileListModelEmpty && !root.store.discordDataExtractionInProgress
        onClicked: root.store.clearFileList()
    }

    rightButtons: [clearFilesButton, nextButton, finishButton]

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
            id: fileListView
            objectName: "discordFileListView" // !!! DON'T CHANGE, clearFilesButton depends on this
            spacing: 24
            readonly property var fileListModel: root.store.discordFileList
            readonly property bool fileListModelEmpty: !fileListModel.count

            readonly property bool canGoNext: fileListModel.selectedCount
                                              || (fileListModel.selectedCount && fileListModel.selectedFilesValid)
            readonly property string nextButtonText:  // TODO plural
                fileListModel.selectedCount && fileListModel.selectedFilesValid ? qsTr("Proceed with (%1/%2) files").arg(fileListModel.selectedCount).arg(fileListModel.count) :
                fileListModel.selectedCount ? qsTr("Validate (%1/%2) files").arg(fileListModel.selectedCount).arg(fileListModel.count)
                : qsTr("Import files")
            readonly property var nextAction: function () {
                if (!fileListView.fileListModel.selectedFilesValid) {
                  return root.store.requestExtractChannelsAndCategories()
                }
                root.currentIndex++
            }

            RowLayout {
                Layout.fillWidth: true
                StatusBaseText {
                    font.pixelSize: 15
                    text: fileListView.fileListModelEmpty ? qsTr("Select Discord JSON files to import") :
                                                            qsTr("Uncheck any files you would like to exclude from the import")
                }
                StatusBaseText {
                    visible: fileListView.fileListModelEmpty
                    font.pixelSize: 12
                    color: Theme.palette.baseColor1
                    text: qsTr("(JSON file format only)")
                }
                Item { Layout.fillWidth: true }
                StatusButton {
                    text: qsTr("Browse files")
                    normalColor: Theme.palette.primaryColor1
                    hoverColor: Qt.lighter(normalColor) // FIXME not in spec?
                    textColor: Theme.palette.white
                    onClicked: fileDialog.open()
                    enabled: !root.store.discordDataExtractionInProgress
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.palette.baseColor4

                ColumnLayout {
                    visible: fileListView.fileListModelEmpty
                    anchors.top: parent.top
                    anchors.topMargin: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    StatusRoundIcon {
                        Layout.alignment: Qt.AlignHCenter
                        icon.name: "info"
                    }
                    StatusBaseText {
                        Layout.topMargin: 8
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        linkColor: Theme.palette.primaryColor1
                        text: qsTr("Export your Discord JSON data using %1")
                          .arg("<a href='https://github.com/Tyrrrz/DiscordChatExporter'>DiscordChatExporter</a>")
                        onLinkActivated: Global.openLink(link)
                    }
                    StatusBaseText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        linkColor: Theme.palette.primaryColor1
                        text: qsTr("Refer to this <a href='https://github.com/Tyrrrz/DiscordChatExporter/wiki'>wiki</a> if you have any queries")
                        onLinkActivated: Global.openLink(link)
                    }
                }

                StatusListView {
                    visible: !fileListView.fileListModelEmpty
                    anchors.fill: parent
                    anchors.margins: 16
                    model: fileListView.fileListModel
                    delegate: ColumnLayout {
                        width: ListView.view.width
                        StatusCheckBox {
                            id: fileCheckBox
                            Layout.fillWidth: true
                            text: model.filePath
                            font.pixelSize: 13
                            checked: model.selected
                            enabled: model.errorMessage === "" // TODO distinguish between error/warning
                            onToggled: model.selected = checked
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.leftMargin: fileCheckBox.leftPadding + fileCheckBox.spacing + fileCheckBox.indicator.width
                            text: model.errorMessage
                            visible: text
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Theme.palette.dangerColor1
                            verticalAlignment: Qt.AlignTop
                        }
                    }
                }
            }

            FileDialog {
                id: fileDialog

                title: qsTr("Choose files to import")
                selectMultiple: true
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
            readonly property var nextAction: function () {
                // TODO: request discord import
            }

          Item {
              Layout.fillWidth: true
              Layout.fillHeight: true
              visible: !root.store.discordChannelsModel.count
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
              visible: root.store.discordChannelsModel.count

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
                                      readonly property string categoryId: model.id
                                      id: categoryCheckbox
                                      checked: model.selected
                                      text: model.name
                                      onToggled: model.selected = checked
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
