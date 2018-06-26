import Embassy
import Foundation

let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
let server = DefaultHTTPServer(eventLoop: loop, port: 8888) {
    (
        environ: [String: Any],
        startResponse: ((String, [(String, String)]) -> Void),
        sendBody: ((Data) -> Void)
    ) in
    // Start HTTP response
    startResponse("200 OK", [])
    let pathInfo = environ["PATH_INFO"]! as! String
    if pathInfo == "/hello" {
        let file = "file.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory,
        in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            // Write to a file in documents directory
            // do {
            //     try text.write(to: fileURL, atomically: false, encoding: .utf8)
            // }
            // catch {/* error handling here */}

            // Read from a file in documents directory
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                sendBody(Data(text2.utf8))
            }
            catch {
                print("Error while reading file")
                sendBody(Data("Error reading file".utf8))
            }
        }
        
    } else {
        sendBody(Data("the path you're visiting is \(pathInfo.debugDescription)".utf8))
    }
    sendBody(Data())
}

// Start HTTP server to listen on the port
try! server.start()

// Run event loop
loop.runForever()