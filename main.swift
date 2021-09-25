//
//  main.swift
//  ColorfulCLI
//
//  Created by Rowenna Emma and Kat on 9/24/21.
//

import Foundation

typealias ColoredGraph = [Int : (CGColor, [Int])]

enum Colors {
    static let red = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let grn = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    static let blu = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
    static let prp = CGColor(red: 1, green: 0, blue: 1, alpha: 1)
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
    "tetrahedronWithPurpleCorner":
        ([1: (Colors.blu, [2, 3, 4]),
          2: (Colors.red, [1, 3, 4]),
          3: (Colors.grn, [1, 2, 4]),
          4: (Colors.prp, [1, 2, 3])],
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

func isThreeColored (graph : ColoredGraph) -> Bool {
    var colorsSeen = Set<CGColor>()
    
    for (_, (color, edges)) in graph {
        colorsSeen.insert(color)
        
        for pairVertexID in edges {
            let (pairColor, _) = graph[pairVertexID]!
            
            if color == pairColor {
                return false
            }
        }
    }
    
    if colorsSeen.count > 3 {
        return false
    }
    
    return true
}

for (name, (graph, expectation)) in TestGraphs {
    if(isThreeColored(graph: graph) != expectation) {
        print("isThreeColored(\(name)) result did not match expected \(expectation)")
    } else {
        print("\(name) passed!")
    }
}
