import { AppRouter } from '@ohos/dynamicsrouter';

@AppRouter({ name: "custom/CustomRouterPageB" })
@Component
export struct CustomRouterPageB {
  @State message: string = 'Hello CustomRouterPageB';

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
