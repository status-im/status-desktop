# Dapp Browser Reintroduction FURPS ([#17970](https://github.com/status-im/status-app/issues/17970))

## Functionality
- Reintegrate a Dapp browser into the app, allowing users to open and interact with decentralized applications.
- Enable seamless integration with the built-in Ethereum wallet for signing transactions and messages.
- Provide configuration to choose between the in-app browser and the system/default browser for opening links.

## Usability
- Offer a clear and user-friendly interface to switch between browser options.
- Ensure consistent and predictable behavior when opening Dapp links from chats or the UI.
- Display wallet interaction prompts clearly and securely within the browser context.
- Provide warnings or indicators when navigating to untrusted or unsupported Dapps.

## Reliability
- Ensure consistent transaction signing and wallet connectivity across browser contexts.
- Handle unsupported Dapp features or failed wallet interactions gracefully.
- Maintain session state, permissions, and network configuration across browsing sessions.

## Performance
- Ensure fast page load and smooth interaction within the embedded browser.
- Use a recent version of QtWebEngine (desktop) or native system browser (mobile) for better performance and compatibility.
- Avoid memory leaks and crashes from browser rendering or wallet bridge logic.

## Supportability
- Architect the browser integration in a modular way to support platform-specific implementations (desktop/mobile).
- Provide diagnostic logging for browser errors, wallet connection issues, and user actions.
- Maintain compatibility with major Dapp standards (EIP-1193, WalletConnect fallback if needed).
