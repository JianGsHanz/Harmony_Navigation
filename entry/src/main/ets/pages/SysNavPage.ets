//系统路由表
//https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-navigation-navigation-V5#系统路由表
@Component
export struct SysNavPage {
  @State message: string = 'Hello Sys Nav';
  pageStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      RelativeContainer() {
        Text(this.message)
          .id('System')
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
            top: { anchor: 'System', align: VerticalAlign.Bottom },
            middle: { anchor: 'System', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.pageStack.pushPathByName('SysRouter', new Array("zyhfafafa", "zyhfafafa1"), (p) => {
              console.log("zyh...popinfo:" + p.result) //接收回传数据
            }, false) //path name对应route_map下的name
          })
      }
      .height('100%')
      .width('100%')
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .backgroundColor(Color.Orange)
  }
}

@Builder
export function SysNavPageBuilder(name: string, param: Object) {
  SysNavPage()
}