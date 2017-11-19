//
//  PJBaseModel.swift
//  PJQuicklyDev
//
//  Created by piaojin on 2017/11/17.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import ObjectMapper
import HandyJSON
/*
 *
 *假设服务器返的数据格式是{code:200, data: {字典}, message: "message"}
 *
*/
class PJBaseModel: NSObject, HandyJSON, PJDecodable {
    
//    var code: Int?
//    var message: String?
//    var data: Any?
    
    override required init() {
        super.init()
    }
}

extension PJBaseModel {
    
    func parse(jsonString: String) -> Self? {
        let type = type(of: self)
        if let baseModel = type.deserialize(from: jsonString) {
            return baseModel
        }
        return nil
    }
    
    static func parseStruct(jsonString: String) -> Self? {
        let type = self
        if let baseModel = type.deserialize(from: jsonString) {
            return baseModel
        }
        return nil
    }
}
