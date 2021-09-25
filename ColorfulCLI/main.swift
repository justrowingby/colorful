//
//  main.swift
//  ColorfulCLI
//
//  Created by Rowenna Emma and Kat on 9/24/21.
//

import Foundation

typealias ColoredGraph = [Int : (Colors, [Int])]

enum Colors {
    case red
    case grn
    case blu
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
