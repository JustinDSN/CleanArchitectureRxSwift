import Foundation
import Domain
import NetworkPlatform
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()

    private let coreDataPostsEntityGateway: Domain.PostsEntityGateway
    private let realmPostsEntityGateway: Domain.PostsEntityGateway
    private let networkPostsEntityGateway: Domain.PostsEntityGateway

    private init() {
        coreDataPostsEntityGateway = CoreDataPlatform.PostsEntityGateway()
        realmPostsEntityGateway = RealmPlatform.PostsEntityGateway()
        networkPostsEntityGateway = NetworkPlatform.PostsEntityGateway()
    }

    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        //Core Data
        let cdUseCases = makeUseCases(postsEntityGateway: coreDataPostsEntityGateway)

        let cdNavigationController = UINavigationController()
        cdNavigationController.tabBarItem = UITabBarItem(title: "CoreData",
                                                         image: UIImage(named: "Box"),
                                                         selectedImage: nil)

        let cdNavigator = DefaultPostsNavigator(savePostUseCase: cdUseCases.0,
                                                deletePostUseCase: cdUseCases.1,
                                                listPostsUseCase: cdUseCases.2,
                                                navigationController: cdNavigationController,
                                                storyBoard: storyboard)
        //Realm
        let rmUseCases = makeUseCases(postsEntityGateway: realmPostsEntityGateway)

        let rmNavigationController = UINavigationController()
        rmNavigationController.tabBarItem = UITabBarItem(title: "Realm",
                                                         image: UIImage(named: "Toolbox"),
                                                         selectedImage: nil)

        let rmNavigator = DefaultPostsNavigator(savePostUseCase: rmUseCases.0,
                                                deletePostUseCase: rmUseCases.1,
                                                listPostsUseCase: rmUseCases.2,
                                                navigationController: rmNavigationController,
                                                storyBoard: storyboard)


        //Network
        let nwUseCase = makeUseCases(postsEntityGateway: networkPostsEntityGateway)

        let nwNavigationController = UINavigationController()
        nwNavigationController.tabBarItem = UITabBarItem(title: "Network",
                                                         image: UIImage(named: "Toolbox"),
                                                         selectedImage: nil)

        let nwNavigator = DefaultPostsNavigator(savePostUseCase: nwUseCase.0,
                                                deletePostUseCase: nwUseCase.1,
                                                listPostsUseCase: nwUseCase.2,
                                                navigationController: nwNavigationController,
                                                storyBoard: storyboard)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            cdNavigationController,
            rmNavigationController,
            nwNavigationController
        ]
        window.rootViewController = tabBarController

        cdNavigator.toPosts()
        rmNavigator.toPosts()
        nwNavigator.toPosts()
    }

    func makeUseCases(postsEntityGateway: Domain.PostsEntityGateway) -> (SavePostUseCase, DeletePostUseCase, ListPostsUseCase) {
        let savePostUseCase: SavePostUseCase = Domain.ConcreteSavePostUseCase(entityGateway: postsEntityGateway)
        let deletePostUseCase: DeletePostUseCase = Domain.ConcreteDeletePostUseCase(entityGateway: postsEntityGateway)
        let listPostsUseCase: ListPostsUseCase = Domain.ConcreteListPostsUseCase(entityGateway: postsEntityGateway)

        return (savePostUseCase, deletePostUseCase, listPostsUseCase)
    }
    
}
