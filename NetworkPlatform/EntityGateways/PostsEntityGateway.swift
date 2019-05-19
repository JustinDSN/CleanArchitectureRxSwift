import Foundation
import RxSwift
import Domain

public final class PostsEntityGateway: Domain.PostsEntityGateway {
    private let repository: PostRepository<Cache<Post>>

    public init() {
        let networkProvider = NetworkProvider()
        let cache = Cache<Post>(path: "allPosts")
        self.repository = PostRepository(network: networkProvider.makePostsNetwork(),
                                         cache: cache)
    }

    public func query() -> Observable<[Post]> {
        return repository.posts()
    }

    public func save(entity: Post) -> Observable<Void> {
        return repository.save(post: entity)
    }

    public func delete(entity: Post) -> Observable<Void> {
        return repository.delete(post: entity)
    }

}
