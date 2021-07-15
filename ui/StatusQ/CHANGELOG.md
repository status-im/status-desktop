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



