import QtQuick 2.13

import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.stores 1.0

// WIP: Not used yet. Just preparing it for further refactoring
QtObject {
    id: root

    // Indicates whether the current community module is initialized and available.
    required property bool isModuleReady

    // Whether the user has joined the community
    required property bool joined

    required property bool allChannelsAreHiddenBecauseNotPermitted
    required property int communityMemberReevaluationStatus

    // Validates temporal requirements when a user shares one or more addresses with the community.
    // This applies during both the joining flow and when editing shared addresses later.
    required property bool spectatedPermissionsCheckOngoing

    // Temporary permissions model used in join/edit address flows.
    // Reflects which permissions are met based on currently selected addresses,
    // without affecting the real community state
    required property var spectatedPermissionsModel

    // TODO: Review if the 2 next properties should be inside `PermissionsStore` instead
    // Indicates whether a permission check is currently ongoing at the community level.
    // Used to determine access to community-wide features and channels.
    required property bool communityPermissionsCheckOngoing

    // Indicates whether a permission check is in progress for the currently active chat.
    // Used to validate whether the user can read or post in a specific conversation.
    required property bool chatPermissionsCheckOngoing

    // Private property used to define context properties asignements and other private stuff.
    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var communitiesModuleInst: communitiesModule
        readonly property var localAccountSensitiveSettingsInst: localAccountSensitiveSettings
    }

    signal communityAccessFailed(string communityId)

    signal allSharedAddressesSigned()

    signal communityMembershipNotificationReceived()

    signal acceptRequestToJoinCommunity(string requestId, string communityId)

    signal declineRequestToJoinCommunity(string requestId, string communityId)

    /*function acceptRequestToJoinCommunity(requestId, communityId) {
        root.acceptRequestToJoinCommunity(requestId, communityId)
    }

    function declineRequestToJoinCommunity(requestId, communityId) {
        root.declineRequestToJoinCommunity(requestId, communityId)
    }*/

    // TO REVIEW: Should be on Community PermissionsStore instead?
    function prepareTokenModelForCommunity(publicKey) { //
        d.communitiesModuleInst.prepareTokenModelForCommunity(publicKey)
    }

    // TO REVIEW: Should be on Community PermissionsStore instead?
    function prepareTokenModelForCommunityChat(publicKey, chatId) { //
        d.communitiesModuleInst.prepareTokenModelForCommunityChat(publicKey, chatId)
    }

    function spectateCommunity(id, ensName) {
        return d.communitiesModuleInst.spectateCommunity(id, ensName)
    }

    // TO REVIEW: not sure if it's required for access
    function prepareKeypairsForSigning(communityId, ensName, addressesToShare = [], airdropAddress = "", editMode = false) {
        d.communitiesModuleInst.prepareKeypairsForSigning(communityId, ensName, JSON.stringify(addressesToShare), airdropAddress, editMode)
    }

    // TO REVIEW: not sure if it's required for access
    function signProfileKeypairAndAllNonKeycardKeypairs() {
        d.communitiesModuleInst.signProfileKeypairAndAllNonKeycardKeypairs()
    }

    // TO REVIEW: not sure if it's required for access
    function signSharedAddressesForKeypair(keyUid) {
        d.communitiesModuleInst.signSharedAddressesForKeypair(keyUid)
    }

    function joinCommunityOrEditSharedAddresses() {
        d.communitiesModuleInst.joinCommunityOrEditSharedAddresses()
    }

    function cleanJoinEditCommunityData() {
        d.communitiesModuleInst.cleanJoinEditCommunityData()
    }

    function userCanJoin(id) {
        return d.communitiesModuleInst.userCanJoin(id)
    }

    function isUserMemberOfCommunity(id) {
        return d.communitiesModuleInst.isUserMemberOfCommunity(id)
    }

    function isMyCommunityRequestPending(id) {
        return d.communitiesModuleInst.isMyCommunityRequestPending(id)
    }

    function cancelPendingRequest(id: string) {
        d.communitiesModuleInst.cancelRequestToJoinCommunity(id)
    }

    function updatePermissionsModel(communityId, sharedAddresses) {
        d.communitiesModuleInst.checkPermissions(communityId, JSON.stringify(sharedAddresses))
    }

    readonly property Connections mainModuleInstConnections: Connections {
        target: d.mainModuleInst
        enabled: root.isModuleReady

        // TODO: Review this trigger on the business-logic side since it will not be the
        // one conditioning any UI navigation explicitly (it seems it's related to some OS notifications)
        function onOpenCommunityMembershipRequestsView(sectionId: string) {
            if(root.mySectionId !== sectionId)
                return

            root.communityMembershipNotificationReceived()
        }
    }

    readonly property Connections communitiesModuleConnections: Connections {
        target: d.communitiesModuleInst

        function onCommunityAccessFailed(communityId: string, error: string) {
            root.communityAccessFailed(communityId, error)
        }

        function onAllSharedAddressesSigned() {
            root.allSharedAddressesSigned()
        }
    }
}
