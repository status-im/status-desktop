import QtQuick

StatusPalette {
    baseColor3: StatusColors.grey3

    appBackgroundColor: "white"

    primaryColor1: StatusColors.blue
    primaryColor2: Utils.addAlphaTo(StatusColors.blue, 0.2)
    primaryColor3: Utils.addAlphaTo(StatusColors.blue, 0.1)

    dangerColor1: StatusColors.red
    dangerColor2: Utils.addAlphaTo(StatusColors.red, 0.2)
    dangerColor3: Utils.addAlphaTo(StatusColors.red, 0.1)

    successColor1: StatusColors.green
    successColor2: Utils.addAlphaTo(StatusColors.green, 0.1)

    mentionColor1: StatusColors.turquoise
    mentionColor2: Utils.addAlphaTo(StatusColors.turquoise2, 0.3)
    mentionColor3: Utils.addAlphaTo(StatusColors.turquoise2, 0.2)
    mentionColor4: Utils.addAlphaTo(StatusColors.turquoise2, 0.1)

    pinColor1: StatusColors.orange
    pinColor2: Utils.addAlphaTo(StatusColors.orange2, 0.2)
    pinColor3: Utils.addAlphaTo(StatusColors.orange2, 0.1)
}
