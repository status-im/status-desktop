import QtQuick

import StatusQ
import StatusQ.Core.Utils
import utils

import QtModelsToolkit
import SortFilterProxyModel

/**
  * Adaptor concatenating model of contacts with own profile details into single
    model in order to use it as a complete source of profile info, with no
    distinction between own and contat's profiles.
  */
QObject {
    id: root

    /* Model with details (not including self) */
    property alias contactsModel: mainSource.model

    /* Self-profile details */
    property string selfPubKey
    property string selfDisplayName
    property string selfName
    property string selfPreferredDisplayName
    property string selfAlias
    property bool selfUsesDefaultName
    property string selfIcon
    property int selfColorId
    property var selfColorHash
    property int selfOnlineStatus
    property string selfThumbnailImage
    property string selfLargeImage
    property string selfBio

    readonly property ConcatModel allContactsModel: ConcatModel {
        id: concatModel

        function hasUser(pubKey) {
            return  pubKey === root.selfPubKey || contactsModel.hasUser(pubKey)
        }

        expectedRoles: [
            "pubKey", "displayName", "ensName", "isEnsVerified", "localNickname", "usesDefaultName",
            "alias", "icon", "colorId", "colorHash", "onlineStatus",
            "isContact", "isCurrentUser", "isVerified", "isUntrustworthy",
            "isBlocked", "contactRequestState", "preferredDisplayName",
            "lastUpdated", "lastUpdatedLocally", "thumbnailImage", "largeImage",
            "isContactRequestReceived", "isContactRequestSent", "removed",
            "trustStatus", "bio"
        ]

        markerRoleName: ""

        sources: [
            SourceModel {
                model: ObjectProxyModel {
                    sourceModel: ListModel {
                        ListElement {
                            _: "" // empty role to prevent warning
                        }
                    }

                    delegate: QtObject {
                        readonly property string pubKey: root.selfPubKey
                        readonly property string displayName: root.selfDisplayName
                        readonly property string ensName: root.selfName
                        readonly property bool isEnsVerified: root.selfName !== ""
                                                              && Utils.isValidEns(root.selfName)
                        readonly property string localNickname: ""
                        readonly property string preferredDisplayName: root.selfPreferredDisplayName
                        readonly property string name: preferredDisplayName
                        readonly property string alias: root.selfAlias
                        readonly property bool usesDefaultName: root.selfUsesDefaultName
                        readonly property string icon: root.selfIcon
                        readonly property int colorId: root.selfColorId
                        readonly property var colorHash: root.selfColorHash
                        readonly property int onlineStatus: root.selfOnlineStatus
                        readonly property bool isContact: false
                        readonly property bool isCurrentUser: true
                        readonly property bool isVerified: false
                        readonly property bool isUntrustworthy: false
                        readonly property bool isBlocked: false
                        readonly property int contactRequestState: Constants.ContactRequestState.None
                        readonly property int lastUpdated: 0
                        readonly property int lastUpdatedLocally: 0
                        readonly property string thumbnailImage: root.selfThumbnailImage
                        readonly property string largeImage: root.selfLargeImage
                        readonly property bool isContactRequestReceived: Constants.ContactRequestState.None
                        readonly property bool isContactRequestSent: Constants.ContactRequestState.None
                        readonly property bool removed: false
                        readonly property int trustStatus: Constants.trustStatus.unknown
                        readonly property string bio: root.selfBio
                    }

                    exposedRoles: concatModel.expectedRoles
                }
            },
            SourceModel {
                id: mainSource
            }
        ]
    }
}
