import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Profile.controls 1.0

StatusDialog {
    id: root

    property var containsSocialLink: function (text, url) {return false}
    property int linkType: -1
    property string icon

    property int index
    property string linkText
    property string linkUrl

    signal updateLinkRequested(string index, string linkText, string linkUrl)
    signal removeLinkRequested(string index)

    implicitWidth: 480 // design

    title: ProfileUtils.linkTypeToText(linkType) ? qsTr("Edit %1 link").arg(ProfileUtils.linkTypeToText(linkType)) : qsTr("Edit custom Link")

    footer: StatusDialogFooter {
        leftButtons: ObjectModel {
            StatusButton {
                type: StatusButton.Danger
                text: qsTr("Delete")
                onClicked: {
                    root.removeLinkRequested(root.index)
                    root.close()
                }
            }
        }
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Update")
                enabled: linkTarget.valid && (!customTitle.visible || customTitle.valid)
                onClicked: {
                    root.updateLinkRequested(root.index, customTitle.text, ProfileUtils.addSocialLinkPrefix(linkTarget.text, root.linkType))
                    root.close()
                }
            }
        }
    }

    onAboutToShow: {
        if (linkType === Constants.socialLinkType.custom)
            customTitle.input.edit.forceActiveFocus()
        else
            linkTarget.input.edit.forceActiveFocus()
    }

    onClosed: destroy()

    contentItem: ColumnLayout {
        width: root.availableWidth
        spacing: Style.current.halfPadding

        StaticSocialLinkInput {
            id: customTitle
            Layout.fillWidth: true
            visible: root.linkType === Constants.socialLinkType.custom
            placeholderText: ""
            label: qsTr("Change title")
            linkType: Constants.socialLinkType.custom
            icon: "language"
            text: root.linkText
            charLimit: Constants.maxSocialLinkTextLength
            input.tabNavItem: linkTarget.input.edit

            validators: [
                StatusValidator {
                    name: "text-validation"
                    validate: (value) => {
                                  return value.trim() !== ""
                              }
                    errorMessage: qsTr("Invalid title")
                },
                StatusValidator {
                    name: "check-social-link-existence"
                    validate: (value) => {
                                  return !root.containsSocialLink(value,
                                                                  ProfileUtils.addSocialLinkPrefix(linkTarget.text, root.linkType))
                              }
                    errorMessage: root.linkType === Constants.socialLinkType.custom ?
                                      qsTr("Title and link combination already added") :
                                      qsTr("Username already added")
                }
            ]

            onValidChanged: {linkTarget.validate(true)}
            onTextChanged: {linkTarget.validate(true)}
        }

        StaticSocialLinkInput {
            id: linkTarget
            Layout.fillWidth: true
            Layout.topMargin: customTitle.visible ? Style.current.padding : 0
            placeholderText: ""
            label: ProfileUtils.linkTypeToDescription(linkType) || qsTr("Edit your link")
            linkType: root.linkType
            icon: root.icon
            text: root.linkUrl
            input.tabNavItem: customTitle.input.edit

            validators: [
                StatusValidator {
                    name: "link-validation"
                    validate: (value) => {
                                  return value.trim() !== "" && Utils.validLink(ProfileUtils.addSocialLinkPrefix(value, root.linkType))
                              }
                    errorMessage: qsTr("Invalid %1").arg(ProfileUtils.linkTypeToDescription(linkTarget.linkType).toLowerCase() || qsTr("link"))
                },
                StatusValidator {
                    name: "check-social-link-existence"
                    validate: (value) => {
                                  return !root.containsSocialLink(customTitle.text,
                                                                  ProfileUtils.addSocialLinkPrefix(value, root.linkType))
                              }
                    errorMessage: root.linkType === Constants.socialLinkType.custom?
                                      qsTr("Title and link combination already added") :
                                      qsTr("Username already added")
                }
            ]

            onValidChanged: {customTitle.validate(true)}
            onTextChanged: {customTitle.validate(true)}
        }
    }
}
