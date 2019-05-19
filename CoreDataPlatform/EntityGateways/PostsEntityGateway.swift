import Foundation
import RxSwift
import Domain

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
