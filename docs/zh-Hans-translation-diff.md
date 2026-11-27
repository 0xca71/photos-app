# 简体中文译文对照

已重译 295 条既有界面文案和 4 条系统权限说明，另为遗留英文及动态格式补入 285 条简体中文资源。下表按英文键列出已有译文的改动；原译保留原有标点和空格，未改动的条目不列出。

参考：[Gallery](https://github.com/0xca71/gallery) 的 `i18n/en.json` 和 `i18n/zh_Hans.json`。相同功能沿用“资源库”“归档”“好友共享”“实况照片”“裁剪”等术语。不同功能分别表述：资源库用“筛选”，照片编辑用“滤镜”；从相册“移除”不等于从资源库“删除”。

## 系统权限说明

`App/zh-Hans.lproj/InfoPlist.strings`

| 英文键 | 改动前 | 改动后 |
| --- | --- | --- |
| NSLocalNetworkUsageDescription | Photos 需要连接家庭网络中的 Cloud 服务器。 | Photos 需要通过家庭网络连接你的云端服务器。 |
| NSFaceIDUsageDescription | Face ID 用于解锁隐藏相册。 | 使用面容 ID 解锁隐藏相册。 |
| NSPhotoLibraryUsageDescription | Photos 会显示此 iPhone 上的照片和视频，并在开启备份后上传它们。 | Photos 会将此 iPhone 上的照片和视频与云端资源库中的内容一同显示。开启备份后，也会备份此 iPhone 上的照片和视频。 |
| NSPhotoLibraryAddUsageDescription | Photos 会在你选择保存时，将 Cloud 中的照片和视频保存到此 iPhone。 | 选择“保存到此 iPhone”时，Photos 会将云端资源库中的照片和视频保存到这台设备。 |

## 界面文案

`App/zh-Hans.lproj/Localizable.strings`

### 数字、符号及 A–C

| 英文键 | 改动前 | 改动后 |
| --- | --- | --- |
| 1 day | 1天 | 1 天 |
| 1 Item | 1 项目 | 1 个项目 |
| 1 item | 1 件 | 1 个项目 |
| 1 Video | 1 视频 | 1 个视频 |
| 1 Year Ago | 1年前 | 1 年前 |
| &lt; 1 day | &lt; 1 天 | 不足 1 天 |
| a | 一个 | a |
| A partner's whole library, shared with you. It only shows in your Library if you turn on Show in Library. Their photos stay in their account: you can view, share and save them, but only they can change or delete them. | 伙伴的整个图库会与你共享。打开“在图库中显示”后才会显示在你的图库中。照片仍保留在对方账户中，你可以查看、共享和保存，但只有对方可以修改或删除。 | 好友与你共享的是整个资源库。只有打开“在资源库中显示”，这些照片才会出现在你的资源库中。照片仍属于对方的账户。你可以查看、分享和保存，但只有对方能修改或删除。 |
| About Recently Deleted | 关于最近删除 | 关于“最近删除” |
| Account Picture | 账户图片 | 账户头像 |
| Add a Caption | 添加标题 | 添加描述 |
| Add Name | 添加姓名 | 添加人名 |
| Added | 已添加 | 添加时间 |
| Added to Favourites | 已添加至收藏夹 | 已添加到收藏 |
| Adjusted | 已调整 | 调整后 |
| AirDrop & Shared Albums Only | 仅限 AirDrop 和共享相册 | 仅限隔空投送和共享相册 |
| Albums load from your Cloud server. | 相册从 Cloud 服务器加载。 | 相册从云端服务器加载。 |
| Albums you share, or that others share with you, appear here. | 你共享的相册或他人与你共享的相册会显示在这里。 | 这里会显示你共享给他人的相册，以及他人与你共享的相册。 |
| Allow Featured Photos and Memories to automatically appear on this device. | 允许精选照片和回忆自动出现在此设备上。 | 在此设备上自动显示精选照片和回忆。 |
| Allow recent holiday events for your home country or region to automatically appear on this device. | 允许您所在国家或地区最近的节日活动自动显示在此设备上。 | 在此设备上自动显示你所在国家或地区近日的节日活动。 |
| App Lock protects this app on this iPhone. It is stored locally and is unrelated to your Cloud server. | 应用锁只保护此 iPhone 上的应用，密码保存在本机，与 Cloud 服务器无关。 | 应用锁仅保护此 iPhone 上的应用。密码保存在本机，与云端服务器无关。 |
| Archive | 存档 | 归档 |
| Archived | 已存档 | 已归档 |
| Area | 面积 | 日志类别 |
| Aspect Ratio | 纵横比 | 宽高比 |
| Aspect Ratio Grid | 纵横比网格 | 按原始宽高比显示网格 |
| Audio Mix | 音频混合 | 混音 |
| Auto | 汽车 | 自动 |
| Auto-Play Motion | 自动播放动作 | 自动播放视频和实况照片 |
| Automatically adjust the display to show the complete dynamic range (HDR) of photos. | 自动调整显示以显示照片的完整动态范围 (HDR)。 | 自动调整显示效果，呈现 HDR 照片的完整动态范围。 |
| Away | 离开 | 远程网络 |
| Back to Library | 返回图库 | 返回资源库 |
| Back Up From | 备份来源 | 备份范围 |
| Brilliance | 辉煌 | 鲜明度 |
| By default everything on this iPhone is backed up. Choose albums to back up only those, or mark albums not to back up (they win if a photo is in both). | 默认情况下，此 iPhone 上的所有内容都会备份。选择相册仅备份那些相册，或标记相册不备份（如果照片都包含在其中，则它们获胜）。 | 默认备份此 iPhone 上的所有照片和视频。你也可以只备份选定的相册，或排除不想备份的相册。如果一张照片同时出现在两类相册中，则不会备份。 |
| Cached thumbnails and the synced library index for this account are removed from this iPhone. Nothing is deleted on the server. | 该帐户的缓存缩略图和同步库索引将从该 iPhone 中删除。服务器上没有删除任何内容。 | 此 iPhone 将清除该账户的缩略图缓存和已同步的资源库索引。服务器上的内容不会被删除。 |
| Captions are saved in Cloud. Back this up first. | 字幕保存在云端。首先支持这一点。 | 描述保存在云端，请先备份此项目。 |
| Captured | 被捕获 | 拍摄时间 |
| Captured by Me | 被我捕获 | 我拍摄的 |
| Change Layout | 改变布局 | 更改布局 |
| Choose Automatic for the best format for the destination or Current to prevent file format conversions. Photos and videos may convert to JPEG, PNG and H.264 formats if you choose Most Compatible. | 选择“自动”作为目标的最佳格式，或选择“当前”以防止文件格式转换。如果您选择“最兼容”，照片和视频可能会转换为 JPEG、PNG 和 H.264 格式。 | 选择“自动”会使用最适合接收方的格式；选择“当前”则保留现有格式。选择“兼容性最佳”时，照片可能会转换为 JPEG 或 PNG，视频可能会转换为 H.264。 |
| Choose Your PIN | 选择您的 PIN 码 | 设置 PIN 码 |
| CINEMATIC | 电影级 | 电影效果 |
| Clear Downloaded Originals | 清除下载的原件 | 清除已下载的原始文件 |
| Clear Saved Logs | 清除保存的日志 | 清除已保存的日志 |
| Clear Thumbnails and Previews | 清晰的缩略图和预览 | 清除缩略图和预览 |
| CLOUD | 云 | 云端 |
| Cloud | 云 | 云端 |
| Cloud account | Cloud 账户 | 云端账户 |
| Cloud accounts | Cloud 账户 | 云端账户 |
| Cloud must be reachable to check that each item is backed up. | 必须可访问云以检查每个项目是否已备份。 | 需要连接云端，才能逐项确认是否已备份。 |
| CLOUD NOT REACHABLE | 云无法访问 | 无法连接云端 |
| Cloud Not Reachable | 云无法访问 | 无法连接云端 |
| Cloud PIN | Cloud PIN | 云端 PIN 码 |
| Cloud Server Settings | Cloud 服务器设置 | 云端服务器设置 |
| Cloud Version | Cloud 版本 | 云端服务器版本 |
| CLOUD · AWAY (TAILSCALE) | 云 · 远（尾鳞） | 云端 · 远程网络（Tailscale） |
| CLOUD · HOME NETWORK | 云·家庭网络 | 云端 · 家庭网络 |
| Collapse All | 全部折叠 | 全部收起 |
| Compact | 紧凑型 | 紧凑 |
| Confirm PIN | 确认密码 | 确认 PIN 码 |
| Connecting to Cloud… | 正在连接到云... | 正在连接云端… |
| Contrast | 对比 | 对比度 |
| Couldn’t Load Library | 无法加载库 | 无法加载资源库 |
| Creating | 创造 | 正在生成 |
| Crop | 作物 | 裁剪 |
| Current | 当前版本 | 当前 |

### D–H

| 英文键 | 改动前 | 改动后 |
| --- | --- | --- |
| Date adjusted | 调整日期 | 已调整日期 |
| Definition | 定义 | 清晰度 |
| Delete 1 Item? | 删除 1 项？ | 删除 1 个项目？ |
| Delete All | 全部删除 | 永久删除全部项目 |
| Dismiss | 解雇 | 关闭 |
| Don't Back Up | 不要备份 | 不备份 |
| Done Selecting | 选择完成 | 完成选择 |
| Download Originals from iCloud | 从 iCloud 下载原件 | 从 iCloud 下载原始文件 |
| Downloaded Originals | 下载原件 | 已下载的原始文件 |
| Drag to change the order of Collections. Sections that aren't ticked are hidden. | 拖动以更改集合的顺序。未勾选的部分将被隐藏。 | 拖动可调整集合顺序，未勾选的集合会隐藏。 |
| DRAMATIC | 戏剧性的 | 反差色 |
| DRAMATIC COOL | 戏剧性的酷 | 反差冷色 |
| DRAMATIC WARM | 戏剧性的温暖 | 反差暖色 |
| Duplicate | 重复 | 创建副本 |
| Duplicated | 重复的 | 已创建副本 |
| Duplicating… | 正在复制… | 正在创建副本… |
| Each upload is prepared as a file first. At most this much space is used at once; each file is deleted as soon as its upload finishes. | 每次上传都首先准备为文件。最多一次使用这么多空间；每个文件上传完成后都会被删除。 | 上传前会先生成临时文件。临时文件占用的空间不会超过此上限，每个文件上传完毕后就会清除。 |
| Email | 电子邮件 | 邮箱 |
| Enter Your Cloud PIN Once | 输入您的云 PIN 一次 | 输入云端 PIN 码（仅需一次） |
| Errors Only | 仅错误 | 仅显示错误 |
| Export Unmodified Originals | 导出未修改的原件 | 导出未修改的原始文件 |
| Favourites | 收藏 | 收藏夹 |
| Featured photos will appear here when more photos and videos are added to the library, or synced with Cloud. | 当更多照片和视频添加到库或与云同步时，精选照片将显示在此处。 | 向资源库添加更多照片和视频，或从云端同步后，这里就会显示精选照片。 |
| Fetches the thumbnail of every photo and video in Cloud, so the whole Library can be browsed without a connection. Thumbnails, once on this iPhone, stay. Runs on Wi-Fi, and in the background while charging. | 获取云端每张照片和视频的缩略图，因此无需连接即可浏览整个图库。缩略图一旦出现在这款 iPhone 上，就会保留下来。通过 Wi-Fi 运行，并在充电时在后台运行。 | 下载云端所有照片和视频的缩略图，方便离线浏览整个资源库。下载的缩略图会保留在此 iPhone 上。下载通过 Wi-Fi 进行，充电时可在后台继续。 |
| Filter | 过滤器 | 筛选 |
| Filter and Sort | 过滤和排序 | 筛选与排序 |
| Filter: | 过滤器： | 筛选： |
| Filters | 过滤器 | 滤镜 |
| Full | 满 | 完全访问 |
| Full-quality files from Cloud, kept after zooming in, sharing, Live Photos and video downloads. The oldest are removed first when the limit is reached. | 来自云端的全质量文件，在放大、共享、实时照片和视频下载后保留。当达到限制时，最旧的将首先被删除。 | 放大查看、分享、播放实况照片或下载视频时，从云端获取的原始文件会缓存在本机。达到容量上限时，会先清除最早缓存的文件。 |
| Grid thumbnails from Cloud stay on this iPhone once loaded. The larger previews the viewer shows are kept up to the limit, the oldest removed first. Photos on this iPhone don't use this space. | 加载后，来自云端的网格缩略图将保留在此 iPhone 上。查看器显示的较大预览将保持在限制范围内，首先删除最旧的预览。此 iPhone 上的照片不使用此空间。 | 浏览网格时，从云端加载的缩略图会保留在此 iPhone 上。打开照片时显示的较大预览图也会缓存，达到容量上限时会先清除最早缓存的预览图。此 iPhone 上已有的照片不占用这部分空间。 |
| Hidden | 隐藏 | 已隐藏 |
| Hidden Album Is Locked | 隐藏相册被锁定 | 隐藏相册已锁定 |
| Hidden is stored in your Cloud’s Locked Folder. Face ID unlocks it here; the Cloud web app asks for this PIN instead. | 隐藏存储在您的云的锁定文件夹中。 Face ID在这里解锁；云 Web 应用程序会要求输入此 PIN 码。 | 隐藏相册中的项目存放在云端的“锁定文件夹”中。在此 iPhone 上可以用面容 ID 解锁；在云端网页版则需要输入这个 PIN 码。 |
| Hidden uses your Cloud’s Locked Folder, and your Cloud account already has a PIN for it. Enter it once here; after that, Face ID unlocks Hidden on this iPhone. | 隐藏使用您的云的锁定文件夹，并且您的云帐户已经有一个 PIN。在这里输入一次；之后，Face ID 会解锁此 iPhone 上的隐藏功能。 | 隐藏相册使用云端的“锁定文件夹”。你的云端账户已经为它设置了 PIN 码。在这里输入一次，以后就可以在此 iPhone 上用面容 ID 解锁隐藏相册。 |
| Hidden uses your Cloud’s Locked Folder, which needs a 6-digit PIN. You can use the same digits as your iPhone passcode — iOS never shares the passcode itself with apps. You enter it once; after that, Face ID unlocks Hidden here. The Cloud web app asks for this PIN. | 隐藏使用云的锁定文件夹，该文件夹需要 6 位 PIN 码。您可以使用与 iPhone 密码相同的数字 - iOS 绝不会与应用程序共享密码本身。您输入一次；之后，Face ID 解锁此处隐藏。云 Web 应用程序要求输入此 PIN 码。 | 隐藏相册使用云端的“锁定文件夹”，需要设置 6 位 PIN 码。可以使用与 iPhone 解锁密码相同的数字；iOS 不会将你的解锁密码透露给任何应用。只需在这里设置一次，以后就可以用面容 ID 解锁隐藏相册。在云端网页版仍需输入这个 PIN 码。 |
| Hide 1 Item? | 隐藏 1 件物品？ | 隐藏 1 个项目？ |
| Highlights | 亮点 | 高光 |
| Home | 首页 | 家庭网络 |

### I–P

| 英文键 | 改动前 | 改动后 |
| --- | --- | --- |
| IN-FRAME | 框架内 | 画面内 |
| Include | 包括 | 包含内容 |
| Keep Favourites | 保留收藏夹 | 保留已收藏的项目 |
| Keep Offline | 保持离线可用 | 离线保存 |
| Kept on This iPhone | 保留在这部 iPhone 上 | 已保存在此 iPhone 上 |
| Keywords are Cloud tags. Adding them to photos comes in a later version. | 关键字是云标签。将它们添加到照片中会出现在更高版本中。 | 关键词就是云端的标签。后续版本将支持为照片添加关键词。 |
| Library | 图库 | 资源库 |
| Library Sync | 图库同步 | 资源库同步 |
| Library Unavailable | 图库不可用 | 资源库不可用 |
| Limit | 限制 | 容量上限 |
| Limit for Previews | 预览限制 | 预览图缓存上限 |
| Limited | 有限公司 | 有限访问 |
| LIVE | 现场直播 | 实况 |
| Live | 直播 | 实况 |
| Live Photo, off | 实时照片，关闭 | 实况照片，已关闭 |
| Live Photos | 现场照片 | 实况照片 |
| Loading Albums… | 正在加载相册... | 正在加载相册… |
| Loading People… | 正在加载人员... | 正在加载人物… |
| Loading Your Library | 加载你的库 | 正在加载资源库 |
| Location | 地点 | 位置 |
| Location adjusted | 地点调整 | 已调整位置 |
| Location Included | 包含地点 | 已包含位置信息 |
| Logs show what the app did, and can be shared as a text file. Resync from Scratch downloads the library list from Cloud again. Nothing is deleted, and cached thumbnails are kept. | 日志显示应用程序执行的操作，并且可以作为文本文件共享。从头开始重新同步会再次从云端下载库列表。不会删除任何内容，并保留缓存的缩略图。 | 日志记录了应用执行的操作，可以用文本文件分享。选择“从头同步”会从云端重新下载资源库列表，不会删除任何内容，也不会清除已缓存的缩略图。 |
| Loop Videos | 循环视频 | 循环播放视频 |
| Memories will appear here when more photos and videos are added to the library, or synced with Cloud. | 当更多照片和视频添加到库中或与云同步时，回忆将出现在此处。 | 向资源库添加更多照片和视频，或从云端同步后，这里就会显示回忆。 |
| MONO | 单声道 | 单色 |
| Most Compatible | 最佳兼容性 | 兼容性最佳 |
| Moved to Recently Deleted | 移至最近删除 | 已移至“最近删除” |
| Name | 名称 | 姓名 |
| New PIN | 新密码 | 新 PIN 码 |
| No albums on this iPhone. | 此 iPhone 上没有专辑。 | 此 iPhone 上没有相册。 |
| No Featured Photos Available | 没有可用的精选照片 | 暂无精选照片 |
| No Items | 没有商品 | 没有项目 |
| No items match, or none are confirmed in Cloud yet. | 没有匹配的项目，或者尚未在云端确认任何项目。 | 没有符合条件的项目，或尚无项目经核实已备份到云端。 |
| No Keywords | 没有关键字 | 没有关键词 |
| No Location | 没有位置 | 不含位置信息 |
| No Memories Available | 没有可用的记忆 | 暂无回忆 |
| No one else uses this Cloud server yet. | 目前还没有其他人使用此云服务器。 | 目前还没有其他人使用这台云端服务器。 |
| No one shares their library with you. | 没有人与你共享图库。 | 还没有人与你共享资源库。 |
| No One to Add | 无人可添加 | 没有可添加的用户 |
| No People Available | 无人可用 | 暂无人物 |
| No Results | 没有结果 | 未找到匹配项 |
| No Trips Available | 没有可用的行程 | 暂无行程 |
| NOIR | 黑色 | 黑白 |
| Not enough free space on this iPhone to prepare the upload. | 此 iPhone 上没有足够的可用空间来准备上传。 | 此 iPhone 上的可用空间不足，无法准备要上传的文件。 |
| Nothing matches the current filter. | 没有任何内容与当前过滤器匹配。 | 没有符合当前筛选条件的项目。 |
| Nothing shared yet. Photos appear here after the next sync. | 尚未分享任何内容。下次同步后照片将显示在此处。 | 暂无共享内容。下次同步后，这里就会显示共享的照片。 |
| Nothing to Remove | 没有什么可删除的 | 没有可移除的项目 |
| OK | 好 | 确定 |
| On | 开 | 开启 |
| On This iPhone | 在这款 iPhone 上 | 在此 iPhone 上 |
| Only on Wi-Fi | 仅在 Wi-Fi 上 | 仅在连接 Wi-Fi 时 |
| Only the album's owner or the people who added these items can remove them. | 只有相册的所有者或添加这些项目的人才能删除它们。 | 相册所有者可以从相册中移除这些项目；其他人只能移除自己添加的项目。 |
| Only the album's owner or the person who added this item can remove it. | 只有相册的所有者或添加此项目的人才能将其删除。 | 只有相册所有者或添加此项目的人才能将它从相册中移除。 |
| ORIGINAL | 原创 | 原片 |
| Original | 原片 | 原始 |
| Original-quality files will include edit history and metadata like location, depth information and captions. The recipient can view the current version and modify any edits. | 原始质量的文件将包括编辑历史记录和元数据，例如位置、深度信息和标题。收件人可以查看当前版本并修改任何编辑。 | 原始画质的文件会包含编辑记录，以及位置、深度信息和描述等元数据。接收者可以查看当前版本，也可以调整已有的编辑。 |
| Panoramas | 全景图 | 全景照片 |
| Partner Sharing | 合作伙伴分享 | 好友共享 |
| Partner sharing shares your whole library with someone on your Cloud server, and shows the libraries shared with you. To share only some photos, use shared albums. | 合作伙伴共享与您的云服务器上的某人共享您的整个库，并显示与您共享的库。要仅共享部分照片，请使用共享相册。 | 通过好友共享，你可以与同一云端服务器上的其他人共享整个资源库，也可以查看他人与你共享的资源库。如果只想共享部分照片，请使用共享相册。 |
| Partner sharing shares your whole library: everyone listed sees all your photos and videos, except those in Hidden, Archive and Recently Deleted. To share only some photos, use a shared album instead (··· › Add To › Shared Album). | 合作伙伴共享共享您的整个图库：列出的每个人都可以看到您的所有照片和视频，隐藏、存档和最近删除的照片和视频除外。要仅共享部分照片，请使用共享相册（··· › 添加到 › 共享相册）。 | 开启好友共享后，列表中的每个人都能看到资源库中的所有照片和视频，但“已隐藏”“归档”和“最近删除”中的项目除外。如果只想共享部分照片，请使用共享相册（••• › 添加到 › 共享相册）。 |
| People & Pets suggestions were reset. | 人物和宠物建议已重置。 | 人物与宠物建议已重置。 |
| People appear here when face recognition is turned on for your Cloud server. | 当您的云服务器开启人脸识别时，人员会出现在此处。 | 在云端服务器上开启人脸识别后，这里就会显示识别出的人物。 |
| People will appear here when face recognition is turned on for your Cloud server. | 当您的云服务器开启人脸识别时，人员将出现在此处。 | 在云端服务器上开启人脸识别后，这里就会显示识别出的人物。 |
| Photo copied | 照片已复印 | 已复制照片 |
| Photo duplicated | 照片重复 | 已创建照片副本 |
| Photos Access | 照片访问 | 照片访问权限 |
| Photos and videos you hide appear here. Hide them from the ••• menu in a photo. | 您隐藏的照片和视频会显示在此处。将它们隐藏在照片的••• 菜单中。 | 这里会显示已隐藏的照片和视频。要隐藏某个项目，请打开它并在 ••• 菜单中选择“隐藏”。 |
| Photos in these albums always stay on this iPhone. Messaging apps' albums are kept unless you change it. | 这些相册中的照片始终保留在这台 iPhone 上。消息应用程序的相册将保留，除非您更改它。 | 这些相册中的照片会一直保留在此 iPhone 上。默认也会保留聊天应用的相册，你可以取消勾选。 |
| Photos on your Cloud server appear here. | 您的云服务器上的照片将显示在此处。 | 云端服务器上的照片会显示在这里。 |
| Play | 玩 | 播放 |
| PORTRAIT | 肖像 | 人像 |
| Portrait | 肖像 | 人像 |
| Portrait Off | 肖像关闭 | 关闭人像效果 |
| Portrait, off | 肖像，关闭 | 人像效果已关闭 |
| Preparing original… | 准备原版… | 正在准备原始文件… |
| Preparing… | 正在准备…… | 正在准备… |
| Previews | 预览 | 预览图 |

### Q–Z

| 英文键 | 改动前 | 改动后 |
| --- | --- | --- |
| Recents | 最近的内容 | 最近搜索 |
| Recovered 1 item | 回收 1 件物品 | 已恢复 1 个项目 |
| Remove 1 Item? | 删除 1 件商品？ | 移除 1 个项目？ |
| Remove from Album keeps them in your Library. Delete moves them to Recently Deleted, from Cloud and from this iPhone where they are on it. | 从相册中删除将它们保留在您的图书馆中。 “删除”会将它们从云端以及它们所在的 iPhone 移至“最近删除”。 | 选择“从相册移除”只会将项目移出此相册，项目仍在资源库中。选择“删除”会将项目移至云端的“最近删除”；如果此 iPhone 上也有该项目，本机副本也会移至“最近删除”。 |
| Remove from Favourites | 从收藏夹中删除 | 取消收藏 |
| Remove from This iPhone | 从此 iPhone 中删除 | 从此 iPhone 移除 |
| Remove it from this album only, or delete it everywhere? | 仅将其从该相册中删除，还是将其全部删除？ | 只从这个相册中移除，还是从所有位置删除并移至“最近删除”？ |
| Removed 1 Item | 删除 1 件商品 | 已移除 1 个项目 |
| Removed from Album | 已从相册中删除 | 已从相册移除 |
| Removes photos and videos from this iPhone that are safely backed up to Cloud. They stay in your Library and open from Cloud. Only items in your own Cloud library and not in its Recently Deleted are removed, and each one is checked with the server first. | 从此 iPhone 中删除安全备份到云端的照片和视频。它们保留在您的图书馆中并从云端打开。仅删除您自己的云库中的项目，而不是最近删除的项目，并且首先会通过服务器检查每一项。 | 从此 iPhone 上移除已安全备份到云端的照片和视频。移除后，这些项目仍保留在资源库中，可从云端打开。移除前会逐项向服务器核实：项目必须在你自己的云端资源库中，且不在“最近删除”中。 |
| Require Password | 要求输入密码 | 需要密码 |
| Reset People & Pets Suggestions | 重置人物和宠物建议 | 重置人物与宠物建议 |
| Reset Suggested Memories | 重置建议的记忆 | 重置回忆建议 |
| Reset to Default Order | 重置为默认顺序 | 恢复默认顺序 |
| Resync from Scratch | 从头重新同步 | 从头同步 |
| Revert to Original | 恢复至原始状态 | 还原为原始版本 |
| Saved to iPhone | 保存到 iPhone | 已保存到 iPhone |
| Saving to iPhone… | 保存到 iPhone... | 正在保存到 iPhone… |
| Screenshots | 截图 | 截屏 |
| Search your library… | 搜索你的图库… | 搜索资源库… |
| Searching… | 正在寻找... | 正在搜索… |
| Server addresses, accounts, sync, storage and diagnostics for your Cloud server. | 云服务器的服务器地址、帐户、同步、存储和诊断。 | 管理云端服务器的地址、账户、同步和存储设置，并查看诊断信息。 |
| Server Not Reachable | 服务器无法访问 | 无法连接服务器 |
| Set Up Hidden | 设置隐藏 | 设置隐藏相册 |
| Share | 共享 | 分享 |
| Share My Whole Library… | 分享我的整个图书馆...... | 共享我的整个资源库… |
| Share Whole Library | 共享整个库 | 共享整个资源库 |
| Share With | 分享给 | 共享对象 |
| Shared albums count too. Videos can be large: check the album sizes before choosing. | 共享相册也很重要。视频可能很大：选择之前请检查相册大小。 | 也可以选择共享相册。视频可能占用较多空间，选择前请先查看相册大小。 |
| Shared with You | 与您分享 | 与你共享 |
| Sharing | 分享 | 共享 |
| Sharpness | 清晰度 | 锐度 |
| Show Cloud PIN | 显示云 PIN | 显示云端 PIN 码 |
| Show Featured Content | 显示特色内容 | 显示精选内容 |
| Show in Library | 在图库中显示 | 在资源库中显示 |
| Show Ratings Controls | 显示收视率控制 | 显示星级评分控件 |
| Show Status on Tiles | 在图块上显示状态 | 在缩略图上显示存储位置 |
| Show your Cloud PIN | 显示您的云 PIN 码 | 查看云端 PIN 码 |
| Sign In Again to Back Up | 再次登录以备份 | 重新登录以继续备份 |
| SILVERTONE | 银音 | 银色调 |
| Some of these are in a library someone shares with you, so only they can change them. | 其中一些位于某人与您共享的库中，因此只有他们可以更改它们。 | 部分项目来自他人与你共享的资源库，只有所有者才能修改这些项目。 |
| Some of these are only on this iPhone. Back them up to Cloud first. | 其中一些仅适用于这款 iPhone。首先将它们备份到云端。 | 部分项目仅存储在此 iPhone 上。请先将这些项目备份到云端。 |
| Square | 广场 | 方形 |
| Start Slideshow | 开始幻灯片放映 | 播放幻灯片 |
| Stop Sharing | 停止分享 | 停止共享 |
| STUDIO | 工作室 | 录音室 |
| Suggested memories were reset. | 建议的记忆已重置。 | 回忆建议已重置。 |
| Sync Albums creates a Cloud album for each album you back up, with the same photos. | 同步相册会为您备份的每个相册创建一个云相册，其中包含相同的照片。 | 开启“同步相册”后，每个备份的相册都会在云端有一个对应的相册，里面包含相同的照片。 |
| Sync with your Cloud server right away, even in Low Power Mode or on mobile data. When off, syncing waits for Wi-Fi and enough battery. | 立即与您的云服务器同步，即使在低功耗模式或使用移动数据时也是如此。关闭时，同步会等待 Wi-Fi 和足够的电池。 | 开启后，即使处于低电量模式或使用蜂窝数据，也会立即与云端服务器同步。关闭后，只有在已连接 Wi-Fi 且电量充足时才会同步。 |
| Syncing with Cloud Paused | 与云同步已暂停 | 云端同步已暂停 |
| Syncing with Cloud… | 与云同步... | 正在与云端同步… |
| Taken On or Before | 拍摄日期或之前 | 拍摄日期不晚于 |
| Telephoto Camera | 长焦相机 | 长焦摄像头 |
| That PIN didn’t work. Check it in the Cloud web app under Account Settings › PIN Code. | 该 PIN 码无效。在云网络应用程序中的帐户设置 › PIN 码下进行检查。 | PIN 码不正确。请前往云端网页版的“账户设置” › “PIN 码”核对。 |
| The app stopped while preparing this file three times, so it was skipped. Try Again retries it. | 应用程序在准备此文件时停止了 3 次，因此被跳过。再试一次重试。 | 应用在准备此文件时已三次意外退出，因此跳过了此文件。点按“立即重试”可再次尝试备份。 |
| The app stopped while preparing this file. | 应用程序在准备此文件时停止。 | 应用在准备此文件时意外退出。 |
| The edit couldn't be saved. | 无法保存编辑。 | 无法保存所做的更改。 |
| The full-quality originals of these photos and videos stay on this iPhone, so they open, play and share without a connection. Items already on this iPhone aren't downloaded again. Downloads run on Wi-Fi. | 这些照片和视频的全品质原件保留在这款 iPhone 上，因此无需连接即可打开、播放和共享。此 iPhone 上已有的项目不会再次下载。下载通过 Wi-Fi 运行。 | 这些照片和视频的原始文件会保留在此 iPhone 上，无需联网即可打开、播放和分享。下载仅通过 Wi-Fi 进行，此 iPhone 上已有的项目不会重复下载。 |
| The home address is used when it answers within 1.5 seconds; otherwise the away address (Tailscale). | 1.5秒内应答即使用家庭地址；否则为离开地址 (Tailscale)。 | 如果家庭网络地址在 1.5 秒内响应，就使用该地址；否则使用远程网络地址（Tailscale）。 |
| The original is in iCloud and will be downloaded on Wi-Fi. | 原件位于 iCloud 中，可通过 Wi-Fi 下载。 | 原始文件存储在 iCloud 中，连接 Wi-Fi 后会自动下载。 |
| The original is only in iCloud; downloading from iCloud is off. | 原版仅在 iCloud 中；从 iCloud 下载已关闭。 | 原始文件仅存储在 iCloud 中，且“从 iCloud 下载原始文件”已关闭。 |
| The PIN must be exactly 6 digits. | PIN 码必须正好是 6 位数字。 | PIN 码必须为 6 位数字。 |
| The spatial scene couldn't be drawn on this iPhone. | 空间场景无法在这款 iPhone 上绘制。 | 此 iPhone 无法渲染这个空间场景。 |
| The upload was interrupted. | 上传被中断。 | 上传已中断。 |
| These are in a library someone shares with you, so only they can change them. | 这些位于某人与您共享的库中，因此只有他们可以更改它们。 | 这些项目来自他人与你共享的资源库，只有所有者才能修改。 |
| These items will be hidden, but can be found in the Hidden album in Collections › Utilities. | 这些项目将被隐藏，但可以在收藏夹 › 实用程序的隐藏相册中找到。 | 这些项目将被隐藏。你仍可前往“集合” › “实用工具” › “已隐藏”查看。 |
| They'll see your whole library: all your photos and videos, except those in Hidden, Archive and Recently Deleted. | 他们将看到您的整个图库：您的所有照片和视频，隐藏、存档和最近删除的照片和视频除外。 | 对方将能看到你资源库中的所有照片和视频，但“已隐藏”“归档”和“最近删除”中的项目除外。 |
| They're still in your Library from Cloud. To free the space straight away, empty Recently Deleted in the iPhone's photo library. | 它们仍然位于您的云端图书馆中。要立即释放空间，请清空 iPhone 照片库中的“最近删除”。 | 你仍可在资源库中查看保留在云端的这些项目。要立即释放空间，请清空 iPhone 系统“照片”中的“最近删除”相册。 |
| This build doesn't include the depth model. | 此构建不包括深度模型。 | 此版本未包含深度估算模型。 |
| This iPhone | 这款iPhone | 此 iPhone |
| This item is no longer on the iPhone. | 该项目不再出现在 iPhone 上。 | 该项目已不在此 iPhone 上。 |
| This photo will be deleted from Cloud. This action can't be undone. | 这张照片将从云端删除。此操作无法撤消。 | 这张照片将从云端永久删除，无法恢复。 |
| This video will be deleted from Cloud. This action can't be undone. | 该视频将从云端删除。此操作无法撤消。 | 这个视频将从云端永久删除，无法恢复。 |
| Time Scale | 时间尺度 | 时间线分组方式 |
| Trips will appear here when more photos and videos are added to the library, or synced with Cloud. | 当更多照片和视频添加到库中或与云同步时，旅行将显示在此处。 | 将更多照片和视频添加到资源库或从云端同步后，即可在这里查看行程。 |
| Troubleshooting | 故障排查 | 故障排除 |
| Try a place, a month or year, “videos”, a person, or what's in the photo (“dog on a beach”). | 尝试一个地方、一个月或一年、“视频”、一个人或照片中的内容（“海滩上的狗”）。 | 试试搜索地点、月份、年份、人物或照片内容（如“海滩上的狗”），也可以输入“视频”。 |
| Try Again | 再试一次 | 重试 |
| Try Again Now | 现在再试一次 | 立即重试 |
| Turn On in Settings | 在设置中打开 | 前往“设置”开启照片访问权限 |
| Ultra Wide Camera | 超广角相机 | 超广角摄像头 |
| Unhidden | 不隐藏 | 已取消隐藏 |
| Unlock Recently Deleted | 解锁最近删除 | 解锁“最近删除”相册 |
| Unlock the Hidden album to unhide. | 解锁隐藏相册以取消隐藏。 | 请先解锁隐藏相册，再取消隐藏。 |
| Upload: no answer from the server. | 上传：服务器没有应答。 | 上传失败：服务器未响应。 |
| Use Face ID to view this album. | 使用 Face ID 查看此相册。 | 使用面容 ID 查看此相册。 |
| Use Mobile Data | 使用移动数据 | 使用蜂窝数据 |
| Use My Contact Photo | 使用我的联系照片 | 使用我的名片照片 |
| Used | 二手 | 已用空间 |
| Utilities | 公用事业 | 实用工具 |
| Vibrance | 活力 | 自然饱和度 |
| Video copied | 视频已复制 | 已复制视频 |
| Video duplicated | 视频重复 | 已创建视频副本 |
| Vignette | 小插图 | 暗角 |
| VIVID | 生动 | 鲜明 |
| VIVID COOL | 生动酷炫 | 鲜明冷色 |
| VIVID WARM | 生动温暖 | 鲜明暖色 |
| Waiting for Power | 等待电源 | 等待接入电源 |
| Warmth | 温暖 | 色温 |
| What the app does is logged here as you use it. | 当您使用该应用程序时，该应用程序的功能会记录在此处。 | 这里会记录应用在使用期间的运行情况。 |
| When viewing a photo, zoom slightly to fit the screen size. | 查看照片时，请稍微缩放以适合屏幕尺寸。 | 查看照片时会自动稍微放大照片，使其填满屏幕。 |
| Wide Camera | 广角相机 | 广角摄像头 |
| With Optimise iPhone Storage, some originals are only in iCloud. They're downloaded just to be uploaded, then the copy is deleted. Turn this off to skip them. | 通过优化 iPhone 存储，某些原件仅存储在 iCloud 中。下载它们只是为了上传，然后副本就会被删除。关闭此选项以跳过它们。 | 开启“优化 iPhone 储存空间”后，部分原始文件仅存储在 iCloud 中。备份时会临时下载这些原始文件，上传到云端后再删除本地临时副本。关闭“从 iCloud 下载原始文件”即可跳过这些项目。 |
| You can choose to reset previously blocked Memories or People and Pets in order for them to appear in new Memories and Featured Photos. | 您可以选择重置以前阻止的回忆或人物和宠物，以便它们出现在新的回忆和精选照片中。 | 重置后，之前屏蔽的回忆、人物和宠物可以重新出现在新的回忆和精选照片中。 |
| Your Cloud PIN has changed. Enter the current PIN once. | 您的云 PIN 码已更改。输入一次当前的 PIN 码。 | 云端 PIN 码已更改。请在此输入一次当前的 PIN 码。 |
| Your Cloud server can't be reached. New or changed photos will sync when it's back. | 无法访问您的云服务器。新的或更改的照片将在返回时同步。 | 无法连接云端服务器。连接恢复后会同步新增或有更改的照片。 |
| Your library is kept in sync with your Cloud server. | 你的图库会与 Cloud 服务器保持同步。 | 你的资源库会与云端服务器保持同步。 |
| Your Library Is Shared With | 你的图库已共享给 | 你的资源库已共享给以下用户 |
| Your photos will no longer appear on their devices. | 您的照片将不再出现在他们的设备上。 | 你的照片将不再显示在对方的设备上。 |
| Your server no longer accepts this sign-in. Sign in again below to resume syncing. | 您的服务器不再接受此登录。在下面再次登录以恢复同步。 | 当前登录已失效。请在下方重新登录以恢复同步。 |
| Zoom to Fill Screen | 缩放至填满屏幕 | 缩放以填满屏幕 |

## 原先显示英文的文案

以下 285 个条目补入简体中文资源表。左列为原先显示的英文或其格式模板：`%@`、`%lld` 等在界面上会替换成数量、相册名、时间或图标。`%lld GB` 的单位在两种语言中相同，保留国际符号。用户命名的相册、服务器自定义的登录按钮、服务器返回的原始消息不作为可翻译的固定文案。

| 原英文文案／格式模板 | 补译后 |
| --- | --- |
|  (%@) | （%@） |
| %@ %@: FAILED – %@ | %1$@ %2$@：连接失败（%3$@） |
| %@ %@: OK | %1$@ %2$@：连接成功 |
| %@ (Live Photo video) | %@（实况照片的视频部分） |
| %@ couldn't be removed: only the album's owner or the person who added an item can remove it. | 有 %@ 个项目无法从相册移除。只有相册所有者或添加该项目的人才能将其移除。 |
| %@ is Locked | “%@”已锁定 |
| %@ items | %@ 个项目 |
| %@ Items | %@ 个项目 |
| %@ Items Not Backed Up to Cloud | 还有 %@ 个项目尚未备份到云端 |
| %@ items received | 已接收 %@ 个项目 |
| %@ kept because Cloud couldn't confirm them yet | 已保留 %@ 个项目，云端暂时无法确认它们是否已备份。 |
| %@ kept in your chosen albums | 已保留所选相册中的 %@ 个项目。 |
| %@ Live Photos halfway (video uploaded) | %@ 张实况照片仅完成部分备份（视频部分已上传） |
| %@ mm | %@ 毫米 |
| %@ MP | %@ 百万像素 |
| %@ of %@ | %@ / %@ |
| %@ of %@ backed up · %@ remaining | 已备份 %1$@ 项，共 %2$@ 项 · 剩余 %3$@ 项 |
| %@ Photos | %@ 张照片 |
| %@ Photos, %@ Videos | %1$@ 张照片、%2$@ 个视频 |
| %@ Results | %@ 个结果 |
| %@ s | %@ 秒 |
| %@ Videos | %@ 个视频 |
| %@: %@ | %1$@：%2$@ |
| %@: not configured | %@：未设置 |
| %@: the server's response could not be read (%@). | %1$@：无法读取服务器响应（%2$@）。 |
| %lld Albums | %lld 个相册 |
| %lld days | %lld 天 |
| %lld GB | %lld GB |
| %lld Items | %lld 个项目 |
| %lld Items Selected | 已选择 %lld 个项目 |
| %lld Photos | %lld 张照片 |
| %lld Photos Selected | 已选择 %lld 张照片 |
| %lld Videos | %lld 个视频 |
| %lld Videos Selected | 已选择 %lld 个视频 |
| %lld Years Ago | %lld 年前 |
| : %@ | ：%@ |
| Add to album | 添加到相册 |
| Add to Favourites | 添加到收藏 |
| add to Favourites | 添加到收藏 |
| add to the album | 添加到相册 |
| Added to “%@” | 已添加到“%@” |
| All %@ kept | 已离线保存全部 %@ 个项目 |
| All %@ on this iPhone | 全部 %@ 个项目均已保存在此 iPhone 上 |
| All Photos, %lld Excluded | 所有照片（已排除 %lld 个相册） |
| Allow Photos access (Settings › This iPhone) to back up. | 请在“设置”›“此 iPhone”中允许访问照片，以便备份。 |
| Also removes them from iCloud and your other devices. | 这些项目也会从 iCloud 和你的其他设备中移除。 |
| An image from the server could not be decoded. | 无法解码服务器返回的图像。 |
| answered, but not like a Cloud server. | 该地址有响应，但不是云端服务器应有的响应。 |
| archive | 归档 |
| AUTO | 自动 |
| AUTO ON | 自动调整已开启 |
| Away (Tailscale) | 远程网络（Tailscale） |
| Backing Up %@ Items | 正在备份 %@ 个项目 |
| Backing Up %@ Items to Cloud | 正在将 %@ 个项目备份到云端 |
| cancelled. | 已取消。 |
| Change | 更改 |
| Change the date | 更改日期 |
| change the date | 更改日期 |
| Change the location | 更改位置 |
| change the location | 更改位置 |
| change the shared library | 更改共享资源库 |
| check for existing uploads | 检查是否已上传 |
| check the Hidden album | 检查隐藏相册 |
| Checking with Cloud… | 正在向云端核实… |
| Clear the saved logs? | 清除已保存的日志？ |
| Collapse %@ | 收起“%@” |
| Connect to Cloud to choose albums. | 连接云端后即可选择相册。 |
| Converting the photo to JPEG failed. | 无法将照片转换为 JPEG 格式。 |
| Could not reach the server. | 无法连接服务器。 |
| Couldn't Finish | 无法完成操作 |
| Couldn't Save | 无法保存 |
| Create | 创建 |
| create a shared link | 创建共享链接 |
| create the album | 创建相册 |
| Database | 数据库 |
| delete | 删除 |
| Delete %@ | 永久删除%@ |
| Delete %@ %@ | 永久删除所选%2$@（%1$@） |
| Delete %@ Items | 删除 %@ 个项目 |
| Delete %lld Items | 删除 %lld 个项目 |
| Delete %lld Items? | 删除 %lld 个项目？ |
| delete the shared link | 删除共享链接 |
| Deleted items stay here for %lld days, then they're removed from Cloud for good. | 删除的项目会在这里保留 %lld 天，之后将从云端永久删除。 |
| Discard Changes? | 放弃更改？ |
| Downloading the original failed: %@ | 无法下载原始文件：%@ |
| Duplicating the photo failed: %@ | 无法创建照片副本：%@ |
| Edit Pinned | 编辑固定项目 |
| Error | 错误 |
| Error: %@ | 错误：%@ |
| Expand %@ | 展开“%@” |
| Fault | 严重故障 |
| finish single sign-on | 完成单点登录 |
| Hidden album | 隐藏相册 |
| Hidden album setup | 设置隐藏相册 |
| hide | 隐藏 |
| Hide %@ Items | 隐藏 %@ 个项目 |
| Hide %@ Items? | 隐藏 %@ 个项目？ |
| Hide %lld Items | 隐藏 %lld 个项目 |
| Hide %lld Items? | 隐藏 %lld 个项目？ |
| Home (local network) | 家庭网络（局域网） |
| Horizontal Perspective | 水平透视 |
| iCloud Photos is on for this iPhone: removing items here also removes them from iCloud and your other devices. They're still in Cloud. | 此 iPhone 已开启“iCloud 照片”。从这里移除项目也会将其从 iCloud 和你的其他设备中移除。云端服务器上的项目会保留。 |
| If iCloud Photos is on, removing items here also removes them from iCloud and your other devices. They're still in Cloud. | 如果已开启“iCloud 照片”，从这里移除项目也会将其从 iCloud 和你的其他设备中移除。云端服务器上的项目会保留。 |
| iOS blocked plain HTTP to this address (App Transport Security). | iOS 的应用传输安全策略阻止了通过明文 HTTP 连接此地址。 |
| iOS keeps them in its Recently Deleted album for 30 days. | iOS 会在“最近删除”相册中保留这些项目 30 天。 |
| Keep Albums Offline | 离线保存相册 |
| Keychain error %@: %@ | 钥匙串错误 %1$@：%2$@ |
| Last upload %@ | 上次上传：%@ |
| Libraries others share with you appear here. | 他人与你共享的资源库会显示在这里。 |
| load albums | 加载相册 |
| load memories | 加载回忆 |
| load people | 加载人物 |
| load server statistics | 加载服务器统计信息 |
| load the people in this photo | 加载这张照片中的人物 |
| load the people on this server | 加载此服务器上的用户 |
| Load your account | 加载账户 |
| load your account | 加载账户 |
| Loading an image failed: %@ | 无法加载图像：%@ |
| Local | 本地地址 |
| Local (%@): %@ | 本地地址（%1$@）：%2$@ |
| Lock Hidden | 锁定隐藏相册 |
| lock the Hidden album | 锁定隐藏相册 |
| Media | 媒体 |
| Months | 月 |
| Move to Trash | 移至“最近删除” |
| move to Trash | 移至“最近删除” |
| Name person | 为人物命名 |
| name this person | 为此人物命名 |
| network error %@ (%@). | 网络错误 %1$@（%2$@）。 |
| Networking | 网络 |
| New album | 新建相册 |
| No albums yet. | 暂无相册。 |
| no network connection (or Local Network access is turned off for Photos in Settings › Privacy). | 没有网络连接，或“照片”未获准访问本地网络。请在“设置”的隐私选项中检查“本地网络”权限。 |
| No server address is configured. | 尚未设置服务器地址。 |
| Not allowed (403) for %@%@. | 无权执行此操作（403）：%1$@%2$@。 |
| Not connected to the server. | 未连接到服务器。 |
| Not connected to the server. Try again when it’s reachable. | 未连接到服务器。请在服务器恢复连接后重试。 |
| Not found (404) for %@%@. | %1$@时未找到所需资源（404）%2$@。 |
| Not reachable | 无法连接 |
| Not signed in. | 尚未登录。 |
| On your Cloud server, %@ | 云端服务器上的文件：%@ |
| Opens the location in Maps or Google Maps | 在地图或 Google 地图中打开此位置 |
| People on this server | 此服务器上的用户 |
| Photos and videos on this iPhone are uploaded to Cloud in their original quality. Nothing is uploaded twice. Uploads continue in the background. | 此 iPhone 上的照片和视频会以原始画质上传到云端，不会重复上传。上传可在后台继续。 |
| Photos and videos show the days remaining before deletion. After that time, items will be permanently deleted. This may take up to %lld days. | 每张照片和每个视频上都会显示距离永久删除的剩余天数。期限届满后，项目将被永久删除。整个过程最多可能需要 %lld 天。 |
| Photos on this iPhone and in Cloud are shown once. Tiles show %@ only on this iPhone, %@ only in Cloud, %@ in both. | 同时存储在此 iPhone 和云端的照片只显示一次。缩略图上的 %@ 表示仅在本机，%@ 表示仅在云端，%@ 表示两处都有。 |
| Pin %@ | 固定“%@” |
| ping | 检查服务器连接 |
| Preparing original… %lld%% | 正在准备原始文件… %lld%% |
| Profile picture | 头像 |
| read the server settings | 读取服务器设置 |
| read the sign-in options | 读取登录选项 |
| Recover %@ | 恢复%@ |
| Recover %@ %@ | 恢复所选%2$@（%1$@） |
| Recovered %@ items | 已恢复 %@ 个项目 |
| Remote | 远程地址 |
| Remote (%@): %@ | 远程地址（%1$@）：%2$@ |
| Remove %@ Items? | 移除 %@ 个项目？ |
| Remove from album | 从相册移除 |
| remove from Favourites | 取消收藏 |
| remove from the album | 从相册移除 |
| Removed %@ from Album | 已从相册移除 %@ 个项目 |
| Removed %@ Items | 已移除 %@ 个项目 |
| Removing the location from the photo failed. | 无法移除照片的位置信息。 |
| Rename | 重命名 |
| Restore from Trash | 从“最近删除”恢复 |
| restore from Trash | 从“最近删除”恢复 |
| Review | 核对项目 |
| Review Items to Remove | 查看要移除的项目 |
| Save | 保存 |
| Save the caption | 保存描述 |
| save the caption | 保存描述 |
| search | 搜索 |
| Search for a place | 搜索地点 |
| Server settings | 服务器设置 |
| Server statistics | 服务器统计信息 |
| server version | 获取服务器版本 |
| set the profile picture | 设置头像 |
| set up the Hidden album | 设置隐藏相册 |
| Share library | 共享资源库 |
| Share My Whole Library | 共享我的整个资源库 |
| share your library | 共享资源库 |
| Share your whole library with %@? | 与 %@ 共享你的整个资源库？ |
| Shared library | 共享资源库 |
| Shared link | 共享链接 |
| Show Selected (%lld) | 查看所选项目（%lld） |
| Shows why syncing is paused | 查看同步暂停的原因 |
| Sign in | 登录 |
| sign in | 登录 |
| Sign In with Single Sign-On | 使用单点登录 |
| Sign out | 退出登录 |
| sign out | 退出登录 |
| Sign out of %@? | 退出账户 %@？ |
| Single sign-on | 单点登录 |
| Single sign-on answered for a different sign-in attempt. Try again. | 单点登录返回的响应与此次登录不匹配。请重试。 |
| Single sign-on came back without a sign-in code. | 单点登录未返回授权码。 |
| Single sign-on came back without an answer from the identity provider. | 单点登录未收到身份提供商的响应。 |
| Single sign-on: the server's answer could not be read. | 单点登录：无法读取服务器响应。 |
| Smart search | 智能搜索 |
| Stack | 堆叠 |
| stack versions | 堆叠不同版本 |
| start single sign-on | 开始单点登录 |
| Stop sharing | 停止共享 |
| Stop sharing library | 停止共享资源库 |
| Stop Sharing with %@ | 停止与 %@ 共享 |
| stop sharing your library | 停止共享资源库 |
| Stop sharing your library with %@? | 停止与 %@ 共享你的资源库？ |
| Straighten | 校正倾斜 |
| sync | 同步 |
| Sync acknowledgement | 确认同步进度 |
| sync acknowledgement | 确认同步进度 |
| Sync reset | 重置同步 |
| sync reset | 重置同步 |
| Sync: a line from the server could not be read (%@). | 同步失败：无法读取服务器返回的一行数据（%@）。 |
| Sync: the server sent an unexpected response. | 同步失败：服务器返回了意外响应。 |
| Synced with Cloud %@ | 上次云端同步：%@ |
| Syncing %@ | 正在同步 %@ 个项目 |
| Talking to the server… | 正在与服务器通信… |
| That place has no coordinates. | 未找到该地点的坐标。 |
| The Cloud PIN was not accepted. | 云端服务器未接受此 PIN 码。 |
| The Cloud server runs version %@, older than %@ which this app was built for. Update the server. | 云端服务器当前版本为 %1$@，低于此应用所需的 %2$@ 版。请更新服务器。 |
| The Cloud server runs version %@. This app was built for version %lld, so some features may not work until the app is updated. | 云端服务器当前版本为 %1$@。此应用是为 %2$lld 版设计的，更新应用前部分功能可能无法使用。 |
| the connection dropped. | 连接已中断。 |
| The depth of this photo couldn't be worked out. %@ | 无法估算这张照片中景物的深度。%@ |
| The identity provider refused the sign-in%@. | 身份提供商拒绝了此次登录%@。 |
| The item is no longer in the photo library. | 此项目已不在照片资源库中。 |
| The library on this phone could not be opened: %@ | 无法打开此 iPhone 上的资源库：%@ |
| The original is only in iCloud. | 原始文件仅存储在 iCloud 中。 |
| The photo couldn’t be converted for sharing. | 无法将照片转换为可分享的格式。 |
| The photo couldn’t be prepared for sharing. | 无法准备要分享的照片。 |
| The photo couldn’t be read to duplicate it. | 无法读取这张照片，因此无法创建副本。 |
| The picture is shown on this iPhone, but couldn't be saved to Cloud: %@ | 头像已在此 iPhone 上显示，但未能保存到云端：%@ |
| the server address could not be found. | 找不到服务器地址。 |
| the server did not answer in time. | 服务器未及时响应。 |
| The server had an error (%lld) during %@%@. | %2$@时服务器出错（%1$lld）%3$@。 |
| The server has no preview for this item yet (404). It may still be processing. | 服务器尚未提供此项目的预览（404），可能仍在处理中。 |
| The server no longer accepts this sign-in. Open Settings to sign in again. | 当前登录已失效。请打开“设置”重新登录。 |
| the server refused the connection. Is the Cloud server running? | 服务器拒绝了连接。请检查云端服务器是否正在运行。 |
| The server refused the upload (%lld)%@. | 服务器拒绝了上传（%1$lld）%2$@。 |
| The server rejected the sign-in (401)%@. Sign in again. | 服务器拒绝了此次登录（401）%@。请重新登录。 |
| The server rejected the sign-in (401). Sign in again. | 服务器拒绝了此次登录（401）。请重新登录。 |
| The server rejected the sign-in while loading an image (401). | 加载图像时，服务器拒绝了此次登录（401）。 |
| The server returned %lld for the original. | 下载原始文件时，服务器返回了状态码 %lld。 |
| The server returned %lld while loading an image. | 加载图像时，服务器返回了状态码 %lld。 |
| The server sent an unexpected response for the original. | 下载原始文件时，服务器返回了意外响应。 |
| The server's single sign-on page address could not be used. Check the OAuth settings on the server. | 无法使用服务器提供的单点登录页面地址。请检查服务器的 OAuth 设置。 |
| The sign-in for %@ is missing from the Keychain. Sign in again. | 在钥匙串中找不到 %@ 的登录凭据。请重新登录。 |
| The video couldn’t be prepared for sharing. | 无法准备要分享的视频。 |
| The video couldn’t be read to duplicate it. | 无法读取这个视频，因此无法创建副本。 |
| There's no one else on your Cloud server yet. | 你的云端服务器上还没有其他用户。 |
| These %@ will be deleted from Cloud. This action can't be undone. | 所选%@将从云端永久删除，无法恢复。 |
| These items will be deleted from Cloud, and from this iPhone where they are on it. You can recover them from Recently Deleted for %lld days. | 这些项目将从云端删除。如果此 iPhone 上也有副本，本机副本也会删除。你可以在 %lld 天内从“最近删除”恢复这些项目。 |
| This %@ will be deleted from Cloud. This action can't be undone. | 所选%@将从云端永久删除，无法恢复。 |
| This %@ will be deleted from Cloud. You can recover it from Recently Deleted for %lld days. | 此%@将从云端删除。你可以在 %lld 天内从“最近删除”中恢复。 |
| This %@ will be deleted from this iPhone and from Cloud. You can recover it from Recently Deleted for %lld days. | 此%@将从此 iPhone 和云端删除。你可以在 %lld 天内从“最近删除”中恢复。 |
| This %@ will be deleted from this iPhone. It stays in the iPhone's Recently Deleted for 30 days. | 此%@将从此 iPhone 删除，并在此 iPhone 的“最近删除”中保留 30 天。 |
| This %@ will be hidden, but can be found in the Hidden album in Collections › Utilities. | 隐藏后，你仍可在“集合”的“实用工具”下打开“已隐藏”相册，找到此%@。 |
| This item has no file that can be backed up. | 此项目没有可备份的文件。 |
| This item is no longer in the library. | 此项目已不在资源库中。 |
| This item isn't in your Cloud library. | 此项目不在你的云端资源库中。 |
| Ui | 界面 |
| Unarchive | 取消归档 |
| unarchive | 取消归档 |
| Unexpected response %lld for %@%@. | %2$@时服务器返回了意外响应（%1$lld）%3$@。 |
| Unexpected response loading an image. | 加载图像时，服务器返回了意外响应。 |
| unhide | 取消隐藏 |
| Unknown | 未知 |
| unknown error | 未知错误 |
| Unlock Hidden | 解锁隐藏相册 |
| unlock the Hidden album | 解锁隐藏相册 |
| Unpin %@ | 取消固定“%@” |
| Upload | 上传 |
| upload | 上传 |
| Upload check | 检查是否已上传 |
| Upload: the server's response could not be read. | 上传失败：无法读取服务器响应。 |
| Use New Album in the menu to create one. | 在菜单中选择“新建相册”即可创建相册。 |
| Use New Shared Album in the menu to create one. | 在菜单中选择“新建共享相册”即可创建共享相册。 |
| Version check | 检查版本 |
| Vertical Perspective | 垂直透视 |
| Videos in %@ | %@ 年的视频 |
| Waiting for the server | 正在等待服务器响应 |
| Wrong email or password. | 邮箱或密码错误。 |
| Years | 年 |
| Your library is already shared with everyone on your Cloud server. | 你的资源库已与云端服务器上的所有用户共享。 |
| “%@” couldn’t be prepared for sharing: %@ | 无法准备要分享的“%@”：%@ |

## 调用端修复

- 登录页和设置页不再直接显示英文回退值。服务器自定义的单点登录按钮仍显示管理员设置的名称；连接成功或失败的颜色由实际检测结果决定，而不是通过查找英文 “OK” 判断。
- “收藏夹”和“2026 年的视频”等中文搜索建议与实际筛选条件一致，原有英文搜索词仍可用。用户输入的地点名称不会当作翻译键处理。
- 备份、查看器、分享及服务错误分别翻译提示正文，保留相册名、文件名、数量、地址以及服务器返回的具体原因。
