# Wallet Connect Integration

## WalletConnect SDK management

To install/updates dependencies follow these steps by running the following commands in this directory:

- Step 1: update the [`package.json`](./package.json) versions and run `npm install`
  - alternatively
    - use the command `npm install <package-name>@<version/latest> --save` for individual packages
    - or to update to the latest run `ncu -u; npm install` in here
      - run `npm install -g npm-check-updates` for `ncu` command
  - these commands will also create or update a `package-lock.json` file and populate the `node_modules` directory
- Step 2: update the [`bundle.js`](./generated/bundle.js) file by running `npm run build`
  - the result will be embedded with the app and loaded by [`WalletConnectSDK.qml`](../WalletConnectSDK.qml) component
- Step 3: add the newly generated files to index `git add --update .` to include in the commit

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
