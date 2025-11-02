'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"1.png": "5dcef449791fa27946b3d35ad8803796",
"assets/AssetManifest.bin": "ff6ac9d3de359f010731f03d06063aa1",
"assets/AssetManifest.bin.json": "9f6e4cf974a610fe12521d5eb273a4aa",
"assets/AssetManifest.json": "e0ba1c0ba200669af9d65d6704a645da",
"assets/assets/ai/Claude.png": "55e0a07cc3cba5734b01cea49bbef808",
"assets/assets/ai/GoogleBard.png": "9656ab6479bcd0a829a47c3ea82b5376",
"assets/assets/ai/openai.webp": "96445f27d919b61afc55a84346daa322",
"assets/assets/alert/icon_fail.png": "a718aec61aa7bb9c1d49cd232768dbc6",
"assets/assets/alert/icon_success.png": "6eff1af1c52abd5c88ae44acddcf190d",
"assets/assets/alert/icon_warn.png": "5027e2574515ade177b94588856ac129",
"assets/assets/api/channelTable.json": "622bc2960776e97b380a2a814cdf4e25",
"assets/assets/australia.json": "a8710e36ed3224e92175d9ddb7953a22",
"assets/assets/barangay.json": "d92b11fcdc8e531d78061b3a0716b586",
"assets/assets/barangays.json": "984a4c3297f99fe446e0f7e137f802f5",
"assets/assets/brand/brand-01.svg": "2dd59410e0a65ce7183c0edb82d51cec",
"assets/assets/brand/brand-02.svg": "1cd9b0680cbfb78805420659bc1e077d",
"assets/assets/brand/brand-03.svg": "0eca25adef3e8225d50860ec9e935082",
"assets/assets/brand/brand-04.svg": "7dc6ac3b2da4adea0f941e472486a4bc",
"assets/assets/brand/brand-05.svg": "3ebe4ebf55a7faa2aa74ce775c7340fb",
"assets/assets/cards/cards-01.png": "bee503d28d650dc258b6376511f5facd",
"assets/assets/cards/cards-02.png": "704f58c328ebb8c091643b238bd1c62b",
"assets/assets/cards/cards-03.png": "36a3fa394039239a716caf01970174ca",
"assets/assets/cards/cards-04.png": "4443f6a85e3b7e775afc640584f866da",
"assets/assets/cards/cards-05.png": "2d0223d89e31b56459d147647db3a7f0",
"assets/assets/cards/cards-06.png": "080a048d0d862ef60ae4e67db3caf930",
"assets/assets/country/country-01.svg": "59c5ae713308034a1e0a8f138682b2a3",
"assets/assets/country/country-02.svg": "d5f66a93a4ade95ad2a72eb195f85028",
"assets/assets/country/country-03.svg": "8bd9f1d0cdad554fbb6551e0e2316493",
"assets/assets/country/country-04.svg": "47978f51b9a5e565cdf220612aaa4170",
"assets/assets/country/country-05.svg": "b5a8a2f9422c1b8846dabbcf149a673e",
"assets/assets/country/country-06.svg": "f39891596b6c5eeee69d2a02df9f4142",
"assets/assets/cover/cover-01.png": "972c64bf2ce84e837c5b3a2094281e16",
"assets/assets/crm/crm.png": "0c0806c464de6af08315cfb1a5d9d61c",
"assets/assets/DA2.jpg": "b80c683e6de4fe307c00cc4b89538fef",
"assets/assets/DA3.jpg": "37265d45e3019ff873957d7f687ef9f1",
"assets/assets/DA_image.jpg": "3c1029159c129856a805e56a4925a267",
"assets/assets/icon/ai.png": "09e41b7f2e484029ef106886e052d0c5",
"assets/assets/icon/bg-word.svg": "5ccdd1e957e3b7af92b858c86a292fbe",
"assets/assets/icon/edit.svg": "e07e092f6705928126f9dc5aea8a62de",
"assets/assets/icon/firebase.png": "f1c4ff8b380764d209f4fc5d2377bb96",
"assets/assets/icon/icon-arrow-down.svg": "ab3cd915ffa427d34a5e89d864631b04",
"assets/assets/icon/icon-calendar.svg": "b0baecc0aa9c16ead9a856fe58647914",
"assets/assets/icon/icon-copy-alt.svg": "ccc6b1e6fd056d7d25978a064d6b68de",
"assets/assets/icon/icon-moon.svg": "f0c56a1b9282024a7c210588a79dc8a3",
"assets/assets/icon/icon-sun.svg": "99bd84f8192219382166d3264cf6bf8d",
"assets/assets/icon/user.svg": "e4790d0b53a6769df1a4dda0f3a79f26",
"assets/assets/loginBG.jpg": "47e877eb4c86851a114c00984e099129",
"assets/assets/loginBG2.jpg": "6789e3752514ec2bb5dfc857665054a4",
"assets/assets/logo/logo_dark.svg": "d1bb863b23262a859b5eb5aebac9babb",
"assets/assets/logo/logo_white.svg": "d1bb863b23262a859b5eb5aebac9babb",
"assets/assets/map/barangays.geojson": "bbc9ef4830ad527d9e7970b11b5fd178",
"assets/assets/map.html": "95929eb3c1e0557792625d43f0a06ca5",
"assets/assets/notfound.png": "0f36e383d4afc6650d296f660628bb4a",
"assets/assets/product/product-01.png": "34be8cdb4dbf696fb0a39b39c5d94c4a",
"assets/assets/product/product-02.png": "1a4633cb19e391dd753743d62b4a790b",
"assets/assets/product/product-03.png": "2c213e5c10b79de985f7691ad21ca1e6",
"assets/assets/product/product-04.png": "f45c5f8c16c8db472e6b6d7c16cdae9b",
"assets/assets/product/product-thumb.png": "9cb86c53190c3026fb88dd00c232dd57",
"assets/assets/rice.svg": "fb4cb3b6757ac5cfd34f772094a5cda1",
"assets/assets/routes/menu_route_admin_en.json": "41d7298377248ffecadcd541daff4354",
"assets/assets/routes/menu_route_admin_fil.json": "8c18cae79abed3a935ce1cdcc42e7ef7",
"assets/assets/routes/menu_route_farmer_en.json": "282d02b3d0e945d7ea558538ca2d3d68",
"assets/assets/routes/menu_route_farmer_fil.json": "5587c5053e5b11b698998e8504b20159",
"assets/assets/routes/menu_route_guest_en.json": "4270f50c5ee446ea5954dd61e2c5be9c",
"assets/assets/routes/menu_route_officer_en.json": "70f0c96d0fc126d20fb581de72a9f17e",
"assets/assets/routes/menu_route_officer_fil.json": "36e682dc0d8de13928479744a0a17949",
"assets/assets/routes/tools_menu_route_en.json": "7a9ccef4bcbb2e1e87e6cc18ddec84a5",
"assets/assets/sidebar/AI.svg": "87dd9b60da790617f8a392b5960c0f0f",
"assets/assets/sidebar/assocs.svg": "595c306831f76864c3d450f2a63d1a31",
"assets/assets/sidebar/auth.svg": "9524d73090e71ca5386406f52e52e08e",
"assets/assets/sidebar/calendar.svg": "65d24c7b0fbc719f7113eba7813b6410",
"assets/assets/sidebar/chart.svg": "7052ba5ddf4728fdefcf59946fafcebd",
"assets/assets/sidebar/chatbot.svg": "da22b6e867453a3d9fbd4348587bcd47",
"assets/assets/sidebar/dashboard.svg": "acd622e7a7d7363c0fbab805bde95cab",
"assets/assets/sidebar/dictionary.svg": "e89bb6fa7e6a8c4ef53b652dfb958f42",
"assets/assets/sidebar/farm.svg": "45fbc880bdf62d027c7860d202425e93",
"assets/assets/sidebar/farmer.png": "af73f2e055f08f546f8b92c74df86b68",
"assets/assets/sidebar/farmer.svg": "ebc7f4d6618bbf4b9a7bb762ba0ef2ee",
"assets/assets/sidebar/forms.svg": "26080bc6e532163655306906484c521a",
"assets/assets/sidebar/invoice.svg": "be5445ed36fa593bb2b4bca23f4adfa8",
"assets/assets/sidebar/map.svg": "297d7491857627eb87ddcbd9aab325f5",
"assets/assets/sidebar/page.svg": "2defe056beb5eaec2b895e369231f37a",
"assets/assets/sidebar/products.svg": "888303d4b89a1242f1116099c816074c",
"assets/assets/sidebar/profile.svg": "d597d10b478f01f2fbf529e87fe44b1b",
"assets/assets/sidebar/reports.svg": "aa2cae4c87ccb41834790343f65bad6f",
"assets/assets/sidebar/sector.svg": "4c0c255a940a5474880db6cb0c99bc78",
"assets/assets/sidebar/setting.svg": "1c84b34b46bb79982c673d0ed4619063",
"assets/assets/sidebar/table.svg": "c8649dfd8940ec690a0ee02726a8921e",
"assets/assets/sidebar/task.svg": "eb30121e95428353f48a30b5739ce221",
"assets/assets/sidebar/tools.svg": "b3258cf0e54adc61fc24080f0de81020",
"assets/assets/sidebar/ui.svg": "bd4240c78ede1540dbbc70d6c95c67e9",
"assets/assets/sidebar/user.svg": "b2827dd98b3f14d083862dc80c167974",
"assets/assets/sidebar/yield.svg": "9f86bc1549c678cd2bdf1e0cacdf81f4",
"assets/assets/signin/email.svg": "5e43e6afdbd3ea78b763a53054bce79f",
"assets/assets/signin/lock.svg": "3ad8a7c59c0398b00c91eb9b32aea729",
"assets/assets/signin/main.svg": "6773ba3c7b3754d799a96115f4531cd2",
"assets/assets/signin/signup.svg": "a53eaa0dc9565ee40c6f7a4a12b1eec9",
"assets/assets/task/task-01.jpg": "557544c08de1aba4220b710b03d999b0",
"assets/assets/toolbar/alarm.svg": "c182e6a14eb5104f4e252a78bd467775",
"assets/assets/toolbar/arrow_bottom.svg": "bbe9b4cd5363997caa4f4640a4aef955",
"assets/assets/toolbar/dock_right.svg": "2f1abd751615bb0e33a86cd0dc018547",
"assets/assets/toolbar/message.svg": "52894902fba62ce40c7de5d7b1bea499",
"assets/assets/toolbar/moon.png": "3537a6d32a3fdbbde188fac8376c64a2",
"assets/assets/toolbar/moon.svg": "db479c83c6a269c0ce10839b14861190",
"assets/assets/toolbar/sun.png": "15f2e60867947d7ac1c8d91a7372fe41",
"assets/assets/toolbar/sun.svg": "09049d4bb2abba08cfd63891a7fb5ff4",
"assets/assets/toolbar/toggle.svg": "cd17bbf814d52381a6138c6c539fe245",
"assets/assets/user/user-01.png": "c8ed34fe5094d3b127bb9c94633d6371",
"assets/assets/user/user-02.png": "de3bd868997d3f445348922df73d8226",
"assets/assets/user/user-03.png": "93b7c0c394b231732ebe8806448a95a8",
"assets/assets/user/user-04.png": "118e66657a14921a61abc7d21261188b",
"assets/assets/user/user-05.png": "d74bb3c54d3e3c32c73829d652d0d6f4",
"assets/assets/user/user-06.png": "975408d09dc079b97f4ae46480af7ef5",
"assets/assets/user/user-07.png": "e3058df7afaaf5b2dedd732445cfea5b",
"assets/assets/user/user-08.png": "960cd052c95c75462fae0c9930a202db",
"assets/assets/user/user-09.png": "15693dc3edc4775c384585aa757f2421",
"assets/assets/user/user-10.png": "8bbed9cfd9a9e8a7d5ab3e1a43737380",
"assets/assets/user/user-11.png": "11f4a43c10ec710e5e41f261a629ca82",
"assets/assets/user/user-12.png": "8530b9ec54e0b67cb52b44bcbae5482c",
"assets/assets/user/user-13.png": "cdb3cc59c44f18a8029a032a3952663d",
"assets/FontManifest.json": "0f9181c525c30a97b7cc6cf839dbbe04",
"assets/fonts/MaterialIcons-Regular.otf": "87722a2dcf3fd9bc551a97a69dc22f3f",
"assets/NOTICES": "c3aa9b3ac0cb3bbc0defdd0eaa82e3f9",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-arrow.png": "8efbd753127a917b4dc02bf856d32a47",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-attachment.png": "9c8f255d58a0a4b634009e19d4f182fa",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-delivered.png": "b6b5d85c3270a5cad19b74651d78c507",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-document.png": "e61ec1c2da405db33bff22f774fb8307",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-error.png": "5a59dc97f28a33691ff92d0a128c2b7f",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-seen.png": "10c256cc3c194125f8fffa25de5d6b8a",
"assets/packages/flutter_chat_ui/assets/2.0x/icon-send.png": "2a7d5341fd021e6b75842f6dadb623dd",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-arrow.png": "3ea423a6ae14f8f6cf1e4c39618d3e4b",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-attachment.png": "fcf6bfd600820e85f90a846af94783f4",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-delivered.png": "28f141c87a74838fc20082e9dea44436",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-document.png": "4578cb3d3f316ef952cd2cf52f003df2",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-error.png": "872d7d57b8fff12c1a416867d6c1bc02",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-seen.png": "684348b596f7960e59e95cff5475b2f8",
"assets/packages/flutter_chat_ui/assets/3.0x/icon-send.png": "8e7e62d5bc4a0e37e3f953fb8af23d97",
"assets/packages/flutter_chat_ui/assets/icon-arrow.png": "678ebcc99d8f105210139b30755944d6",
"assets/packages/flutter_chat_ui/assets/icon-attachment.png": "17fc0472816ace725b2411c7e1450cdd",
"assets/packages/flutter_chat_ui/assets/icon-delivered.png": "b064b7cf3e436d196193258848eae910",
"assets/packages/flutter_chat_ui/assets/icon-document.png": "b4477562d9152716c062b6018805d10b",
"assets/packages/flutter_chat_ui/assets/icon-error.png": "4fceef32b6b0fd8782c5298ee463ea56",
"assets/packages/flutter_chat_ui/assets/icon-seen.png": "b9d597e29ff2802fd7e74c5086dfb106",
"assets/packages/flutter_chat_ui/assets/icon-send.png": "34e43bc8840ecb609e14d622569cda6a",
"assets/packages/flutter_dropzone_web/assets/flutter_dropzone.js": "dddc5c70148f56609c3fb6b29929388e",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "a2eb084b706ab40c90610942d98886ec",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "83c878235f9c448928034fe5bcba1c8a",
"assets/packages/quickalert/assets/confirm.gif": "bdc3e511c73e97fbc5cfb0c2b5f78e00",
"assets/packages/quickalert/assets/error.gif": "c307db003cf53e131f1c704bb16fb9bf",
"assets/packages/quickalert/assets/info.gif": "90d7fface6e2d52554f8614a1f5deb6b",
"assets/packages/quickalert/assets/loading.gif": "ac70f280e4a1b90065fe981eafe8ae13",
"assets/packages/quickalert/assets/success.gif": "dcede9f3064fe66b69f7bbe7b6e3849f",
"assets/packages/quickalert/assets/warning.gif": "f45dfa3b5857b812e0c8227211635cc4",
"assets/packages/rflutter_alert/assets/images/2.0x/close.png": "abaa692ee4fa94f76ad099a7a437bd4f",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_error.png": "2da9704815c606109493d8af19999a65",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_info.png": "612ea65413e042e3df408a8548cefe71",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_success.png": "7d6abdd1b85e78df76b2837996749a43",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_warning.png": "e4606e6910d7c48132912eb818e3a55f",
"assets/packages/rflutter_alert/assets/images/3.0x/close.png": "98d2de9ca72dc92b1c9a2835a7464a8c",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_error.png": "15ca57e31f94cadd75d8e2b2098239bd",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_info.png": "e68e8527c1eb78949351a6582469fe55",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_success.png": "1c04416085cc343b99d1544a723c7e62",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_warning.png": "e5f369189faa13e7586459afbe4ffab9",
"assets/packages/rflutter_alert/assets/images/close.png": "13c168d8841fcaba94ee91e8adc3617f",
"assets/packages/rflutter_alert/assets/images/icon_error.png": "f2b71a724964b51ac26239413e73f787",
"assets/packages/rflutter_alert/assets/images/icon_info.png": "3f71f68cae4d420cecbf996f37b0763c",
"assets/packages/rflutter_alert/assets/images/icon_success.png": "8bb472ce3c765f567aa3f28915c1a8f4",
"assets/packages/rflutter_alert/assets/images/icon_warning.png": "ccfc1396d29de3ac730da38a8ab20098",
"assets/packages/syncfusion_flutter_datagrid/assets/font/FilterIcon.ttf": "b8e5e5bf2b490d3576a9562f24395532",
"assets/packages/syncfusion_flutter_datagrid/assets/font/UnsortIcon.ttf": "acdd567faa403388649e37ceb9adeb44",
"assets/packages/timezone/data/latest_all.tzf": "a3a6cb5d912b5375926e5b027f91cb00",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "9dd1d750ed1d1bdb53078c5d19646a36",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "9c3408e75fdc3a5970aeca52fded6be2",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "243461d3adb0dbb9492a8689429b5d7e",
"/": "243461d3adb0dbb9492a8689429b5d7e",
"loading.gif": "b5302a7e6f55787961943f3c115f2480",
"main.dart.js": "cd9c69125e892242def702f6e57aba06",
"main.dart.js_1.part.js": "ea80cae237005876669ab0959c5b699a",
"main.dart.js_10.part.js": "8cd05a13ce8d3d99a65d5f90b1d4620d",
"main.dart.js_100.part.js": "15a5be048c80fa6c14dcb061c51ba94f",
"main.dart.js_101.part.js": "96e1a5cd6545a3ab163cf8b7385e0ebe",
"main.dart.js_102.part.js": "98db6d9a22c18d3884ebcdae80d9d332",
"main.dart.js_103.part.js": "c37c456f86f52d66105943bf936d9e10",
"main.dart.js_104.part.js": "bb770c7a6ea412fa918bf4b6b883df6f",
"main.dart.js_105.part.js": "edf9966159fd03ef870eebce87a75579",
"main.dart.js_106.part.js": "3ad954a02c3f6b8aa739e29b5ce7adba",
"main.dart.js_107.part.js": "3ae78fcff62959491f5b664c659b4a67",
"main.dart.js_108.part.js": "47fe8a3a78a90ce72f140e3d6af33a67",
"main.dart.js_109.part.js": "136c1212754d9c6f853ac5109ffa013d",
"main.dart.js_11.part.js": "358cf5795d8acf523fe7ddc61e7afc0b",
"main.dart.js_110.part.js": "083262b08e2f81e75b57db0d09f0f50a",
"main.dart.js_111.part.js": "99f7a1aa0ad2a0bc54e78accd99b8e10",
"main.dart.js_112.part.js": "953ef6484e6e40314641d9f184f5f7dd",
"main.dart.js_113.part.js": "d3ad56168460672b21ce9e51e0369b0b",
"main.dart.js_114.part.js": "ac165e7e83b907c7de0b7ade7ccecb44",
"main.dart.js_115.part.js": "a6f09c708699b06ae66442941f3c78d1",
"main.dart.js_116.part.js": "3e55d6ead5c94d896467d66e1364eef8",
"main.dart.js_117.part.js": "35c3c81c809f4d98c2284d35727d91b8",
"main.dart.js_118.part.js": "3c2e596ecc6fad7130d45f4995be2e4c",
"main.dart.js_119.part.js": "8262b3ee489df7815f88a5837bbd338c",
"main.dart.js_12.part.js": "b5844aed79fb51cc74575b55559415e9",
"main.dart.js_120.part.js": "69a43452a48e0e0fe228c836cf368d2b",
"main.dart.js_13.part.js": "2f53c9cf1e553a26ff6d6e46c1d7d9a2",
"main.dart.js_14.part.js": "9bfbeb287fa4bd53b7008fc372194bf5",
"main.dart.js_15.part.js": "baa96761327e8072041ed21014bd619d",
"main.dart.js_16.part.js": "8d2630739c8956f72e755cbe7e515cb7",
"main.dart.js_17.part.js": "7b9c28fd42a0776268a001511c0bda30",
"main.dart.js_18.part.js": "bd060703d76f71c52a5bec58cb0f80c6",
"main.dart.js_19.part.js": "a93561f5ac95a6f140398e1bc8472e37",
"main.dart.js_2.part.js": "09fbbbed36a224b878d20b9af00c39e5",
"main.dart.js_20.part.js": "5905ec4c874be22f19ef15cda07321fa",
"main.dart.js_21.part.js": "28d73bf4e948f9cad0892a5ac88c8b8b",
"main.dart.js_22.part.js": "2d8eec78ae0c45d4f11a1b9467b0ed92",
"main.dart.js_23.part.js": "ac9552786badf1eb33959d593c170aa6",
"main.dart.js_24.part.js": "a24814ac39ffda70d1b1d84e01da1a81",
"main.dart.js_25.part.js": "598c3299a8c884095a3893897c2ba7c0",
"main.dart.js_26.part.js": "91a61d32b1aedbd807e10470187f4958",
"main.dart.js_27.part.js": "5f8d63e552660e687e9a9337fd7153aa",
"main.dart.js_28.part.js": "9de1c68e7336fa3e0d972a4d26e9e8e3",
"main.dart.js_29.part.js": "9895cbf5dd50ff23cbbcb552e0e4ace2",
"main.dart.js_30.part.js": "3963e727f373dd0854d29e04cf444040",
"main.dart.js_31.part.js": "8053d3ab3095b465406ec17848aae7ae",
"main.dart.js_32.part.js": "707d54131a6b5ed92997a15e3423f013",
"main.dart.js_33.part.js": "74148f893b6bbcb604cc84fd30e60042",
"main.dart.js_34.part.js": "1b5ce524809980e8a65628ae8523c49c",
"main.dart.js_35.part.js": "f75e92ab225f2297e1b65a1862bc24a7",
"main.dart.js_36.part.js": "69c4709cd7958a899fd2b3f397b60ae5",
"main.dart.js_37.part.js": "57034b5da48985b77cddf42463dc500c",
"main.dart.js_38.part.js": "d9d37ac5bbb166f4f8ede110ce710e7d",
"main.dart.js_39.part.js": "9f834a36ca4c33d6d069bb7ca480d702",
"main.dart.js_40.part.js": "15dab96ad75f1ed531db44d4f5c382c4",
"main.dart.js_41.part.js": "adea306af5b0cfc9be9e79f34d69b6a5",
"main.dart.js_42.part.js": "f0c9476b928fe45a071f6583dc7fec5c",
"main.dart.js_43.part.js": "7059ac5b196bc4b6cb67711b42c009f0",
"main.dart.js_44.part.js": "70affbecc0ab5397663452d5ac29361b",
"main.dart.js_45.part.js": "fd8a6b8fdabb41953c3499036d5aeec1",
"main.dart.js_46.part.js": "a0a37a8182deb0a39840839a29d8c7f9",
"main.dart.js_47.part.js": "7b111fd3076c645284fbb666a73d1b3b",
"main.dart.js_48.part.js": "66499bd0a9962dceb5992ef9f49132c4",
"main.dart.js_49.part.js": "4c868258d82191ce51567e8328b1ee9f",
"main.dart.js_50.part.js": "04d056471dd66eba7ba7e700ad658b81",
"main.dart.js_51.part.js": "09d4eacad10817596530b433f930d5a7",
"main.dart.js_52.part.js": "cea17b4dde2986447d896beca036f2ac",
"main.dart.js_53.part.js": "53bd61914d3b6730275bef03e857b365",
"main.dart.js_54.part.js": "e4c21ffb10319f7d55f467ac8ccb3d45",
"main.dart.js_55.part.js": "eca810ee54cc4160b71faa06bb7a41de",
"main.dart.js_56.part.js": "c5f01afdb1334b1a3c824f0e9ca69205",
"main.dart.js_57.part.js": "ba982a07c77216950a5cebea8c2d0dd3",
"main.dart.js_58.part.js": "e0e1c1d1999da91d7ad2ca05e114c765",
"main.dart.js_59.part.js": "8fc0aa76ed0fc59b4886975491b8d271",
"main.dart.js_60.part.js": "a2bc8f74b129196ed649ff6758114ef0",
"main.dart.js_61.part.js": "093ed795b9e0c91a43c5d5c62a55a49a",
"main.dart.js_62.part.js": "6a1a57572d8c69424fd09b680e0853bd",
"main.dart.js_63.part.js": "c462b48b62c60ed0b8cd2b1840610ddb",
"main.dart.js_64.part.js": "0996e8b30c7a5128f13b6ed8dbfe8681",
"main.dart.js_65.part.js": "fbb41cb8396ac36bcf2eee3e8de51603",
"main.dart.js_66.part.js": "ed82d777b8a1bb564a9498f01bcae08c",
"main.dart.js_67.part.js": "8b5b24d92040f144736cdd1b379ce0b8",
"main.dart.js_68.part.js": "1eed6e9cdc9c08af4fec36a1f0a05500",
"main.dart.js_69.part.js": "3d565272ba02d41ddf525272b43061b7",
"main.dart.js_7.part.js": "64c020e43f227e88bd988b18be739391",
"main.dart.js_70.part.js": "303b43b6e26d2575afdf911c55495fb8",
"main.dart.js_71.part.js": "7cbddfb62dd84043369dcc5e19e11efb",
"main.dart.js_73.part.js": "42da62a4a0eb21b47f005561fed368d2",
"main.dart.js_74.part.js": "fa975367014f2f482ede2854093d2fda",
"main.dart.js_75.part.js": "166d9b971fe1968cde38d4d566ce3550",
"main.dart.js_76.part.js": "fee14c4e16f8b86ec3d9bdfe1febaaf3",
"main.dart.js_77.part.js": "276dfefa20a977a510721f88a7229886",
"main.dart.js_78.part.js": "57dc2fd70bfb8216b2319eddb85b4dcf",
"main.dart.js_79.part.js": "ed52d4aea387bd0cf3913ddf16329e4b",
"main.dart.js_80.part.js": "faf0c980d96e33697f8d386d149ed686",
"main.dart.js_81.part.js": "e52c19aaf19ad42fe4e5c6b16c65047a",
"main.dart.js_82.part.js": "230a60e3357c0aa0748a65cf66d1afb3",
"main.dart.js_83.part.js": "b82b15d0462f736b17663a6c01b355ef",
"main.dart.js_84.part.js": "440e66e5c93323fd1213e461dbc4167e",
"main.dart.js_85.part.js": "d78544bb16c7dbe22a47421f701c206b",
"main.dart.js_86.part.js": "23c818e6484510b5fa0de98820daa14e",
"main.dart.js_87.part.js": "e0c36db0bb2192f14d9b258010b70cd0",
"main.dart.js_88.part.js": "4c87cb4fbabc289242fdb1191a3f32fd",
"main.dart.js_89.part.js": "f135f7e6f19b2cfff300ae0307146b25",
"main.dart.js_9.part.js": "0cdff131dde2fa11ab1974fee4ae57d0",
"main.dart.js_90.part.js": "314139c86a0e22e747fe9dbb0a6b2d02",
"main.dart.js_91.part.js": "e302ff260d23be80083dcc48613f5ebc",
"main.dart.js_92.part.js": "cd5ccee2f063cc4be17a226807d482b3",
"main.dart.js_93.part.js": "3d1aace80bbacaa17d469b44101917c9",
"main.dart.js_94.part.js": "28b7cab1974330c689305b8b804663af",
"main.dart.js_95.part.js": "bca37eb1ceafe3d0afc7332edd78bb81",
"main.dart.js_96.part.js": "faf33bbaad0c992b94f3c2ec3d672a3e",
"main.dart.js_97.part.js": "996e13e76a83396457b3ffa18c863f4c",
"main.dart.js_98.part.js": "9e195ab23f6e913ed57c2b6325d5a824",
"main.dart.js_99.part.js": "9af602ed0df0143e8b4e7432092f1aac",
"manifest.json": "d7e4500053251d1c78695d0f3171fbbb",
"version.json": "8a188b0a6525cc674e864d60f363070a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
