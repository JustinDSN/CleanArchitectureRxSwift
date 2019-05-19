import Foundation
import RxSwift
import Domain
import Realm
import RealmSwift

public final class PostsEntityGateway: Domain.PostsEntityGateway {
    private let configuration: Realm.Configuration
    private let repository: Repository<Post>

    public init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
        self.repository = Repository<Post>(configuration: configuration)
    }

    public func query() -> Observable<[Post]> {
        return repository.queryAll()
    }

    public func save(entity: Post) -> Observable<Void> {
        return repository.save(entity: entity)
    }

    public func delete(entity: Post) -> Observable<Void> {
        return repository.delete(entity: entity)
    }

}
