//
//  CubePickerView.swift
//  Cube
//
//  Created by 陈沈杰 on 2022/12/30.
//

import UIKit

class CubePickerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 15.0
        layer.masksToBounds = true
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var cubeSource:[String] = [
                      "三阶速拧"
                      ,"四阶速拧"
                      ,"五阶速拧"
                      ,"二阶速拧"
                      ,"五魔方"
                      ,"金字塔"
                      ,"斜转"
                      ,"三阶单手"
                      ,"三阶盲拧"]{
                          didSet{
                              pickerView.reloadAllComponents()
                          }
                      }
    
    public var confirmTitle:String = ""{
        didSet{
            confirmBt.title = confirmTitle
        }
    }
    
    private lazy var confirmBt:UIBarButtonItem = {
        return UIBarButtonItem(title: confirmTitle, style: .done, target: self, action: #selector(cubePickerDone))
    }()
    
    private lazy var pickerView:UIPickerView = {
        let picker = UIPickerView(frame:.zero)
        picker.frame.origin.y = 44
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var toolbar:UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
       
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([flex,confirmBt], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    private var selectedRow:Int = 0
    
    private lazy var randomManager:RandomManager = RandomManager.shared
    open weak var stepDelegate:CubePickerDelegate?

}

extension CubePickerView{
    func initView(){
        self.addSubview(pickerView)
        self.addSubview(toolbar)
        initLayout()
    }
    
    func initLayout(){
        
    }
    
    @objc
    func cubePickerDone(){
//        let type = randomManager.type(name: cubeSource[selectedRow])
        stepDelegate?.cubePickerSteps(cubePicker: self, index:selectedRow,isFive: selectedRow == 4)
    }
    
    @objc
    func cubePickerCancel(){
        stepDelegate?.cubePickerCancel(cubePicker: self)
    }
}

extension CubePickerView:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cubeSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cubeSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}

protocol CubePickerDelegate:NSObjectProtocol{
    func cubePickerSteps(cubePicker:CubePickerView,index:Int,isFive:Bool)
    
    func cubePickerCancel(cubePicker:CubePickerView)
}
