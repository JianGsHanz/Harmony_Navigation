import { CustomNavPage } from './CustomNavPage'
import { SysNavPage } from './SysNavPage'

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()

  @Builder
  pageMap(name: string) {
    if (name == 'SysNavigation') {
      NavDestination(){
        SysNavPage()
      }.hideTitleBar(true)
    } else if (name == 'CustomNavigation') {
      NavDestination(){
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
