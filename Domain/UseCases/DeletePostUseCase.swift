import Foundation
import RxSwift

public protocol DeletePostUseCase {
    func delete(post: Post) -> Observable<Void>
}

public final class ConcreteDeletePostUseCase: DeletePostUseCase {
    private let entityGateway: PostsEntityGateway

    public init(entityGateway: PostsEntityGateway) {
        self.entityGateway = entityGateway
    }

    public func delete(post: Post) -> Observable<Void> {
        return entityGateway.delete(entity: post)
    }
}
