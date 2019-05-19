import Foundation
import RxSwift

public protocol SavePostUseCase {
    func save(post: Post) -> Observable<Void>
}

public final class ConcreteSavePostUseCase: SavePostUseCase {
    private let entityGateway: PostsEntityGateway

    public init(entityGateway: PostsEntityGateway) {
        self.entityGateway = entityGateway
    }

    public func save(post: Post) -> Observable<Void> {
        return entityGateway.save(entity: post  )
    }
}
