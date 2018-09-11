import Vapor

struct BankController: RouteCollection {
    func boot(router: Router) throws {
        let routeCollection = router.grouped("bank")
        routeCollection.get("transfer", use: transferHandler)
        routeCollection.post(TransferData.self, at: "transfer", use: transferPostHandler)
    }

    func transferHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("transfer", TransferContext())
    }

    func transferPostHandler(_ req: Request, data: TransferData) throws -> Future<View> {
        let context = TransferCompleteContext(amount: data.amount, toAccount: data.toAccount)
        return try req.view().render("transferComplete", context)
    }
}

struct TransferContext: Encodable {
    let title = "Transfer Money"
}

struct TransferData: Content {
    let toAccount: String
    let amount: Int
}

struct TransferCompleteContext: Encodable {
    let title = "Transfer Complete"
    let amount: Int
    let toAccount: String
}
