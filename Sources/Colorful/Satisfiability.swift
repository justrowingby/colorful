//
//  Satisfiability.swift
//  
//
//  Created by Rowenna Emma and Kat on 10/3/21.
//

import Foundation
import CCryptoBoringSSL

typealias PartiallyColoredSATGraph = [UInt: (TruthColoring?, [UInt])]

enum TruthColoring: UInt {
    case falseC = 0
    case truthC = 1
    case neutralC = 2
}

func makeSATGraph() -> PartiallyColoredSATGraph {
    return [TruthColoring.falseC.rawValue: (TruthColoring.falseC, [TruthColoring.truthC.rawValue, TruthColoring.neutralC.rawValue]),
            TruthColoring.truthC.rawValue: (TruthColoring.truthC, [TruthColoring.falseC.rawValue, TruthColoring.neutralC.rawValue]),
            TruthColoring.neutralC.rawValue: (TruthColoring.neutralC, [TruthColoring.falseC.rawValue, TruthColoring.truthC.rawValue])]
}

func attachNot(to base: PartiallyColoredSATGraph, at point: UInt) -> PartiallyColoredSATGraph? {
    let pColor, qColor: TruthColoring?
    
    if let (colorP, _) = base[point] as? (TruthColoring, [UInt]) {
        let notResult : TruthColoring
        switch colorP {
        case .truthC:
            notResult = .falseC
        case .falseC:
            notResult = .truthC
        case .neutralC:
            return nil
        }
        
        (pColor, qColor) = (colorP, notResult)
    } else {
        (pColor, qColor) = (nil, nil)
    }
    
    let notGraph: PartiallyColoredSATGraph = [0: (pColor, [1, 2]), 1: (qColor, [0, 2]), 2: (TruthColoring.neutralC, [0, 1])]
    return attachGraph(notGraph, to: base, matchingVertices: [0: point, 2: TruthColoring.neutralC.rawValue])
}

func attachGraph(_ addition: PartiallyColoredSATGraph, to base: PartiallyColoredSATGraph, matchingVertices: [UInt: UInt] ) -> PartiallyColoredSATGraph? {
    var newBase = base
    let bMax = newBase.keys.max() ?? 0
    
    for (vertexID, (possibleColorA, edges)) in addition {
        let newEdges = edges.map { matchingVertices[$0] ?? $0 + bMax }
        
        if let matchingVertex = matchingVertices[vertexID], let (possibleColorB, edgesB) = newBase[matchingVertex] {
            let newPossibleColor : TruthColoring?
            
            if let colorA = possibleColorA {
                if let colorB = possibleColorB {
                    guard colorA == colorB else {
                        return nil
                    }
                }
                
                newPossibleColor = possibleColorA
            } else {
                newPossibleColor = possibleColorB
            }
            
            newBase[matchingVertex] = (newPossibleColor, edgesB + newEdges)
        } else {
            newBase[vertexID + bMax] = (possibleColorA, newEdges)
        }
    }
    
    return newBase
}

func coloredGraph(from partial: PartiallyColoredSATGraph) -> ColoredGraph? {
    var newGraph = ColoredGraph()
    
    for (vertexID, (possibleColor, edges)) in partial {
        guard let color = possibleColor else {
            return nil
        }
        
        let alteredColor : Colors
        switch color {
        case .falseC:
            alteredColor = .red
        case .truthC:
            alteredColor = .grn
        case .neutralC:
            alteredColor = .blu
        }
        
        newGraph[vertexID] = (alteredColor, edges)
    }
    
    return newGraph
}
