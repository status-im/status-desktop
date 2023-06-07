<a name=""></a>
##  0.25.0 (2022-03-07)


#### Bug Fixes

* **@StatusListItem:**  fix left padding ([f574e390](f574e390))
* **StatusListItem:**  add propagateTitleClicks property to StatusListItem ([8495fae8](8495fae8))
* **StatusQ.Popups:**  removed overlay setting (#557) ([665141f8](665141f8))
* **StatusTagSelector:**  Updates and fixes in the component ([07a5dc09](07a5dc09))
* **build:**  fix linux build ([9d06aae1](9d06aae1), closes [#413](413))
* **sandbox:**  Fix results popup component position ([cdf51fef](cdf51fef))

#### Features

* **@StatusListItem:**  add option for tags ([381150a7](381150a7))
* **StatusChatList:**  Highlight chat item at creation time ([9e6fbe95](9e6fbe95))
* **StatusChatListItem:**  enable assigning emoji to chat item ([5fac8774](5fac8774))
* **StatusContactVerificationIcons:**  Create new row control that includes mutual connect and trust indicator icons (#559) ([c0f825c6](c0f825c6), closes [#542](542))
* **StatusQ:**  Moving docs outside sandbox ([825999b1](825999b1))
* **StatusQ.Core:**  add new arrow-left icon ([e9f20be1](e9f20be1))
* **StatusSmartIdenticon:**  Add support for color rings in StatusSmartIdenticon (#553) ([3b86d13a](3b86d13a), closes [#517](517))

#### Breaking Changes

* **StatusContactVerificationIcons:**  Create new row control that includes mutual connect and trust indicator icons (#559) ([c0f825c6](c0f825c6), closes [#542](542))



<a name=""></a>
##  0.24.0 (2022-02-14)


#### Features

* **StatusListItem:**  add highlighted property ([5780f183](5780f183))
* **StatusQ.Components:**  Adding StatusWizardSteper component ([b7d6554b](b7d6554b), closes [#522](522))



<a name=""></a>
##  Version 0.23.0 (2022-02-08)


#### Bug Fixes

*   Icon components had wrong color in sandbox app ([b632c712](b632c712), closes [#538](538))
* **StatusChatList:**  unexisting property name for chat item fixed ([c2e07517](c2e07517))

#### Features

* **StatusQ.Components:**
  *  Adding StatusToastMessage ([7b290ddd](7b290ddd), closes [#521](521))
  *  Adding StatusTagSelector component ([094dee49](094dee49), closes [#526](526))



<a name=""></a>
##  Version 0.22.0 (2022-01-31)


#### Features

* **StatusMemberListItem:**  Implement `StatusMemberListItem` (#539) ([c5a605bf](c5a605bf), closes [#515](515))



<a name=""></a>
##  Version 0.21.0 (2022-01-24)


#### Bug Fixes

* **build:**  broken MacOS build (#533) ([55901cf0](55901cf0))

#### Features

* **StatusMessage:**  Introducing a new StatusQ Component for Chat Messages ([ea955694](ea955694))
* **StatusQ.Controls:**  Introduce `StatusPasswordStrengthIndicator` ([626695da](626695da), closes [#528](528))



<a name=""></a>
##  Version 0.20.0 (2022-01-17)


#### Features

* **StatusBanner:**  introduce type variants for different banner styles ([35d12f44](35d12f44))

#### Bug Fixes

* **StatusBaseInput:**  Corrects allignment of the placeholder text in the StatusBaseInput. ([5a416aa1](5a416aa1))
* **build:**  Windows build ([14ab4ce5](14ab4ce5))



<a name=""></a>
##  Version 0.19.0 (2021-12-03)


#### Bug Fixes

* **StatusChatListItem:**  This change fixes the issue of the chat list items getting a highlight even when they are not really hovered ([ab6bdf54](ab6bdf54))

#### Features

* **StatusModal:**  introduce `hasCloseButton` property ([2336b6aa](2336b6aa))



<a name=""></a>
##  Version 0.18.0 (2021-11-30)


#### Bug Fixes

* **StatusAppNavBar:**  Fixed position of profile button on the NavBar ([419b7384](419b7384))
* **StatusImageWithTitle:**  Fix position of the edit title button ([8d2121ad](8d2121ad))
* **StatusListItem:**  ensure title is elided ([b7883e82](b7883e82))

#### Features

* **StatusListItem:**  Expose the Aside text so that it can be modified from the outside ([f82ce8b7](f82ce8b7))



<a name=""></a>
##  Version 0.17.1 (2021-11-19)


#### Bug Fixes

* **StatusAccountSelector:**  Adapt ui to data model changed ([db024436](db024436))
* **StatusAssetSelector:**  Fixed error of crypto balance not updated correctly ([2040d0f8](2040d0f8))



<a name=""></a>
##  Version 0.17.0 (2021-11-10)


#### Features

* **StatusBaseButton:**  introduce `Tiny` size ([dee9f437](dee9f437))
* **StatusQ.Controls.Validators:**  introduce `StatusUrlValidator` ([a9155865](a9155865))

#### Bug Fixes

* **StatusAccountSelector:**  adapt AccountSelector to new model (#482) ([ce8d3231](ce8d3231))
* **StatusExpandibleItem:**  add missing hover indicator in `Secondary` type ([e23dc533](e23dc533), closes [#478](478))
* **StatusInput:**  ensure validator messages are rendered when validators return boolean values ([f82cd7f5](f82cd7f5))
* **StatusListItem:**  This solves the issue of channel list overlpaing when a category is collapsed. ([0c715b17](0c715b17))
* **StatusSearchPopup:**  disable enter and return keys to avoid UI breakage ([fecfb2a7](fecfb2a7))
* **StatusSlider:**  slider background and handle should not depend on root's height ([31cfc883](31cfc883))



<a name=""></a>
##  Version 0.16.0 (2021-11-01)


#### Bug Fixes

* **StatusModal:**  render footer correctly based on `showFooter` flag ([da9dc2f4](da9dc2f4))
* **StatusRoundButton:**  ensure disabled state uses correct background color ([eb4aae40](eb4aae40))

#### Features

* **StatusQ.Controls:**
  *  introduce `StatusWalletColorSelect` control ([ea9a5602](ea9a5602), closes [#467](467))
  *  introduce `StatusWalletColorButton` component ([597ae192](597ae192), closes [#466](466))
* **StatusQ.Platform:**  introduce StatusMacNotification component ([d301b94c](d301b94c))



<a name=""></a>
##  Version 0.15.0 (2021-10-26)


#### Features

* **StatusQ.Controls:**
  *  introduce StatusChatCommandButton ([4cc0d2bb](4cc0d2bb), closes [#429](429))
  *  introduce `StatusTabBarIconButton` component ([4bcd89b3](4bcd89b3), closes [#428](428))



<a name=""></a>
##  Version 0.14.0 (2021-10-25)


#### Bug Fixes

* **Spellchecking:**  Add check for hunspell existence ([ab9ab249](ab9ab249))
* **StatusModal:**
  *  ensure `onEditButtonClicked` signal is emitted ([074dc22b](074dc22b), closes [#454](454))
  *  expose `header.editable` property ([9c5f79a6](9c5f79a6), closes [#452](452))

#### Features

* **StatusSmartIdenticon:**  Created a new StatusQ componnent to accomodate: ([14527483](14527483))



<a name=""></a>
##  Version 0.13.0 (2021-10-19)


#### Bug Fixes

*   use proper double checkmark icon ([8aba017c](8aba017c))
* **StatusBaseButton:**  introduce missing `highlighted` property ([a3748920](a3748920))

#### Features

* **StatusFlatRoundButton:**  Update the StatusFlatRoundButton to take over button behaviour from StatusIconButton under ui/shared/status ([71fbdef1](71fbdef1))



<a name=""></a>
##  Version 0.12.0 (2021-10-18)


#### Features

*   Resolve StatusQ modules highlighting and add qml compiler for detecting coompile time errors ([e1b0f2dc](e1b0f2dc))
* **StatusModal:**  Add edit avatar button ([5043b0b6](5043b0b6))
* **StatusQ.Components:**  introduce `StatusAddress` component ([6789446d](6789446d), closes [#430](430))
* **StatusQ.Controls:**
  *  introduce StatusColorSelector component ([bdd69955](bdd69955), closes [#444](444))
  *  introduce `StatusAssetSelector` component ([9fdc9aea](9fdc9aea), closes [#442](442))
  *  introduce `StatusAccountSelector` component ([5e15cc49](5e15cc49), closes [#435](435))
  *  introduce `StatusSelect` ([6e10959e](6e10959e), closes [#436](436))
* **StatusQ.Popups:**  introduce `StatusMenuItemDelegate` ([0764e25a](0764e25a))

#### Breaking Changes

* **StatusQ.Popups:**  introduce `StatusMenuItemDelegate` ([0764e25a](0764e25a))



<a name=""></a>
##  Version 0.11.1(2021-10-12)


#### Bug Fixes

*   Sandbox doesn't build on Linux machines ([dce45c2f](dce45c2f))
* **StatusChatInfoButton:**  StatusChatInfoButton takes up entire available width ([c276a90e](c276a90e))



<a name=""></a>
##  v0.11.0 (2021-09-27)


#### Bug Fixes

*   track category opened state ([0631d500](0631d500))
* **StatusChatList:**  ensure right click popup opens in correct position ([a2e3659d](a2e3659d))
* **StatusSearchPopup:**  use correct theme color for search result text ([654bd9f2](654bd9f2))
* **StatusSpellcheckingMenuItems:**  Exact  menu items order ([478177f2](478177f2))

#### Features

*   add star icons (#422) ([5c3267f7](5c3267f7))


<a name=""></a>
## v0.10.0 (2021-09-20)


#### Bug Fixes

* **StatusChatInfoToolBar:**  Right anchored title in StatusChatInfoToolBar ([6e8a36be](6e8a36be))
* **StatusChatListCategoryItem:**  Disable sensor when chevron clicked ([c83641d2](c83641d2))
* **StatusQ.Controls.Validators:**  fix bug that addressOrEns validator isn't properly exposed in QML ([1374c193](1374c193))

#### Features

* **StatusChatList:**  expose `statusChatListItems` Repeater ([40c0e48b](40c0e48b))
* **StatusExpandableItem:**  Correct placement of expandable region in tertiary type ([1f244f62](1f244f62))
* **StatusInput:**
  *  add support for asynchronous validators ([8820cd89](8820cd89), closes [#395](395))
  *  introduce `leftPadding` and `rightPadding` properties ([13dc8ae3](13dc8ae3))
  *  introduce `reset` API ([a2ad08e4](a2ad08e4))
* **StatusSpellcheckingMenuItems:**  Add spellchecking menu ([3e24b710](3e24b710))



<a name=""></a>
## v0.9.0 (2021-09-13)


#### Breaking Changes

* **StatusExpandableItem:**  Refactored the StatusExpandableSettingsItem to support different types ([718171fd](718171fd))

#### Bug Fixes

* **StatusAppThreePanelLayout:**  Fix margin between left and center panels ([29e9557d](29e9557d))
* **StatusChatListAndCategories:**  rely on correct tooltip settings prop ([2971c607](2971c607))
* **StatusCheckbox:**  give checkbox label proper theme color ([88fb57dd](88fb57dd))
* **StatusModal:**  don't reserve header subtitle space ([eabc62f7](eabc62f7), closes [#378](378))

#### Features

* **Status.Core.Theme:**  add RobotoMono font ([aab44c1e](aab44c1e), closes [#342](342))
* **StatusBaseInput:**  introduce `component` property ([019471c8](019471c8), closes [#380](380))
* **StatusExpandableItem:**  Refactored the StatusExpandableSettingsItem to support different types ([718171fd](718171fd))
* **StatusInput:**
  *  introduce `ValidationMode` ([d73a1584](d73a1584))
  *  exposed edit component ([73c77c29](73c77c29))
* **StatusQ.Controls.Validators:**
  *  introduce `StatusAddressAndEnsValidator` ([a93ef161](a93ef161))
  *  introduce `StatusAddressValidator` ([77d0e9b8](77d0e9b8))
* **StatusSearchPopup:**  introduce forceActiveFocus API ([efe31166](efe31166))
* **StatusValidator:**  allow validators to provide default `errorMessage` ([1a23cc19](1a23cc19))



<a name=""></a>
##  v0.8.0 (2021-09-06)


#### Bug Fixes

* **StatusBaseInput:**
  *  fix one line scroll ([d64aa6de](d64aa6de))
  *  Make clear button bigger ([387bfe77](387bfe77))
* **StatusChatToolBar:**  Fix mouse event catching after menu closing ([fbecac4a](fbecac4a))
* **StatusInput:**  Forward keys events to root ([061c7d1c](061c7d1c))
* **StatusListItem:**  Add propogateCompostedEvents to title mouse area ([5c706fdc](5c706fdc))
* **StatusModal:**  Remove self-calculating height ([3187de54](3187de54))

#### Features

*   introduce bigger versions of navbar icons ([0a4d3860](0a4d3860))
* **StatusBaseInput:**  introduce focussed property ([ddfca7a8](ddfca7a8), closes [#373](373))
* **StatusChatListAndCategories:**  Add tooltip settings for categories buttons ([64098e84](64098e84))
* **StatusDescriptionListItem:**
  *  expose subtitle component for fine control ([1749cc0e](1749cc0e))
  *  introduce support for `value` ([a963ef80](a963ef80))
* **StatusExpandableSettingsItem:**   Added new component for wallet settings ([f3ab4ce9](f3ab4ce9))
* **StatusInput:**  Introduced secondaryLabel property ([d648230d](d648230d), closes [#383](383))
* **StatusModal:**
  *  Add popup menu support for StatusModal ([8a94fb54](8a94fb54))
  *  add ability to set elide config of header titles ([28e514f9](28e514f9), closes [#353](353))
* **StatusQ.Controls:**  introduce StatusSwitchTabBar and StatusSwitchTabButton ([d449f0e9](d449f0e9), closes [#365](365))
* **StatusSearchPopup:**  add function hook to allow timestamp formatting ([b45aba4b](b45aba4b), closes [#363](363))
* **qrc:**  Add new icon needed for share modal ([38fb8f61](38fb8f61))


<a name=""></a>
##  v0.7.0 (2021-08-30)


#### Features

* **StatusChatListAndCategories:**  add drag and drop support for cate… (#349) ([a4178bd6](a4178bd6), closes [#227](227))
* **StatusChatListCategoryItem:**  Add tooltips settings ([f9775e4d](f9775e4d))
* **StatusPopupMenu:**  changed close policy ([2d8fd576](2d8fd576))
* **StatusWindowsTitleBar:**  Add windows title bar ([faca4765](faca4765))

#### Bug Fixes

* **StatusAppThreePanelLayout:**  increase minimum width in right panel ([7da4bdee](7da4bdee))
* **StatusBaseInput:**  fix click to focus ([138458d1](138458d1))
* **StatusChatInfoButton:**  Add self-calculated implicitWIdth and elide to texts ([7ef61ed3](7ef61ed3))
* **StatusListItem:**  don't set width on title item ([ee5ec7b3](ee5ec7b3))
* **StatusModal:**  ensure header and subtitles elide if needed ([503a07bf](503a07bf), closes [#256](256))



<a name=""></a>
##  v0.6.0 (2021-08-24)


#### Features

* **StatusBaseInput:**  introduce `dirty` and `pristine` properties ([ea340801](ea340801), closes [#327](327))
* **StatusChatList:**  Add drag and drop support of list items ([c679854d](c679854d))
* **StatusLetterIdenticon:**  Expose the text component ([d16719ad](d16719ad))
* **StatusListItem:**  introduce itemId and titleId properties and their handlers ([01da7508](01da7508))
* **StatusSearchPopupMenuItem:**
  *  New APIs resetSearchSelection and setSearchSelection ([78edcb37](78edcb37))
  *  new API ([b133d10f](b133d10f))

#### Bug Fixes

* **StatusBaseInput:**
  *  ensure wrapmode works as expectefd in multiline mode ([0243852c](0243852c), closes [#324](324))
  *  expose cursorPosition ([ea6743a7](ea6743a7), closes [#323](323))
* **StatusChatListCategory:**  emit original mouse event data in clicked signal ([5da9cb06](5da9cb06), closes [#333](333))
* **StatusInput:**
  *  ensure validation is performed on initialization ([4b107a0e](4b107a0e), closes [#326](326))
  *  remove recursive binding in label height ([51d8b55b](51d8b55b))
* **StatusSearchLocationMenu:**  typo fix ([c306b682](c306b682))
* **StatusSearchPopup:**  replace "#" character with "channel" icon ([2de261c4](2de261c4))



<a name=""></a>
##  v0.5.0 (2021-08-16)


#### Bug Fixes

* **StatusChatToolBar:**  Use updated StatusFlatRoundButton ([d24c2e62](d24c2e62))

#### Features

* **StatusBaseInput:**  enforce `maximumLength` if it's set ([f635bad6](f635bad6))
* **StatusFlatRoundButton:**  Adding tooltip to the button ([5a0489ba](5a0489ba))
* **StatusIcon:**  add `play-filled` and `pause-filled` icons ([58a30716](58a30716), closes [#310](310))
* **StatusInput:**  introduce new validator pipeline ([ba4f27f9](ba4f27f9), closes [#298](298))
* **StatusToolTip:**  Adding an offset property ([ee429683](ee429683))



<a name=""></a>
##  v0.4.0 (2021-08-12)


#### Bug Fixes

* **StatusAppNavBar:**  add profile button (#311) ([2e1359c9](2e1359c9))
* **StatusChatListItem:**  don't signal item selection if already selected ([b345c75a](b345c75a), closes [#303](303))
* **StatusPopupMenu:**  ensure icon or image settings exist ([90aa9d76](90aa9d76), closes [#295](295))

#### Features

* **StatusListItem:**  add enabled prop to StatusListItem (#302) ([7e03daea](7e03daea))
* **StatusQ.Theme.Core:**  introduce theme colors for StatusChatInput (#299) ([556e5cca](556e5cca))



<a name=""></a>
## v0.3.0 (2021-07-27)


#### Features

* **Controls:**  introduce `StatusInput` ([646c00bd](646c00bd), closes [#288](288))
* **Popups:**  introduce `StatusMenuHeadline` component ([246bec0d](246bec0d))
* **StatusBaseInput:**
  *  add icon support ([c8e90349](c8e90349), closes [#242](242))
  *  add visual validity state ([e8cce72c](e8cce72c), closes [#287](287))
  *  add hover state visuals ([e1ebdaae](e1ebdaae), closes [#285](285))
* **StatusInput:**  implement error message and charlimit APIs ([3cf53d02](3cf53d02), closes [#290](290))
* **StatusPopupMenu:**  add support for letter identicons, identicons and images ([3c4c7f04](3c4c7f04), closes [#263](263))
* **StatusQ.Layout:**  introducing StatusAppThreePanelLayout ([ffc6fcb4](ffc6fcb4), closes [#272](272))
* **sandbox:**  make use of `StatusInput` in chat view ([731a0f8c](731a0f8c))

#### Bug Fixes

* **StatusAppThreePanelLayout:**
  *  limit right panel width to 300px ([d327c515](d327c515))
  *  limit center panel width to 300px ([762ff87b](762ff87b))
  *  hide right panel when closed ([61705990](61705990))
* **StatusBaseInput:**
  *  some minor style adjustment to adhere to design ([f16e857c](f16e857c))
  *  ensure input text is selectable with mouse ([ab303593](ab303593))
  *  ensure clear button has the correct color ([de1cec7e](de1cec7e), closes [#286](286))
  *  add visuals for disabled state ([35f20e33](35f20e33), closes [#284](284))
  *  expose text prop alias ([116ddfbb](116ddfbb))
* **StatusChatInfoButton:**  ensure pin icon button is always rendered ([baefedb8](baefedb8), closes [#278](278))
* **StatusListItem:**  ensure title area wraps text ([e3f79314](e3f79314))
* **StatusModal:**  reset image/identicon width when loader state has changed ([e4e7ebe3](e4e7ebe3))



<a name=""></a>
## v0.2.0 (2021-07-21)


#### Bug Fixes

* **StatusChatListCategory:**  ensures showActionButtons is taken into account ([52cb97e4](52cb97e4))
* **StatusPopupMenu:**  ensure menu items elide ([d1f8e3e5](d1f8e3e5))

#### Features

* **StatusChatInfoToolBar:**  make statusMenuButton public ([38c04cb9](38c04cb9))
* **StatusChatListAndCategories:**  new API showPopupMenu ([9cfcdace](9cfcdace))
* **StatusChatListItem:**  introduce muted badge visuals ([a404ba07](a404ba07), closes [#259](259))
* **StatusListItem:**
  *  support tertiaryTitle ([03131996](03131996), closes [#275](275))
  *  add identicon support ([214ef6b0](214ef6b0), closes [#261](261))
* **StatusModal:**
  *  introduce support for identicons and letter identicons ([fda9b71f](fda9b71f), closes [#269](269))
  *  render header and footer border by default ([18dbaadd](18dbaadd), closes [#265](265))
* **StatusToolTip:**  expose `arrow` for fine-grain control ([51b7c71d](51b7c71d))



<a name=""></a>
##  v0.1.0 (2021-07-15)


#### Bug Fixes

*   Add missing .qml to resources, add qmlcache to gitignore ([71d0ef7f](71d0ef7f))
*   make release build work ([1a7c2133](1a7c2133))
*   introduce tiny icon versions and make use of them where needed ([a0fae6ab](a0fae6ab), closes [#128](128))
*   update position of window to center, add traffic lights ([26aae6d0](26aae6d0))
*   hover effect for StatusFlatRoundButton ([ee4a7c88](ee4a7c88))
*   fix crash on removing title bar ([c94b801e](c94b801e))
* **Components:**
  *  more popup menu position fine-tuning ([22eaf6fa](22eaf6fa))
  *  add proper foreground color for StatusBadge ([6a92ff68](6a92ff68), closes [#59](59))
* **Controls:**  ensure round buttons expose `hovered` state ([98b01946](98b01946), closes [#88](88))
* **Core:**
  *  add missing `rotation` property to `StatusIconSettings` ([341c0ddd](341c0ddd))
  *  don't rotate `ColorOverlay` of `StatusIcon` ([062fe42a](062fe42a), closes [#109](109))
  *  disable StatusIcon ColorOverlay if no color is supplied ([f1e34e39](f1e34e39))
* **Core.Theme:**
  *  ensure proper nav bar colors is used ([6c84fed7](6c84fed7))
  *  remove redundant theme properties ([75e87725](75e87725))
  *  ensure all font weight are available ([0a88e652](0a88e652), closes [#30](30))
* **README:**  fix module name in readme docs ([f4b5b271](f4b5b271))
* **StatusAppNavBar:**
  *  don't rely on `undefined` property ([175d7a19](175d7a19))
  *  don't try to render chat button if it doesn't exist ([d690a0c5](d690a0c5))
* **StatusBadge:**  use medium font weight for badge text ([cb9492ab](cb9492ab))
* **StatusBaseInput:**  Fix focus area Closes: #241 ([f2d36d3d](f2d36d3d))
* **StatusChatInfoButton:**
  *  make component identicon aware ([7dcec0ca](7dcec0ca), closes [#228](228))
  *  prefix chat name with "#" if needed ([144ac69d](144ac69d), closes [#229](229))
  *  vertically center title if no subtitle is provided ([7b2030c6](7b2030c6), closes [#230](230))
  *  disable hover effects when sensor is disabled ([f7e38c9c](f7e38c9c), closes [#231](231))
* **StatusChatList:**
  *  ensure badge is also shown for one to one messages ([ac5c8452](ac5c8452))
  *  ensure popupMenu closeHandler don't break ([722d92c0](722d92c0), closes [#216](216))
  *  use fallback property to determine unread message count ([f7f217ed](f7f217ed))
  *  expect `model.color` instead of `iconColor` prop ([70332a3f](70332a3f))
  *  ensure component provide default `width` ([300536bc](300536bc), closes [#176](176))
* **StatusChatListAndCategories:**
  *  make chat list visibily flag work ([53d63a9b](53d63a9b), closes [#217](217))
  *  ensure chatItemUnmuted event is propagated ([a9ae426c](a9ae426c), closes [#219](219))
  *  ensure chat list receives popup menu ([23ddbc2e](23ddbc2e), closes [#218](218))
* **StatusChatListCategory:**  only try open popup when supplied ([cbdaf128](cbdaf128), closes [#220](220))
* **StatusChatListCategoryItem:**  don't render menubutton with no popup ([05fc97ca](05fc97ca), closes [#153](153))
* **StatusChatListItem:**
  *  ensure chat name elides when it's too long ([34df0f0d](34df0f0d), closes [#151](151))
  *  ensure public chat names are prefixed with '#' ([141872c2](141872c2), closes [#191](191))
  *  use proper font size for chat name ([ac80f7f7](ac80f7f7))
* **StatusChatToolBar:**
  *  ensure context menu as proper position ([3ea8da05](3ea8da05))
  *  ensure menu button stays highlighted ([90bad9e3](90bad9e3), closes [#125](125))
* **StatusFlatRoundButton:**  use correct hover color ([82e34d64](82e34d64))
* **StatusListItem:**
  *  ensure icon background in secondary type works correctly ([34b35318](34b35318))
  *  various fixes w.r.t. sensor, icon size etc ([e5e96af5](e5e96af5))
* **StatusMenuSeparator:**  ensure height is 0 when invisible or disabled ([fd7a5530](fd7a5530), closes [#212](212))
* **StatusModal:**  ensure modal footer uses correct theme color ([de2c36d0](de2c36d0))
* **StatusModalHeader:**  ensure header has enough height for children ([75b2f508](75b2f508), closes [#185](185))
* **StatusNavBarTabButton:**
  *  fix popup menu positioning ([705f1402](705f1402))
  *  ensure click signal is emitted when not menu is provided ([040da2a4](040da2a4))
  *  don't change checked state implicitly ([b1fe73ba](b1fe73ba))
* **StatusNavigationListItem:**  make click event work again ([c5ecfe08](c5ecfe08))
* **StatusQ.Core.Theme:**  use correct dropshadow color in dark theme ([70e17b05](70e17b05))
* **StatusRadioButton:**  ensure control label as correct color ([1cb0c1d3](1cb0c1d3), closes [#51](51))
* **StatusRoundedImage:**  ensure images are scaled and positioned properly ([3d0688b7](3d0688b7), closes [#172](172))
* **sandbox:**  make scrollview content height grow with content ([2f09179f](2f09179f))

#### Features

*   can be used on tablets (#146) ([63be0144](63be0144))
*   add StatusSwitch ([52998d68](52998d68), closes [#12](12))
*  Add buttons components ([91b8d317](91b8d317))
*   Set up catalog app (sandbox) ([3528b2ff](3528b2ff), closes [#5](5))
*   introduce theming capability ([608fdbda](608fdbda), closes [#3](3))
* **Components:**
  *  introduce `StatusContactRequestsIndicatorListItem` ([baa663ce](baa663ce), closes [#175](175))
  *  introduce `StatusListSectionHeadline` ([507703af](507703af), closes [#164](164))
  *  introduce `StatusNavigationPanelHeadline` ([40617cd7](40617cd7), closes [#162](162))
  *  introduce `StatusChatListAndCategories` component ([7bca2745](7bca2745), closes [#133](133))
  *  introduce `StatusChatInfoToolBar` component ([454e73a8](454e73a8), closes [#141](141))
  *  introduce `StatusChatListCategory` ([f4d211ac](f4d211ac), closes [#123](123))
  *  introduce `StatusChatListCategoryItem` ([916dcc9c](916dcc9c), closes [#117](117))
  *  introduce `StatusChatList` ([1e558b59](1e558b59), closes [#100](100))
  *  Add StatusSlider ([c0ad32a1](c0ad32a1))
  *  introduce `StatusChatToolBar` ([a4421b5b](a4421b5b), closes [#80](80))
  *  introduce `StatusDescriptionListItem` ([4a25ca02](4a25ca02))
  *  introduce StatusNavigationListItem ([63275668](63275668), closes [#72](72))
  *  introduce StatusChatListItem ([b40d427d](b40d427d), closes [#65](65))
  *  introduce `StatusListItem` component ([a3fe02d0](a3fe02d0), closes [#19](19))
  *  introduce `StatusRoundIcon` component ([8639e8cc](8639e8cc), closes [#53](53))
  *  introduce StatusBadge component ([a89e218a](a89e218a), closes [#15](15))
  *  introduce StatusRoundedImage ([09876c1f](09876c1f), closes [#32](32))
  *  introduce StatusLetterIdenticon ([b0155313](b0155313), closes [#28](28))
  *  introduce StatusLoadingIndicator ([3ce1138b](3ce1138b), closes [#7](7))
* **Controls:**
  *  introduce StatusBaseInput ([13217604](13217604))
  *  introduce `StatusChatInfoButton` ([8a799182](8a799182))
  *  introduce StatusNavBarTabButton ([ea118d71](ea118d71), closes [#17](17))
  *  introduce StatusToolTip component ([f3a6c9f4](f3a6c9f4), closes [#14](14))
* **Core:**
  *  introduce StatusIconBackgroundSettings ([a4e62fb2](a4e62fb2))
  *  introduce `StatusImageSettings` ([d9529883](d9529883))
  *  introduce StatusBaseText component ([c7d533af](c7d533af), closes [#20](20))
* **Core.Controls:**  introduce StatusIconTabButton component ([b4b1f472](b4b1f472), closes [#16](16))
* **Core.Theme:**  expose solid black and white on `ThemePalette` ([996ceb2b](996ceb2b))
* **Layout:**
  *  introduce `StatusAppTwoPanelLayout` ([af3ca15b](af3ca15b))
  *  introduce StatusAppLayout component ([554998dc](554998dc))
  *  introduce StatusAppNavBar ([0dfd39af](0dfd39af), closes [#18](18))
* **Popups:**
  *  Add StatusModal ([e49b58b9](e49b58b9))
  *  introduce StatusModalDivider ([148c30b9](148c30b9))
  *  Add StatusModalFooter ([9c2a5830](9c2a5830))
  *  Add status modal header ([fa9bb7ad](fa9bb7ad))
* **StatusBadge:**  introduce `borderColor` and `hoverBorderColor` ([041c11fb](041c11fb))
* **StatusBaseInput:**  Add focused state Closes: #240 ([19349881](19349881))
* **StatusChatList:**
  *  expose hook to lazily calculate chat item names ([a664f635](a664f635))
  *  introduce `profileImageFn` property ([cfacd5be](cfacd5be), closes [#174](174))
  *  introduce `popupMenu` property ([a6262f0a](a6262f0a), closes [#171](171))
  *  introduce `filterFn` and `categoryId` ([cb078134](cb078134), closes [#154](154))
* **StatusChatListCategory:**
  *  apply chat list filter and expose category id in popup menu ([45775518](45775518))
  *  introduce flag to show/hide buttons ([9982c3df](9982c3df), closes [#150](150))
* **StatusChatListCategoryItem:**  introduce `highlighted` property ([72bdd2d9](72bdd2d9))
* **StatusChatListCategoryItemButton:**  introduce `highglighted` property ([645a3b79](645a3b79))
* **StatusChatListItem:**
  *  add `highlighted` property ([44343d38](44343d38), closes [#178](178))
  *  accept right clicks ([1f3aa0bb](1f3aa0bb), closes [#131](131))
* **StatusChatToolBar:**
  *  add tooltips to action buttons ([86da901e](86da901e), closes [#244](244))
  *  add members and search button ([e93dab2b](e93dab2b), closes [#243](243))
* **StatusFlatRoundButton:**
  *  introduce `highlighted` color for secondary type ([58e8f1cd](58e8f1cd), closes [#245](245))
  *  support icon rotation ([3a7a338d](3a7a338d))
* **StatusIcon:**  Improvement of Icons ([7bc7df8d](7bc7df8d))
* **StatusIconTabButton:**  introduce image loading state and fallback ([9b99d8a9](9b99d8a9), closes [#37](37))
* **StatusListItem:**
  *  add `Danger` type support ([8155d9a2](8155d9a2), closes [#248](248))
  *  support letter identicons ([531e54f2](531e54f2), closes [#239](239))
  *  introduce primary and secondary types ([146218e0](146218e0))
* **StatusModal:**  expose loaded content ([bd383e87](bd383e87), closes [#237](237))
* **StatusNavBarTabButton:**  introduce `popupMenu` property ([5e8242df](5e8242df), closes [#137](137))
* **StatusPopupMenu:**
  *  introduce `openHandler` ([2427fa2d](2427fa2d))
  *  make menu items invisible when disabled ([c9bc9bab](c9bc9bab), closes [#135](135))
  *  introduce `closeHandler` hook ([fb51e9d7](fb51e9d7))
* **StatusQ.Popups:**  introduce StatusPopupMenu component ([09a6f418](09a6f418), closes [#96](96))
* **StatusRoundButton:**  add `highlighted` and `icon.rotation` props ([7c16a9bd](7c16a9bd))
* **StatusRoundIcon:**  enable `icon.color` support ([70043c5b](70043c5b))
* **StatusRoundedImage:**
  *  introduce identicon support ([7a2648f6](7a2648f6), closes [#173](173))
  *  add loading indicator option ([44b275f2](44b275f2), closes [#56](56))
* **sandbox:**
  *  introduce first part of profile view for reference app ([4588d597](4588d597))
  *  introduce first version of reference app ([202fb886](202fb886))



