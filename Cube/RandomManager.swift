//
//  RandomManager.swift
//  Cube
//
//  Created by 陈沈杰 on 2022/12/28.
//

import Foundation

enum CubeType{
    case Second
    case Third
    case Fourth
    case Fifth
    ///五魔方
    case Five
    case Pyramid
    case Slope
    case ThirdBlind
    case ThirdSingle
}


class RandomManager{
    static let shared:RandomManager = RandomManager()
    
    private init(){
        
    }
    
    private let SecondStep = ["U","F","R"]
    private let ThirdStep = ["R","L","U","D","F","B"]
    private let FourthStep = ["R","L","U","D","F","B","Rw","Uw","Fw"]
    private let FifthStep = ["R","L","U","D","F","B","Rw","Lw","Uw","Dw","Fw","Bw"]
    private let SlopeStep = ["B","U","L","R"]
    private let PyramidStep = ["B","U","L","R"]
    private let FiveStep = ["R","D","U"]
}

extension RandomManager{
    func type(name:String) -> CubeType{
        switch name{
        case "二阶速拧":
            return .Second
        case "三阶速拧":
            return .Third
        case "四阶速拧":
            return .Fourth
        case "五阶速拧":
            return .Fifth
        case "五魔方":
            return .Five
        case "金字塔":
            return .Pyramid
        case "斜转":
            return .Slope
        case "三阶盲拧":
            return .ThirdBlind
        case "三阶单手":
            return .ThirdSingle
        default:
            return .Third
        }
    }
    
    func typeName(type:CubeType) -> String{
        switch type{
        case .Second:
            return "二阶速拧"
        case .Third:
            return "三阶速拧"
        case .Fourth:
            return "四阶速拧"
        case .Fifth:
            return "五阶速拧"
        case .Five:
            return "五魔方"
        case .Pyramid:
            return "金字塔"
        case .Slope:
            return "斜转"
        case .ThirdBlind:
            return "三阶盲拧"
        case .ThirdSingle:
            return "三阶单手"
        }
    }
    
    func randomSteps(type:CubeType) -> String{
        switch type{
        case .Second:
            return stepsByArr(arr: SecondStep)
        case .Third:
            return thirdSteps(arr: ThirdStep)
        case .Fourth:
            return stepsByArr(arr: FourthStep)
        case .Fifth:
            return stepsByArr(arr: FifthStep)
        case .Five:
            return fiveSteps()
        case .Pyramid:
            return pyramidSteps()
        case .Slope:
            return stepsByArr(arr: SlopeStep,isSlope: true)
        case .ThirdBlind:
            return thirdSteps(arr: ThirdStep)
        case .ThirdSingle:
            return thirdSteps(arr: ThirdStep)
        }
        
    }
        
    func stepsByArr(arr:[String],isSlope:Bool = false) -> String{
        var count = arr.count > 4 ?20:11
        if arr.count >= 9{
            count = arr.count > 9 ?50:40
        }
        var res = ""
        var current = -1
        for _ in 0 ..< count{
            var random = 0
            repeat{
                random = Int(arc4random() % UInt32 (arr.count))
            }while(current == random)
            current = random
            var step = arr[random]

            if isSlope{
                let random = Int.random(in: 0 ..< 2)
                if random == 1{
                    step += "'"
                }
            }else{
                step = op(step: step)
            }
            res += step + " "
        }
        return res
    }
    
    func thirdSteps(arr:[String]) -> String{
        var res = ""
        var curren = 999
        let count = 20
        var isInvaild = false
        for _ in 0 ..< count{
            var random = 0
            repeat{
                random = Int(arc4random() % UInt32 (arr.count))
                isInvaild = random / 2 == curren / 2
            }while(random == curren || isInvaild)
            curren = random
            var step = arr[random]
            step = op(step: step)
            res += step + " "
        }
        return res
    }
    
    func pyramidSteps() -> String{
        var res = ""
        var current = -1
        let remind = arc4random() % 5
        for _ in 0 ..< 13 - remind{
            var random = 0
            repeat{
                random = Int(arc4random() % UInt32 (PyramidStep.count))
            }while(current == random)
            current = random
            var step = PyramidStep[random]
            let op = Int(arc4random() % 2)
            if op == 1{
                step += "'"
            }
            res += step + " "
        }
        
        let temp = shuffle(PyramidStep)
        for i in 0 ..< remind{
            var step = temp[Int(i)].lowercased()
            let op = Int.random(in: 0 ..< 2)
            if op == 1{
                step += "'"
            }
            res += step + " "
        }

        return res
    }
    
    func fiveSteps() -> String{
        var res = ""
        for _ in 0 ..< 7{
            for i in 0 ..< 11{
                let random = arc4random() % 2
                if i == 10{
                    var step = "U"
                    if random == 1{
                        step += "'"
                    }
                    res += step + " "
                    break
                }
                var step = FiveStep[i % 2]
                if random == 1{
                    step += "++"
                }else{
                    step += "--"
                }
                res += step + " "
            }
            res += "\n"
        }
        return res
    }
    
    func op(step:String) -> String{
        var temp = step
        let op = Int(arc4random() % 3)
        switch op{
        case 0:
            break
        case 1:
            temp += "'"
            break
        case 2:
            temp += "2"
            break
        default:
            break
        }
        return temp
    }
    
    //打乱
    func shuffle(_ arr:[String]) -> [String]{
        var temp = arr
        for i in 0 ..< arr.count / 2{
            let t = Int.random(in: 0 ..< arr.count)
            temp.swapAt(i, t)
        }
        return temp
    }
}
