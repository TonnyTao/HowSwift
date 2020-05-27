import Foundation

enum DataError: Error {
    case internet(Error)
    case invalidResponse
    case invalidData
    case decoding
}

struct Animal: Decodable, CustomStringConvertible {
    let name: String
    
    var description: String {
        return "Animal: \(name)"
    }
}

struct API {
    typealias Completion<T> = (Result<T, DataError>) -> Void
    
    static func get<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping Completion<T>) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(.internet(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                200 ... 299 ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            }catch {
                completion(.failure(.decoding))
            }
        }.resume()
    }

}

let url = URL(string: "https://www.json-generator.com/api/json/get/cgtNBfTPiq")!

API.get([Animal].self, from: url) { result in
    
    switch result {
    case .failure(let error):
        print(error.localizedDescription)
    case .success(let animals):
        print(animals)
    }
}

let animalUrl = URL(string: "https://www.json-generator.com/api/json/get/clgXOarile")!
API.get(Animal.self, from: animalUrl) { result in
    switch result {
    case .failure(let error):
        print(error.localizedDescription)
    case .success(let animal):
        print(animal)
    }
}

