import { DynamicsRouter } from '@ohos/dynamicsrouter/Index';

//自定义路由表
//https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-navigation-navigation-V5#自定义路由表
@Component
export struct CustomNavPage {
  @State message: string = 'Hello Custom Nav';
  pageStack: NavPathStack = DynamicsRouter.navPathStack;

  build() {
    Navigation(this.pageStack) {
      RelativeContainer() {
        Text(this.message)
          .id('Custom')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .backgroundColor(Color.Green)


        Button("Jump")
          .width('50%')
          .margin({ top: 20 })
          .backgroundColor(Color.Gray)
          .alignRules({
            top: { anchor: 'Custom', align: VerticalAlign.Bottom },
            middle: { anchor: 'Custom', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            // this.pageStack.pushPathByName('CustomRouter', new Array("zyh888", "zyh1888"), (p) => {
            //   console.log("zyh...popinfo:" + p.result) //接收回传数据
            // }, false) //path name对应route_map下的name
            DynamicsRouter.pushUri('custom/CustomRouterPage')
          })
      }
      .height('100%')
      .width('100%')
    }.hideTitleBar(true)
    .navDestination(this.pageMap)
    .backgroundColor(Color.Pink)
  }

  @Builder
  pageMap(name: string, param: ESObject) {
      NavDestination() {
        // 根据模块名，获取WrappedBuilder对象，通过builder接口创建页面
        DynamicsRouter.getBuilder(name).builder(param);
      }
      // 登录页是半模态，需要背景透明，设置为DIALOG
      .mode(NavDestinationMode.STANDARD)
      .hideTitleBar(true)
  }
}