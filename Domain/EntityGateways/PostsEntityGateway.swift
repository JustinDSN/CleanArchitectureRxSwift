import Foundation
import RxSwift

public protocol PostsEntityGateway {

    func query() -> Observable<[Post]>

    func save(entity: Post) -> Observable<Void>

    func delete(entity: Post) -> Observable<Void>

}
