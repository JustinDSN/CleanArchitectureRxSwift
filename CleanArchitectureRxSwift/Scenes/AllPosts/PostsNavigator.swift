import UIKit
import Domain

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

    func toCreatePost() {
        let navigator = DefaultCreatePostNavigator(navigationController: navigationController)
        let viewModel = CreatePostViewModel(savePostUseCase: savePostUseCase,
                                            navigator: navigator)
        let vc = storyBoard.instantiateViewController(ofType: CreatePostViewController.self)
        vc.viewModel = viewModel
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }

    func toPost(_ post: Post) {
        let navigator = DefaultEditPostNavigator(navigationController: navigationController)
        let viewModel = EditPostViewModel(post: post,
                                          savePostUseCase: savePostUseCase,
                                          deletePostUuseCase: deletePostUseCase,
                                          navigator: navigator)
        let vc = storyBoard.instantiateViewController(ofType: EditPostViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
