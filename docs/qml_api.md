## API available to QML

**walletModel**

*walletModel.currentAccount* - returns current account (object)
*walletModel.currentAccount.name* - 
*walletModel.currentAccount.address* - 
*walletModel.currentAccount.iconColor* - 
*walletModel.currentAccount.balance* - 
*walletModel.currentAccount.path* - 
*walletModel.currentAccount.walletType* - 

*walletModel.transactions* - list of transactions (list)

each transaction is an object containing:
* typeValue
* address
* blockNumber
* blockHash
* timestamp
* gasPrice
* gasLimit
* gasUsed
* nonce
* txStatus
* value
* fromAddress
* to

*walletModel.assets* - list of assets (list)

each list is an object containing:
* name
* symbol
* value
* fiatValue

*walletModel.totalFiatBalance* - returns total fiat balance of all accounts (string)

*walletModel.accounts* - list of accounts (list)

each account is an object containing:
* name
* address
* iconColor
* balance

*walletModel.defaultCurrency* - get current currency (string)

*walletModel.setDefaultCurrency(currency: string)* - set a new default currency, `currency` should be a symbol like `"USD"`

*walletModel.hasAsset(account: string, symbol: string)* - returns true if token with `symbol` is enabled, false other wise (boolean)

*walletModel.toggleAsset(symbol: string, checked: bool, address: string, name: string, decimals: int, color: string)* - enables a token with `symbol` or disables it it's already enabled

*walletModel.addCustomToken(address: string, name: string, symbol: string, decimals: string)* - add a custom token to the wallet

*walletModel.loadTransactionsForAccount(address: string)* - loads transaction history for an address

*walletModel.onSendTransaction(from_value: string, to: string, value: string, password: string)* - transfer a value in ether from one account to another

*walletModel.deleteAccount(address: string)* - delete an address from the wallet

*generateNewAccount(password: string, accountName: string, color: string)* - 

*addAccountsFromSeed(seed: string, password: string, accountName: string, color: string)* - 

*addAccountsFromPrivateKey(privateKey: string, password: string, accountName: string, color: string)* - 

*addWatchOnlyAccount(address: string, accountName: string, color: string)* - 

*changeAccountSettings(address: string, accountName: string, color: string)* - 

**chatsModel**

*chatsModel.chats* - get channel list (list)

channel object:
* name - 
* timestamp - 
* lastMessage.text - 
* unviewedMessagesCount - 
* identicon - 
* chatType - 
* color - 

*chatsModel.activeChannelIndex* - 
*chatsModel.activeChannel* - return currently active channel (object)

active channel object:
* id - 
* name - 
* color - 
* identicon - 
* chatType - (int)
* members - (list)
  * userName
  * pubKey
  * isAdmin
  * joined
  * identicon
* isMember(pubKey: string) - check if `pubkey` is a group member (bool)
* isAdmin(pubKey: string) - check if `pubkey` is a group admin (bool)

*chatsModel.messageList* - returns messages for the current channel (list)

message object:
* userName - 
* message - 
* timestamp - 
* clock - 
* identicon - 
* isCurrentUser - 
* contentType - 
* sticker - 
* fromAuthor - 
* chatId - 
* sectionIdentifier - 
* messageId - 

*chatsModel.sendMessage(message: string)* - send a message to currently active channel

*chatsModel.joinChat(channel: string, chatTypeInt: int)* - join a channel

*chatsModel.joinGroup()* - confirm joining group

*chatsModel.leaveActiveChat()* - leave currently active channel

*chatsModel.clearChatHistory()* - clear chat history of currently active channel

*chatsModel.renameGroup(newName: string)* - rename current active group

*chatsModel.blockContact(id: string)* - block contact

*chatsModel.addContact(id: string)*

*chatsModel.createGroup(groupName: string, pubKeys: string)*

**TODO**: document all exposed APIs to QML

