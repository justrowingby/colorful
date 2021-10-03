//
//  main.swift
//  ColorfulCLI
//
//  Created by Rowenna Emma and Kat on 9/24/21.
//

import Foundation
import Crypto

typealias ColoredGraph = [UInt: (Colors, [UInt])]
typealias CommitedGraph = [UInt: (SHA256Digest, [UInt])]
typealias VertexSecrets = [UInt: Data]

enum Colors: UInt8 {
    case red = 82
    case grn = 71
    case blu = 66
}

let TestGraphs : [String: (ColoredGraph, Bool)] = [
    "triangle":
        ([1: (Colors.grn, [2, 3]),
          2: (Colors.blu, [1, 3]),
          3: (Colors.red, [1, 2])],
         true),
    "diamond":
        ([1: (Colors.blu, [2, 3, 4]),
          2: (Colors.red, [1, 3]),
          3: (Colors.grn, [1, 2, 4]),
          4: (Colors.red, [1, 3])],
         true),
    "tetrahedronWithDoubleRed":
        ([1: (Colors.blu, [2, 3, 4]),
          2: (Colors.red, [1, 3, 4]),
          3: (Colors.grn, [1, 2, 4]),
          4: (Colors.red, [1, 2, 3])],
         false),
    "pentastar":
        ([1: (Colors.blu, [6, 7]),
          2: (Colors.red, [7, 8]),
          3: (Colors.grn, [8, 9]),
          4: (Colors.blu, [9, 10]),
          5: (Colors.blu, [6, 10]),
          6: (Colors.red, [1, 5, 7, 10]),
          7: (Colors.grn, [1, 2, 6, 8]),
          8: (Colors.blu, [2, 3, 7, 9]),
          9: (Colors.red, [3, 4, 8, 10]),
          10: (Colors.grn, [4, 5, 6, 9])],
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
    
    // for speed
    let permutations = [
        [Colors.red, Colors.grn, Colors.blu],
        [Colors.red, Colors.blu, Colors.grn],
        [Colors.grn, Colors.red, Colors.blu],
        [Colors.grn, Colors.blu, Colors.red],
        [Colors.blu, Colors.red, Colors.grn],
        [Colors.blu, Colors.grn, Colors.red]
    ]
    
    var graphPermutations = [ColoredGraph]()
    
    for permutation in permutations {
        var newGraph = graph
        for (vertexID, (color, _)) in newGraph {
            switch color {
            case .red:
                newGraph[vertexID]!.0 = permutation[0]
            case .grn:
                newGraph[vertexID]!.0 = permutation[1]
            case .blu:
                newGraph[vertexID]!.0 = permutation[2]
            }
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

func revealEdge(in graph: CommitedGraph, with secrets: VertexSecrets, for vertexA: UInt, and vertexB: UInt) -> (Data, Data)? {
    guard (graph[vertexA]?.1.contains(vertexB) ?? false) && (graph[vertexB]?.1.contains(vertexA) ?? false) else {
        return nil
    }
    
    return (secrets[vertexA], secrets[vertexB]) as? (Data, Data)
}

func verifyEdge(in graph: CommitedGraph, with secrets: (Data, Data), for vertexA: UInt, and vertexB: UInt) -> Bool {
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
