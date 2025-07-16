import QtQuick 2.13

import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.stores 1.0

// WIP: Not used yet. Just preparing it for further refactoring
QtObject {
    id: root

    required property bool isModuleReady
    required property bool allChannelsAreHiddenBecauseNotPermitted
    required property int communityMemberReevaluationStatus
    required property bool requirementsCheckPending
    required property var permissionsModel
    required property bool permissionsCheckOngoing

    // TODO: Review if `mainModuleInst.activeSection` is indeed the same as `sectionDetails` here. If yes, this is redundant
    readonly property bool joined: d.mainModuleInst.activeSection.joined
    readonly property bool ensCommunityPermissionsEnabled: localAccountSensitiveSettingsInst.ensCommunityPermissionsEnabled

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var communitiesModuleInst: communitiesModule
        readonly property var localAccountSensitiveSettingsInst: localAccountSensitiveSettings
    }

    // TODO: Switch handler in `Popups.qml`
    signal communityAccessRequested(string communityId)

    // TODO: Switch handler in `Popups.qml`
    signal communityAccessFailed(string communityId)

    // TODO: Rename it since store should not know about UI flows or navigations
    signal goToMembershipRequestsPage()

    signal acceptRequestToJoinCommunity(string requestId, string communityId)

    signal declineRequestToJoinCommunity(string requestId, string communityId)

    /*function acceptRequestToJoinCommunity(requestId, communityId) {
        root.acceptRequestToJoinCommunity(requestId, communityId)
    }

    function declineRequestToJoinCommunity(requestId, communityId) {
        root.declineRequestToJoinCommunity(requestId, communityId)
    }*/

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
        function onOpenCommunityMembershipRequestsView(sectionId: string) {
            if(root.mySectionId !== sectionId)
                return

            root.goToMembershipRequestsPage()
        }
    }

    readonly property Connections communitiesModuleConnections: Connections {
      target: d.communitiesModuleInst

      function onCommunityAccessRequested(communityId: string) {
          root.communityAccessRequested(communityId)
      }

      function onCommunityAccessFailed(communityId: string, error: string) {
          root.communityAccessFailed(communityId, error)
      }
    }
}
