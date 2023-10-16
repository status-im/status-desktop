import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQml.Models 2.15

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

StatusStackModal {
    id: root

    property var communitiesStore

    property bool isDiscordImport // creating new or importing from discord?
    property bool isEdit: false
    property bool isDeleteable: false

    property string communityId: ""
    property string chatId: ""
    property string categoryId: ""
    property string channelName: ""
    property string channelDescription: ""
    property string channelEmoji: ""
    property string channelColor: ""
    property bool emojiPopupOpened: false
    property var emojiPopup: null
    readonly property int communityColorValidator: Utils.Validate.NoEmpty
                                                   | Utils.Validate.TextHexColor

    readonly property int maxChannelNameLength: 24
    readonly property int maxChannelDescLength: 140

    signal createCommunityChannel(string chName, string chDescription, string chEmoji, string chColor, string chCategoryId)
    signal editCommunityChannel(string chName, string chDescription, string chEmoji, string chColor, string chCategoryId)
    signal deleteCommunityChannel()

    width: 640

    QtObject {
        id: d
        function isFormValid() {
            return nameInput.valid && descriptionTextArea.valid &&
                    Utils.validateAndReturnError(colorDialog.color.toString().toUpperCase(), communityColorValidator) === ""
        }

        function openEmojiPopup(leftSide = false) {
            root.emojiPopupOpened = true;
            root.emojiPopup.open();
            root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
            root.emojiPopup.x = leftSide ? root.x + Style.current.padding : (root.x + (root.width - root.emojiPopup.width - Style.current.padding));
            root.emojiPopup.y = root.y + root.header.height + root.topPadding + nameInput.height + Style.current.smallPadding;
        }

        function _getChannelConfig() {
            return {
                communityId: root.communityId,
                discordChannelId: root.communitiesStore.discordImportChannelId,
                categoryId: root.categoryId,
                name: StatusQUtils.Utils.filterXSS(nameInput.input.text),
                description: StatusQUtils.Utils.filterXSS(descriptionTextArea.text),
                color: colorDialog.color.toString().toUpperCase(),
                emoji: StatusQUtils.Emoji.deparse(nameInput.input.asset.emoji),
                options: {
                    // TODO
                }
            }
        }

        function requestImportDiscordChannel() {
            const error = root.communitiesStore.requestImportDiscordChannel(_getChannelConfig(), datePicker.selectedDate.valueOf()/1000)
            if (error) {
                creatingError.text = error.error
                creatingError.open()
            }
        }
    }

    stackTitle: isDiscordImport ? qsTr("New Channel With Imported Chat History") :
                                  isEdit ? qsTr("Edit #%1").arg(root.channelName)
                                         : qsTr("New channel")

    nextButton: StatusButton {
        objectName: "createChannelNextBtn"
        font.weight: Font.Medium
        text: typeof currentItem.nextButtonText !== "undefined" ? currentItem.nextButtonText : qsTr("Import chat history")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        loading: root.communitiesStore.discordDataExtractionInProgress
        onClicked: {
            const nextAction = currentItem.nextAction
            if (typeof(nextAction) == "function") {
                return nextAction()
            }
            root.currentIndex++
        }
    }

    finishButton: StatusButton {
        objectName: "createOrEditCommunityChannelBtn"
        font.weight: Font.Medium
        text: isDiscordImport ? qsTr("Import chat history") : isEdit ? qsTr("Save changes") : qsTr("Create channel")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof (nextAction) == "function") {
                return nextAction()
            }
            if (!root.isDiscordImport) {
                if (!d.isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }
                let emoji = StatusQUtils.Emoji.deparse(nameInput.input.asset.emoji)

                if (!isEdit) {
                    root.createCommunityChannel(StatusQUtils.Utils.filterXSS(nameInput.input.text),
                                                StatusQUtils.Utils.filterXSS(descriptionTextArea.text),
                                                emoji,
                                                colorDialog.color.toString().toUpperCase(),
                                                root.categoryId)
                } else {
                    root.editCommunityChannel(StatusQUtils.Utils.filterXSS(nameInput.input.text),
                                              StatusQUtils.Utils.filterXSS(descriptionTextArea.text),
                                              emoji,
                                              colorDialog.color.toString().toUpperCase(),
                                              root.categoryId)
                }
                // TODO Open the channel once we have designs for it
                root.close()
            }
        }
    }

    readonly property StatusButton clearFilesButton: StatusButton {
        font.weight: Font.Medium
        text: qsTr("Clear all")
        type: StatusBaseButton.Type.Danger
        visible: typeof currentItem.isFileListView !== "undefined" && currentItem.isFileListView
        enabled: !fileListView.fileListModelEmpty && !root.communitiesStore.discordDataExtractionInProgress
        onClicked: root.communitiesStore.clearFileList()
    }

    readonly property StatusButton deleteChannelButton: StatusButton {
        objectName: "deleteCommunityChannelBtn"
        visible: isEdit && isDeleteable && !isDiscordImport && typeof(replaceItem) === "undefined"
        text: qsTr("Delete channel")
        type: StatusBaseButton.Type.Danger
        onClicked: root.deleteCommunityChannel()
    }

    rightButtons: [clearFilesButton, deleteChannelButton, nextButton, finishButton]

    onAboutToShow: {
        if (root.isDiscordImport) {
            if (!root.communitiesStore.discordImportInProgress) {
                root.communitiesStore.clearFileList()
                root.communitiesStore.clearDiscordCategoriesAndChannels()
            }
            for (let i = 0; i < discordPages.length; i++) {
                stackItems.push(discordPages[i])
            }
        }

        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
        if (isEdit) {
            nameInput.text = root.channelName
            descriptionTextArea.text = root.channelDescription
            if (root.channelEmoji) {
                nameInput.input.asset.emoji = root.channelEmoji
            }
            colorDialog.color = root.channelColor
        } else {
            nameInput.input.asset.isLetterIdenticon = true;
        }

        updateRightButtons()
    }

    readonly property list<Item> discordPages: [
        ColumnLayout {
            id: fileListView
            spacing: 24

            readonly property bool isFileListView: true

            readonly property var fileListModel: root.communitiesStore.discordFileList
            readonly property bool fileListModelEmpty: !fileListModel.count

            readonly property bool canGoNext: fileListModel.selectedCount
                                              || (fileListModel.selectedCount && fileListModel.selectedFilesValid)
            readonly property string nextButtonText: fileListModel.selectedCount && fileListModel.selectedFilesValid ?
                                                         qsTr("Proceed with (%1/%2) files").arg(fileListModel.selectedCount).arg(fileListModel.count) :
                                                         fileListModel.selectedCount && fileListModel.selectedCount === fileListModel.count ? qsTr("Validate %n file(s)", "", fileListModel.selectedCount)
                                                                                                                                            : fileListModel.selectedCount ? qsTr("Validate (%1/%2) files").arg(fileListModel.selectedCount).arg(fileListModel.count)
                                                                                                                                                                          : qsTr("Start channel import")
            readonly property var nextAction: function () {
                if (!fileListView.fileListModel.selectedFilesValid)
                    return root.communitiesStore.requestExtractChannelsAndCategories()

                root.currentIndex++
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                StatusBaseText {
                    Layout.fillWidth: true
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    text: fileListView.fileListModelEmpty ? qsTr("Select Discord channel JSON files to import") :
                                                            root.communitiesStore.discordImportErrorsCount ? qsTr("Some of your community files cannot be used") :
                                                                                                             qsTr("Uncheck any files you would like to exclude from the import")
                }
                StatusBaseText {
                    visible: fileListView.fileListModelEmpty && !issuePill.visible
                    font.pixelSize: 12
                    color: Theme.palette.baseColor1
                    text: qsTr("(JSON file format only)")
                }
                IssuePill {
                    id: issuePill
                    type: root.communitiesStore.discordImportErrorsCount ? IssuePill.Type.Error : IssuePill.Type.Warning
                    count: root.communitiesStore.discordImportErrorsCount || root.communitiesStore.discordImportWarningsCount || 0
                    visible: !!count && !fileListView.fileListModelEmpty
                }
                StatusButton {
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("Browse files")
                    type: StatusBaseButton.Type.Primary
                    onClicked: fileDialog.open()
                    enabled: !root.communitiesStore.discordDataExtractionInProgress
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
                        asset.name: "info"
                    }
                    StatusBaseText {
                        Layout.topMargin: 8
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: qsTr("Export the Discord channel’s chat history data using %1").arg("<a href='https://github.com/Tyrrrz/DiscordChatExporter/releases/tag/2.40.4'>DiscordChatExporter</a>")
                        onLinkActivated: Global.openLink(link)
                        HoverHandler {
                            id: handler1
                        }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: handler1.hovered && parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    StatusBaseText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: qsTr("Refer to this <a href='https://github.com/Tyrrrz/DiscordChatExporter/blob/master/.docs/Readme.md'>documentation</a> if you have any queries")
                        onLinkActivated: Global.openLink(link)
                        HoverHandler {
                            id: handler2
                        }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: handler2.hovered && parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }

                Component {
                    id: floatingDivComp
                    Rectangle {
                        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                        width: ListView.view ? ListView.view.width : 0
                        height: 4
                        color: Theme.palette.directColor8
                    }
                }

                StatusListView {
                    visible: !fileListView.fileListModelEmpty
                    enabled: !root.communitiesStore.discordDataExtractionInProgress
                    anchors.fill: parent
                    leftMargin: 8
                    rightMargin: 8
                    model: fileListView.fileListModel
                    header: !atYBeginning ? floatingDivComp : null
                    headerPositioning: ListView.OverlayHeader
                    footer: !atYEnd ? floatingDivComp : null
                    footerPositioning: ListView.OverlayHeader
                    delegate: ColumnLayout {
                        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                        RowLayout {
                            spacing: 20
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            StatusBaseText {
                                Layout.fillWidth: true
                                text: model.filePath
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }

                            StatusFlatRoundButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                type: StatusFlatRoundButton.Type.Secondary
                                icon.name: "close"
                                icon.color: Theme.palette.directColor1
                                icon.width: 24
                                icon.height: 24
                                onClicked: root.communitiesStore.removeFileListItem(model.filePath)
                            }
                        }

                        StatusBaseText {
                            Layout.fillWidth: true
                            text: "%1 %2".arg("⚠").arg(model.errorMessage)
                            visible: model.errorMessage
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            elide: Text.ElideMiddle
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
                nameFilters: [qsTr("JSON files (%1)").arg("*.json *.JSON")]
                onAccepted: {
                    if (fileDialog.fileUrls.length > 0) {
                        const files = []
                        for (let i = 0; i < fileDialog.fileUrls.length; i++)
                            files.push(decodeURI(fileDialog.fileUrls[i].toString()))
                        root.communitiesStore.setFileListItems(files)
                    }
                }
            }
        },

        ColumnLayout {
            id: categoriesAndChannelsView
            spacing: 24

            readonly property bool canGoNext: root.communitiesStore.discordChannelsModel.hasSelectedItems
            readonly property var nextAction: function () {
                d.requestImportDiscordChannel()
                // replace ourselves with the progress dialog, no way back
                root.leftButtons[0].visible = false
                root.backgroundColor = Theme.palette.baseColor4
                root.replace(progressComponent)
            }

            Component {
                id: progressComponent
                DiscordImportProgressContents {
                    width: root.availableWidth
                    store: root.communitiesStore
                    importingSingleChannel: true
                    onClose: root.close()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.communitiesStore.discordChannelsModel.count
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
                visible: root.communitiesStore.discordChannelsModel.count

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Select the chat history you would like to import into #%1...").arg(StatusQUtils.Utils.filterXSS(nameInput.input.text))
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true
                    StatusRadioButton {
                        text: qsTr("Import all history")
                        checked: true
                    }
                    StatusRadioButton {
                        id: startDateRadio
                        text: qsTr("Start date")
                    }
                    StatusDatePicker {
                        id: datePicker
                        Layout.fillWidth: true
                        selectedDate: new Date(root.communitiesStore.discordOldestMessageTimestamp * 1000)
                        enabled: startDateRadio.checked
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.palette.baseColor4

                    StatusListView {
                        anchors.fill: parent
                        anchors.margins: 16
                        model: root.communitiesStore.discordCategoriesModel
                        delegate: ColumnLayout {
                            width: ListView.view.width
                            spacing: 8

                            StatusBaseText {
                                readonly property string categoryId: model.id
                                id: categoryCheckbox
                                text: model.name
                            }

                            ColumnLayout {
                                spacing: 8
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Repeater {
                                    Layout.fillWidth: true
                                    model: root.communitiesStore.discordChannelsModel
                                    delegate: StatusRadioButton {
                                        width: parent.width
                                        text: model.name
                                        checked: model.selected
                                        visible: model.categoryId === categoryCheckbox.categoryId
                                        onToggled: root.communitiesStore.toggleOneDiscordChannel(model.id)
                                        Component.onCompleted: {
                                            if (model.selected) {
                                                root.communitiesStore.toggleOneDiscordChannel(model.id)
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

    Connections {
        enabled: root.opened && root.emojiPopupOpened
        target: emojiPopup

        function onEmojiSelected(emojiText: string, atCursor: bool) {
            nameInput.input.asset.isLetterIdenticon = false;
            nameInput.input.asset.emoji = emojiText
        }
        function onClosed() {
            root.emojiPopupOpened = false
        }
    }

    stackItems: [
        StatusScrollView {
            id: scrollView

            readonly property bool canGoNext: d.isFormValid()

            property ScrollBar vScrollBar: ScrollBar.vertical

            contentWidth: availableWidth
            padding: 0

            function scrollBackUp() {
                vScrollBar.setPosition(0)
            }

            ColumnLayout {
                id: content

                width: scrollView.availableWidth
                spacing: 0

                StatusInput {
                    id: nameInput
                    Layout.fillWidth: true
                    input.edit.objectName: "createOrEditCommunityChannelNameInput"
                    label: qsTr("Channel name")
                    charLimit: root.maxChannelNameLength
                    placeholderText: qsTr("# Name the channel")

                    input.onTextChanged: {
                        const cursorPosition = input.cursorPosition
                        input.text = Utils.convertSpacesToDashes(input.text)
                        input.cursorPosition = cursorPosition
                        if (root.channelEmoji === "") {
                            input.letterIconName = text
                        }
                    }
                    input.asset.color: colorDialog.color.toString()
                    input.rightComponent: StatusRoundButton {
                        objectName: "StatusChannelPopup_emojiButton"
                        implicitWidth: 32
                        implicitHeight: 32
                        icon.width: 20
                        icon.height: 20
                        icon.name: "smiley"
                        onClicked: d.openEmojiPopup()
                    }
                    onIconClicked: {
                        d.openEmojiPopup(true);
                    }

                    validators: [
                        StatusMinLengthValidator {
                            minLength: 1
                            errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("channel name"))
                        },
                        StatusRegularExpressionValidator {
                            regularExpression: Constants.regularExpressions.alphanumericalExpanded
                            errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
                        }
                    ]
                }

                Item {
                    Layout.preferredHeight: 16
                    Layout.fillWidth: true
                }

                ColorPicker {
                    id: colorDialog
                    Layout.fillWidth: true
                    title: qsTr("Channel colour")
                    color: root.isEdit && root.channelColor ? root.channelColor : Theme.palette.primaryColor1
                    onPick: root.replace(colorPanel)

                    Component {
                        id: colorPanel
                        ColorPanel {
                            title: qsTr("Channel colour")
                            buttonText: qsTr("Select Colour")
                            Component.onCompleted: color = colorDialog.color
                            onAccepted: {
                                colorDialog.color = color
                                root.replaceItem = undefined
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: 16
                    Layout.fillWidth: true
                }

                StatusInput {
                    id: descriptionTextArea
                    Layout.fillWidth: true
                    input.edit.objectName: "createOrEditCommunityChannelDescriptionInput"
                    input.verticalAlignment: TextEdit.AlignTop
                    label: qsTr("Description")
                    charLimit: 140

                    placeholderText: qsTr("Describe the channel")
                    input.multiline: true
                    minimumHeight: 88
                    maximumHeight: 88
                    validators: [
                        StatusMinLengthValidator {
                            minLength: 1
                            errorMessage: Utils.getErrorMessage(descriptionTextArea.errors, qsTr("channel description"))
                        },
                        StatusRegularExpressionValidator {
                            regularExpression: Constants.regularExpressions.alphanumericalExpanded
                            errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
                        }
                    ]
                }
            }
        }
    ]

    MessageDialog {
        id: creatingError
        title: qsTr("Error creating the channel")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
