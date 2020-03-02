//
//  ViewModel.swift
//  iTranslateSample01
//
//  Created by Andreas Gruber on 04.07.19.
//  Copyright © 2019 iTranslate. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
    func signalUpdate()
}

protocol ViewModelController: ViewModelDelegate {
    associatedtype ControllerViewModel
    var viewModel: ControllerViewModel { get }
}
