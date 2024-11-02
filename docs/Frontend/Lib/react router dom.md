检测路由地址变化Hook
useLocation()

路由跳转

```ts
const navigate = useNavigate()
```

错误路由: `errorElement`

```tsx
const router = createBrowserRouter([
    {
        path: "/",
        element: <App/>,
        errorElement: <ErrorPage/>
    },
]);
```