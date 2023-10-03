# Wallet Connect Integration

## WalletConnect SDK management

Install dependencies steps by executing commands in this directory:

- update the [`package.json`](./package.json) versions and run `npm install`
  - alternatively
    - use the command `npm install <package-name>@<version/latest> --save` for individual packages
    - or to update to the latest run `npm update` in here
  - these commands will also create or update a `package-lock.json` file and populate the `node_modules` directory
- update the [`bundle.js`](./dist/main.js) file by running `npm run build`
  - the result will be embedded with the app and loaded by [`WalletConnectSDK.qml`](../WalletConnectSDK.qml) component
- add the newly generated files to index `git add --update .` to include in the commit

## Testing

Use the web demo test client https://react-app.walletconnect.com/ for wallet pairing and https://react-auth-dapp.walletconnect.com/ for authentication

## TODO

- [ ] test namespaces implementation https://se-sdk-dapp.vercel.app/

## Log

Initial setup

```sh
npm init -y
npm install --save-dev webpack webpack-cli webpack-dev-server
npm install --save @walletconnect/web3wallet
npm run build
```

## Dev - to be removed

To test SDK loading add the following to `ui/app/mainui/AppMain.qml`

```qml
import AppLayouts.Wallet.views.walletconnect 1.0

// ...

StatusDialog {
    id: wcHelperDialog
    visible: true

    WalletConnect {
        SplitView.preferredWidth: 400
        SplitView.preferredHeight: 600

        projectId: "<Project ID>"
        backgroundColor: wcHelperDialog.backgroundColor
    }

    clip: true
}
```
