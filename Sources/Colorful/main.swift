//
//  main.swift
//  ColorfulCLI
//
//  Created by Rowenna Emma and Kat on 9/24/21.
//

import Foundation
import Crypto

typealias ColoredGraph = [Int: (Colors, [Int])]
typealias CommitedGraph = [Int: (SHA256Digest, [Int])]
typealias VertexSecrets = [Int: Data]

enum Colors: UInt8 {
    case first = 0
    case second = 1
    case third = 2

     static func makeColorMap(from colors : [Colors]) -> [Colors: Colors] {
        return [Colors.first : colors[0], Colors.second: colors[1], Colors.third: colors[2]]
    }

    static let permutations = [
        makeColorMap([Colors.first, Colors.second, Colors.third]),
        makeColorMap([Colors.first, Colors.third, Colors.second]),
        makeColorMap([Colors.second, Colors.first, Colors.third]),
        makeColorMap([Colors.second, Colors.third, Colors.first]),
        makeColorMap([Colors.third, Colors.first, Colors.second]),
        makeColorMap([Colors.third, Colors.second, Colors.first])
    ]
}

let TestGraphs : [String: (ColoredGraph, Bool)] = [
    "triangle":
        ([1: (Colors.first, [2, 3]),
          2: (Colors.second, [1, 3]),
          3: (Colors.third, [1, 2])],
         true),
    "diamond":
        ([1: (Colors.first, [2, 3, 4]),
          2: (Colors.second, [1, 3]),
          3: (Colors.third, [1, 2, 4]),
          4: (Colors.second, [1, 3])],
         true),
    "tetrahedronWithDoubleRed":
        ([1: (Colors.first, [2, 3, 4]),
          2: (Colors.second, [1, 3, 4]),
          3: (Colors.third, [1, 2, 4]),
          4: (Colors.first, [1, 2, 3])],
         false),
    "pentastar":
        ([1: (Colors.first, [6, 7]),
          2: (Colors.second, [7, 8]),
          3: (Colors.third, [8, 9]),
          4: (Colors.first, [9, 10]),
          5: (Colors.first, [6, 10]),
          6: (Colors.second, [1, 5, 7, 10]),
          7: (Colors.third, [1, 2, 6, 8]),
          8: (Colors.first, [2, 3, 7, 9]),
          9: (Colors.second, [3, 4, 8, 10]),
          10: (Colors.third, [4, 5, 6, 9])],
         true)
]

func isThreeColored (_ graph : ColoredGraph) -> Bool {
    var colorsSeen = [Colors]()
    
    for (_, (color, edges)) in graph {
        if !colorsSeen.contains(color) {
            colorsSeen.append(color)
        }
        
        for pairVertexID in edges {
            let (pairColor, _) = graph[pairVertexID]!
            
            if color == pairColor {
                return false
            }
        }
    }
    
    if colorsSeen.count != 3 {
        return false
    }
    
    return true
}

func threeColorPermutations (for graph : ColoredGraph) -> [ColoredGraph] {
    guard isThreeColored(graph) else {
        return []
    }
    
    var graphPermutations = [ColoredGraph]()
    
    for permutation in Color.permutations {
        var newGraph = graph
        for (vertexID, (color, _)) in newGraph {
            newGraph[vertexID]!.0 = permutation[color]!
        }
        graphPermutations.append(newGraph)
    }
    
    return graphPermutations
}

func commitmentForColor(_ color: Colors) -> (Data, SHA256Digest)? {
    let secretLength = 33
    var bytes = [UInt8](repeating: 0, count: secretLength)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    
    guard status == errSecSuccess else { // Always test the status.
        return nil
    }
    
    bytes[secretLength - 1] = color.rawValue
    
    let secret = Data(bytes: bytes, count: secretLength)
    return (secret, SHA256.hash(data: secret))
}

func commitedGraph(from graph: ColoredGraph) -> (CommitedGraph, VertexSecrets)? {
    var commitedGraph = CommitedGraph()
    var vertexSecrets = VertexSecrets()
    
    for (vertexID, (color, edges)) in graph {
        guard let (secret, commitment) = commitmentForColor(color) else {
            return nil
        }
        
        commitedGraph[vertexID] = (commitment, edges)
        vertexSecrets[vertexID] = secret
    }
    
    return (commitedGraph, vertexSecrets)
}

func revealEdge(in graph: CommitedGraph, with secrets: VertexSecrets, for vertexA: Int, and vertexB: Int) -> (Data, Data)? {
    guard (graph[vertexA]?.1.contains(vertexB) ?? false) && (graph[vertexB]?.1.contains(vertexA) ?? false) else {
        return nil
    }
    
    return (secrets[vertexA], secrets[vertexB]) as? (Data, Data)
}

func verifyEdge(in graph: CommitedGraph, with secrets: (Data, Data), for vertexA: Int, and vertexB: Int) -> Bool {
    guard let lastByteA = Colors(rawValue: secrets.0.last ?? UInt8.max),
            let lastByteB = Colors(rawValue: secrets.1.last ?? UInt8.max) else {
        return false
    }
    
    guard SHA256.hash(data: secrets.0) == graph[vertexA]?.0 && SHA256.hash(data: secrets.1) == graph[vertexB]?.0 else {
        return false
    }
    
    return lastByteA != lastByteB
}

for (name, (graph, expectation)) in TestGraphs {
    if(isThreeColored(graph) != expectation) {
        print("isThreeColored(\(name)) result did not match expected \(expectation)")
    } else {
        print("\(name) passed!")
        for permutation in threeColorPermutations(for: graph) {
            print(permutation)
        }
    }
}
