忽略目录：在file.includes的元素填写路径前添加一个!例如：`"!**/src/gen"`

```json
{
	"$schema": "https://biomejs.dev/schemas/2.2.4/schema.json",
	"vcs": {
		"enabled": false,
		"clientKind": "git",
		"useIgnoreFile": false
	},
	"files": {
		"ignoreUnknown": false,
		"includes": [
			"**/src/**/*",
			"**/.vscode/**/*",
			"**/index.html",
			"**/vite.config.js",
			"!**/src/routeTree.gen.ts",
			"!**/src/gen"
		]
	},
	"formatter": {
		"enabled": true,
		"indentStyle": "tab"
	},
	"assist": {
		"actions": {
			"source": {
				"organizeImports": "on"
			}
		}
	},
	"linter": {
		"enabled": true,
		"rules": {
			"recommended": true
		}
	},
	"javascript": {
		"parser": {
			"unsafeParameterDecoratorsEnabled": true
		},
		"formatter": {
			"quoteStyle": "single",
			"jsxQuoteStyle": "single",
			"trailingCommas": "all",
			"quoteProperties": "asNeeded",
			"semicolons": "asNeeded",
			"arrowParentheses": "always",
			"enabled": true,
			"indentStyle": "tab",
			"indentWidth": 2,
			"lineEnding": "lf",
			"lineWidth": 80,
			"bracketSameLine": false,
			"attributePosition": "multiline",
			"expand": "auto"
		}
	}
}
```