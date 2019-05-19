import Foundation
import RxSwift

public protocol ListPostsUseCase {
    func posts() -> Observable<[Post]>
}

public final class ConcreteListPostsUseCase: ListPostsUseCase {
    private let entityGateway: PostsEntityGateway

    public init(entityGateway: PostsEntityGateway) {
        self.entityGateway = entityGateway
    }

    public func posts() -> Observable<[Post]> {
        return entityGateway.query()
    }
}
