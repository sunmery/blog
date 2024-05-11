store/list.Store.js

```jsx
import {makeAutoObservable, computed} from "mobx-react-lite"

class ModuleA {
	list = [1,2,3,4]
	
	constructor(){
		makeAutoObservable(this,{
			listFilter: computed
		})
	}
	
	get listFilter(){
		this.list.map(_=>{_>2})
	}
}
```

store/count.Store.js

```jsx
import {makeAutoObservable, computed} from 'mobx-react-lite'

class ModuleB {
	count = 0
	
	constructor(){
		makeAutoOvservable(this,{
			countPlus:computed
		})
	}
	
	countPlus=()=>{
		
	}
}
```

store/index

```jsx
import {makeAutoObservable} from 'mobx-react-lite'

import {listStore} from './listStore'
import {countStore} from './countStore'

class IndexStore {
	constructor(){
		this.listStore = new listStore()
		this.countStore = new countStore()
		makeAutoObservable(this)
	}
}

const indexStore = new indexStore()
export default indexStore
```