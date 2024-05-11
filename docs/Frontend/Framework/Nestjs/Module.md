使用其他模块的`Service`提供者:
1. **再本模块导入所需要提供者的模块**
使用关键字`imports`导入所需`service`的`module`模块
例子: 
```ts
import { Module } from '@nestjs/common'
import { ProfileService } from './profile.service'
import { ProfileController } from './profile.controller'

import { StudentModule } from '../student/student.module'
import { TeacherModule } from '../teacher/teacher.module'
import { AdminModule } from '../admin/admin.module'

@Module({
	imports: [StudentModule, TeacherModule, AdminModule], // 导入学生/教师/管理员的Module以使用它们的Service
	providers: [ProfileService],
	controllers: [ProfileController],
})
export class ProfileModule {}
```

2. 使用其他模块的`Service`
**使用`constructor`导入其他模块的`Service`**
```ts
import { Injectable } from '@nestjs/common'

import { StudentService } from '../student/student.service'
import { TeacherService } from '../teacher/teacher.service'
import { AdminService } from '../admin/admin.service'

import { IStudent } from '../student/interface/user'
import { ITeacher } from '../teacher/interface/user'
import { IAdmin } from '../admin/interface/user'

import { PublicError } from '../types/publicError'

@Injectable()
export class ProfileService {
	constructor (
		private readonly userStudentService: StudentService,
		private readonly userTeacherService: TeacherService,
		private readonly userAdminService: AdminService,
	) {}

	private async find (role: number, userId: string): Promise<IStudent | ITeacher | IAdmin | PublicError> {
		switch (role) {
			case 0:
				return this.userAdminService.findUser(userId)
			case 1:
				return this.userTeacherService.findUser(userId)
			case 2:
				return this.userStudentService.findUser(userId)
			default:
				return {
					msg: '传递错误的role',
					status: 400,
				}
		}
	}

	public async findUser(role:number, userId:string): Promise<IStudent | ITeacher | IAdmin | PublicError> {
		console.log('profileService',role, userId)
		return this.find(role, userId)
	}
}
```