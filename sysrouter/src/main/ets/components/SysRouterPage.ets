@Component
export struct SysRouterPage {
  @State message: string = 'Hello SysRouterPage';
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Brown)

        Button("返回").margin({ top: 50 }).backgroundColor(Color.Gray).onClick(() => {
          this.pathStack.pop('zyh result') //回传数据可为null
        })
      }
      .width('100%')
      .height('100%')

    }.hideTitleBar(true)
    //https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-router-to-navigation-V5#%E9%A1%B5%E9%9D%A2%E7%BB%93%E6%9E%84
    .onReady((context: NavDestinationContext) => { //子页面想要做路由需要拿到Navigation持有的页面栈对象NavPathStack,可通过这种方式获取
      this.pathStack = context.pathStack
      // let data = context.getConfigInRouteMap()?.data //route_map下data数据
      // console.log("zyh..."+JSON.stringify(data))

      let data1 = this.pathStack.getParamByName('SysRouter')[0] as Array<string> //获取pushPathByName传值
      console.log("zyh..."+data1[0])
    })
  }
}

@Builder
export function SysRouterBuilder() {
  SysRouterPage()
}
