import { AppRouter, DynamicsRouter } from '@ohos/dynamicsrouter';

@AppRouter({ name: "custom/InterceptorPage" })
@Component
export struct InterceptorPage {
  @State message: string = 'Hello InterceptorPage';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // 初始化登录状态
            AppStorage.setOrCreate("login", true);
            DynamicsRouter.popAppRouter()
            DynamicsRouter.pushUri("custom/CustomRouterPage");
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
