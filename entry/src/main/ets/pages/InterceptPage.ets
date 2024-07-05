@Component
export struct InterceptPage {

  build() {
    NavDestination(){
      Text('Hello InterceptPage').width('100%').height('100%').textAlign(TextAlign.Center)
    }
  }
}

@Builder
export function InterceptPageBuilder(name: string, param: Object) {
  InterceptPage()
}