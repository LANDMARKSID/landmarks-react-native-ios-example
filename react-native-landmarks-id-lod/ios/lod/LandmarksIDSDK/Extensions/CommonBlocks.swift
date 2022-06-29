//
//  CommonBlocks.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.02.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

typealias VoidBlock = () -> ()
typealias Block<T> = (T) -> ()
typealias Block2<T1, T2> = (T1, T2) -> ()
typealias BlockRet<T> = () -> T
