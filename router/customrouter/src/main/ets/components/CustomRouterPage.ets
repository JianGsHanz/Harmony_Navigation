import { AppRouter } from '@ohos/dynamicsrouter';

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
      }
      .width('100%')
    }
    .height('100%')
  }
}
