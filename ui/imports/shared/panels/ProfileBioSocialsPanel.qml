import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1

import "../controls"

import SortFilterProxyModel 0.2

Item {
    id: root

    property string bio
    property string userSocialLinksJson

    onUserSocialLinksJsonChanged: d.buildSocialLinksModel()

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        function textToType(text) {
            if (text === "__twitter") return Constants.socialLinkType.twitter
            if (text === "__personal_site") return Constants.socialLinkType.personalSite
            if (text === "__github") return Constants.socialLinkType.github
            if (text === "__youtube") return Constants.socialLinkType.youtube
            if (text === "__discord") return Constants.socialLinkType.discord
            if (text === "__telegram") return Constants.socialLinkType.telegram
            return Constants.socialLinkType.custom
        }

        // Unfortunately, nim can't expose temporary QObjects thorugh slots
        // The only way to expose static models on demand is through json strings (see getContactDetailsAsJson)
        // Model is built here manually, which I know is completely wrong..
        function buildSocialLinksModel() {
            socialLinksModel.clear()

            if (root.userSocialLinksJson == "") return

            try {
                let links = JSON.parse(root.userSocialLinksJson)
                for (let i=0; i<links.length; i++) {
                    let obj = links[i]
                    socialLinksModel.append({
                                                "text": obj.text,
                                                "url": obj.url,
                                                "linkType": textToType(obj.text)
                                            })
                }
            }
            catch (e) {
                console.warn("can't parse userSocialLinksJson", e)
            }
        }
    }

    ListModel {
        id: socialLinksModel
    }

    SortFilterProxyModel {
        id: sortedSocialLinksModel

        function customsLastPredicate(linkTypeLeft, linkTypeRight) {
            if (linkTypeLeft === Constants.socialLinkType.custom) return false
            if (linkTypeRight === Constants.socialLinkType.custom) return true
            return linkTypeLeft < linkTypeRight
        }

        sourceModel: socialLinksModel
        filters: ExpressionFilter {
            expression: model.text !== "" && model.url !== ""
        }
        sorters: [
            ExpressionSorter {
                expression: sortedSocialLinksModel.customsLastPredicate(modelLeft.linkType, modelRight.linkType)
            },
            StringSorter {
                roleName: "text"
                caseSensitivity: Qt.CaseInsensitive
            }
        ]
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent

        spacing: 20

        StatusBaseText {
            Layout.fillWidth: true
            text: root.bio
            wrapMode: Text.WordWrap
        }

        Flow {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            spacing: 16
            visible: repeater.count > 0

            Repeater {
                id: repeater

                model: sortedSocialLinksModel
                delegate: SocialLinkPreview {
                    text: model.text
                    url: model.url
                    linkType: model.linkType
                }
            }
        }
    }
}
