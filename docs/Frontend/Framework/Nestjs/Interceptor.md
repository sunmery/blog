拦截器
```ts
import {
	CallHandler,
	ExecutionContext,
	Injectable,
	NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';

@Injectable()
export class LoggerInterceptor implements NestInterceptor {
	intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
		const now = Date.now();
		const url = context.switchToHttp().getRequest().url; // 路由path
		return next
			.handle()
			.pipe(
				tap(() => console.log(`访问${url} 路由用时: ${Date.now() - now}ms`)),
			);
	}
}

```