//系统路由表
//https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-navigation-navigation-V5#系统路由表
@Component
export struct SysNavPage {
  @State message: string = 'Hello Sys Nav';
  pageStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    // let  navigationInfo : NavigationInfo = this.queryNavigationInfo() as NavigationInfo
    // this.pageStack = navigationInfo.pathStack;
    //路由拦截 目前测试只能哪里跳转哪里拦截？
    this.pageStack.setInterception({
      willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === "string") {
          console.log("target page is navigation home page.");
          return;
        }
        // 将跳转到PageTwo的路由重定向到PageOne
        let target: NavDestinationContext = to as NavDestinationContext;
        if (target != null && target.pathInfo != undefined && target.pathInfo.name === 'SysRouter') {
          target.pathStack.pop(); //
          target.pathStack.pushPathByName('InterceptPage', null);
        }
      }
    })
  }

  build() {
    Navigation(this.pageStack) {
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
    .backgroundColor(Color.Orange)
  }
}