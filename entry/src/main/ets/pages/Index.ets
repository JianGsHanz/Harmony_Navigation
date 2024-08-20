import { DynamicsRouter, Interceptor, InterceptorExecute } from '@ohos/dynamicsrouter'
import { CustomNavPage } from './CustomNavPage'
import { SysNavPage } from './SysNavPage'

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    Interceptor.registerInterceptorPage(new CustomInterceptorExecute());
    //原生拦截
    this.pathStack.setInterception({
      willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === "string") {
          console.log("target page is navigation home page.");
          return;
        }
        // 将跳转到PageTwo的路由重定向到PageOne
        let target: NavDestinationContext = to as NavDestinationContext;
        if (target != null && target.pathInfo != undefined && target.pathInfo.name === 'SysRouter'  && !AppStorage.get('login')) {
          target.pathStack.pop(); //
          target.pathStack.pushPathByName('InterceptPage', null);
        }
      }
    })
  }

  @Builder
  pageMap(name: string) {
    if (name == 'SysNavigation') {
        SysNavPage()
    } else if (name == 'CustomNavigation') {
      NavDestination() {
        CustomNavPage()
      }.hideTitleBar(true)
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Button('SysNavigation').width('100%').height(60).onClick(() => {
          this.pathStack.pushPath({ name: 'SysNavigation' })
          // this.pathStack.pushPathByName('SysNavPage', null)
        })
        Blank().height(20)
        Button('CustomNavigation').width('100%').height(60).onClick(() => {
          this.pathStack.pushPath({ name: 'CustomNavigation' })
        })
      }.justifyContent(FlexAlign.Center)
      .height('100%')
    }
    .navDestination(this.pageMap)
  }
}

export class CustomInterceptorExecute implements InterceptorExecute {
  executeFunction(appUri: string, param?: string | undefined): boolean {
    if (appUri !== undefined && appUri === "custom/CustomRouterPage") {
      if (!AppStorage.get("login")) {
        DynamicsRouter.pushUri("custom/InterceptorPage", param);
        return true
      }
    }
    return false
  }
}
