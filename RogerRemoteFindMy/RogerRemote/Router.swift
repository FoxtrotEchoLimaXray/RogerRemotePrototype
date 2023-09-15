//
//  Router.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI

final class Router: ObservableObject{
    public enum Destination : Codable, Hashable{
        case scanner
        case connection
        case services
        case characteristics
        case findmyroger
    }
    
    @Published var navPath = NavigationPath()
        
        func navigate(to destination: Destination) {
            navPath.append(destination)
        }
        
        func navigateBack() {
            navPath.removeLast()
        }
        
        func navigateToRoot() {
            navPath.removeLast(navPath.count)
        }
}

