```protobuf
syntax = "proto3";

package api.errors.v1;

import "errors/errors.proto";

option go_package = "api/errors/v1;v1";
option java_multiple_files = true;
option java_package = "api.errors.v1";

// HTTP状态码错误定义
// 此文件定义了系统中常见的HTTP状态码及其对应的错误原因
enum ErrorReason {
  option (errors.default_code) = 500; // 默认HTTP状态码
  
  // ====== 客户端错误 (4xx) ======
  // 400 - Bad Request - 错误请求
  BAD_REQUEST = 0 [(errors.code) = 400]; // 请求参数有误，服务器无法理解
  INVALID_PARAMETER = 1 [(errors.code) = 400]; // 请求参数无效
  MISSING_REQUIRED_FIELD = 2 [(errors.code) = 400]; // 缺少必填字段
  VALIDATION_FAILED = 3 [(errors.code) = 400]; // 数据验证失败
  
  // 401 - Unauthorized - 未授权
  UNAUTHORIZED = 10 [(errors.code) = 401]; // 需要身份验证
  INVALID_CREDENTIALS = 11 [(errors.code) = 401]; // 无效的凭据
  TOKEN_EXPIRED = 12 [(errors.code) = 401]; // 令牌已过期
  TOKEN_INVALID = 13 [(errors.code) = 401]; // 令牌无效
  
  // 403 - Forbidden - 禁止访问
  FORBIDDEN = 20 [(errors.code) = 403]; // 拒绝执行请求
  INSUFFICIENT_PERMISSIONS = 21 [(errors.code) = 403]; // 权限不足
  ACCESS_DENIED = 22 [(errors.code) = 403]; // 访问被拒绝
  RESOURCE_ACCESS_DENIED = 23 [(errors.code) = 403]; // 无权访问该资源
  
  // 404 - Not Found - 未找到
  NOT_FOUND = 30 [(errors.code) = 404]; // 请求的资源不存在
  USER_NOT_FOUND = 31 [(errors.code) = 404]; // 用户不存在
  RESOURCE_NOT_FOUND = 32 [(errors.code) = 404]; // 资源不存在
  ENDPOINT_NOT_FOUND = 33 [(errors.code) = 404]; // API端点不存在
  FILE_NOT_FOUND = 34 [(errors.code) = 404]; // 文件不存在
  
  // 405 - Method Not Allowed - 方法不允许
  METHOD_NOT_ALLOWED = 40 [(errors.code) = 405]; // 请求方法不被允许
  
  // 408 - Request Timeout - 请求超时
  REQUEST_TIMEOUT = 50 [(errors.code) = 408]; // 请求超时
  
  // 409 - Conflict - 冲突
  CONFLICT = 60 [(errors.code) = 409]; // 请求与当前资源状态冲突
  RESOURCE_ALREADY_EXISTS = 61 [(errors.code) = 409]; // 资源已存在
  USER_ALREADY_EXISTS = 62 [(errors.code) = 409]; // 用户已存在
  
  // 410 - Gone - 已删除
  GONE = 70 [(errors.code) = 410]; // 请求的资源已被永久删除
  
  // 413 - Payload Too Large - 负载过大
  PAYLOAD_TOO_LARGE = 80 [(errors.code) = 413]; // 请求体过大
  
  // 415 - Unsupported Media Type - 不支持的媒体类型
  UNSUPPORTED_MEDIA_TYPE = 90 [(errors.code) = 415]; // 不支持的媒体类型
  
  // 422 - Unprocessable Entity - 不可处理的实体
  UNPROCESSABLE_ENTITY = 100 [(errors.code) = 422]; // 请求格式正确，但语义错误
  VALIDATION_ERROR = 101 [(errors.code) = 422]; // 数据验证错误
  
  // 429 - Too Many Requests - 请求过多
  RATE_LIMIT_EXCEEDED = 110 [(errors.code) = 429]; // 请求频率超过限制
  TOO_MANY_REQUESTS = 111 [(errors.code) = 429]; // 请求过多
  
  // ====== 服务器错误 (5xx) ======
  
  // 500 - Internal Server Error - 服务器内部错误
  INTERNAL_SERVER_ERROR = 200 [(errors.code) = 500]; // 服务器内部错误
  DATABASE_ERROR = 201 [(errors.code) = 500]; // 数据库错误
  INTERNAL_ERROR = 202 [(errors.code) = 500]; // 内部错误
  
  // 501 - Not Implemented - 未实现
  NOT_IMPLEMENTED = 210 [(errors.code) = 501]; // 服务器不支持请求的功能
  
  // 502 - Bad Gateway - 错误网关
  BAD_GATEWAY = 220 [(errors.code) = 502]; // 网关或代理服务器从上游服务器收到无效响应
  UPSTREAM_SERVICE_UNAVAILABLE = 221 [(errors.code) = 502]; // 上游服务不可用
  
  // 503 - Service Unavailable - 服务不可用
  SERVICE_UNAVAILABLE = 230 [(errors.code) = 503]; // 服务暂时不可用
  MAINTENANCE_MODE = 231 [(errors.code) = 503]; // 系统维护中
  
  // 504 - Gateway Timeout - 网关超时
  GATEWAY_TIMEOUT = 240 [(errors.code) = 504]; // 网关或代理服务器等待上游服务器响应超时
  
  // 507 - Insufficient Storage - 存储空间不足
  INSUFFICIENT_STORAGE = 250 [(errors.code) = 507]; // 服务器存储空间不足
}
```

使用方式:
```go
import (
    apierrors "api/errors/v1"
    "github.com/go-kratos/kratos/v2/errors"
)

// 示例：抛出用户不存在的错误
func GetUser(userID string) (*User, error) {
    user, err := userRepo.FindByID(userID)
    if err != nil {
        return nil, err
    }
    if user == nil {
        return nil, errors.NotFound(
            apierrors.ErrorReason_USER_NOT_FOUND.String(), 
            "用户不存在",
        )
    }
    return user, nil
}

// 示例：抛出参数验证错误
func CreateUser(req *CreateUserRequest) error {
    if req.Username == "" {
        return errors.BadRequest(
            apierrors.ErrorReason_MISSING_REQUIRED_FIELD.String(), 
            "用户名不能为空",
        )
    }
    // ... 其他业务逻辑
}
```

前端:
```js
async function fetchUser(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        if (!response.ok) {
            const errorData = await response.json();
            
            // 根据错误原因进行特定处理
            switch (errorData.reason) {
                case 'USER_NOT_FOUND':
                    showUserNotFoundError();
                    break;
                case 'UNAUTHORIZED':
                    redirectToLogin();
                    break;
                case 'RATE_LIMIT_EXCEEDED':
                    showRateLimitError();
                    break;
                default:
                    showGenericError(errorData.message);
            }
            return;
        }
        
        // 处理成功响应
        const user = await response.json();
        displayUser(user);
    } catch (error) {
        console.error('请求失败:', error);
        showNetworkError();
    }
}
```