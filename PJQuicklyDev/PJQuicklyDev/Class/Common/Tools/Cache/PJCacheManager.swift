//
//  PJCacheManager.swift
//  PJQuicklyDev
//
//  Created by Zoey Weng on 2017/11/21.
//  Copyright © 2017年 飘金. All rights reserved.
//

import UIKit
import HandyJSON
import CryptoSwift
import CocoaLumberjack

// MARK: 数据缓存类
struct PJCacheManager {
    
    static var shared = PJCacheManager()
    static let bigObject = "/BigObject/"
    static let fileManager = FileManager()
    ///获取程序的Home目录
    static let homeDirectory = NSHomeDirectory()
    
    ///用户文档目录，苹果建议将程序中建立的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
    lazy var documnetPath: String = {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let path = documentPaths.first {
            return path
        } else {
            return ""
        }
    }()
    
    lazy var libraryPath: String = {
        let libraryPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let path = libraryPaths.first {
            return path
        } else {
            return ""
        }
    }()
    
    ///主要存放缓存文件，iTunes不会备份此目录，此目录下文件不会再应用退出时删除
    lazy var cachePath: String = {
        let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let path = cachePaths.first {
            return path
        } else {
            return ""
        }
    }()
    
    ///tmp目录 ./tmp.用于存放临时文件，保存应用程序再次启动过程中不需要的信息，重启后清空
    static let tmpDir = NSTemporaryDirectory()
    
    static let userDefaults = UserDefaults.standard
    
    static func saveCustomObject<T: Encodable>(customObject object: T, key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
            print(String(data: data, encoding: .utf8)!)
            self.userDefaults.set(data, forKey: key)
            self.userDefaults.synchronize()
        }
    }
    
    static func removeCustomObject(key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
    
    static func getCustomObject<T: Decodable>(type: T, forKey key: String) -> T? {
        if let decodedObject = self.userDefaults.object(forKey: key), let data = decodedObject as? Data {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                print("\(String(describing: object))")
                return object
            } else {
                return nil
            }
        }
        return nil
    }
    
    static func createDirectory(path: String) throws {
        do {
            //创建子目录对应的文件夹
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            DDLogError("createDirectory error:\(error)")
        }
    }
    
    static func createFile(atPath: String, data: Data?) {
        self.fileManager.createFile(atPath: atPath, contents: data, attributes: nil)
    }
    
    //保存大对象(只要是遵循HandyJSON协议的都可以)
    static func saveBigObject<T: HandyJSON>(key:String, value: T) {
        let bigObjectPath = self.shared.documnetPath + self.bigObject + key.md5()
        self.saveBigObject(key: key, value: value, forPath: bigObjectPath)
    }
    
    //保存大对象(只要是遵循HandyJSON协议的都可以)
    static func saveBigObject<T: HandyJSON>(key:String, value: T, forPath: String) {
        if let value = value.toJSONString(), let data = value.data(using: String.Encoding.utf8) {
            if self.fileManager.fileExists(atPath: forPath) {
                do {
                    try self.fileManager.removeItem(atPath: forPath)
                } catch let error {
                    DDLogError("saveBigObject ->removeItem error:\(error)")
                }
            }
            self.createFile(atPath: forPath, data: data)
        } else {
            DDLogError("bigObject toJSONString error")
        }
    }
    
    //获取大对象，classType为要转成的类型，可以是class也可以是struct,用法PJCacheManager.getBigObject(key: "piaojin", Model.self())
    static func getBigObject<T: HandyJSON>(key:String, returnClassType : T) -> T? {
        do {
            let bigObjectPath = self.shared.documnetPath + self.bigObject + key.md5()
            let bigObjectString = try String(contentsOfFile: bigObjectPath, encoding: String.Encoding.utf8)
            let object = JSONDeserializer<T>.deserializeFrom(json: bigObjectString)
            return object
        } catch let error {
            DDLogError("getBigObject forPath -> error:\(error)")
            return nil
        }
    }
    
    ///保存中小对象(只要是遵循HandyJSON协议的都可以)
    static func saveObject<T: HandyJSON>(key:String, value: T) {
        if let value = value.toJSONString() {
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    //获取中小对象，classType为要转成的类型，可以是class也可以是struct,用法PJCacheManager.getObject(key: "piaojin", Model.self())
    static func getObject<T: HandyJSON>(key:String, returnClassType : T) -> T? {
        if let bigObjectString = self.getDefault(key: key) as? String {
            let object = JSONDeserializer<T>.deserializeFrom(json: bigObjectString)
            return object
        }
        return nil
    }
    
    static func setDefault(key:String, value: Any?) {
        if value == nil {
            UserDefaults.standard.removeObject(forKey: key)
        }else{
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func removeUserDefault(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func getDefault(key: String) -> Any? {
        if let object = UserDefaults.standard.value(forKey: key) {
            return object
        }
        return nil
    }
}
