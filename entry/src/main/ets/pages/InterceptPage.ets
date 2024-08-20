@Component
export struct InterceptPage {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Text('Hello InterceptPage').width('100%').height('100%').textAlign(TextAlign.Center).onClick(() => {
        AppStorage.setOrCreate('login', true)
        this.pathStack.pop()
        this.pathStack.pushPathByName('SysRouter', new Array("zyhfafafa", "zyhfafafa1"))
      })
    }.onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function InterceptPageBuilder(name: string, param: Object) {
  InterceptPage()
}