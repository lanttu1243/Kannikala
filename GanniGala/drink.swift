//
//  drink.swift
//  GanniGala
//
//  Created by Lasse Kukkula on 20.11.2023.
//

import Foundation

class Drink {
    private let percentage: Float
    private let volumeInMl: Int
    private let carbonated: Bool
    private let _totalAlcohol: Float
    
    init(percentage: Float, volumeInMl: Int, carbonated: Bool) {
        self.percentage = percentage
        self.volumeInMl = volumeInMl
        self.carbonated = carbonated
        self._totalAlcohol = percentage * Float(volumeInMl)
    }
    
    func totalAlcohol() -> Float {
        return self._totalAlcohol
    }
    
    func momentumMultiplier() -> Float {
        switch self.carbonated {
        case true:
            return 1.75
        case false:
            return 1.0
        }
    }
}

class Drinker {
    private let _age: Int
    private var _weight: Float
    private var _height: Float
    private var _gender: Bool
    private var _limit: Float
    private var _bmi: Float
    init(age: Int, weight: Float, height: Float, limit: Float = 0.8, gender: Bool) {
        self._age = age
        self._weight = weight
        self._height = height
        self._limit = limit
        self._gender = gender
        self._bmi = 1.3 * self._weight / (sqrt(self._height / 100)*pow(self._height / 100, 2))
    }
    
    func weight() -> Float {
        return self._weight
    }
    func gender() -> Float {
        return self._gender ? 1.0 : 0.0
    }
    func bmi() -> Float {
        return self._bmi
    }
    
}

class Drunkenness {
    private let _drinker: Drinker
    private let _drinks: [Drink]
    private let _start: time_t
    init(drinker: Drinker, drinks: [Drink], start: time_t) {
        self._drinker = drinker
        self._drinks = drinks
        self._start = start
    }
    
    func promilles(time: time_t) -> [Float] {
        let density: Float = 0.79 // g/ml
        let V_b =  self._drinker.weight() * (self._drinker.gender() * 0.13 +  0.58)
        let A: [Float] = self._drinks.map{
            (v) -> Float in
            v.totalAlcohol() * density
        }
        let B: [Float] = self._drinks.map{
            (d) -> Float in
            d.momentumMultiplier() * 0.15 * (self._drinker.bmi() / 20.0)
        }
        let T: Float = (Float(time) - Float(self._start)) / 3600.0
        return zip(A, B).map{
            (a, b) -> Float in
            (a / V_b) - b * T
        }
    }
    
    func promillePlot(time: time_t) -> [Int: Float] {
        let tf: Int = (time - self._start)
    }
}
