# 叮当同学D1热敏打印机PoC

> ⚠️ 本代码仅供学习交流，请勿用于商业用途。

需求就是远程打小纸条，咕咕机开发者平台好像没了，自己造又太粗糙，所以决定整一个现成的逆向。

![Preview](./Knowledge/Resources/Preview.png)

商品名`叮当同学D1`，PDD很多，大概都是50左右，200dpi也还算够用，所以就选他了。（给个链接 https://mobile.yangkeduo.com/goods2.html?goods_id=215919711645

## 编译

使用 Xcode 进行编译，编译完成直接启动即可。监听端口和目标设备 mac 地址写死在代码中。请参考 `./Lyn/Config.swift` 。

```bash
$ xcode-select --install
$ xcodebuild -workspace ./Lyn.xcworkspace -scheme Lyn
```

## 协议描述

看代码去吧。在 `Instructor` 这个 enum 里头。

关于逆向的相关笔记请参考 [./Knowledge/README.md](./Knowledge/README.md)

## 致谢

- 感谢 [Lyn](https://github.com/LynMoe) 陪我折腾了一个星期，但就是这个家伙想的馊主意(°ㅂ° ╬)
- [瞎猫碰见死耗子但是他工作！](https://github.com/LynMoe/DingdangD1-poc)


