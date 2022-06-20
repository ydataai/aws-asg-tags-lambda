import AWSLambdaRuntime

Lambda.run { (_, name: String, callback: @escaping (Result<String, Error>) -> Void) in
  callback(.success("Hello, \(name)"))
}
