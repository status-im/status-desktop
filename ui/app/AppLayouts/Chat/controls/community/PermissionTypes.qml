pragma Singleton

import QtQml 2.14

import StatusQ.Core.Theme 0.1

QtObject {
    enum Type {
        None, Admin, Member, Read, ViewAndPost
    }

    function getName(type) {
        switch (type) {
            case PermissionTypes.Type.Admin:
                return qsTr("Become admin")
            case PermissionTypes.Type.Member:
                return qsTr("Become member")
            case PermissionTypes.Type.Moderator:
                return qsTr("Moderate")
            case PermissionTypes.Type.ViewAndPost:
                return qsTr("View and post")
            case PermissionTypes.Type.Read:
                return qsTr("View only")
        }

        return ""
    }

    function getIcon(type) {
        switch (type) {
            case PermissionTypes.Type.Admin:
                return "admin"
            case PermissionTypes.Type.Member:
                return "in-contacts"
            case PermissionTypes.Type.Moderator:
                return "arbitrator"
            case PermissionTypes.Type.ViewAndPost:
                return "edit"
            case PermissionTypes.Type.Read:
                return "show"
        }

        return ""
    }

    function getDescription(type) {
        switch (type) {
            case PermissionTypes.Type.Admin:
                const generalInfo = qsTr("Members who meet the requirements will be allowed to create and edit permissions, token sales, airdrops and subscriptions")
                const warning = qsTr("Be careful with assigning this permission.")
                const warningExplanation = qsTr("Only the community owner can modify admin permissions")

                const warningStyled = `<font color="${Theme.palette.dangerColor1}">${warning}</font>`
                return `${generalInfo}<br><br>${warningStyled} ${warningExplanation}`
            case PermissionTypes.Type.Member:
                return qsTr("Anyone who meets the requirements will be allowed to join your community")
            case PermissionTypes.Type.Moderator:
                return qsTr("Members who meet the requirements will be allowed to read, write, ban members and pin messages in the selected channels")
            case PermissionTypes.Type.ViewAndPost:
                return qsTr("Members who meet the requirements will be allowed to read and write in the selected channels")
            case PermissionTypes.Type.Read:
                return qsTr("Members who meet the requirements will be allowed to read the selected channels")
        }

        return ""
    }

    function isCommunityPermission(permissionType) {
        return permissionType === PermissionTypes.Type.Admin
                || permissionType === PermissionTypes.Type.Member
    }

    function getPermissionsCountLimit(permissionType) {
        if (permissionType === PermissionTypes.Type.Member)
            return 5

        return -1
    }

    function getPermissionsLimitWarning(permissionType) {
        if (permissionType !== PermissionTypes.Type.Member)
            return ""

        return qsTr("Max of 5 ‘become member’ permissions for this Community has been reached. You will need to delete an existing ‘become member’ permission before you can add a new one.")
    }
}
