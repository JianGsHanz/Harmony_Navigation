import { DynamicsRouter, Interceptor, InterceptorExecute } from '@ohos/dynamicsrouter'
import { CustomNavPage } from './CustomNavPage'
import { SysNavPage } from './SysNavPage'

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    Interceptor.registerInterceptorPage(new CustomInterceptorExecute());
  }

  @Builder
  pageMap(name: string) {
    if (name == 'SysNavigation') {
      NavDestination() {
        SysNavPage()
      }.hideTitleBar(true)
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
