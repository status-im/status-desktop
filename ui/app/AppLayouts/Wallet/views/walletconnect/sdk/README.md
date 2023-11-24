# Wallet Connect Integration

## TODO

- [ ] test namespaces implementation https://se-sdk-dapp.vercel.app/

### Design questions

- [ ] Do we report **disabled chains**? **Update session** in case of enabled/disabled chains?
- [ ] User error workflow: retry?
- [ ] Check the `Auth` request for verifyContext <https://docs.walletconnect.com/web3wallet/verify>
- [ ] What `description` and `icons` to use for the app? See `metadata` parameter in `Web3Wallet.init` call

## WalletConnect SDK management

Install dependencies steps by executing commands in this directory:

- update the [`package.json`](./package.json) versions and run `npm install`
  - alternatively
    - use the command `npm install <package-name>@<version/latest> --save` for individual packages
    - or to update to the latest run `ncu -u; npm install` in here
      - run `npm install -g npm-check-updates` for `ncu` command
  - these commands will also create or update a `package-lock.json` file and populate the `node_modules` directory
- update the [`bundle.js`](./dist/main.js) file by running `npm run build`
  - the result will be embedded with the app and loaded by [`WalletConnectSDK.qml`](../WalletConnectSDK.qml) component
- add the newly generated files to index `git add --update .` to include in the commit

## Testing

Use the web demo test client https://react-app.walletconnect.com/ for wallet pairing and https://react-auth-dapp.walletconnect.com/ for authentication

## Log

Initial setup

```sh
npm init -y
npm install --save-dev webpack webpack-cli webpack-dev-server
npm install --save @walletconnect/web3wallet
npm run build
# npm run build:dev # for development
```

- [x] Do we report all chains and all accounts combination or let user select?
  - Wallet Connect require to report all chainIDs that were requested
  - Answer: We only report the available chains for the current account. We will look into adding others to he same session instead of requiring a new link
- [x] Can't respond to sign messages if the wallet-connect dialog/view is closed (app is minimized)
  - Only apps that use deep links are expected to work seamlessly
  - Also the main workflow will be driven by user
- [x] Allow user to **disconnect session**? Manage sessions?
  - Yes, in settings
- [x] Support update session if one account is added/removed?
  - Not at first
- [X] User awareness of session expiration?
  - Support extend session?
    - Yes
