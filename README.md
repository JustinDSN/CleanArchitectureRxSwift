# Clean architecture with [RxSwift](https://github.com/ReactiveX/RxSwift)

## Contributions are welcome and highly appreciated!!
You can do this by:

- opening an issue to discuss the current solution, ask a question, propose your solution etc. (also English is not my native language so if you think that something can be corrected please open a PR 😊)
- opening a PR if you want to fix bugs or improve something

### Instalation

Dependencies in this project are provided via Cocoapods. Please install all dependecies with

`
pod install
`

## High level overview
![](Architecture/Modules.png)

#### Domain 

The `Domain` is basically what is your App about and what it can do.  It contains:
* **[Entities](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html#entities)** - Which are the business objects of the application.  They can ecapsulate _enterprise wide_ business rules independent of any application.  
* **[Use cases](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html#use-cases)** - Which are the application specific business rules.  They collaborate with to fetch, save, delete entites from an abstract interface that hides data persistence and data fetching implementation details.
* **Entity Gateways** - Abstractions of the implementation details of *networking* or *persistence*.  The concrete implementation of an *entity gateway* can be swapped out at anytime and the use case should work the same.  Example entity gateways are included in the Platform layer.  

**It does not depend on UIKit or any persistence framework**

#### Platform

The `Platform` contains concrete implementation of  `Domain` `EntityGateways`. It hides all implementation details. For example database implementation whether it is CoreData, Realm, SQLite etc.  There is also an example of a network based  `EntityGateway`.

#### Application
`Application` is responsible for delivering information to the user and handling user input. It can be implemented with any delivery pattern e.g (MVVM, MVC, MVP). This is the place for your `UIView`s and `UIViewController`s. As you will see from the example app, `ViewControllers` are completely independent of the `Platform`.  The only responsibility of a view controller is to "bind" the UI to the Domain to make things happen. In fact, in the current example we are using the same view controller for Realm, CoreData, and Network.


## Detail overview
![](Architecture/ModulesDetails.png)
 
To enforce modularity, `Domain`, `Platform` and `Application` are separate targets in the App, which allows us to take advantage of the `internal` access layer in Swift to prevent exposing of types that we don't want to expose.

#### Domain

Entities are implemented as Swift value types

```swift
public struct Post {
    public let uid: String
    public let createDate: Date
    public let updateDate: Date
    public let title: String
    public let content: String
}
```

UseCases are protocols which do one specific thing:

```swift

public protocol SavePostUseCase {
    func save(post: Post) -> Observable<Void>
}
```

UseCases also have concrete implementation which accept an abstract `EntityGateway`, this allows them to collaborate with *any* type of persistance framework or network while owning *use case* or *application specific* business rules:

```swift
public final class ConcreteSavePostUseCase: SavePostUseCase {
    private let entityGateway: PostsEntityGateway

    public init(entityGateway: PostsEntityGateway) {
        self.entityGateway = entityGateway
    }

    public func save(post: Post) -> Observable<Void> {
        return entityGateway.save(entity: post  )
    }
}
```

#### Platform

In some cases, we can't use Swift structs for our domain objects because of DB framework requirements (e.g. CoreData, Realm). 

```swift
final class CDPost: NSManagedObject {
    @NSManaged public var uid: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var updateDate: NSDate?
}

final class RMPost: Object {
    dynamic var uid: String = ""
    dynamic var createDate: NSDate = NSDate()
    dynamic var updateDate: NSDate = NSDate()
    dynamic var title: String = ""
    dynamic var content: String = ""
}
```


The `Platform` also contains concrete implementations of your `EntityGateways`, repositories or any services that are defined in the `Domain`.

```swift
public final class PostsEntityGateway: Domain.PostsEntityGateway {
    private let coreDataStack = CoreDataStack()
    private let postRepository: Repository<Post>

    public init() {
        postRepository = Repository<Post>(context: coreDataStack.context)
    }

    public func query() -> Observable<[Post]> {
        return postRepository.query(with: nil,
                                    sortDescriptors: [Post.CoreDataType.createdAt.descending()])
    }

    public func save(entity: Post) -> Observable<Void> {
        return postRepository.save(entity: entity)
    }

    public func delete(entity: Post) -> Observable<Void> {
        return postRepository.delete(entity: entity)
    }

}

final class Repository<T: CoreDataRepresentable>: AbstractRepository where T == T.CoreDataType.DomainType {
    private let context: NSManagedObjectContext
    private let scheduler: ContextScheduler

    init(context: NSManagedObjectContext) {
        self.context = context
        self.scheduler = ContextScheduler(context: context)
    }

    func query(with predicate: NSPredicate? = nil,
               sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[T]> {
        let request = T.CoreDataType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return context.rx.entities(fetchRequest: request)
            .mapToDomain()
            .subscribeOn(scheduler)
    }

    func save(entity: T) -> Observable<Void> {
        return entity.sync(in: context)
            .mapToVoid()
            .flatMapLatest(context.rx.save)
            .subscribeOn(scheduler)
    }

    func delete(entity: T) -> Observable<Void> {
        return entity.sync(in: context)
            .map({$0 as! NSManagedObject})
            .flatMapLatest(context.rx.delete)
    }
}
```

#### Application

In the current example, `Application` is implemented with the [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) pattern and heavy use of [RxSwift](https://github.com/ReactiveX/RxSwift), which makes binding very easy.

![](Architecture/MVVMPattern.png)

Where the `ViewModel` performs pure transformation of a user `Input` to the `Output`

```swift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
```


```swift
final class PostsViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let createPostTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    struct Output {
        let fetching: Driver<Bool>
        let posts: Driver<[PostItemViewModel]>
        let createPost: Driver<Void>
        let selectedPost: Driver<Post>
        let error: Driver<Error>
    }

    private let listPostsUseCase: ListPostsUseCase
    private let navigator: PostsNavigator

    init(listPostsUseCase: ListPostsUseCase, navigator: PostsNavigator) {
        self.listPostsUseCase = listPostsUseCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
       ......
    }
```

A `ViewModel` can be injected into a `ViewController` via property injection or initializer. In the current example, this is done by `Navigator`.

```swift

protocol PostsNavigator {
    func toCreatePost()
    func toPost(_ post: Post)
    func toPosts()
}

class DefaultPostsNavigator: PostsNavigator {
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
    private let savePostUseCase: SavePostUseCase
    private let deletePostUseCase: DeletePostUseCase
    private let listPostsUseCase: ListPostsUseCase

    init(savePostUseCase: SavePostUseCase,
         deletePostUseCase: DeletePostUseCase,
         listPostsUseCase: ListPostsUseCase,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.savePostUseCase = savePostUseCase
        self.deletePostUseCase = deletePostUseCase
        self.listPostsUseCase = listPostsUseCase
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }

    func toPosts() {
        let vc = storyBoard.instantiateViewController(ofType: PostsViewController.self)
        vc.viewModel = PostsViewModel(listPostsUseCase: listPostsUseCase,
        navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    ....
}

class PostsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel: PostsViewModel!
    
    ...
}
```

### Example

The example app is Post/TODOs app which uses `Realm`, `CoreData` and `Network` at the same time as a proof of concept that the `Application` level is not dependant on the Platform level implementation details.

| CoreData | Realm | Network |
| -------- | ----- | ------- |
|![](Architecture/CoreData.gif) | ![](Architecture/Realm.gif) | ![](Architecture/Network.gif) |

### Modularization

The corner stone of **Clean Architecture** is modularization, as you can hide implementation detail under `internal` access layer. Further read of this topic [here](https://github.com/microfeatures/guidelines)

### TODO:

* add tests 
* add [MVP](https://en.wikipedia.org/wiki/Model–view–presenter) example
* [Redux](http://redux.js.org) example??

### Links
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [RxSwift Book](https://store.raywenderlich.com/products/rxswift)
* [Robert C Martin - Clean Architecture and Design](https://www.youtube.com/watch?v=Nsjsiz2A9mg)
* [Cycle.js](https://cycle.js.org)
* [ViewModel](https://medium.com/@SergDort/viewmodel-in-rxswift-world-13d39faa2cf5#.qse37r6jw) in Rx world

### Any questions?

* ping me on [Twitter](https://twitter.com/SergDort)
