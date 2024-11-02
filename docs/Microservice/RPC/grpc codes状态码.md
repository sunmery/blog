https://github.com/grpc-ecosystem/grpc-gateway/blob/main/runtime/errors.go#L15

- `OK` (0): 操作成功完成。
- `CANCELLED` (1): 操作被取消。
- `UNKNOWN` (2): 未知错误。
- `INVALID_ARGUMENT` (3): 客户端指定了无效的参数。
- `DEADLINE_EXCEEDED` (4): 截止时间已过期。
- `NOT_FOUND` (5): 请求的实体不存在。
- `ALREADY_EXISTS` (6): 实体已存在。
- `PERMISSION_DENIED` (7): 没有足够的权限。
- `RESOURCE_EXHAUSTED` (8): 资源耗尽。
- `FAILED_PRECONDITION` (9): 操作依赖于某些条件，而这些条件未能满足。
- `ABORTED` (10): 操作被中止。
- `OUT_OF_RANGE` (11): 参数超出范围。
- `UNIMPLEMENTED` (12): 服务未实现。
- `INTERNAL` (13): 内部错误。
- `UNAVAILABLE` (14): 服务不可用。
- `DATA_LOSS` (15): 数据丢失或被破坏。
- `UNAUTHENTICATED` (16): 未通过身份验证。