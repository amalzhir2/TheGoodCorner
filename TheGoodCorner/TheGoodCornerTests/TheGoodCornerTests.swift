import XCTest
@testable import TheGoodCorner

final class TheGoodCornerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - Test 1 : Décodage JSON d'une annonce
    @MainActor
    func testlisting_decodesCorrectlyFromJSON() throws {
        // Given
        let json = """
            {
                "id": 1,
                "category_id": 2,
                "title": "Vélo hollandais",
                "description": "Très bon état, peu servi.",
                "price": 120,
                "creation_date": "2026-09-19T10:00:00.000Z",
                "is_urgent": true,
                "imagesUrl": null
            }
            """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // When
        let listing = try decoder.decode(Listing.self, from: json)
        
        // Then
        XCTAssertEqual(listing.id, 1)
        XCTAssertEqual(listing.categoryId, 2)
        XCTAssertEqual(listing.title, "Vélo hollandais")
        XCTAssertTrue(listing.isUrgent)
        XCTAssertNil(listing.imagesUrl)
    }
    
    // MARK: - Test 2 : Formatage du prix
    
    func test_formattedPrice_returnsCorrectCurrencyFormat() {
        // Given
        let listing = Listing(
            id: 1, categoryId: 1, title: "Test",
            description: "Test", price: 140,
            creationDate: .now, isUrgent: false, imagesUrl: nil
        )
        
        // When
        let result = listing.formattedPrice
        
        // Then
        XCTAssertTrue(result.contains("140"))
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Test 3 : Formatage de date — affichage vs accessibilité
    
    func test_dateFormatting_longStyleSpellsOutMonth() {
        // Given
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 19
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!
        
        // When
        let mediumResult = date.formatted(style: .medium)
        let longResult = date.formatted(style: .long)
        
        // Then
        XCTAssertNotEqual(mediumResult, longResult)
        XCTAssertTrue(longResult.contains("septembre") || longResult.lowercased().contains("september"))
    }
    
    // MARK: - Test 4 : Filtrage des annonces par catégorie (ViewModel)
    
    @MainActor
    func test_viewModel_filtersListingsBySelectedCategory() async {
        // Given
        let mockListings = [
            Listing(id: 1, categoryId: 1, title: "Vélo", description: "", price: 100, creationDate: .now, isUrgent: false, imagesUrl: nil),
            Listing(id: 2, categoryId: 2, title: "Table", description: "", price: 50, creationDate: .now, isUrgent: false, imagesUrl: nil),
            Listing(id: 3, categoryId: 1, title: "Trottinette", description: "", price: 30, creationDate: .now, isUrgent: false, imagesUrl: nil)
        ]
        let mockClient = MockAPIClient(listingsToReturn: mockListings)
        let viewModel = ListingsViewModel(client: mockClient)
        
        await viewModel.load()
        viewModel.selectedCategoryId = 1
        
        // When
        let result = viewModel.filteredListingsByCategory
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.categoryId == 1 })
    }
    
    // MARK: - Test 5 : Récupération du nom de catégorie via son id
    @MainActor
    func test_viewModel_categoryName_returnsCorrectNameForGivenId() async throws {
        // Given
        let json = """
        [
            {"id":1,"name":"Véhicule"},
            {"name":"Mode","id":2},
            {"name":"Bricolage","id":3},
            {"name":"Maison","id":4},
            {"name":"Loisirs","id":5},
            {"name":"Immobilier","id":6},
            {"name":"Livres/CD/DVD","id":7},
            {"name":"Multimédia","id":8},
            {"name":"Service","id":9},
            {"name":"Animaux","id":10},
            {"name":"Enfants","id":11}
        ]
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let categories = try decoder.decode([TheGoodCorner.Category].self, from: json)
        
        let mockClient = MockAPIClient(categoriesToReturn: categories)
        let viewModel = ListingsViewModel(client: mockClient)
        
        await viewModel.load()
        
        // When
        let result = viewModel.categoryName(for: 6)
        
        // Then
        XCTAssertEqual(result, "Immobilier")
    }
}

// MARK: - Mock du client API pour les tests

final class MockAPIClient: APIClientProtocol {
    
    private let listingsToReturn: [Listing]
    private let categoriesToReturn: [TheGoodCorner.Category]
    private let shouldThrowError: Bool
    
    init(
        listingsToReturn: [Listing] = [],
        categoriesToReturn: [TheGoodCorner.Category] = [],
        shouldThrowError: Bool = false
    ) {
        self.listingsToReturn = listingsToReturn
        self.categoriesToReturn = categoriesToReturn
        self.shouldThrowError = shouldThrowError
    }
    
    func fetchCategories() async throws -> [TheGoodCorner.Category] {
        if shouldThrowError {
            throw URLError(.notConnectedToInternet)
        }
        return categoriesToReturn
    }
    
    func fetchListings(page: Int?, limit: Int?, query: String?) async throws -> ListingFeed {
        if shouldThrowError {
            throw URLError(.notConnectedToInternet)
        }
        return ListingFeed(
            total: listingsToReturn.count,
            page: 1,
            limit: listingsToReturn.count,
            hasMore: false,
            items: listingsToReturn
        )
    }
}
