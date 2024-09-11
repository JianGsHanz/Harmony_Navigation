import { AppRouter, DynamicsRouter } from '@ohos/dynamicsrouter';

@AppRouter({ name: "custom/CustomRouterPage" })
@Component
export struct CustomRouterPage {
  @State message: string = 'Hello CustomRouterPage';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(()=>{
            DynamicsRouter.pushUri('custom/CustomRouterPageB') //跨模块跳转不需相互依赖
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
