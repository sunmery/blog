默认返回驼峰命名的 JSON, 非定义的字段, 如果需要蛇形命名法或其他 json 字段名需要添加
`[json_name="field_name"]`

```protobuf
message UserResponse {
    int32 status_code = 1 [json_name="status_code"]; // 状态码，0-成功，其他值-失败
    string status_msg = 2 [json_name="status_msg"]; // 返回状态描述
    int64 user_id = 3 [json_name="user_id"]; // 用户id
    optional string token = 4; // 用户鉴权token
}
```