# 自动生成代码插件

### 介绍

本示例将介绍如何通过ts抽象语法树，根据自定义装饰器，自动生成代码。

### 实现原理

在编译期通过扫描并解析ets文件中的自定义装饰器来生成方法并调用

### 实现思路

**插件初始化**

1. 创建ts工程，并添加hvigor依赖，可以使用hvigor中配置的解析和打包方法

    ```shell
    npm init
    npm install --save-dev @types/node @ohos/hvigor @ohos/hvigor-ohos-plugin
    npm install typescript handlebars
    ```

2. 初始化ts配置

    ```shell
    ./node_modules/.bin/tsc --init
    ```
   
3. 修改package.json文件

   ```json
   {
   "name": "autobuilddecoration",
   "version": "1.0.0",
   "description": "",
   "main": "lib/index.js",
   "scripts": {
     "test": "echo \"Error: no test specified\" && exit 1",
     "dev": "tsc && node lib/index.js",
     "build": "tsc"
   },
   ...
   ```

4. 修改tsconfig.json，指定编译相关的选项

    ```json5
    {
      "compilerOptions": {
        "target": "es2021",                                  /* Set the JavaScript language version for emitted JavaScript and include compatible library 
        "module": "commonjs",                                /* Specify what module code is generated. */
        "esModuleInterop": true,                             /* Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for type compatibility. */
        "forceConsistentCasingInFileNames": true,            /* Ensure that casing is correct in imports. */
        "skipLibCheck": true,                                 /* Skip type checking all .d.ts files. */
        "sourceMap": true,
        "outDir": "./lib"
      },
      "include": [".eslintrc.js","src/**/*"],
      "exclude": ["node_modules","lib/**/*"]
    }
    ```

5. 创建插件文件src/index.ts，用于编写插件代码

6. 插件代码编写完成后，运行/node_modules/.bin/tsc.cmd，在hvigor/hvigor-config.json5中配置插件后即可使用。
