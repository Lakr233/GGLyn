# 叮当同学 D1 热敏打印机 PoC

> ⚠️ 本代码仅供学习交流，请勿用于商业用途。

我的英语荒废太久，如果让我以真心撰写一大段话颇耗精力，所以还是拿中文写吧。

需求就是远程打小纸条，咕咕机开发者平台好像没了，自己造又太粗糙，所以决定整一个现成的看看他的协议。

![Preview](./Knowledge/Resources/Preview.png)

商品名 `叮当同学D1`，PDD 很多，大概都是 50 左右，200 dpi 也还算够用，所以就选他了。[给个链接](https://mobile.yangkeduo.com/goods2.html?goods_id=215919711645)

## 编译

使用 Xcode 进行编译，编译完成直接启动即可。监听端口和目标设备 mac 地址写死在代码中。请参考 `./Lyn/Config.swift` 。

```bash
$ xcode-select --install
$ xcodebuild -workspace ./Lyn.xcworkspace -scheme Lyn
```

## 协议描述

看代码去吧。在 `Instructor` 这个 enum 里头。macOS 有 PacketLogger 可以直接 dump 数据包。

## 致谢

- 感谢 [Lyn](https://github.com/LynMoe) 陪我折腾了一个星期，但就是这个家伙想的馊主意(°ㅂ° ╬)
- [瞎猫碰见死耗子但是他工作！](https://github.com/LynMoe/DingdangD1-poc)

## 免责声明

我们不对使用本程序造成的任何后果承担任何责任。下文中，我们列出了一些可能发生的内容，请悉知。

- 计算机死机，卡顿，重启
- 计算机芯片烧毁
- 花屏，白屏，黑屏，闪屏 
- 被老板看到你在摸鱼
- 被辞退
- 变得不幸
- 变成猫猫
- 地球爆炸
- 宇宙重启

## 使用许可

本程序及其源码和编译产物附属 [Unlicensed License](./LICENSE)，其生成展示的内容与相关图标和符号不做许可承诺，请参考他们的原始许可。

请不要售卖本程序。因为这样做会有人受伤。

---

Copyright © 2022 Lakr Aream & Lyn Chen. All Rights Reserved.