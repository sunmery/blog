## 注意事项
创建`Schema`数据模型时, 映射的类型是该类名的复数, 例如使用`Cat`作为类名, 那么`mongoose`就回去寻找`mongodb`数据库中的同名复数数据库`cats`

## 下载

```shell
pnpm add -S @nest/mongoose mongoose
```
## 导入Mongoose
1. 从`@nestjs/mongoose`导入`mongoose`模块
2. 使用`forRoot`链接`mongodb`数据库, 例如`mongodb://root:admin@192.168.0.152:27017/edu_system`

`app.module.ts`
```ts
@Module({
	imports: [MongooseModule.forRoot('mongodb-url')]
})
```

## 定义Schema

> ! 创建`Schema`数据模型时, 映射的类型是该类名的复数, 例如使用`Cat`作为类名, 那么`mongoose`就回去寻找`mongodb`数据库中的同名复数数据库`cats`

> 如果不想再数据库更新已有的表, 那么需要再`Schema`这个装饰器中添加参数: `collectio:n : '表名'`

更多[Schema](https://mongoosejs.com/docs/guide.html#options)参数

例子:
```ts
@Schema({ collection: 'user_student' })
```

`schemas/user.schema.ts`
```ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
// 定义文档(表)字段的类型
export type UserDocument = HydratedDocument<User>

Schema({ collection: 'user' })
export class User {
	@Prop()
	key1: type1

	@Prop()
	key2: type2
}

export const UserSchema = SchemaFactory.createForClass(User) // 导出模型
```

## 定义控制器
`user.controller.ts`
```ts
import { Controller, Get, Query } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('user')
export class UserController {
	constructor(private readonly userService: UserService) {}
	
	// 根据id查询用户
	@Get()
	find(@Query() query: { id: string }) {
		return this.userService.find(query?.id);
	}
}

```

定义Service
`user.serive.ts`
```ts
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { User, UserDocument } from '../schemas/user.schema';
import { Model } from 'mongoose';

@Injectable()
export class UserService {
	constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

	// 根据id查询用户
	async find(id: string): Promise<User[]> {
		return await this.userModel.find({ id }).exec();
	}
}

```

定义Module
1. 导入`mongoose`的模型`User.name`为`User`, 即类名,`schema`数据模型, 在`schemas`目录定义的数据模型
2. 导入Service
3. 导入控制器
```ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../schemas/user.schema';
import { UserController } from '../user/user.controller';
import { UserService } from '../user/user.service';

console.log(User.name);
@Module({
	imports: [
		MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
	],
	controllers: [UserController],
	providers: [UserService],
})
export class UserModule {}

```