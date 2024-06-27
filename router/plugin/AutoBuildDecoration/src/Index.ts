import * as path from "path";
import { readFileSync, constants } from "node:fs";
import ts, { ExpressionStatement, Identifier, PropertyName, StringLiteral } from "typescript";
import Handlebars from "handlebars";
import { accessSync, existsSync, mkdirSync, readdirSync, writeFileSync } from "fs";
import { HvigorNode, HvigorPlugin } from "@ohos/hvigor";
import { json } from "stream/consumers";

// 配置文件，在hvigor中配置
export class PluginConfig {
  // 模块名
  moduleName?: string;
  // 模块路径
  modulePath?: string;
  // 装饰器名称
  annotation?: string;
  // 扫描的文件路径
  scanFiles?: string[];
  // 生成代码模板
  builderTpl?: string;
}

class NodeInfo {
  value?: any;
}

// 装饰器信息
class DecorationInfo {
  // 方法信息
  methods: MethodInfo[] = [];
  // 组件ID
  bindId: string='';
}

class MethodInfo {
  name: string;
  value: string;
}

const PLUGIN_ID = "etsGeneratorPlugin";

// hvigor中配置的插件方法
export function etsDecorationPlugin(pluginConfig: PluginConfig): HvigorPlugin {
  pluginConfig.annotation = 'CallbackObserver';
  pluginConfig.builderTpl = 'methodBuilder.tpl'
  return {
    pluginId: PLUGIN_ID,
    apply(node: HvigorNode) {
      console.log(`Exec ${PLUGIN_ID}...${__dirname}`);
      console.log(`node:${node.getNodeName},nodePath:${node.getNodePath()}`);
      // 获取模块名
      pluginConfig.moduleName = node.getNodeName();
      // 获取模块路径
      pluginConfig.modulePath = node.getNodePath();
      pluginExec(pluginConfig);
    }
  }
}

// 解析插件开始执行
function pluginExec(config: PluginConfig) {
  console.log("plugin exec...");
  // 遍历需要扫描的文件列表
  config.scanFiles.forEach((file) => {
    // 文件绝对路径
    let sourcePath = `${config.modulePath}/${file}`;
    if (!sourcePath.endsWith('.ets')) {
      sourcePath = sourcePath + '.ets';
    }
    const analyzer = new EtsAnalyzer(config, sourcePath);
    // 开始解析文件
    analyzer.start();
    // 如果解析的文件中存在装饰器，则将结果保存到列表中
    if (analyzer.routerAnnotationExisted) {
      // 如果有需要创建的方法
      if (analyzer.methodArray.length > 0) {
        // 读取整个文件
        let fileContent = readFileSync(sourcePath, { encoding: "utf8" });
        // 添加了装饰器的自定义组件的结构体位置
        let firstHalfText = fileContent.slice(0, analyzer.positionOfBlockEnd - 1);
        // 文件中的剩余部分
        let secondHalfText = fileContent.slice(analyzer.positionOfBlockEnd - 1, fileContent.length)
        // 装饰器中如果设置了bindId，则添加listener变量，并在aboutToAppear中调用监听方法
        // aboutToAppear方法是否已存在 
        if (analyzer.aboutToAppearExist) {
          // 如果已经存在aboutToAppear，则根据aboutToAppear方法的位置拆分结构体，并将需要生成的代码添加到对应的位置
          let beforeAboutToAppear = firstHalfText.slice(0, analyzer.positionOfAboutToAppear);
          let inAboutToAppear =
            firstHalfText.slice(analyzer.positionOfAboutToAppear, analyzer.positionOfAboutToAppearEnd-2);
          let afterAboutToAppear = firstHalfText.slice(analyzer.positionOfAboutToAppearEnd-2, firstHalfText.length);
          // 遍历所有装饰器，根据装饰器中配置的方法名，添加listener初始化和调用代码
          analyzer.decorationInfos.forEach((decorationInfo: DecorationInfo) => {
            if (decorationInfo.bindId !== '' && !firstHalfText.includes(`${decorationInfo.bindId}Listener`)) {
              beforeAboutToAppear = beforeAboutToAppear +
                `\n  ${decorationInfo.bindId}Listener: inspector.ComponentObserver = inspector.createComponentObserver('${decorationInfo.bindId}')`;
              decorationInfo.methods.forEach((methodInfo: MethodInfo) => {
                if (methodInfo.name === 'onDraw') {
                  inAboutToAppear =
                    inAboutToAppear + `\nthis.${decorationInfo.bindId}Listener.on('draw',this.${methodInfo.value});\n`
                }
                if (methodInfo.name === 'onLayout') {
                  inAboutToAppear =
                    inAboutToAppear + `this.${decorationInfo.bindId}Listener.on('layout',this.${methodInfo.value});\n`
                }
              });
              
            }
          })
          firstHalfText=beforeAboutToAppear+inAboutToAppear+afterAboutToAppear;
        } else {
          // 如果不存在aboutToAppear方法，则创建aboutToAppear方法，并添加调用代码
          analyzer.decorationInfos.forEach((decorationInfo: DecorationInfo) => {
            if (decorationInfo.bindId !== ''&& !firstHalfText.includes(`${decorationInfo.bindId}Listener`)) {
              firstHalfText = firstHalfText +
                `  ${decorationInfo.bindId}Listener: inspector.ComponentObserver = inspector.createComponentObserver('${decorationInfo.bindId}');\n  aboutToAppear(): void {\n`;
                
              decorationInfo.methods.forEach((methodInfo: MethodInfo) => {
                if (methodInfo.name === 'onDraw') {
                  firstHalfText =
                  firstHalfText + `    this.${decorationInfo.bindId}Listener.on('draw',this.${methodInfo.value});\n`
                }
                if (methodInfo.name === 'onLayout') {
                  firstHalfText =
                  firstHalfText + `    this.${decorationInfo.bindId}Listener.on('layout',this.${methodInfo.value});\n`
                }
              });
            
              firstHalfText=firstHalfText+'\n  }\n';
            }
          })
          firstHalfText=firstHalfText+'\n';
        }
        // 根据模板创建装饰器中配置的方法
        const builderPath = path.resolve(__dirname, `../${config.builderTpl}`);
        const tpl = readFileSync(builderPath, { encoding: "utf8" });
        const template = Handlebars.compile(tpl);
        analyzer.methodArray.forEach((name: string) => {
          const output = template({
            functionName: name
          });
          firstHalfText = firstHalfText + "\n" + output;
        })
        fileContent = firstHalfText + '\n' + secondHalfText;
        // 将生成的代码写入文件中
        writeFileSync(sourcePath, fileContent, { encoding: "utf8" })
      }
    }
  })

}

// ets文件解析
export class EtsAnalyzer {
  // 文件路径
  sourcePath: string;
  // hvigor配置
  pluginConfig: PluginConfig;
  // 关键字位置
  keywordPos: number = 0;
  // 是否存在装饰器
  routerAnnotationExisted: boolean = false;
  // 被装饰器装饰的struct位置
  positionOfStruct: number = -1;
  // 被装饰器装饰的自定义组件@Component的位置
  positionOfComponent: number = -1;
  // 被装饰器装饰的自定义组件的位置（从“{”开始）
  positionOfBlock: number = -1;
  // 被装饰器装饰的自定义组件的结束位置（到“}”结束）
  positionOfBlockEnd: number = -1;
  // 被装饰器装饰的自定义组件中aboutToAppear方法的位置（从“{”开始）
  positionOfAboutToAppear: number = -1;
  // 被装饰器装饰的自定义组件中aboutToAppear方法的结束位置（到“}”结束）
  positionOfAboutToAppearEnd: number = -1;
  // 当前的未知Node
  currentMissDeclarationNode: ts.Node | undefined = undefined;
  // 装饰器的信息
  decorationInfos: DecorationInfo[] = [];
  // aboutToAppear方法是否存在
  aboutToAppearExist: boolean = false;
  // 组件ID
  bindId: string = '';
  // 需要创建的方法列表
  methodArray: string[] = [];

  constructor(pluginConfig: PluginConfig, sourcePath: string) {
    this.pluginConfig = pluginConfig;
    this.sourcePath = sourcePath;
  }

  start() {
    // 读取文件
    const sourceCode = readFileSync(this.sourcePath, "utf-8");
    // 解析文件，生成节点树信息
    const sourceFile = ts.createSourceFile(this.sourcePath, sourceCode, ts.ScriptTarget.ES2021, false);
    // 遍历节点信息
    ts.forEachChild(sourceFile, (node: ts.Node) => {
      // 解析节点
      console.log(JSON.stringify(node));
      this.resolveNode(node);
    });
  }

  resolveNode(node: ts.Node) {
    switch (node.kind) {
    // 未知的声明节点
      case ts.SyntaxKind.MissingDeclaration:
        this.resolveMissDeclaration(node);
        break;
    // 装饰器节点
      case ts.SyntaxKind.Decorator:
        this.resolveDecoration(node);
        break;
        // 获取节点的位置
      case ts.SyntaxKind.ExpressionStatement:
        this.resolveExpressionStatement(node);
        break;
        // 解析装饰器装饰的自定义组件
      case ts.SyntaxKind.Block:
        this.resolveBlock(node);
        break;
    }
  }

  // 未知节点，则继续解析子节点
  resolveMissDeclaration(node: ts.Node) {
    this.currentMissDeclarationNode = node;
    node.forEachChild((cnode) => {
      this.resolveNode(cnode);
    })
  }

  // 解析装饰器
  resolveDecoration(node: ts.Node) {
    // 转换为装饰器节点类型
    let decorator = node as ts.Decorator;
    // 判断表达式是否是函数调用
    if (decorator.expression.kind === ts.SyntaxKind.CallExpression) {
      const callExpression = decorator.expression as ts.CallExpression;
      // 表达式类型是否是标识符
      if (callExpression.expression.kind === ts.SyntaxKind.Identifier) {
        const identifier = callExpression.expression as ts.Identifier;
        // 标识符是否是自定义的装饰器
        if (identifier.text === this.pluginConfig.annotation) {
          this.routerAnnotationExisted = true;
          // 记录装饰器装饰的struct的位置
          if (this.currentMissDeclarationNode !== undefined) {
            this.positionOfStruct = this.currentMissDeclarationNode.end;
            this.currentMissDeclarationNode = undefined;
          }
          const arg = callExpression.arguments[0];
          // 调用方法的第一个参数是否是表达式
          if (arg.kind === ts.SyntaxKind.ObjectLiteralExpression) {
            const properties = (arg as ts.ObjectLiteralExpression).properties;
            // 遍历装饰器中的所有参数
            let decoratorInfo: DecorationInfo = new DecorationInfo();
            properties.forEach((propertie) => {
              if (propertie.kind === ts.SyntaxKind.PropertyAssignment) {
                if ((propertie.name as ts.StringLiteral).text !== 'bindId') {
                  // 如果参数名不是“bindId”，则放入需要创建的方法列表中
                  let methodInfo: MethodInfo = new MethodInfo();
                  methodInfo.name = (propertie.name as ts.StringLiteral).text;
                  methodInfo.value = (propertie.initializer as ts.StringLiteral).text;
                  decoratorInfo.methods.push(methodInfo);
                  this.methodArray.push((propertie.initializer as ts.StringLiteral).text);
                } else {
                  // 如果参数名是“buildId”，则设置到对应的变量中
                  decoratorInfo.bindId = (propertie.initializer as ts.StringLiteral).text;
                }
              }
            })
            this.decorationInfos.push(decoratorInfo);
          }
        }
      }
    }
  }

  // 获取固定节点的位置
  resolveExpressionStatement(node: ts.Node) {
    if (node.pos === this.positionOfStruct) {
      this.positionOfComponent = node.end;
    }
    if (node.pos === this.positionOfComponent) {
      this.positionOfBlock = node.end;
    }
    if(node.pos===this.positionOfAboutToAppear){
      this.positionOfAboutToAppearEnd=node.end;
    }
  }
  // 解析装饰器装饰的自定义组件（从“{”到“}”）
  resolveBlock(node: ts.Node) {
    if (node.pos === this.positionOfBlock) {
      let method: ts.MethodDeclaration = undefined;
      const block = node as ts.Block;
      const statements = block.statements;
      // 自定义组件中已经存在的方法列表
      const methodNameArray: string[] = [];
      statements.forEach((statement: ts.Statement) => {
        if (statement.kind === ts.SyntaxKind.ExpressionStatement) {
          const expression = (statement as ts.ExpressionStatement).expression;
          if (expression.kind === ts.SyntaxKind.CallExpression) {
            const callExpression = expression as ts.CallExpression;
            if (callExpression.expression.kind === ts.SyntaxKind.Identifier) {
              const identifier = callExpression.expression as Identifier;
              methodNameArray.push(identifier.escapedText.toString());
              // 查找是否已经存在aboutToAppear方法
              if (identifier.escapedText === 'aboutToAppear') {
                this.aboutToAppearExist = true;
                this.positionOfAboutToAppear = statement.pos;
              }
            }
          }
        }
      })
      // 过滤已经存在的装饰器中的方法
      const temp = this.methodArray.filter((value: string, index: number) => {
        return !methodNameArray.includes(value);
      })
      this.methodArray = temp;
      // 记录自定义组件的结束位置
      this.positionOfBlockEnd = node.end;
    }
  }
}