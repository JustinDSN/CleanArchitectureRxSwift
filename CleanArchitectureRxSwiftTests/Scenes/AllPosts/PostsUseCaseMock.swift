@testable import CleanArchitectureRxSwift
import RxSwift
import Domain

class SavePostUseCaseMock: Domain.SavePostUseCase {
    var save_ReturnValue: Observable<Void> = Observable.just(())
    var save_Called = false

    func save(post: Post) -> Observable<Void> {
        save_Called = true
        return save_ReturnValue
    }
}

class DeletePostUseCaseMock: Domain.DeletePostUseCase {
    var delete_ReturnValue: Observable<Void> = Observable.just(())
    var delete_Called = false

    func delete(post: Post) -> Observable<Void> {
        delete_Called = true
        return delete_ReturnValue
    }
}

class ListPostsUseCaseMock: Domain.ListPostsUseCase {
    var posts_ReturnValue: Observable<[Post]> = Observable.just([])
    var posts_Called = false

    func posts() -> Observable<[Post]> {
        posts_Called = true
        return posts_ReturnValue
    }
}
