//
//  main.swift
//  ColorfulCLI
//
//  Created by Rowenna Emma and Kat on 9/24/21.
//

import Foundation

func isThreeColored (graph : [Int : (CGColor, [Int])]) -> Bool {
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
